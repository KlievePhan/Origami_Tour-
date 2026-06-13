using Microsoft.AspNetCore.Identity;

namespace Backend.Domain
{
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
}
