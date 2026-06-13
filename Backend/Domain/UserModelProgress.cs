namespace Backend.Domain
{
    // Drives completion status, In-Progress, resume, best time
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
}
