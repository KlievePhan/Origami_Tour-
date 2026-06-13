namespace Backend.Domain
{
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
}
