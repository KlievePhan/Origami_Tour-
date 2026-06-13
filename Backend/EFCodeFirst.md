# Origami Tour — Relational Schema (EF Core / SQL Server)

Code-first entity model for the **ASP.NET Core Web API** backend. Replaces
`firebase-schema.md`. Identity is handled by **ASP.NET Core Identity**; the domain tables
below sit alongside the `AspNet*` Identity tables in the same database.

**Packages:** `Microsoft.EntityFrameworkCore.SqlServer`,
`Microsoft.AspNetCore.Identity.EntityFrameworkCore`, `Microsoft.EntityFrameworkCore.Tools`.

---

## 1. ER Overview

```
ApplicationUser (IdentityUser + profile/mastery/stats)
   ├─1:N─ UserModelProgress ─N:1─ OrigamiModel
   ├─1:N─ Favorite          ─N:1─ OrigamiModel
   ├─1:N─ Rating            ─N:1─ OrigamiModel
   ├─1:N─ UserAchievement   ─N:1─ Achievement
   └─N:1─ Category (favorite category, nullable)

OrigamiModel
   ├─1:N─ FoldStep
   └─N:N─ Category   (via ModelCategory join)

LevelDefinition   (config table: Level → RequiredExp → RankTitle)
```

Keys are `int` identity (catalog-style app); `ApplicationUser.Id` is `string` (Identity default).
Switch to `Guid` only if you need distributed/offline-generated IDs.

---

## 2. Enums  `// Domain/Enums.cs`

```csharp
public enum Difficulty { Easy, Medium, Hard }
public enum FoldType   { Valley, Mountain, Squash, Reverse, Other }
public enum AchievementConditionType { FirstFold, ModelsCompleted, StreakDays, CategoryMaster, TotalFoldMinutes }
```

---

## 3. Entities

```csharp
// Domain/ApplicationUser.cs  (extends Identity — holds profile, mastery, stats)
public class ApplicationUser : IdentityUser
{
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Mastery (current denormalized state; recomputed by the gamification service).
    // RankTitle / next rank / expForNextLevel are DERIVED from LevelDefinition at read time,
    // so they are not stored here (single source of truth = LevelDefinition).
    public int Exp { get; set; }
    public int Level { get; set; } = 1;

    // Stats
    public int TotalCompleted { get; set; }
    public long TotalFoldTimeSeconds { get; set; }
    public int? FavoriteCategoryId { get; set; }
    public Category? FavoriteCategory { get; set; }
    public int CurrentStreak { get; set; }
    public DateTime? LastFoldDate { get; set; }

    // Navigation
    public ICollection<UserModelProgress> Progresses { get; set; } = new List<UserModelProgress>();
    public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    public ICollection<Rating> Ratings { get; set; } = new List<Rating>();
    public ICollection<UserAchievement> Achievements { get; set; } = new List<UserAchievement>();
}
```

```csharp
// Domain/OrigamiModel.cs
public class OrigamiModel
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string ThumbnailUrl { get; set; } = string.Empty;
    public string HeroUrl { get; set; } = string.Empty;
    public Difficulty Difficulty { get; set; }
    public int EstimatedMinutes { get; set; }
    public string PaperSize { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    // Denormalized aggregates (maintained in services / triggers).
    public decimal RatingAvg { get; set; }
    public int RatingCount { get; set; }
    public int CompletionCount { get; set; }
    public int Popularity { get; set; }        // sort key (e.g. = CompletionCount or weighted)
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<FoldStep> Steps { get; set; } = new List<FoldStep>();
    public ICollection<ModelCategory> ModelCategories { get; set; } = new List<ModelCategory>();
    public ICollection<Rating> Ratings { get; set; } = new List<Rating>();
    // StepCount = Steps.Count (not stored)
}
```

```csharp
// Domain/FoldStep.cs
public class FoldStep
{
    public int Id { get; set; }
    public int ModelId { get; set; }
    public OrigamiModel Model { get; set; } = null!;
    public int StepOrder { get; set; }          // 1-based
    public string DiagramUrl { get; set; } = string.Empty;
    public string? AnimationUrl { get; set; }   // optional GIF/animation
    public string Instruction { get; set; } = string.Empty;
    public FoldType FoldType { get; set; }
}
```

```csharp
// Domain/Category.cs  +  Domain/ModelCategory.cs (N:N join)
public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;   // "Animals"
    public string Slug { get; set; } = string.Empty;   // "animals"
    public ICollection<ModelCategory> ModelCategories { get; set; } = new List<ModelCategory>();
}

public class ModelCategory
{
    public int ModelId { get; set; }
    public OrigamiModel Model { get; set; } = null!;
    public int CategoryId { get; set; }
    public Category Category { get; set; } = null!;
}
```

```csharp
// Domain/UserModelProgress.cs  (drives completion status, In-Progress, resume, best time)
public class UserModelProgress
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public ApplicationUser User { get; set; } = null!;
    public int ModelId { get; set; }
    public OrigamiModel Model { get; set; } = null!;

    public bool Completed { get; set; }
    public int CurrentStep { get; set; }                // resume point
    public long AccumulatedTimeSeconds { get; set; }
    public long? BestTimeSeconds { get; set; }
    public DateTime LastSessionDate { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
```

```csharp
// Domain/Favorite.cs   |   Domain/Rating.cs
public class Favorite
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public ApplicationUser User { get; set; } = null!;
    public int ModelId { get; set; }
    public OrigamiModel Model { get; set; } = null!;
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;
}

public class Rating
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public ApplicationUser User { get; set; } = null!;
    public int ModelId { get; set; }
    public OrigamiModel Model { get; set; } = null!;
    public int Stars { get; set; }                      // 1..5
    public DateTime RatedAt { get; set; } = DateTime.UtcNow;
}
```

```csharp
// Domain/Achievement.cs  +  Domain/UserAchievement.cs
public class Achievement
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty;    // stable key, e.g. "first_fold"
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string IconUrl { get; set; } = string.Empty;
    public string ConditionText { get; set; } = string.Empty;   // hint for locked badge
    public AchievementConditionType ConditionType { get; set; }
    public int Threshold { get; set; }
    public ICollection<UserAchievement> UserAchievements { get; set; } = new List<UserAchievement>();
}

public class UserAchievement
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public ApplicationUser User { get; set; } = null!;
    public int AchievementId { get; set; }
    public Achievement Achievement { get; set; } = null!;
    public DateTime UnlockedAt { get; set; } = DateTime.UtcNow;
}
```

```csharp
// Domain/LevelDefinition.cs  (config table — makes the rank ladder data-driven)
public class LevelDefinition
{
    public int Level { get; set; }            // PK, 1..N
    public int RequiredExp { get; set; }      // cumulative EXP to REACH this level
    public string RankTitle { get; set; } = string.Empty;  // rank name shown at this level
}
// Current rank = LevelDefinition[user.Level].RankTitle.
// Next rank   = first level above with a different RankTitle.
// expForNextLevel = LevelDefinition[user.Level + 1].RequiredExp - user.Exp.
```

---

## 4. DbContext  `// Data/AppDbContext.cs`

```csharp
public class AppDbContext : IdentityDbContext<ApplicationUser>
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<OrigamiModel> Models => Set<OrigamiModel>();
    public DbSet<FoldStep> FoldSteps => Set<FoldStep>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<ModelCategory> ModelCategories => Set<ModelCategory>();
    public DbSet<UserModelProgress> Progresses => Set<UserModelProgress>();
    public DbSet<Favorite> Favorites => Set<Favorite>();
    public DbSet<Rating> Ratings => Set<Rating>();
    public DbSet<Achievement> Achievements => Set<Achievement>();
    public DbSet<UserAchievement> UserAchievements => Set<UserAchievement>();
    public DbSet<LevelDefinition> LevelDefinitions => Set<LevelDefinition>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        base.OnModelCreating(b);   // REQUIRED for Identity tables

        // Enums stored as readable strings
        b.Entity<OrigamiModel>().Property(m => m.Difficulty).HasConversion<string>().HasMaxLength(10);
        b.Entity<FoldStep>().Property(s => s.FoldType).HasConversion<string>().HasMaxLength(15);
        b.Entity<Achievement>().Property(a => a.ConditionType).HasConversion<string>().HasMaxLength(30);
        b.Entity<OrigamiModel>().Property(m => m.RatingAvg).HasColumnType("decimal(3,2)");

        // Steps: ordered & unique within a model; cascade from model
        b.Entity<FoldStep>().HasIndex(s => new { s.ModelId, s.StepOrder }).IsUnique();
        b.Entity<FoldStep>().HasOne(s => s.Model).WithMany(m => m.Steps)
            .HasForeignKey(s => s.ModelId).OnDelete(DeleteBehavior.Cascade);

        // Model <-> Category (N:N)
        b.Entity<ModelCategory>().HasKey(mc => new { mc.ModelId, mc.CategoryId });
        b.Entity<ModelCategory>().HasOne(mc => mc.Model).WithMany(m => m.ModelCategories)
            .HasForeignKey(mc => mc.ModelId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<ModelCategory>().HasOne(mc => mc.Category).WithMany(c => c.ModelCategories)
            .HasForeignKey(mc => mc.CategoryId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<Category>().HasIndex(c => c.Slug).IsUnique();

        // Progress / Favorite / Rating: one row per (user, model)
        b.Entity<UserModelProgress>().HasIndex(p => new { p.UserId, p.ModelId }).IsUnique();
        b.Entity<UserModelProgress>().HasIndex(p => new { p.UserId, p.Completed });
        b.Entity<Favorite>().HasIndex(f => new { f.UserId, f.ModelId }).IsUnique();
        b.Entity<Rating>().HasIndex(r => new { r.UserId, r.ModelId }).IsUnique();
        b.Entity<UserAchievement>().HasIndex(ua => new { ua.UserId, ua.AchievementId }).IsUnique();
        b.Entity<Achievement>().HasIndex(a => a.Code).IsUnique();

        // --- Cascade strategy (see §6): User side cascades, Model side RESTRICTS ---
        foreach (var rel in new[]
        {
            b.Entity<UserModelProgress>().HasOne(p => p.Model).WithMany().HasForeignKey(p => p.ModelId),
            b.Entity<Favorite>().HasOne(f => f.Model).WithMany().HasForeignKey(f => f.ModelId),
        }) rel.OnDelete(DeleteBehavior.Restrict);

        b.Entity<Rating>().HasOne(r => r.Model).WithMany(m => m.Ratings)
            .HasForeignKey(r => r.ModelId).OnDelete(DeleteBehavior.Restrict);
        b.Entity<UserAchievement>().HasOne(ua => ua.Achievement).WithMany(a => a.UserAchievements)
            .HasForeignKey(ua => ua.AchievementId).OnDelete(DeleteBehavior.Restrict);

        b.Entity<UserModelProgress>().HasOne(p => p.User).WithMany(u => u.Progresses)
            .HasForeignKey(p => p.UserId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<Favorite>().HasOne(f => f.User).WithMany(u => u.Favorites)
            .HasForeignKey(f => f.UserId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<Rating>().HasOne(r => r.User).WithMany(u => u.Ratings)
            .HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<UserAchievement>().HasOne(ua => ua.User).WithMany(u => u.Achievements)
            .HasForeignKey(ua => ua.UserId).OnDelete(DeleteBehavior.Cascade);

        // Favorite category on user (nullable)
        b.Entity<ApplicationUser>().HasOne(u => u.FavoriteCategory).WithMany()
            .HasForeignKey(u => u.FavoriteCategoryId).OnDelete(DeleteBehavior.SetNull);

        // Collection filter/sort indexes
        b.Entity<OrigamiModel>().HasIndex(m => m.Difficulty);
        b.Entity<OrigamiModel>().HasIndex(m => m.Popularity);
        b.Entity<OrigamiModel>().HasIndex(m => m.CreatedAt);
        b.Entity<OrigamiModel>().HasIndex(m => m.EstimatedMinutes);

        b.Entity<LevelDefinition>().HasKey(l => l.Level);
    }
}
```

Registration in `Program.cs`:
```csharp
builder.Services.AddDbContext<AppDbContext>(o =>
    o.UseSqlServer(builder.Configuration.GetConnectionString("Default")));
builder.Services.AddIdentityCore<ApplicationUser>(o => {
        o.Password.RequiredLength = 8;          // matches Register/Recover rules
        o.User.RequireUniqueEmail = true;
    })
    .AddEntityFrameworkStores<AppDbContext>();
// JWT + Google sign-in are configured in the API/auth layer (next artifact).
```

---

## 5. Index summary

| Table | Index | Purpose |
|---|---|---|
| Models | `Difficulty`, `Popularity`, `CreatedAt`, `EstimatedMinutes` | Collection filter + sort |
| FoldSteps | unique `(ModelId, StepOrder)` | ordered steps |
| Categories | unique `Slug` | lookup |
| ModelCategories | PK `(ModelId, CategoryId)` | N:N |
| Progresses | unique `(UserId, ModelId)`, `(UserId, Completed)` | resume + In-Progress list |
| Favorites | unique `(UserId, ModelId)` | bookmark toggle |
| Ratings | unique `(UserId, ModelId)` | one rating per user |
| UserAchievements | unique `(UserId, AchievementId)` | unlock once |
| Achievements | unique `Code` | stable key |

---

## 6. SQL Server gotcha — multiple cascade paths

`UserModelProgress` / `Favorite` / `Rating` each have **two** FKs (to User *and* to Model).
If both cascade-delete, SQL Server rejects the migration: *"may cause cycles or multiple
cascade paths."* The fix used above: **User → child = Cascade**, **Model → child = Restrict**.
So deleting a user cleans up their rows automatically; deleting a model requires removing its
dependent rows first (intentional — you rarely hard-delete catalog models; prefer a soft-delete
`IsActive` flag if needed).

---

## 7. Seeding  `// in OnModelCreating, via HasData`

```csharp
b.Entity<Category>().HasData(
    new Category { Id = 1, Name = "Animals", Slug = "animals" },
    new Category { Id = 2, Name = "Birds",   Slug = "birds" },
    new Category { Id = 3, Name = "Flowers", Slug = "flowers" },
    new Category { Id = 4, Name = "Dinosaurs", Slug = "dinosaurs" },
    new Category { Id = 5, Name = "Abstract", Slug = "abstract" });

b.Entity<LevelDefinition>().HasData(
    new LevelDefinition { Level = 1, RequiredExp = 0,    RankTitle = "Crane Apprentice" },
    new LevelDefinition { Level = 2, RequiredExp = 100,  RankTitle = "Crane Apprentice" },
    new LevelDefinition { Level = 3, RequiredExp = 250,  RankTitle = "Crane Apprentice" },
    new LevelDefinition { Level = 4, RequiredExp = 500,  RankTitle = "Crane Apprentice" },
    new LevelDefinition { Level = 5, RequiredExp = 800,  RankTitle = "Paper Artisan" },
    new LevelDefinition { Level = 6, RequiredExp = 1200, RankTitle = "Paper Artisan" });
// (placeholder thresholds — finalize in §9)

b.Entity<Achievement>().HasData(
    new Achievement { Id = 1, Code = "first_fold", Name = "First Fold",
        Description = "Complete your first model.", IconUrl = "",
        ConditionText = "Complete 1 model", ConditionType = AchievementConditionType.ModelsCompleted, Threshold = 1 });
```

---

## 8. How the screens query this (the relational win)

The Collection screen — impossible as one Firestore query — is one LINQ query here:
```csharp
var q = db.Models
    .Where(m => difficulties.Count == 0 || difficulties.Contains(m.Difficulty))
    .Where(m => categoryIds.Count == 0 || m.ModelCategories.Any(mc => categoryIds.Contains(mc.CategoryId)))
    .Where(m => string.IsNullOrEmpty(search) || m.Name.Contains(search))
    .OrderByDescending(m => m.Popularity)   // switch by sort option
    .Skip(skip).Take(take);
```
Per-user overlay (completion + in-progress) via a left join to `Progresses` filtered by the
caller's `UserId` — returned together in the list DTO, so the client doesn't merge anything.
"Finished: X / Y" = `Progresses.Count(p => p.UserId == uid && p.Completed)` over
`Models.Count()`.

---

## 9. Migrations & open decisions

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

Still to finalize (carried from CLAUDE.md §13):
- **Level/rank thresholds** — replace the placeholder `LevelDefinition` seed values.
- **Achievement catalog** — fill `ConditionType` + `Threshold` for the full list.
- **Soft delete** — add `IsActive` on `OrigamiModel` if you need to retire models without
  breaking the Restrict FKs.
- **PK type** — `int` (chosen) vs `Guid`.
- **RatingAvg** — keep denormalized (shown above) vs compute on read with EF `Average()`.
```