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

        private static OrigamiModelDto ToDto(OrigamiModel model) => OrigamiModelMapper.ToDto(model);
    }
}
