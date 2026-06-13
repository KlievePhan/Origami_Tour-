namespace Backend.Domain
{
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
}
