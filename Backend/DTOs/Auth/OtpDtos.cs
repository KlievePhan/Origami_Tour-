using System.ComponentModel.DataAnnotations;

namespace Backend.DTOs.Auth
{
    public class EmailRequestDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = null!;
    }

    public class VerifyRegisterDto
    {
        [Required]
        public RegisterRequestDto RegisterDto { get; set; } = null!;

        [Required]
        public string Otp { get; set; } = null!;
    }

    public class ResetPasswordDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = null!;

        [Required]
        public string Otp { get; set; } = null!;

        [Required]
        public string NewPassword { get; set; } = null!;
    }

    public class GoogleLoginDto
    {
        [Required]
        public string IdToken { get; set; } = null!;
    }
}
