using Backend.DTOs.Bookmarks;
using Backend.Repositories.Interfaces;
using Backend.Services.Interfaces;

namespace Backend.Services
{
    public class BookmarkService : IBookmarkService
    {
        private readonly IBookmarkRepository _repository;

        public BookmarkService(IBookmarkRepository repository)
        {
            _repository = repository;
        }

        public async Task<List<FavoriteDto>> GetFavoritesAsync(string userId)
        {
            var favorites = await _repository.GetFavoritesAsync(userId);
            return favorites
                .Select(f => new FavoriteDto
                {
                    Model = OrigamiModelMapper.ToDto(f.Model),
                    AddedAt = f.AddedAt,
                })
                .ToList();
        }

        public Task<bool> AddFavoriteAsync(string userId, int modelId) =>
            _repository.AddFavoriteAsync(userId, modelId);

        public Task<bool> RemoveFavoriteAsync(string userId, int modelId) =>
            _repository.RemoveFavoriteAsync(userId, modelId);

        public async Task<List<ProgressDto>> GetInProgressAsync(string userId)
        {
            var progresses = await _repository.GetInProgressAsync(userId);
            return progresses.Select(ToProgressDto).ToList();
        }

        public async Task<ProgressDto?> UpsertProgressAsync(
            string userId,
            int modelId,
            UpsertProgressRequestDto dto)
        {
            var result = await _repository.UpsertProgressAsync(
                userId,
                modelId,
                dto.CurrentStep,
                dto.AccumulatedTimeSeconds,
                dto.Completed);
                
            if (result.Progress is null) return null;
            
            var progressDto = ToProgressDto(result.Progress);
            progressDto.ExpGained = result.ExpGained;
            progressDto.NewExp = result.NewExp;
            progressDto.NewLevel = result.NewLevel;
            
            return progressDto;
        }

        public Task<bool> RemoveProgressAsync(string userId, int modelId) =>
            _repository.RemoveProgressAsync(userId, modelId);

        private static ProgressDto ToProgressDto(Domain.UserModelProgress progress) => new()
        {
            Model = OrigamiModelMapper.ToDto(progress.Model),
            CurrentStep = progress.CurrentStep,
            TotalSteps = progress.Model.Steps.Count,
            Completed = progress.Completed,
            LastSessionDate = progress.LastSessionDate,
        };
    }
}
