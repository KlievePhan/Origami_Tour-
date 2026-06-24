using Backend.DTOs;

namespace Backend.Services.Interfaces
{
    public interface IOrigamiModelService
    {
        Task<List<OrigamiModelDto>> GetModelsAsync(ModelQueryParameters query);

        Task<OrigamiModelDto?> GetModelByIdAsync(int id);
    }
}
