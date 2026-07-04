using Backend.Domain;
using Backend.DTOs;

namespace Backend.Services
{
    /// <summary>Shared entity-to-DTO mapping for <see cref="OrigamiModel"/>, used by both
    /// <see cref="OrigamiModelService"/> and <see cref="BookmarkService"/> so favorites/in-progress
    /// responses describe models identically to the main catalog endpoints.</summary>
    public static class OrigamiModelMapper
    {
        public static OrigamiModelDto ToDto(OrigamiModel model) => new()
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
