using System.Security.Claims;
using Backend.DTOs.Bookmarks;
using Backend.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    /// <summary>Per-user favorites and in-progress fold tracking. Every endpoint reads the
    /// signed-in user from the JWT — never from a request body/query param — so a user can only
    /// ever read/write their own bookmarks.</summary>
    [Authorize]
    [ApiController]
    [Route("api/bookmarks")]
    public class BookmarksController : ControllerBase
    {
        private readonly IBookmarkService _bookmarkService;

        public BookmarksController(IBookmarkService bookmarkService)
        {
            _bookmarkService = bookmarkService;
        }

        private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        [HttpGet("favorites")]
        public async Task<ActionResult<List<FavoriteDto>>> GetFavorites()
        {
            return Ok(await _bookmarkService.GetFavoritesAsync(UserId));
        }

        [HttpPost("favorites/{modelId:int}")]
        public async Task<IActionResult> AddFavorite(int modelId)
        {
            var success = await _bookmarkService.AddFavoriteAsync(UserId, modelId);
            return success ? Ok() : NotFound();
        }

        [HttpDelete("favorites/{modelId:int}")]
        public async Task<IActionResult> RemoveFavorite(int modelId)
        {
            var success = await _bookmarkService.RemoveFavoriteAsync(UserId, modelId);
            return success ? Ok() : NotFound();
        }

        [HttpGet("in-progress")]
        public async Task<ActionResult<List<ProgressDto>>> GetInProgress()
        {
            return Ok(await _bookmarkService.GetInProgressAsync(UserId));
        }

        [HttpPut("progress/{modelId:int}")]
        public async Task<ActionResult<ProgressDto>> UpsertProgress(
            int modelId,
            UpsertProgressRequestDto dto)
        {
            var progress = await _bookmarkService.UpsertProgressAsync(UserId, modelId, dto);
            return progress is null ? NotFound() : Ok(progress);
        }

        [HttpDelete("progress/{modelId:int}")]
        public async Task<IActionResult> RemoveProgress(int modelId)
        {
            var success = await _bookmarkService.RemoveProgressAsync(UserId, modelId);
            return success ? Ok() : NotFound();
        }
    }
}
