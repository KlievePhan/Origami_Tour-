using Backend.Domain;
using Backend.DTOs;

namespace Backend.Repositories.Interfaces
{
    public interface IOrigamiModelRepository
    {
        /// <summary>
        /// Returns models (with their categories and ordered fold steps loaded),
        /// optionally filtered by category and/or difficulty.
        /// </summary>
        Task<List<OrigamiModel>> GetAllAsync(ModelQueryParameters query);

        /// <summary>Returns a single model with its categories and ordered fold steps, or null if not found.</summary>
        Task<OrigamiModel?> GetByIdAsync(int id);
    }
}
