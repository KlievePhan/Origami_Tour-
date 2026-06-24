using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Backend.Domain;
using Backend.DTOs.Auth;
using Backend.Repositories.Interfaces;
using Backend.Services.Interfaces;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _repository;
        private readonly IConfiguration _configuration;

        public AuthService(IAuthRepository repository, IConfiguration configuration)
        {
            _repository = repository;
            _configuration = configuration;
        }

        public async Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> RegisterAsync(RegisterRequestDto dto)
        {
            var existing = await _repository.FindByEmailAsync(dto.Email);
            if (existing is not null)
            {
                return (false, null, new[] { "This email is already registered." });
            }

            var user = new ApplicationUser
            {
                UserName = dto.Email,
                Email = dto.Email,
                DisplayName = dto.DisplayName,
            };

            var (success, errors) = await _repository.CreateAsync(user, dto.Password);
            if (!success)
            {
                return (false, null, errors);
            }

            return (true, BuildAuthResponse(user), Array.Empty<string>());
        }

        public async Task<(bool Success, AuthResponseDto? Result)> LoginAsync(LoginRequestDto dto)
        {
            var user = await _repository.FindByEmailAsync(dto.Email);
            if (user is null || !await _repository.CheckPasswordAsync(user, dto.Password))
            {
                // Generic failure message — never reveal whether the email or the
                // password was wrong (matches LoginScreen's single inline error).
                return (false, null);
            }

            return (true, BuildAuthResponse(user));
        }

        public async Task<UserProfileDto?> GetProfileAsync(string userId)
        {
            var user = await _repository.FindByIdAsync(userId);
            if (user is null) return null;

            return new UserProfileDto
            {
                Id = user.Id,
                DisplayName = user.DisplayName,
                Email = user.Email ?? string.Empty,
                AvatarUrl = user.AvatarUrl,
                Exp = user.Exp,
                Level = user.Level,
                TotalCompleted = user.TotalCompleted,
            };
        }

        private AuthResponseDto BuildAuthResponse(ApplicationUser user)
        {
            var jwtSection = _configuration.GetSection("Jwt");
            var signingKey = jwtSection["SigningKey"]!;
            var expiryMinutes = int.Parse(jwtSection["ExpiryMinutes"]!);
            var expiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
                new Claim(ClaimTypes.Name, user.DisplayName),
            };

            var credentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: jwtSection["Issuer"],
                audience: jwtSection["Audience"],
                claims: claims,
                expires: expiresAt,
                signingCredentials: credentials);

            return new AuthResponseDto
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                ExpiresAt = expiresAt,
                UserId = user.Id,
                DisplayName = user.DisplayName,
                Email = user.Email ?? string.Empty,
            };
        }
    }
}
