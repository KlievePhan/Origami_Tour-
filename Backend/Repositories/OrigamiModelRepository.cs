using Backend.Data;
using Backend.Domain;
using Backend.DTOs;
using Backend.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Backend.Repositories
{
    public class OrigamiModelRepository : IOrigamiModelRepository
    {
        private readonly AppDbContext _db;

        public OrigamiModelRepository(AppDbContext db)
        {
            _db = db;
        }

        public async Task<List<OrigamiModel>> GetAllAsync(ModelQueryParameters query)
        {
            var models = _db.Models
                .Include(m => m.Steps.OrderBy(s => s.StepOrder))
                .Include(m => m.ModelCategories).ThenInclude(mc => mc.Category)
                .AsQueryable();

            if (query.Difficulty.HasValue)
                models = models.Where(m => m.Difficulty == query.Difficulty.Value);

            if (query.CategoryId.HasValue)
                models = models.Where(m => m.ModelCategories.Any(mc => mc.CategoryId == query.CategoryId.Value));

            return await models
                .OrderByDescending(m => m.Popularity)
                .ToListAsync();
        }

        public async Task<OrigamiModel?> GetByIdAsync(int id)
        {
            return await _db.Models
                .Include(m => m.Steps.OrderBy(s => s.StepOrder))
                .Include(m => m.ModelCategories).ThenInclude(mc => mc.Category)
                .FirstOrDefaultAsync(m => m.Id == id);
        }
    }
}
