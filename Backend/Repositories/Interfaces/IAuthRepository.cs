using Backend.Domain;

namespace Backend.Repositories.Interfaces
{
    public interface IAuthRepository
    {
        Task<ApplicationUser?> FindByEmailAsync(string email);

        Task<ApplicationUser?> FindByIdAsync(string userId);

        /// <summary>Creates a user with a hashed password. Returns the Identity errors on failure.</summary>
        Task<(bool Success, IEnumerable<string> Errors)> CreateAsync(ApplicationUser user, string password);

        Task<(bool Success, IEnumerable<string> Errors)> CreateWithoutPasswordAsync(ApplicationUser user);
        
        Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordAsync(ApplicationUser user, string newPassword);

        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);

        Task<bool> UpdateAsync(ApplicationUser user);
    }
}
