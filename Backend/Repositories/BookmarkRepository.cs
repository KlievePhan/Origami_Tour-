using Backend.Data;
using Backend.Domain;
using Backend.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Backend.Repositories
{
    public class BookmarkRepository : IBookmarkRepository
    {
        private readonly AppDbContext _db;

        public BookmarkRepository(AppDbContext db)
        {
            _db = db;
        }

        private IQueryable<OrigamiModel> ModelsWithSteps =>
            _db.Models
                .Include(m => m.Steps.OrderBy(s => s.StepOrder))
                .Include(m => m.ModelCategories).ThenInclude(mc => mc.Category)
                .AsSplitQuery();

        public async Task<List<Favorite>> GetFavoritesAsync(string userId)
        {
            return await _db.Favorites
                .Where(f => f.UserId == userId)
                .Include(f => f.Model.Steps.OrderBy(s => s.StepOrder))
                .Include(f => f.Model.ModelCategories).ThenInclude(mc => mc.Category)
                .AsSplitQuery()
                .OrderByDescending(f => f.AddedAt)
                .ToListAsync();
        }

        public async Task<bool> AddFavoriteAsync(string userId, int modelId)
        {
            var modelExists = await ModelsWithSteps.AnyAsync(m => m.Id == modelId);
            if (!modelExists) return false;

            var existing = await _db.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ModelId == modelId);
            if (existing is not null) return true;

            _db.Favorites.Add(new Favorite { UserId = userId, ModelId = modelId });
            await _db.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveFavoriteAsync(string userId, int modelId)
        {
            var existing = await _db.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ModelId == modelId);
            if (existing is null) return false;

            _db.Favorites.Remove(existing);
            await _db.SaveChangesAsync();
            return true;
        }

        public async Task<List<UserModelProgress>> GetInProgressAsync(string userId)
        {
            return await _db.Progresses
                .Where(p => p.UserId == userId && !p.Completed)
                .Include(p => p.Model.Steps.OrderBy(s => s.StepOrder))
                .Include(p => p.Model.ModelCategories).ThenInclude(mc => mc.Category)
                .AsSplitQuery()
                .OrderByDescending(p => p.LastSessionDate)
                .ToListAsync();
        }

        public async Task<(UserModelProgress? Progress, int ExpGained, int NewExp, int NewLevel)> UpsertProgressAsync(
            string userId,
            int modelId,
            int currentStep,
            long? accumulatedSeconds,
            bool completed)
        {
            var modelExists = await ModelsWithSteps.AnyAsync(m => m.Id == modelId);
            if (!modelExists) return (null, 0, 0, 0);

            var existing = await _db.Progresses
                .FirstOrDefaultAsync(p => p.UserId == userId && p.ModelId == modelId);

            var now = DateTime.UtcNow;
            if (existing is null)
            {
                existing = new UserModelProgress
                {
                    UserId = userId,
                    ModelId = modelId,
                    StartedAt = now,
                };
                _db.Progresses.Add(existing);
            }

            existing.CurrentStep = currentStep;
            existing.LastSessionDate = now;
            if (accumulatedSeconds.HasValue)
            {
                existing.AccumulatedTimeSeconds = accumulatedSeconds.Value;
            }

            int expGained = 0;
            int newExp = 0;
            int newLevel = 0;

            if (completed && !existing.Completed)
            {
                existing.CompletedAt = now;
                existing.BestTimeSeconds = existing.BestTimeSeconds is null
                    ? existing.AccumulatedTimeSeconds
                    : Math.Min(existing.BestTimeSeconds.Value, existing.AccumulatedTimeSeconds);
                    
                // Fetch the user to update their EXP and Level
                var user = await _db.Users.FindAsync(userId);
                if (user != null)
                {
                    // Calculate EXP
                    var model = await _db.Models.Include(m => m.Steps).FirstAsync(m => m.Id == modelId);
                    int totalSteps = model.Steps.Count;
                    
                    double difficultyMultiplier = model.Difficulty switch
                    {
                        Difficulty.Easy => 1.5,
                        Difficulty.Medium => 2.0,
                        Difficulty.Hard => 3.0,
                        _ => 1.0
                    };
                    
                    double baseExp = totalSteps * difficultyMultiplier;
                    
                    double timeMultiplier = 1.0;
                    int estimatedSeconds = model.EstimatedMinutes * 60;
                    if (estimatedSeconds > 0)
                    {
                        if (existing.AccumulatedTimeSeconds <= estimatedSeconds / 2) timeMultiplier = 1.2;
                        else if (existing.AccumulatedTimeSeconds <= estimatedSeconds) timeMultiplier = 1.1;
                    }
                    
                    expGained = (int)Math.Floor(baseExp * timeMultiplier);
                    user.Exp += expGained;
                    user.TotalCompleted += 1;
                    
                    // Check level ups
                    var levels = await _db.LevelDefinitions.OrderByDescending(l => l.RequiredExp).ToListAsync();
                    var newLevelDef = levels.FirstOrDefault(l => user.Exp >= l.RequiredExp);
                    if (newLevelDef != null && newLevelDef.Level > user.Level)
                    {
                        user.Level = newLevelDef.Level;
                    }
                    
                    newExp = user.Exp;
                    newLevel = user.Level;
                }
            }
            existing.Completed = completed;

            await _db.SaveChangesAsync();

            var updatedProgress = await _db.Progresses
                .Include(p => p.Model.Steps.OrderBy(s => s.StepOrder))
                .Include(p => p.Model.ModelCategories).ThenInclude(mc => mc.Category)
                .AsSplitQuery()
                .FirstAsync(p => p.Id == existing.Id);
                
            return (updatedProgress, expGained, newExp, newLevel);
        }

        public async Task<bool> RemoveProgressAsync(string userId, int modelId)
        {
            var existing = await _db.Progresses
                .FirstOrDefaultAsync(p => p.UserId == userId && p.ModelId == modelId);
            if (existing is null) return false;

            _db.Progresses.Remove(existing);
            await _db.SaveChangesAsync();
            return true;
        }
    }
}
