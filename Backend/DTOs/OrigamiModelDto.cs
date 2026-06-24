namespace Backend.DTOs
{
    public class OrigamiModelDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Author { get; set; } = string.Empty;
        public string ThumbnailUrl { get; set; } = string.Empty;
        public string HeroUrl { get; set; } = string.Empty;
        public string Difficulty { get; set; } = string.Empty;
        public int EstimatedMinutes { get; set; }
        public string PaperSize { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal RatingAvg { get; set; }
        public int RatingCount { get; set; }
        public int CompletionCount { get; set; }
        public int Popularity { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<string> Categories { get; set; } = new();
        public List<FoldStepDto> Steps { get; set; } = new();
    }
}
