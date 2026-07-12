using System.ComponentModel.DataAnnotations;

namespace Backend.Domain
{
    public class OtpCode
    {
        public int Id { get; set; }

        [Required]
        public string Email { get; set; } = null!;

        [Required]
        [MaxLength(6)]
        public string Code { get; set; } = null!;

        [Required]
        [MaxLength(20)]
        public string Purpose { get; set; } = null!;

        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
    }
}
