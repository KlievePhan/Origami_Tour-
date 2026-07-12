using Backend.Domain;

namespace Backend.Repositories.Interfaces
{
    public interface IBookmarkRepository
    {
        Task<List<Favorite>> GetFavoritesAsync(string userId);

        Task<bool> AddFavoriteAsync(string userId, int modelId);

        Task<bool> RemoveFavoriteAsync(string userId, int modelId);

        Task<List<UserModelProgress>> GetInProgressAsync(string userId);

        Task<(UserModelProgress? Progress, int ExpGained, int NewExp, int NewLevel)> UpsertProgressAsync(
            string userId,
            int modelId,
            int currentStep,
            long? accumulatedSeconds,
            bool completed);

        Task<bool> RemoveProgressAsync(string userId, int modelId);
    }
}
