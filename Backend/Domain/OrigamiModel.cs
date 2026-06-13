namespace Backend.Domain
{
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
}
