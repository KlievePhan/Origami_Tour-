using Backend.Domain;

namespace Backend.DTOs
{
    /// <summary>Filters accepted by GET /api/models.</summary>
    public class ModelQueryParameters
    {
        public int? CategoryId { get; set; }
        public Difficulty? Difficulty { get; set; }
    }
}
