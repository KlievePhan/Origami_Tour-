using Backend.Domain;
using Backend.Repositories.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace Backend.Repositories
{
    /// <summary>
    /// Thin wrapper around <see cref="UserManager{TUser}"/> so the Service layer never
    /// touches Identity/EF Core directly, matching the Controller -> Service -> Repository
    /// pattern used by the Models feature (<see cref="OrigamiModelRepository"/>).
    /// </summary>
    public class AuthRepository : IAuthRepository
    {
        private readonly UserManager<ApplicationUser> _userManager;

        public AuthRepository(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        public Task<ApplicationUser?> FindByEmailAsync(string email)
        {
            return _userManager.FindByEmailAsync(email);
        }

        public Task<ApplicationUser?> FindByIdAsync(string userId)
        {
            return _userManager.FindByIdAsync(userId);
        }

        public async Task<(bool Success, IEnumerable<string> Errors)> CreateAsync(ApplicationUser user, string password)
        {
            var result = await _userManager.CreateAsync(user, password);
            return (result.Succeeded, result.Errors.Select(e => e.Description));
        }

        public async Task<(bool Success, IEnumerable<string> Errors)> CreateWithoutPasswordAsync(ApplicationUser user)
        {
            var result = await _userManager.CreateAsync(user);
            return (result.Succeeded, result.Errors.Select(e => e.Description));
        }

        public async Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordAsync(ApplicationUser user, string newPassword)
        {
            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var result = await _userManager.ResetPasswordAsync(user, token, newPassword);
            return (result.Succeeded, result.Errors.Select(e => e.Description));
        }

        public Task<bool> CheckPasswordAsync(ApplicationUser user, string password)
        {
            return _userManager.CheckPasswordAsync(user, password);
        }

        public async Task<bool> UpdateAsync(ApplicationUser user)
        {
            var result = await _userManager.UpdateAsync(user);
            return result.Succeeded;
        }
    }
}
