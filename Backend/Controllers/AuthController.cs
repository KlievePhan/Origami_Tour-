using System.Security.Claims;
using Backend.DTOs.Auth;
using Backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    /// <summary>Registration, login, and the current user's profile.</summary>
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthResponseDto>> Register(RegisterRequestDto dto)
        {
            var (success, result, errors) = await _authService.RegisterAsync(dto);
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
