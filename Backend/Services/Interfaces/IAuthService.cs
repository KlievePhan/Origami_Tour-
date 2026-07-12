using Backend.DTOs.Auth;

namespace Backend.Services.Interfaces
{
    public interface IAuthService
    {
        // Removed original RegisterAsync
        Task<(bool Success, AuthResponseDto? Result)> LoginAsync(LoginRequestDto dto);

        Task<UserProfileDto?> GetProfileAsync(string userId);

        Task<(bool Success, IEnumerable<string> Errors)> SendRegisterOtpAsync(string email);
        Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> RegisterWithOtpAsync(RegisterRequestDto dto, string otp);
        
        Task<(bool Success, IEnumerable<string> Errors)> SendRecoveryOtpAsync(string email);
        Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordWithOtpAsync(string email, string otp, string newPassword);
        
        Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> GoogleLoginAsync(string idToken);
    }
}
