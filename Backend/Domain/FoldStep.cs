namespace Backend.Domain
{
    public class FoldStep
    {
        public int Id { get; set; }
        public int ModelId { get; set; }
        public OrigamiModel Model { get; set; } = null!;
        public int StepOrder { get; set; }          // 1-based
        public string DiagramUrl { get; set; } = string.Empty;
        public string? AnimationUrl { get; set; }   // optional GIF/animation
        public string Instruction { get; set; } = string.Empty;
        public FoldType FoldType { get; set; }
    }
}
