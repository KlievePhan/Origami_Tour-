namespace Backend.DTOs
{
    public class FoldStepDto
    {
        public int Id { get; set; }
        public int StepOrder { get; set; }
        public string DiagramUrl { get; set; } = string.Empty;
        public string? AnimationUrl { get; set; }
        public string Instruction { get; set; } = string.Empty;
        public string FoldType { get; set; } = string.Empty;
    }
}
