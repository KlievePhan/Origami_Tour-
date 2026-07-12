# Giải Phẫu Kiến Trúc Kỹ Thuật - Origami Tour
Tài liệu này đi sâu vào mã nguồn thực tế (Flutter & C#) của dự án Origami Tour để giải phẫu 4 luồng nghiệp vụ (Flow) phức tạp nhất. 

---

## I. Luồng 1: Đăng nhập Google (Google Login Flow)

**1. Data Flow (Luồng dữ liệu):**
- Khi bấm nút `Continue with Google` (file `lib/widgets/google_auth_button.dart` dòng 81), hàm `_handleGoogleSignIn()` được gọi.
- App sử dụng thư viện `GoogleSignIn` để bật hộp thoại xác thực. Sau khi lấy được `idToken`, data tiếp tục truyền sang `context.read<AuthProvider>().googleLogin(auth.idToken!)`.
- `AuthProvider` gọi tới `AuthRepository`, nơi bắn API `POST /api/auth/google`.
- Khi Backend trả về JSON chứa chuỗi JWT, `AuthProvider` lưu JWT này vào `SharedPreferences` (bộ nhớ tạm), đồng thời gán vào biến state nội bộ và báo `notifyListeners()`. UI nhận biết user đã có token và cấp quyền đi tiếp.

**2. State Management (Quản lý State):**
- Đang dùng **Provider** (`AuthProvider`). State lưu trữ biến `token` và `currentUser`. 
- Nếu cần chia sẻ token này cho API requests, file `lib/core/api_config.dart` sẽ được truyền JWT vào header của mọi request Http: `Authorization: Bearer <token>`.

**3. Impact Analysis (Tác động chéo):**
- Giả sử cần lấy thêm `AvatarUrl` của người dùng từ Google: 
  - (Sửa Backend) Map field `Picture` từ Google payload vào bảng `Users` và DTO.
  - (Sửa Dart) Mở `lib/models/user_profile.dart`, thêm `final String? avatarUrl;`.
  - (Sửa UI) Mở `lib/widgets/account_menu_button.dart` thay Icon tròn mặc định bằng `Image.network(user.avatarUrl)`.

**4. Performance (Tối ưu Rebuild):**
- Nút Google Sign In tự quản lý trạng thái Load (`_isLoading`) bằng `setState` cục bộ trong file `google_auth_button.dart`. Vì nó là `StatefulWidget` nhỏ nhất, vòng xoay loading chỉ làm rebuild đúng duy nhất cái nút đó thay vì toàn bộ màn hình `LoginScreen`.

**5. Null Safety & Parse JSON:**
- Backend có thể trả về lỗi (ví dụ thiếu cấu hình SHA-1). Dart dùng khối try-catch an toàn: bắt lỗi `GoogleSignInExceptionCode.unknownError` và chặn crash ứng dụng bằng cách hiển thị `SnackBar` báo lỗi thay vì ném ra Exception mù mờ (dòng 57 file `google_auth_button.dart`).

**6. Điều hướng (Navigation):**
- Sau khi Login thành công, code chạy: `Navigator.pushAndRemoveUntil(..., (route) => false)`. Toàn bộ ngăn xếp (stack) màn hình bị hủy. Nút Back hệ thống sẽ đóng ứng dụng.

**7. Dữ liệu nạp lại:**
- `SharedPreferences` (lưu JWT cục bộ) được gọi ở `AuthService`. Mỗi lần khởi động lại app, `AuthProvider.tryAutoLogin()` chạy ẩn để bốc JWT từ ổ cứng lên lại RAM mà không bắt đăng nhập lại.

---

## II. Luồng 2: Load Collection & Step Fold (Xem danh sách & Gập giấy)

**1. Data Flow (Luồng dữ liệu):**
- Khi mở `CollectionScreen` (file `collection_screen.dart`), hàm `initState` gọi `context.read<ModelRepository>().getModels()`.
- Repository bắn GET request tới `Backend/Controllers/ModelsController.cs`. 
- Sau khi tải xong, `FutureBuilder` nhận dữ liệu List<OrigamiModel> và hiển thị ra các thẻ (Card). Khi bấm vào Card, app điều hướng sang `ModelDetailsScreen`, hiển thị tổng quan và có nút "Start Folding" để vào `ProcessViewScreen`.

**2. Null Safety & Parse JSON:**
- Mở file `lib/models/origami_model.dart`. Hàm `OrigamiModel.fromJson(Map<String, dynamic> json)` map các steps (các bước gập):
  `steps: (json['steps'] as List?)?.map((s) => FoldStep.fromJson(s)).toList() ?? []`
  - Nếu Backend quên cấu hình Include `Steps` (khiến JSON không có mảng `steps`), Dart xử lý mượt mà và trả về danh sách rỗng `[]` nhờ cú pháp fallback `?? []`. 

**3. Data Passing (Truyền tham số):**
- Dữ liệu `model` (OrigamiModel) truyền trực tiếp từ màn Danh sách -> Màn Chi tiết thông qua parameter của constructor: `ModelDetailsScreen(model: model)`. Không cần gọi lại API GET /id ở màn hình thứ hai để tiết kiệm băng thông.

**4. Performance (Tối ưu Rebuild):**
- Ở `ProcessViewScreen` (Màn hình hướng dẫn gập 3D), mỗi khi người dùng bấm `Next` (qua bước tiếp theo), UI chỉ thay đổi biến `_currentStep` bằng hàm `setState`. Các widget chứa hình ảnh 3D/Video được load từ network sẽ có cơ chế Cache tự động của Flutter, nên không bị giật hoặc tải lại hình ảnh từ đầu.

---

## III. Luồng 3: Time Constraint & Clock (Đồng hồ & Ràng buộc thời gian)

**1. Data Flow (Luồng dữ liệu):**
- **Khởi tạo:** Ở `lib/screens/process_view/process_view_screen.dart` (dòng 48), ngay khi mở màn hình, `_stopwatch.start()` được kích hoạt và một `Timer.periodic(1 giây)` chạy ngầm.
- **Vẽ lại UI:** Mỗi giây, hàm `Timer` gọi `setState(() {})` để cập nhật con số đếm giờ hiển thị trên góc màn hình.
- **Hoàn thành:** Khi bấm Next ở bước cuối cùng, hàm `_finishTutorial()` được gọi, `_stopwatch.stop()` chạy để chốt sổ thời gian.

**2. Impact Analysis (Tác động chéo):**
- Ràng buộc nghiệp vụ: Không cho phép hoàn thành nếu chưa gập được 60 giây.
- **Code (Dòng 104):** `if (_stopwatch.elapsed.inSeconds < 60) { ... showSnackBar('You cannot finish in less than 1 minute!'); return; }`
- **Tác động:** Nếu nghiệp vụ yêu cầu giảm xuống 30 giây: Chỉ cần sửa con số 60 thành 30 ở khối `if` này.

**3. Lưu trữ cục bộ & Backend:**
- Khi user thoát ngang hoặc hoàn thành, biến `_stopwatch.elapsed.inSeconds` được gửi gộp cùng tiến độ `_currentStep` truyền vào hàm `saveProgress()` của Provider.
- Provider gửi cục data này lên API `PUT /api/bookmarks/progress/{modelId}`. Backend (C#) cộng dồn số giây này vào cột `AccumulatedTimeSeconds` trong Database để phục vụ tính thưởng EXP.

---

## IV. Luồng 4: Bookmark / Favourite (Lưu trữ và Yêu thích)

**1. Data Flow & Quản lý State:**
- Khi bấm icon Trái tim, hàm `toggleFavorite()` của `BookmarkProvider` được gọi.
- Provider duy trì 2 mảng State song song: `_favorites` (danh sách Model yêu thích) và `_inProgress` (danh sách Model đang gập dở). Khi bấm Trái tim, Provider thay đổi List `_favorites` trong RAM và báo `notifyListeners()`. Toàn bộ Icon trái tim của Model đó trên mọi màn hình sẽ sáng màu đỏ lập tức.

**2. Lưu trữ SQL Server (Backend):**
- File C# xử lý là `Backend/Repositories/BookmarkRepository.cs`. 
- Khi Flutter bắn POST request, Backend chạy logic kiểm tra xem bảng `Favorites` đã có cặp `UserId` và `ModelId` này chưa.
- **Lưu dữ liệu:** Gọi `await _db.Favorites.AddAsync(newFavorite)` và `await _db.SaveChangesAsync()`.
- **Hệ quả của Code Lỗi (Đã fix):** Nếu Backend sử dụng `.AsSplitQuery()` kết hợp với kết nối cơ sở dữ liệu không bật `MultipleActiveResultSets=True` (MARS), Entity Framework sẽ cố gắng nạp quan hệ `Models -> FoldSteps` bằng 2 truy vấn song song, gây ra hiện tượng *Deadlock* hoặc `Execution Timeout Expired` kéo dài 25 giây. Mình đã fix triệt để lỗi này bằng cách bỏ MARS và cấu trúc lại câu query LINQ.

**3. Data Passing (Truyền tham số):**
- Thay vì truyền `isFavorite` qua từng lớp màn hình, Flutter App dùng `BookmarkProvider` như một trạm phát sóng toàn cục (Global). Bất cứ chỗ nào cần hiển thị Trái tim đều tự động biết trạng thái bằng cách hỏi `context.watch<BookmarkProvider>().isFavorite(model)`.

---
*Tài liệu được sinh ra dựa trên mã nguồn thực tế của thư mục Frontend (Flutter) và Backend (.NET 8).*
