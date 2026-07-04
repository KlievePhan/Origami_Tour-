namespace Backend.DTOs.Bookmarks
{
    public class FavoriteDto
    {
        public OrigamiModelDto Model { get; set; } = null!;
        public DateTime AddedAt { get; set; }
    }
}
