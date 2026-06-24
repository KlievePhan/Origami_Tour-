using Backend.Domain;
using Backend.DTOs;
using Backend.Repositories.Interfaces;
using Backend.Services.Interfaces;

namespace Backend.Services
{
    public class OrigamiModelService : IOrigamiModelService
    {
        private readonly IOrigamiModelRepository _repository;

        public OrigamiModelService(IOrigamiModelRepository repository)
        {
            _repository = repository;
        }

        public async Task<List<OrigamiModelDto>> GetModelsAsync(ModelQueryParameters query)
        {
            var models = await _repository.GetAllAsync(query);
            return models.Select(ToDto).ToList();
        }

        public async Task<OrigamiModelDto?> GetModelByIdAsync(int id)
        {
            var model = await _repository.GetByIdAsync(id);
            return model is null ? null : ToDto(model);
        }

        private static OrigamiModelDto ToDto(OrigamiModel model) => new()
        {
            Id = model.Id,
            Name = model.Name,
            Author = model.Author,
            ThumbnailUrl = model.ThumbnailUrl,
            HeroUrl = model.HeroUrl,
            Difficulty = model.Difficulty.ToString(),
            EstimatedMinutes = model.EstimatedMinutes,
            PaperSize = model.PaperSize,
            Description = model.Description,
            RatingAvg = model.RatingAvg,
            RatingCount = model.RatingCount,
            CompletionCount = model.CompletionCount,
            Popularity = model.Popularity,
            CreatedAt = model.CreatedAt,
            Categories = model.ModelCategories
                .Select(mc => mc.Category.Name)
                .ToList(),
            Steps = model.Steps
                .Select(s => new FoldStepDto
                {
                    Id = s.Id,
                    StepOrder = s.StepOrder,
                    DiagramUrl = s.DiagramUrl,
                    AnimationUrl = s.AnimationUrl,
                    Instruction = s.Instruction,
                    FoldType = s.FoldType.ToString(),
                })
                .ToList(),
        };
    }
}
