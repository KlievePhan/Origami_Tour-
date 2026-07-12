using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Backend.Domain;
using Backend.DTOs.Auth;
using Backend.Repositories.Interfaces;
using Backend.Services.Interfaces;
using Google.Apis.Auth;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _repository;
        private readonly IConfiguration _configuration;
        private readonly IMailService _mailService;
        private readonly IOtpService _otpService;

        public AuthService(IAuthRepository repository, IConfiguration configuration, IMailService mailService, IOtpService otpService)
        {
            _repository = repository;
            _configuration = configuration;
            _mailService = mailService;
            _otpService = otpService;
        }

        public async Task<(bool Success, IEnumerable<string> Errors)> SendRegisterOtpAsync(string email)
        {
            var existing = await _repository.FindByEmailAsync(email);
            if (existing != null)
            {
                return (false, new[] { "This email is already registered." });
            }

            var otp = await _otpService.GenerateAndSaveOtpAsync(email, "Register");
            await _mailService.SendEmailAsync(
                email, 
                "OrigamiTour: Register OTP", 
                $"Your registration OTP code is: <b>{otp}</b>. It is valid for 10 minutes.");
                
            return (true, Array.Empty<string>());
        }

        public async Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> RegisterWithOtpAsync(RegisterRequestDto dto, string otp)
        {
            var isValid = await _otpService.VerifyOtpAsync(dto.Email, otp, "Register");
            if (!isValid)
            {
                return (false, null, new[] { "Invalid or expired OTP." });
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

        public async Task<(bool Success, IEnumerable<string> Errors)> SendRecoveryOtpAsync(string email)
        {
            var existing = await _repository.FindByEmailAsync(email);
            if (existing == null)
            {
                // We shouldn't reveal if the email exists, so we return true regardless, 
                // but we only actually send if it exists.
                return (true, Array.Empty<string>());
            }

            var otp = await _otpService.GenerateAndSaveOtpAsync(email, "PasswordRecovery");
            await _mailService.SendEmailAsync(
                email, 
                "OrigamiTour: Recovery OTP", 
                $"Your password recovery OTP code is: <b>{otp}</b>. It is valid for 10 minutes.");
                
            return (true, Array.Empty<string>());
        }

        public async Task<(bool Success, IEnumerable<string> Errors)> ResetPasswordWithOtpAsync(string email, string otp, string newPassword)
        {
            var user = await _repository.FindByEmailAsync(email);
            if (user == null)
            {
                return (false, new[] { "Invalid or expired OTP." });
            }

            var isValid = await _otpService.VerifyOtpAsync(email, otp, "PasswordRecovery");
            if (!isValid)
            {
                return (false, new[] { "Invalid or expired OTP." });
            }

            // Using repository or usermanager to reset password
            var resetResult = await _repository.ResetPasswordAsync(user, newPassword);
            if (!resetResult.Success)
            {
                return (false, resetResult.Errors);
            }

            return (true, Array.Empty<string>());
        }

        public async Task<(bool Success, AuthResponseDto? Result, IEnumerable<string> Errors)> GoogleLoginAsync(string idToken)
        {
            try
            {
                var clientId = _configuration["Authentication:Google:ClientId"];
                var settings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { clientId }
                };

                var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);
                
                var user = await _repository.FindByEmailAsync(payload.Email);
                if (user == null)
                {
                    // Create new user if they don't exist
                    user = new ApplicationUser
                    {
                        UserName = payload.Email,
                        Email = payload.Email,
                        DisplayName = payload.Name ?? payload.Email,
                        AvatarUrl = payload.Picture
                    };
                    
                    var (success, errors) = await _repository.CreateWithoutPasswordAsync(user);
                    if (!success)
                    {
                        return (false, null, errors);
                    }
                }

                user.LastFoldDate = DateTime.UtcNow;
                await _repository.UpdateAsync(user);

                return (true, BuildAuthResponse(user), Array.Empty<string>());
            }
            catch (InvalidJwtException)
            {
                return (false, null, new[] { "Invalid Google token." });
            }
            catch (Exception ex)
            {
                return (false, null, new[] { "Google login failed: " + ex.Message });
            }
        }

        public async Task<(bool Success, AuthResponseDto? Result)> LoginAsync(LoginRequestDto dto)
        {
            var user = await _repository.FindByEmailAsync(dto.Email);
            if (user is null || !await _repository.CheckPasswordAsync(user, dto.Password))
            {
                return (false, null);
            }

            user.LastFoldDate = DateTime.UtcNow;
            await _repository.UpdateAsync(user);

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
