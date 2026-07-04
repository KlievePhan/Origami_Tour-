namespace Backend.DTOs.Bookmarks
{
    public class ProgressDto
    {
        public OrigamiModelDto Model { get; set; } = null!;
        public int CurrentStep { get; set; }
        public int TotalSteps { get; set; }
        public bool Completed { get; set; }
        public DateTime LastSessionDate { get; set; }
    }
}
