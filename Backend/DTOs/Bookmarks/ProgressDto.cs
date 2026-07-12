namespace Backend.DTOs.Bookmarks
{
    public class ProgressDto
    {
        public OrigamiModelDto Model { get; set; } = null!;
        public int CurrentStep { get; set; }
        public int TotalSteps { get; set; }
        public bool Completed { get; set; }
        public DateTime LastSessionDate { get; set; }
        
        // Properties added for leveling up calculations upon completion
        public int ExpGained { get; set; }
        public int NewExp { get; set; }
        public int NewLevel { get; set; }
    }
}
