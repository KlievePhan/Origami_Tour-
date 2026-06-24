using Backend.Domain;

namespace Backend.Repositories.Interfaces
{
    public interface IAuthRepository
    {
        Task<ApplicationUser?> FindByEmailAsync(string email);

        Task<ApplicationUser?> FindByIdAsync(string userId);

        /// <summary>Creates a user with a hashed password. Returns the Identity errors on failure.</summary>
        Task<(bool Success, IEnumerable<string> Errors)> CreateAsync(ApplicationUser user, string password);

        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
    }
}
