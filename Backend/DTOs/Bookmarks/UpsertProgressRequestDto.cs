namespace Backend.DTOs.Bookmarks
{
    public class UpsertProgressRequestDto
    {
        public int CurrentStep { get; set; }
        public long? AccumulatedTimeSeconds { get; set; }
        public bool Completed { get; set; }
    }
}
