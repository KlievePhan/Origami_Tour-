using System.Security.Claims;
using Backend.DTOs.Auth;
using Backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register/send-otp")]
        public async Task<IActionResult> SendRegisterOtp(EmailRequestDto dto)
        {
            var (success, errors) = await _authService.SendRegisterOtpAsync(dto.Email);
            if (!success)
            {
                return BadRequest(new { errors });
            }
            return Ok();
        }

        [HttpPost("register/verify")]
        public async Task<ActionResult<AuthResponseDto>> RegisterVerify(VerifyRegisterDto dto)
        {
            var (success, result, errors) = await _authService.RegisterWithOtpAsync(dto.RegisterDto, dto.Otp);
            if (!success)
            {
                return BadRequest(new { errors });
            }
            return Ok(result);
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthResponseDto>> Login(LoginRequestDto dto)
        {
            var (success, result) = await _authService.LoginAsync(dto);
            if (!success)
            {
                return Unauthorized(new { errors = new[] { "Incorrect email or password." } });
            }
            return Ok(result);
        }

        [HttpPost("google-login")]
        public async Task<ActionResult<AuthResponseDto>> GoogleLogin(GoogleLoginDto dto)
        {
            var (success, result, errors) = await _authService.GoogleLoginAsync(dto.IdToken);
            if (!success)
            {
                return BadRequest(new { errors });
            }
            return Ok(result);
        }

        [HttpPost("recover/send-otp")]
        public async Task<IActionResult> SendRecoveryOtp(EmailRequestDto dto)
        {
            var (success, errors) = await _authService.SendRecoveryOtpAsync(dto.Email);
            if (!success)
            {
                return BadRequest(new { errors });
            }
            return Ok();
        }

        [HttpPost("recover/verify")]
        public async Task<IActionResult> RecoverVerify(ResetPasswordDto dto)
        {
            var (success, errors) = await _authService.ResetPasswordWithOtpAsync(dto.Email, dto.Otp, dto.NewPassword);
            if (!success)
            {
                return BadRequest(new { errors });
            }
            return Ok();
        }

        [Authorize]
        [HttpGet("me")]
        public async Task<ActionResult<UserProfileDto>> Me()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId is null) return Unauthorized();

            var profile = await _authService.GetProfileAsync(userId);
            return profile is null ? NotFound() : Ok(profile);
        }
    }
}
