using Backend.Domain;
using Backend.DTOs;
using Backend.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    /// <summary>Public catalog endpoints for origami models and their fold steps.</summary>
    [ApiController]
    [Route("api/models")]
    public class ModelsController : ControllerBase
    {
        private readonly IOrigamiModelService _modelService;

        public ModelsController(IOrigamiModelService modelService)
        {
            _modelService = modelService;
        }

        /// <summary>
        /// Gets all origami models (with their fold steps), optionally filtered
        /// by category and/or difficulty.
        /// </summary>
        /// <param name="categoryId">Only return models belonging to this category.</param>
        /// <param name="difficulty">Only return models with this difficulty (Easy, Medium, Hard).</param>
        [HttpGet]
        public async Task<ActionResult<List<OrigamiModelDto>>> GetModels(
            [FromQuery] int? categoryId,
            [FromQuery] Difficulty? difficulty)
        {
            var query = new ModelQueryParameters
            {
                CategoryId = categoryId,
                Difficulty = difficulty,
            };

            var models = await _modelService.GetModelsAsync(query);
            return Ok(models);
        }

        /// <summary>Gets a single origami model, including its fold steps, by id.</summary>
        [HttpGet("{id:int}")]
        public async Task<ActionResult<OrigamiModelDto>> GetModelById(int id)
        {
            var model = await _modelService.GetModelByIdAsync(id);
            return model is null ? NotFound() : Ok(model);
        }
    }
}
