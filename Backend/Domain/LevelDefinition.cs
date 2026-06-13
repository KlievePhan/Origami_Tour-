namespace Backend.Domain
{
    // Config table — makes the rank ladder data-driven.
    // Current rank = LevelDefinition[user.Level].RankTitle.
    // Next rank   = first level above with a different RankTitle.
    // expForNextLevel = LevelDefinition[user.Level + 1].RequiredExp - user.Exp.
    public class LevelDefinition
    {
        public int Level { get; set; }            // PK, 1..N
        public int RequiredExp { get; set; }      // cumulative EXP to REACH this level
        public string RankTitle { get; set; } = string.Empty;  // rank name shown at this level
    }
}
