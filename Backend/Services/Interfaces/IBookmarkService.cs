using Backend.DTOs.Bookmarks;

namespace Backend.Services.Interfaces
{
    public interface IBookmarkService
    {
        Task<List<FavoriteDto>> GetFavoritesAsync(string userId);

        Task<bool> AddFavoriteAsync(string userId, int modelId);

        Task<bool> RemoveFavoriteAsync(string userId, int modelId);

        Task<List<ProgressDto>> GetInProgressAsync(string userId);

        Task<ProgressDto?> UpsertProgressAsync(string userId, int modelId, UpsertProgressRequestDto dto);

        Task<bool> RemoveProgressAsync(string userId, int modelId);
    }
}
