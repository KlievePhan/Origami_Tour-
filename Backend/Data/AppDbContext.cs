using Backend.Domain;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Backend.Data
{
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

            // --- Cascade strategy (see EFCodeFirst.md §6): User side cascades, Model side RESTRICTS ---
            b.Entity<UserModelProgress>().HasOne(p => p.Model).WithMany().HasForeignKey(p => p.ModelId)
                .OnDelete(DeleteBehavior.Restrict);
            b.Entity<Favorite>().HasOne(f => f.Model).WithMany().HasForeignKey(f => f.ModelId)
                .OnDelete(DeleteBehavior.Restrict);

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

            // Seed data
            b.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Animals", Slug = "animals" },
                new Category { Id = 2, Name = "Birds", Slug = "birds" },
                new Category { Id = 3, Name = "Flowers", Slug = "flowers" },
                new Category { Id = 4, Name = "Dinosaurs", Slug = "dinosaurs" },
                new Category { Id = 5, Name = "Abstract", Slug = "abstract" });

            b.Entity<LevelDefinition>().HasData(
                new LevelDefinition { Level = 1, RequiredExp = 0, RankTitle = "Crane Apprentice" },
                new LevelDefinition { Level = 2, RequiredExp = 100, RankTitle = "Crane Apprentice" },
                new LevelDefinition { Level = 3, RequiredExp = 250, RankTitle = "Crane Apprentice" },
                new LevelDefinition { Level = 4, RequiredExp = 500, RankTitle = "Crane Apprentice" },
                new LevelDefinition { Level = 5, RequiredExp = 800, RankTitle = "Paper Artisan" },
                new LevelDefinition { Level = 6, RequiredExp = 1200, RankTitle = "Paper Artisan" });
            // (placeholder thresholds — finalize per CLAUDE.md §13)

            b.Entity<Achievement>().HasData(
                new Achievement
                {
                    Id = 1,
                    Code = "first_fold",
                    Name = "First Fold",
                    Description = "Complete your first model.",
                    IconUrl = "",
                    ConditionText = "Complete 1 model",
                    ConditionType = AchievementConditionType.ModelsCompleted,
                    Threshold = 1
                });
        }
    }
}
