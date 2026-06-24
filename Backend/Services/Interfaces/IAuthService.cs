using Backend.DTOs.Auth;

namespace Backend.Services.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> RegisterAsync(RegisterRequestDto dto);

        Task<(bool Success, AuthResponseDto? Result)> LoginAsync(LoginRequestDto dto);

        Task<UserProfileDto?> GetProfileAsync(string userId);
    }
}
