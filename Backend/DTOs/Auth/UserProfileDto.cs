namespace Backend.DTOs.Auth
{
    public class UserProfileDto
    {
        public string Id { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public int Exp { get; set; }
        public int Level { get; set; }
        public int TotalCompleted { get; set; }
    }
}
