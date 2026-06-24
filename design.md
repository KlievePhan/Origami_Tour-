# design.md — Auth, Per-User Bookmark, Diagram Gestures, Physical-Device Run

Design doc for 4 connected features. Written against the current codebase state (Models/FoldSteps
catalog API already working end-to-end; `Favorites` + `Progresses` tables and `ApplicationUser`
already exist in the schema but have no controllers/services/repos yet; `LoginScreen`/`RegisterScreen`
UI exists but only show "not wired up yet" snackbars).

Not implementing yet — this is the plan to review before coding starts.

---

## 0. What already exists (don't rebuild)

| Layer | Exists | Notes |
|---|---|---|
| DB | `AspNetUsers` (+ Identity tables), `Favorites`, `Progresses` | [schema.sql](Backend/schema.sql), `ApplicationUser : IdentityUser` |
| Backend | `Models`/`FoldSteps` 3-layer (`ModelsController` → `OrigamiModelService` → `OrigamiModelRepository`) | pattern to copy for the new features |
| Backend | CORS (`AllowFlutterDev`), static files | [Program.cs](Backend/Program.cs) |
| Flutter | `api_config.dart`, `RemoteSource`/`ModelRepository`, `OrigamiModel.fromJson` | data layer pattern to copy |
| Flutter | `LoginScreen`, `RegisterScreen`, `RecoverPasswordScreen`, `BookmarkScreen` | UI-complete, **not wired to any backend** |
| Flutter | `provider` package | **not yet added** to `pubspec.yaml` — needed for `AuthProvider`/`BookmarkProvider` per `CLAUDE.md` §7 |
| Backend | JWT package | **not yet added** to `Backend.csproj` |

---

## 1. Backend — Auth (3-layer: Controller → Service → Repository)

### 1.1 New package
```xml
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.2" />
```

### 1.2 DTOs (`Backend/DTOs/Auth/`)
```csharp
public class RegisterRequestDto { string DisplayName, Email, Password; }
public class LoginRequestDto    { string Email, Password; }
public class AuthResponseDto    { string Token, UserId, DisplayName, Email; DateTime ExpiresAt; }
public class UserProfileDto     { string Id, DisplayName, Email; string? AvatarUrl; int Exp, Level; ... }  // mirrors ApplicationUser, for /api/auth/me
```

### 1.3 Repository (`Backend/Repositories/IAuthRepository.cs` + `AuthRepository.cs`)
Thin wrapper around `UserManager<ApplicationUser>` so the Service layer stays consistent with the
rest of the codebase (Service never touches `UserManager`/EF directly) and stays unit-testable:

```csharp
public interface IAuthRepository
{
    Task<ApplicationUser?> FindByEmailAsync(string email);
    Task<(bool Success, IEnumerable<string> Errors)> CreateAsync(ApplicationUser user, string password);
    Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
}
```
Implementation delegates to `UserManager<ApplicationUser>` (already registered via `AddIdentityCore`
in [Program.cs:27-32](Backend/Program.cs#L27-L32)). Password hashing is handled by Identity's
`PasswordHasher` inside `UserManager.CreateAsync` — no custom hashing code needed.

### 1.4 Service (`Backend/Services/IAuthService.cs` + `AuthService.cs`)
```csharp
public interface IAuthService
{
    Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> RegisterAsync(RegisterRequestDto dto);
    Task<(bool Success, AuthResponseDto? Result)> LoginAsync(LoginRequestDto dto);
    Task<UserProfileDto?> GetProfileAsync(string userId);
}
```
- `RegisterAsync`: validate (`DisplayName`/`Email`/`Password` rules already defined client-side in
  `RegisterScreen._validatePassword` — **mirror server-side**: ≥8 chars, ≥1 uppercase, ≥1 number),
  call `IAuthRepository.CreateAsync`, on success issue a JWT.
- `LoginAsync`: `FindByEmailAsync` → `CheckPasswordAsync` → issue JWT on success, generic
  "Incorrect email or password" on failure (don't leak which field was wrong — matches the Login
  screen's existing inline-error copy).
- JWT issuing: `System.IdentityModel.Tokens.Jwt` (`JwtSecurityTokenHandler`), claims =
  `ClaimTypes.NameIdentifier` (user id), `ClaimTypes.Email`, `ClaimTypes.Name` (DisplayName).
  Signing key + issuer/audience/expiry read from `appsettings.json` → new `"Jwt"` section.

### 1.5 Controller (`Backend/Controllers/AuthController.cs`)
```
POST /api/auth/register   → 200 AuthResponseDto | 400 { errors }
POST /api/auth/login      → 200 AuthResponseDto | 401
GET  /api/auth/me         → 200 UserProfileDto   [Authorize]
```

### 1.6 Program.cs additions
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o => { /* issuer, audience, signing key from config */ });
builder.Services.AddScoped<IAuthRepository, AuthRepository>();
builder.Services.AddScoped<IAuthService, AuthService>();
...
app.UseAuthentication();   // before UseAuthorization(), after UseCors()
app.UseAuthorization();
```
Pipeline order becomes: `UseHttpsRedirection → UseCors → UseStaticFiles → UseAuthentication →
UseAuthorization → MapControllers` (CORS still first, per the bug fixed earlier this session).

### 1.7 Google sign-in
Out of scope for this pass — `LoginScreen`'s "Sign in with Google" button stays a stub
(`_notifyPending`). Real Google OAuth (verifying an ID token server-side) is a separate, larger
task; flag as `CLAUDE.md` §13 already does ("confirm whether Google sign-in is implemented
backend-side").

---

## 2. Backend — Bookmark (Favorites + In-Progress) per user

Schema already has both tables; only the API layer is missing.

### 2.1 DTOs (`Backend/DTOs/Bookmarks/`)
```csharp
public class FavoriteDto    { OrigamiModelDto Model; DateTime AddedAt; }
public class ProgressDto    { OrigamiModelDto Model; int CurrentStep; int TotalSteps; bool Completed;
                               DateTime LastSessionDate; }
public class UpsertProgressRequestDto { int CurrentStep; long? AccumulatedTimeSeconds; bool Completed; }
```

### 2.2 Repository (`IBookmarkRepository`/`BookmarkRepository`)
```csharp
Task<List<Favorite>> GetFavoritesAsync(string userId);
Task<bool> AddFavoriteAsync(string userId, int modelId);
Task<bool> RemoveFavoriteAsync(string userId, int modelId);
Task<List<UserModelProgress>> GetInProgressAsync(string userId);   // Completed == false
Task<UserModelProgress> UpsertProgressAsync(string userId, int modelId, int currentStep, long? accumulatedSeconds, bool completed);
Task<bool> RemoveProgressAsync(string userId, int modelId);
```
Uses `_db.Favorites`/`_db.Progresses` with `.Include(Model).ThenInclude(Steps)` like
`OrigamiModelRepository` already does. Unique indexes `(UserId, ModelId)` already exist on both
tables — `AddFavoriteAsync`/`UpsertProgressAsync` upsert (check-then-insert-or-update) against them.

### 2.3 Service (`IBookmarkService`/`BookmarkService`)
Maps repository entities → DTOs (reusing `OrigamiModelService`'s private `ToDto` mapper — extract
it to a small shared `OrigamiModelMapper` static class so both services use the same model→DTO
logic instead of duplicating it).

### 2.4 Controller (`Backend/Controllers/BookmarksController.cs`), all `[Authorize]`
```
GET    /api/bookmarks/favorites
POST   /api/bookmarks/favorites/{modelId}
DELETE /api/bookmarks/favorites/{modelId}
GET    /api/bookmarks/in-progress
PUT    /api/bookmarks/progress/{modelId}     (body: UpsertProgressRequestDto)
DELETE /api/bookmarks/progress/{modelId}
```
`UserId` comes from `User.FindFirstValue(ClaimTypes.NameIdentifier)` (populated by the JWT
middleware from §1.6) — never from a request body/query param, so a user can only ever
read/write their own bookmarks.

---

## 3. Flutter — Auth wiring

### 3.1 New dependency
```yaml
provider: ^6.1.2              # CLAUDE.md §2/§7 — first ChangeNotifier provider in the app
flutter_secure_storage: ^9.2.2  # JWT storage (Keychain/Keystore-backed, not shared_preferences)
```

### 3.2 New files
- `lib/data/sources/auth_remote_source.dart` — `AuthRemoteSource.login()`/`.register()`, same
  shape as `RemoteSource` (POST JSON, `jsonDecode`).
- `lib/data/repositories/auth_repository.dart` — calls the source, persists the JWT to
  `flutter_secure_storage`, exposes `login()`/`register()`/`logout()`/`currentToken()`.
- `lib/models/user_profile.dart` — matches `UserProfileDto`, per `CLAUDE.md` §6 `UserProfile`.
- `lib/providers/auth_provider.dart` — `ChangeNotifier`: `currentUser`, `status`
  (`unauthenticated`/`authenticating`/`authenticated`), `login()`, `register()`, `logout()`.
  Restores session on app start by reading the stored token (and calling `GET /api/auth/me`).

### 3.3 Authenticated requests
`RemoteSource`/`ModelRepository` and the new `BookmarkRemoteSource` need an `Authorization: Bearer
<token>` header. Add a small shared `lib/core/api_client.dart` wrapping `http.Client` that injects
the header (read from `AuthRepository`/secure storage) on every request — avoids threading the
token through every `RemoteSource` method by hand.

### 3.4 Wire up existing screens
- `LoginScreen._submitLogin()` ([login_screen.dart:48-58](Frontend/lib/screens/auth/login_screen.dart#L48-L58)):
  replace the `Future.delayed` stub with `context.read<AuthProvider>().login(email, password)`;
  on success `Navigator` → `ShellScreen`; on failure surface the error **inline beneath the
  password field** (per the spec's "Incorrect email or password" state), not a snackbar.
- `RegisterScreen._submitRegister()` ([register_screen.dart:87-100](Frontend/lib/screens/auth/register_screen.dart#L87-L100)):
  same pattern via `AuthProvider.register()`; "email already registered" → inline error under the
  email field (server returns 400 with that message from Identity's `DuplicateUserName` error).
- `main.dart`: wrap the app in `MultiProvider`; add a redirect/guard so the splash screen routes to
  `LoginScreen` or `ShellScreen` based on `AuthProvider.status` (this is the "auth gating" `CLAUDE.md`
  §8 already specifies but defers — still no `go_router`, so do it with a simple
  `StreamBuilder`/`Consumer` check in `main.dart` for now rather than introducing routing as part of
  this task).

---

## 4. Flutter — Bookmark wiring

### 4.1 New files
- `lib/data/sources/bookmark_remote_source.dart`, `lib/data/repositories/bookmark_repository.dart`
  — mirror `ModelRepository`, call the 6 endpoints from §2.4.
- `lib/providers/bookmark_provider.dart` — `favorites: List<OrigamiModel>`,
  `inProgress: List<(OrigamiModel, int currentStep, int totalSteps, DateTime lastSession)>`,
  `toggleFavorite(modelId)`, `removeProgress(modelId)` (optimistic update + undo, per `CLAUDE.md` §7).

### 4.2 Wire up existing screens
- `BookmarkScreen` ([bookmark_screen.dart:28-89](Frontend/lib/screens/bookmark/bookmark_screen.dart#L28-L89)):
  replace the hardcoded `_favorites`/`_inProgress` static lists with
  `context.watch<BookmarkProvider>().favorites/.inProgress`; swipe-to-remove calls
  `toggleFavorite`/`removeProgress` and shows the `Undo` snackbar already implied by the spec.
- `ModelDetailsScreen`'s bookmark icon button ([model_details_screen.dart:134-148](Frontend/lib/screens/model_details/model_details_screen.dart#L134-L148)):
  currently shows "Bookmarking is not wired up yet" — call
  `context.read<BookmarkProvider>().toggleFavorite(model.id)` instead, and reflect current state
  (filled vs outline icon) from `bookmarkProvider.favorites`.
- `ProcessViewScreen`: persist progress as the user moves between steps. Call
  `BookmarkProvider`'s progress-upsert on `_goToNextStep`/`_goToPreviousStep` (debounced — not on
  every single step, e.g. only when leaving the screen or every N steps) and explicitly on
  "Cancel" (per `CLAUDE.md` §9-B: cancel → confirm → `cancel(save:true)` → navigate to
  `/home/bookmark`'s In Progress tab). On `_finishTutorial()`, call `removeProgress` (or mark
  `Completed = true` server-side) so the model drops out of "In Progress".

---

## 5. Flutter — Diagram gesture interactions (Process View)

Target: `_DiagramCard` in [process_view_screen.dart:332-403](Frontend/lib/screens/process_view/process_view_screen.dart#L332-L403)
(the diagram viewer just simplified to a plain `Image.network` in this session).

**Interpretation of the requested gestures** (stated here so it can be corrected before coding):
- *Double tap*: toggle between 1.0x and ~2.5x zoom, centered on the tap point.
- *Pinch zoom in/out*: standard two-finger scale gesture.
- *"Lắc trái, lắc phải để move ảnh"*: read as **drag/swipe left-right to pan** the image while
  zoomed in (not device accelerometer shake) — this is the natural complement to pinch-zoom, and
  is what lets you see the edges of a zoomed-in diagram.

All three map directly onto Flutter's built-in **`InteractiveViewer`** widget — no extra package
needed:

```dart
class _ZoomableDiagram extends StatefulWidget {
  const _ZoomableDiagram({required this.imageUrl});
  final String imageUrl;
  @override
  State<_ZoomableDiagram> createState() => _ZoomableDiagramState();
}

class _ZoomableDiagramState extends State<_ZoomableDiagram> {
  final _controller = TransformationController();

  void _onDoubleTapDown(TapDownDetails details) => _pendingTapPosition = details.localPosition;
  late Offset _pendingTapPosition;

  void _onDoubleTap() {
    const zoomed = 2.5;
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();          // zoomed in → reset
    } else {
      _controller.value = Matrix4.identity()
        ..translate(-_pendingTapPosition.dx * (zoomed - 1), -_pendingTapPosition.dy * (zoomed - 1))
        ..scale(zoomed);                                 // zoomed out → zoom in at tap point
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 4,
        panEnabled: true,    // drag left/right/up/down once zoomed in
        scaleEnabled: true,  // pinch zoom in/out
        child: Image.network(widget.imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
```

Drop this in place of the plain `Image.network` inside `_DiagramCard`'s `Positioned.fill` (the
padding/`errorBuilder` wrapper stays). `panEnabled: true` with `minScale: 1` means it won't pan
while at the default 1x zoom (nothing to pan to), so it doesn't fight with the page's vertical
`ListView` scroll — only kicks in once the user has zoomed in, exactly matching "double tap /
pinch to zoom, then drag to move the now-larger image".

If "lắc trái/phải" actually meant **physical device shake** (accelerometer, e.g. `sensors_plus`)
rather than a touch drag, flag that now — it's a materially different (and unusual for an image
viewer) implementation and changes the dependency list.

---

## 6. Running on a physical Android phone over USB-C (not the AVD emulator)

The current `apiBaseUrl` ([api_config.dart:10-15](Frontend/lib/core/api_config.dart#L10-L15))
hard-codes `10.0.2.2` for **any** Android target — that alias only resolves on the AVD emulator's
virtual NAT, not on a real phone plugged in via USB-C. A physical device's `localhost` is the
phone itself.

**Recommended fix — `adb reverse` (no IP/Wi-Fi/firewall config needed):**
```bash
adb devices                          # confirm the phone shows up (USB debugging must be enabled)
adb reverse tcp:5116 tcp:5116         # phone's localhost:5116 → host's localhost:5116
flutter run -d <device-id>
```
With the reverse tunnel active, the phone's own `http://localhost:5116` transparently reaches the
backend running on the PC. This means `api_config.dart` can be **simplified** to always return
`http://localhost:5116` (drop the `10.0.2.2` Android special-case entirely) — one code path for
emulator *and* physical device, as long as the workflow above (or the emulator's `10.0.2.2`,
handled separately if still needed) is documented. Trade-off: `adb reverse` must be re-run after
every USB reconnect/`adb kill-server`; worth a short `scripts/run-device.ps1` wrapper that runs
`adb reverse` then `flutter run`.

**Alternative — LAN IP** (if `adb reverse` isn't viable, e.g. wireless debugging):
- Find the PC's LAN IP (`ipconfig` → IPv4 Address) and point `apiBaseUrl` at
  `http://<lan-ip>:5116`.
- Allow inbound TCP 5116 through Windows Firewall (`New-NetFirewallRule`).
- Phone and PC must be on the same Wi-Fi/subnet.
- Backend must bind beyond `localhost` — change `launchSettings.json`'s `applicationUrl` (or pass
  `--urls http://0.0.0.0:5116`) since `http://localhost:5116` only listens on the loopback
  interface.

**Cleartext HTTP on Android:** the backend serves plain `http://`, and Android 9+ (API 28+)
blocks cleartext traffic by default. Need one of:
- `android/app/src/main/AndroidManifest.xml`: `<application android:usesCleartextTraffic="true" ...>`
  (fine for a dev build talking to a local backend), or
- a `network_security_config.xml` scoped to `localhost`/the LAN IP only (tighter, still simple).
Without this, every `Image.network`/`http.get` call to the backend will fail silently on a real
device even though it works fine on the emulator or Chrome.

**Sanity checklist before testing on the phone:**
1. `adb reverse tcp:5116 tcp:5116` run (or LAN IP + firewall rule in place).
2. `usesCleartextTraffic` (or network security config) added.
3. Backend running and CORS doesn't matter here (CORS is a *browser* mechanism — native Android
   `http` calls aren't subject to it, only the Flutter **Web** target needs the `AllowFlutterDev`
   policy from earlier this session).
4. JWT, once §1/§3 land, must be sent as `Authorization: Bearer <token>` — same on every platform.

---

## 7. Suggested implementation order

1. Backend Auth (§1) — needed before bookmark endpoints can require `[Authorize]`.
2. Flutter Auth wiring (§3) — `provider` + `flutter_secure_storage` added, `AuthProvider`, screens
   wired, app gated by login.
3. Backend Bookmark (§2).
4. Flutter Bookmark wiring (§4).
5. Diagram gestures (§5) — independent of the above, can land anytime.
6. Physical-device config (§6) — independent, can land anytime; worth doing early just to keep
   testing on a real phone throughout the rest of the work.

Open questions to confirm before coding (flagged inline above too):
- JWT lifetime/refresh strategy (no refresh tokens proposed here — plain expiring JWT; confirm
  that's acceptable for now).
- Secure token storage: `flutter_secure_storage` vs. reusing `shared_preferences` (simpler, less
  secure) — `CLAUDE.md` §2 only lists `shared_preferences`/`sqflite`/`hive`, not
  `flutter_secure_storage`.
- "Lắc trái/phải" = drag-to-pan (assumed above) vs. literal device shake (accelerometer).
