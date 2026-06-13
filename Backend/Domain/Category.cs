namespace Backend.Domain
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;   // "Animals"
        public string Slug { get; set; } = string.Empty;   // "animals"
        public ICollection<ModelCategory> ModelCategories { get; set; } = new List<ModelCategory>();
    }

    public class ModelCategory
    {
        public int ModelId { get; set; }
        public OrigamiModel Model { get; set; } = null!;
        public int CategoryId { get; set; }
        public Category Category { get; set; } = null!;
    }
}
