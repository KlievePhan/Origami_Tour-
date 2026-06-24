-- ============================================================================
-- OrigamiDB — Full Seed Script (All 12 Models)
-- Runs as a single transaction. Drops and re-inserts every model listed below.
-- Safe to re-run: existing rows are deleted first (cascades to FoldSteps and
-- ModelCategories automatically via ON DELETE CASCADE).
-- ============================================================================
-- Models included:
--   Easy   : Water Bomb Base, Blinzt Base, Diamond Base,
--             Fish Base, Rabbit Ear Fold, Frog Base
--   Medium : The Cross Shield, The Simple Flower,
--             The Baby Chick in Egg, The Sleeping Rabbit
--   Hard   : The 8 Petal Flower, The Heart Bookmark
-- ============================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

-- ============================================================================
-- 0. RESOLVE CATEGORY IDs (fail fast if Categories not seeded)
-- ============================================================================
DECLARE @CatModular  INT = (SELECT Id FROM Categories WHERE Slug = N'modular');
DECLARE @CatAnimals  INT = (SELECT Id FROM Categories WHERE Slug = N'animals');
DECLARE @CatFlowers  INT = (SELECT Id FROM Categories WHERE Slug = N'flowers');
DECLARE @CatObjects  INT = (SELECT Id FROM Categories WHERE Slug = N'objects');

IF @CatModular IS NULL OR @CatAnimals IS NULL
   OR @CatFlowers IS NULL OR @CatObjects IS NULL
BEGIN
    RAISERROR('One or more required categories (modular/animals/flowers/objects) not found. Seed Categories first.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
END

-- ============================================================================
-- 1. DROP EXISTING ROWS  (FoldSteps + ModelCategories cascade automatically)
-- ============================================================================
DELETE FROM Models WHERE Name IN (
    N'Water Bomb Base', N'Blinzt Base',    N'Diamond Base',
    N'Fish Base',       N'Rabbit Ear Fold',N'Frog Base',
    N'The Cross Shield',N'The Simple Flower',
    N'The Baby Chick in Egg', N'The Sleeping Rabbit',
    N'The 8 Petal Flower',    N'The Heart Bookmark'
) AND Author = N'Traditional';

-- ============================================================================
-- 2. INSERT MODELS + STEPS
--    Pattern per model:
--      a) INSERT INTO Models … → capture SCOPE_IDENTITY() into @Mid
--      b) INSERT INTO ModelCategories
--      c) INSERT INTO FoldSteps (bulk VALUES)
-- ============================================================================

DECLARE @Mid INT;   -- reused for every model

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.01  WATER BOMB BASE  (Easy / Modular / 16 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Water Bomb Base', N'Traditional',
    N'/diagrams/Easy/BallonBase/thumb.jpg', N'/diagrams/Easy/BallonBase/thumb.jpg',
    N'Easy', 5, N'15x15 cm, square paper',
    N'Learn how to fold an origami water bomb base (sometimes called a balloon base)! '
  + N'This origami model is the base for many different origamis, it will definitely become '
  + N'a very useful base to commit to your memory. The origami balloon base is named after '
  + N'the traditional origami water balloon / water bomb model.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatModular);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Easy/BallonBase/1.jpg',  NULL, N'This is the back of the paper (usually white).',                      N'Other'),
(@Mid,  2, N'/diagrams/Easy/BallonBase/2.jpg',  NULL, N'This is the front of the paper.',                                     N'Other'),
(@Mid,  3, N'/diagrams/Easy/BallonBase/3.jpg',  NULL, N'Fold the bottom edge of the paper up to the top edge.',               N'Valley'),
(@Mid,  4, N'/diagrams/Easy/BallonBase/4.jpg',  NULL, N'Unfold the previous step.',                                           N'Other'),
(@Mid,  5, N'/diagrams/Easy/BallonBase/5.jpg',  NULL, N'Fold the right edge over to the left edge.',                          N'Valley'),
(@Mid,  6, N'/diagrams/Easy/BallonBase/6.jpg',  NULL, N'Unfold the previous step.',                                           N'Other'),
(@Mid,  7, N'/diagrams/Easy/BallonBase/7.jpg',  NULL, N'Rotate the paper.',                                                   N'Other'),
(@Mid,  8, N'/diagrams/Easy/BallonBase/8.jpg',  NULL, N'Flip the paper over to the other side.',                              N'Other'),
(@Mid,  9, N'/diagrams/Easy/BallonBase/9.jpg',  NULL, N'Fold the bottom corner up to the top corner.',                        N'Valley'),
(@Mid, 10, N'/diagrams/Easy/BallonBase/10.jpg', NULL, N'Unfold the previous step.',                                           N'Other'),
(@Mid, 11, N'/diagrams/Easy/BallonBase/11.jpg', NULL, N'Fold the right corner over to the left corner.',                      N'Valley'),
(@Mid, 12, N'/diagrams/Easy/BallonBase/12.jpg', NULL, N'Unfold the previous step.',                                           N'Other'),
(@Mid, 13, N'/diagrams/Easy/BallonBase/13.jpg', NULL, N'Rotate the paper.',                                                   N'Other'),
(@Mid, 14, N'/diagrams/Easy/BallonBase/14.jpg', NULL, N'Bring the left and right edges towards you.',                         N'Squash'),
(@Mid, 15, N'/diagrams/Easy/BallonBase/15.jpg', NULL, N'Flatten the top layer, squashing the left and right corners inside.', N'Squash'),
(@Mid, 16, N'/diagrams/Easy/BallonBase/16.jpg', NULL, N'The finished water bomb base.',                                       N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.02  BLINZT BASE  (Easy / Modular / 8 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Blinzt Base', N'Traditional',
    N'/diagrams/Easy/BlinztBase/thumb.jpg', N'/diagrams/Easy/BlinztBase/thumb.jpg',
    N'Easy', 3, N'15x15 cm, square paper',
    N'Learn how to fold an origami blintz base. This simple origami base folding technique '
  + N'is the beginning of many origami boxes and other models. If you have folded an origami '
  + N'blintz box (origami masu box) then you''ve already folded this origami base.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatModular);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid, 1, N'/diagrams/Easy/BlinztBase/1.jpg', NULL, N'This is the front of the paper, our blintz base will be this colour.', N'Other'),
(@Mid, 2, N'/diagrams/Easy/BlinztBase/2.jpg', NULL, N'Fold the bottom edge up to the top edge.',                             N'Valley'),
(@Mid, 3, N'/diagrams/Easy/BlinztBase/3.jpg', NULL, N'Unfold the previous step.',                                            N'Other'),
(@Mid, 4, N'/diagrams/Easy/BlinztBase/4.jpg', NULL, N'Fold the right edge over to the left edge.',                           N'Valley'),
(@Mid, 5, N'/diagrams/Easy/BlinztBase/5.jpg', NULL, N'Unfold the previous step.',                                            N'Other'),
(@Mid, 6, N'/diagrams/Easy/BlinztBase/6.jpg', NULL, N'Flip the paper over to the other side.',                               N'Other'),
(@Mid, 7, N'/diagrams/Easy/BlinztBase/7.jpg', NULL, N'Fold one of the corners to the middle.',                               N'Valley'),
(@Mid, 8, N'/diagrams/Easy/BlinztBase/8.jpg', NULL, N'Fold the rest of the corners to the center.',                          N'Valley');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.03  DIAMOND BASE  (Easy / Modular / 8 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Diamond Base', N'Traditional',
    N'/diagrams/Easy/DiamondBase/thumb.jpg', N'/diagrams/Easy/DiamondBase/thumb.jpg',
    N'Easy', 3, N'15x15 cm, square paper',
    N'Learn how to make an origami diamond base. This easy origami base fold is used to make '
  + N'many different origami models. The origami diamond base starts off with the origami kite '
  + N'fold technique. It''s very easy to make and has just five creases!',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatModular);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid, 1, N'/diagrams/Easy/DiamondBase/1.jpg', NULL, N'This is the back of the paper (usually white).',                                        N'Other'),
(@Mid, 2, N'/diagrams/Easy/DiamondBase/2.jpg', NULL, N'Take the bottom corner and fold it up to the top corner to create a central crease.',    N'Valley'),
(@Mid, 3, N'/diagrams/Easy/DiamondBase/3.jpg', NULL, N'Unfold the previous step.',                                                              N'Other'),
(@Mid, 4, N'/diagrams/Easy/DiamondBase/4.jpg', NULL, N'Take the bottom right diagonal edge and fold it up to align with the central crease.',   N'Valley'),
(@Mid, 5, N'/diagrams/Easy/DiamondBase/5.jpg', NULL, N'Fold the top right diagonal edge to also align with the central crease.',                N'Valley'),
(@Mid, 6, N'/diagrams/Easy/DiamondBase/6.jpg', NULL, N'Next take the bottom left diagonal edge and fold it to align with the central crease.',  N'Valley'),
(@Mid, 7, N'/diagrams/Easy/DiamondBase/7.jpg', NULL, N'Again, take the top left diagonal edge and fold to align with the central crease.',      N'Valley'),
(@Mid, 8, N'/diagrams/Easy/DiamondBase/8.jpg', NULL, N'Rotate the paper, this is a completed origami diamond base.',                           N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.04  FISH BASE  (Easy / Animals / 14 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Fish Base', N'Traditional',
    N'/diagrams/Easy/FishBase/thumb.jpg', N'/diagrams/Easy/FishBase/thumb.jpg',
    N'Easy', 5, N'15x15 cm, square paper',
    N'Learn how to fold an origami fish base. This origami base is used to create many fish '
  + N'origami models, as well as others.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatAnimals);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Easy/FishBase/1.jpg',  NULL, N'This is the front of the paper.',                                                          N'Other'),
(@Mid,  2, N'/diagrams/Easy/FishBase/2.jpg',  NULL, N'This is the back of the paper (usually white).',                                           N'Other'),
(@Mid,  3, N'/diagrams/Easy/FishBase/3.jpg',  NULL, N'Fold the bottom corner up to the top corner.',                                             N'Valley'),
(@Mid,  4, N'/diagrams/Easy/FishBase/4.jpg',  NULL, N'Unfold the previous step.',                                                                N'Other'),
(@Mid,  5, N'/diagrams/Easy/FishBase/5.jpg',  NULL, N'Fold the bottom right diagonal edge up to align with the central horizontal crease.',      N'Valley'),
(@Mid,  6, N'/diagrams/Easy/FishBase/6.jpg',  NULL, N'Fold the top right diagonal edge down to align with the central horizontal crease.',       N'Valley'),
(@Mid,  7, N'/diagrams/Easy/FishBase/7.jpg',  NULL, N'Flip the model over, keeping the narrow end on the right.',                                N'Other'),
(@Mid,  8, N'/diagrams/Easy/FishBase/8.jpg',  NULL, N'Fold the right corner over to the left corner.',                                          N'Valley'),
(@Mid,  9, N'/diagrams/Easy/FishBase/9.jpg',  NULL, N'Flip the model over to the other side, keeping the point on the left.',                   N'Other'),
(@Mid, 10, N'/diagrams/Easy/FishBase/10.jpg', NULL, N'Open out the lower section.',                                                             N'Squash'),
(@Mid, 11, N'/diagrams/Easy/FishBase/11.jpg', NULL, N'Pull the lower section to the right until it becomes a point and flatten.',               N'Squash'),
(@Mid, 12, N'/diagrams/Easy/FishBase/12.jpg', NULL, N'Repeat the last step on the top section.',                                               N'Squash'),
(@Mid, 13, N'/diagrams/Easy/FishBase/13.jpg', NULL, N'Bring the layer from behind out to the right.',                                          N'Other'),
(@Mid, 14, N'/diagrams/Easy/FishBase/14.jpg', NULL, N'Flatten the front flaps. The origami fish base is complete.',                            N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.05  RABBIT EAR FOLD  (Easy / Animals / 9 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Rabbit Ear Fold', N'Traditional',
    N'/diagrams/Easy/RabbitEarFold/thumb.jpg', N'/diagrams/Easy/RabbitEarFold/thumb.jpg',
    N'Easy', 4, N'15x15 cm, square paper',
    N'The rabbit ear fold is a common origami technique which collapses the paper and then '
  + N'gives a new flap or "ear" at the front. The origami rabbit ear fold is used a lot in '
  + N'origami fish models!',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatAnimals);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid, 1, N'/diagrams/Easy/RabbitEarFold/1.jpg', NULL, N'Start with your paper like this.',                                                              N'Other'),
(@Mid, 2, N'/diagrams/Easy/RabbitEarFold/2.jpg', NULL, N'Fold the top point down to the bottom point.',                                                  N'Valley'),
(@Mid, 3, N'/diagrams/Easy/RabbitEarFold/3.jpg', NULL, N'Unfold the previous step.',                                                                     N'Other'),
(@Mid, 4, N'/diagrams/Easy/RabbitEarFold/4.jpg', NULL, N'Take the top right diagonal edge and fold it down, aligning with the crease you made in step 2.', N'Valley'),
(@Mid, 5, N'/diagrams/Easy/RabbitEarFold/5.jpg', NULL, N'Unfold the previous step.',                                                                     N'Other'),
(@Mid, 6, N'/diagrams/Easy/RabbitEarFold/6.jpg', NULL, N'Repeat the same fold on the top left diagonal edge.',                                           N'Valley'),
(@Mid, 7, N'/diagrams/Easy/RabbitEarFold/7.jpg', NULL, N'Unfold the previous step.',                                                                     N'Other'),
(@Mid, 8, N'/diagrams/Easy/RabbitEarFold/8.jpg', NULL, N'Create a new vertical valley fold at the top whilst pushing top left and right edges forward.',  N'Valley'),
(@Mid, 9, N'/diagrams/Easy/RabbitEarFold/9.jpg', NULL, N'Flatten the paper like this.',                                                                  N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.06  FROG BASE  (Easy / Animals / 17 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'Frog Base', N'Traditional',
    N'/diagrams/Easy/FrogBase/thumb.jpg', N'/diagrams/Easy/FrogBase/thumb.jpg',
    N'Easy', 8, N'15x15 cm, square paper',
    N'Learn how to fold an origami frog base, sometimes called a lily base. This origami base '
  + N'fold is the start of many flower models as well as the traditional frog. You will need to '
  + N'start off by folding an origami square base (sometimes called a preliminary base) first.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatAnimals);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Easy/FrogBase/1.jpg',  NULL, N'Start with an origami square base. The open end of the square should be at the top.',  N'Other'),
(@Mid,  2, N'/diagrams/Easy/FrogBase/2.jpg',  NULL, N'Fold the lower right diagonal edge inwards to align with the vertical crease.',        N'Valley'),
(@Mid,  3, N'/diagrams/Easy/FrogBase/3.jpg',  NULL, N'Unfold the previous step.',                                                            N'Other'),
(@Mid,  4, N'/diagrams/Easy/FrogBase/4.jpg',  NULL, N'Fold the right section over to the left, so that you will be able to open it out.',    N'Valley'),
(@Mid,  5, N'/diagrams/Easy/FrogBase/5.jpg',  NULL, N'Open out the flap.',                                                                   N'Squash'),
(@Mid,  6, N'/diagrams/Easy/FrogBase/6.jpg',  NULL, N'Push the middle of the flap so that it becomes flat.',                                 N'Squash'),
(@Mid,  7, N'/diagrams/Easy/FrogBase/7.jpg',  NULL, N'Fold the right section of the new flap you just created over to the left.',            N'Valley'),
(@Mid,  8, N'/diagrams/Easy/FrogBase/8.jpg',  NULL, N'Continue to repeat the same process on all remaining flaps.',                         N'Squash'),
(@Mid,  9, N'/diagrams/Easy/FrogBase/9.jpg',  NULL, N'Next, fold the top right diagonal edge to align with the central crease.',             N'Valley'),
(@Mid, 10, N'/diagrams/Easy/FrogBase/10.jpg', NULL, N'Fold the top left diagonal edge to align with the central crease.',                   N'Valley'),
(@Mid, 11, N'/diagrams/Easy/FrogBase/11.jpg', NULL, N'Unfold the previous steps.',                                                          N'Other'),
(@Mid, 12, N'/diagrams/Easy/FrogBase/12.jpg', NULL, N'To make it easier, bring the bottom point up to the top point and crease.',           N'Valley'),
(@Mid, 13, N'/diagrams/Easy/FrogBase/13.jpg', NULL, N'Unfold the previous crease.',                                                         N'Other'),
(@Mid, 14, N'/diagrams/Easy/FrogBase/14.jpg', NULL, N'Using the creases you just made, open out the top section, pulling it down.',          N'Squash'),
(@Mid, 15, N'/diagrams/Easy/FrogBase/15.jpg', NULL, N'Carefully pull it down to become a point.',                                           N'Squash'),
(@Mid, 16, N'/diagrams/Easy/FrogBase/16.jpg', NULL, N'Fold the new flap upwards.',                                                          N'Valley'),
(@Mid, 17, N'/diagrams/Easy/FrogBase/17.jpg', NULL, N'Repeat the same process for the other 3 sides. Now it is a completed origami frog base.', N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.07  THE CROSS SHIELD  (Medium / Objects / 12 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The Cross Shield', N'Traditional',
    N'/diagrams/Medium/TheCrossShield/thumb.jpg', N'/diagrams/Medium/TheCrossShield/thumb.jpg',
    N'Medium', 5, N'15x15 cm, two-colour square paper',
    N'Learn how to fold a simple origami shield with cross. Can also be a cross or crucifix '
  + N'against a background. This easy origami shield is so easy to make in just a couple of minutes. '
  + N'You will need one sheet of square paper — it would be best to use paper with two different '
  + N'colours on each side such as blue and white. Use this origami cross symbol as a shield or as '
  + N'a religious crucifix design as part of Easter crafts, Christmas or other holiday crafts.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatObjects);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Medium/TheCrossShield/1.jpg',  NULL, N'This is the front of our paper, the background of the shield will end up this colour.',       N'Other'),
(@Mid,  2, N'/diagrams/Medium/TheCrossShield/2.jpg',  NULL, N'This is the back of our origami paper, this colour will become the shape of the cross.',      N'Other'),
(@Mid,  3, N'/diagrams/Medium/TheCrossShield/3.jpg',  NULL, N'Fold the paper up in half.',                                                                  N'Valley'),
(@Mid,  4, N'/diagrams/Medium/TheCrossShield/4.jpg',  NULL, N'Unfold the previous step.',                                                                   N'Other'),
(@Mid,  5, N'/diagrams/Medium/TheCrossShield/5.jpg',  NULL, N'Fold the right side over to the left side.',                                                  N'Valley'),
(@Mid,  6, N'/diagrams/Medium/TheCrossShield/6.jpg',  NULL, N'Unfold the previous step.',                                                                   N'Other'),
(@Mid,  7, N'/diagrams/Medium/TheCrossShield/7.jpg',  NULL, N'Using the creases as guidelines, fold one of the corners to the middle, leaving a small gap.', N'Valley'),
(@Mid,  8, N'/diagrams/Medium/TheCrossShield/8.jpg',  NULL, N'Fold the rest of the corners in to match the first one.',                                     N'Valley'),
(@Mid,  9, N'/diagrams/Medium/TheCrossShield/9.jpg',  NULL, N'Next, fold the top edge over to the back. You can decide upon the positioning of this fold.', N'Mountain'),
(@Mid, 10, N'/diagrams/Medium/TheCrossShield/10.jpg', NULL, N'Fold the left and right sides behind as well.',                                               N'Mountain'),
(@Mid, 11, N'/diagrams/Medium/TheCrossShield/11.jpg', NULL, N'Here is the back of the paper.',                                                              N'Other'),
(@Mid, 12, N'/diagrams/Medium/TheCrossShield/12.jpg', NULL, N'You can fold the top left and right points and the bottom edge behind a little to round out your shield.', N'Mountain');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.08  THE SIMPLE FLOWER  (Medium / Flowers / 20 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The Simple Flower', N'Traditional',
    N'/diagrams/Medium/SimpleFlower/thumb.jpg', N'/diagrams/Medium/SimpleFlower/thumb.jpg',
    N'Medium', 7, N'15x15 cm, two-colour square paper',
    N'Learn how to fold a traditional origami flower. This flower is very simple to make and '
  + N'only takes a couple of minutes! It''s easy to customise the look of this blossom — make '
  + N'curved petals, rounded petals, or a cluster of flowers for a hydrangea.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatFlowers);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Medium/SimpleFlower/1.jpg',  NULL, N'This is the front of our origami paper, our simple flower will have this colour as the petals.',      N'Other'),
(@Mid,  2, N'/diagrams/Medium/SimpleFlower/2.jpg',  NULL, N'This is the back of our origami paper (usually white), our stem will end up this colour.',            N'Other'),
(@Mid,  3, N'/diagrams/Medium/SimpleFlower/3.jpg',  NULL, N'We will fold a square base to start. Fold the bottom right point of the paper diagonally up to the top left corner.', N'Valley'),
(@Mid,  4, N'/diagrams/Medium/SimpleFlower/4.jpg',  NULL, N'Unfold the previous step.',                                                                           N'Other'),
(@Mid,  5, N'/diagrams/Medium/SimpleFlower/5.jpg',  NULL, N'Fold the bottom left point of the paper diagonally up to the top right corner.',                      N'Valley'),
(@Mid,  6, N'/diagrams/Medium/SimpleFlower/6.jpg',  NULL, N'Unfold the previous step.',                                                                           N'Other'),
(@Mid,  7, N'/diagrams/Medium/SimpleFlower/7.jpg',  NULL, N'Flip the paper over to the other side.',                                                              N'Other'),
(@Mid,  8, N'/diagrams/Medium/SimpleFlower/8.jpg',  NULL, N'Fold the right edge over to the left edge.',                                                          N'Valley'),
(@Mid,  9, N'/diagrams/Medium/SimpleFlower/9.jpg',  NULL, N'Unfold the previous step.',                                                                           N'Other'),
(@Mid, 10, N'/diagrams/Medium/SimpleFlower/10.jpg', NULL, N'Fold the bottom edge up to the top edge.',                                                            N'Valley'),
(@Mid, 11, N'/diagrams/Medium/SimpleFlower/11.jpg', NULL, N'Bring the two sides forming a mouth shape, and continue pushing the folds together.',                 N'Squash'),
(@Mid, 12, N'/diagrams/Medium/SimpleFlower/12.jpg', NULL, N'Flatten the paper — this is a completed square base or preliminary base.',                            N'Squash'),
(@Mid, 13, N'/diagrams/Medium/SimpleFlower/13.jpg', NULL, N'Rotate your square base so that the opening is at the top.',                                          N'Other'),
(@Mid, 14, N'/diagrams/Medium/SimpleFlower/14.jpg', NULL, N'Fold the front left and right diagonal edges to the middle as shown.',                                N'Valley'),
(@Mid, 15, N'/diagrams/Medium/SimpleFlower/15.jpg', NULL, N'Flip the paper over from left to right and repeat the last step.',                                    N'Valley'),
(@Mid, 16, N'/diagrams/Medium/SimpleFlower/16.jpg', NULL, N'Fold the top point down to the bottom point, allowing the inner part of the flower to open.',         N'Valley'),
(@Mid, 17, N'/diagrams/Medium/SimpleFlower/17.jpg', NULL, N'Flatten the inner part of the flower to form the petals. You can keep pulling the petals down and apart until there is no more give.', N'Squash'),
(@Mid, 18, N'/diagrams/Medium/SimpleFlower/18.jpg', NULL, N'We folded this flower again, this time without pulling the flower like the previous step.',           N'Other'),
(@Mid, 19, N'/diagrams/Medium/SimpleFlower/19.jpg', NULL, N'You can tuck these little corners behind as shown.',                                                  N'Mountain'),
(@Mid, 20, N'/diagrams/Medium/SimpleFlower/20.jpg', NULL, N'Round the petals by folding them behind.',                                                            N'Mountain');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.09  THE BABY CHICK IN EGG  (Medium / Animals / 19 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The Baby Chick in Egg', N'Traditional',
    N'/diagrams/Medium/BabyChickInEgg/thumb.jpg', N'/diagrams/Medium/BabyChickInEgg/thumb.jpg',
    N'Medium', 8, N'15x15 cm, two-colour square paper (yellow and white recommended)',
    N'Learn how to fold a cute origami baby chick nested in an egg for Easter. Kids will enjoy '
  + N'making this origami Easter craft. This is a simple origami that anyone can complete with '
  + N'one sheet of square paper. This origami chick and egg is not two sheets but one — using '
  + N'origami paper with two different colours such as yellow and white would be preferable.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatAnimals);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Medium/BabyChickInEgg/1.jpg',  NULL, N'This is the back of our origami paper, this colour will be the egg.',                                  N'Other'),
(@Mid,  2, N'/diagrams/Medium/BabyChickInEgg/2.jpg',  NULL, N'This is the front of our origami paper which will be the little chick.',                               N'Other'),
(@Mid,  3, N'/diagrams/Medium/BabyChickInEgg/3.jpg',  NULL, N'Fold the bottom point up to the top point.',                                                           N'Valley'),
(@Mid,  4, N'/diagrams/Medium/BabyChickInEgg/4.jpg',  NULL, N'Unfold the previous step.',                                                                            N'Other'),
(@Mid,  5, N'/diagrams/Medium/BabyChickInEgg/5.jpg',  NULL, N'Fold the right point over to the left point.',                                                        N'Valley'),
(@Mid,  6, N'/diagrams/Medium/BabyChickInEgg/6.jpg',  NULL, N'Unfold the previous step.',                                                                            N'Other'),
(@Mid,  7, N'/diagrams/Medium/BabyChickInEgg/7.jpg',  NULL, N'Bring the top point down to meet the center of the paper and make a small mark at the top.',           N'Valley'),
(@Mid,  8, N'/diagrams/Medium/BabyChickInEgg/8.jpg',  NULL, N'Unfold the previous step.',                                                                            N'Other'),
(@Mid,  9, N'/diagrams/Medium/BabyChickInEgg/9.jpg',  NULL, N'Next, fold the bottom point up to the little mark you made in the previous step.',                     N'Valley'),
(@Mid, 10, N'/diagrams/Medium/BabyChickInEgg/10.jpg', NULL, N'Fold the left and right sides in to the middle.',                                                      N'Valley'),
(@Mid, 11, N'/diagrams/Medium/BabyChickInEgg/11.jpg', NULL, N'Flip the paper over to the other side.',                                                               N'Other'),
(@Mid, 12, N'/diagrams/Medium/BabyChickInEgg/12.jpg', NULL, N'Fold the upper left and right edges diagonally in to meet in the middle.',                             N'Valley'),
(@Mid, 13, N'/diagrams/Medium/BabyChickInEgg/13.jpg', NULL, N'Fold the top point diagonally down as shown.',                                                         N'Valley'),
(@Mid, 14, N'/diagrams/Medium/BabyChickInEgg/14.jpg', NULL, N'Fold the point diagonally out to the left, creating the shape of a little beak.',                      N'Reverse'),
(@Mid, 15, N'/diagrams/Medium/BabyChickInEgg/15.jpg', NULL, N'Flip the paper over to the other side.',                                                               N'Other'),
(@Mid, 16, N'/diagrams/Medium/BabyChickInEgg/16.jpg', NULL, N'Bring the right part of the egg out to the right.',                                                    N'Squash'),
(@Mid, 17, N'/diagrams/Medium/BabyChickInEgg/17.jpg', NULL, N'Next, bring the left side of the egg out to match the right side and flatten the paper.',              N'Squash'),
(@Mid, 18, N'/diagrams/Medium/BabyChickInEgg/18.jpg', NULL, N'You can further shape the chick and the egg on the back so that it''s more rounded.',                 N'Mountain'),
(@Mid, 19, N'/diagrams/Medium/BabyChickInEgg/19.jpg', NULL, N'The origami baby chick in an egg is complete. Cheeep!',                                                N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.10  THE SLEEPING RABBIT  (Medium / Animals / 23 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The Sleeping Rabbit', N'Traditional',
    N'/diagrams/Medium/SleepingRabbit/thumb.jpg', N'/diagrams/Medium/SleepingRabbit/thumb.jpg',
    N'Medium', 10, N'15x15 cm, square paper',
    N'Learn how to fold a traditional origami sleeping rabbit. This easy to intermediate origami '
  + N'bunny rabbit is simple to make from a single sheet of square paper. Kids will really enjoy '
  + N'folding this origami animal model — younger children may find a few steps tricky, so adult '
  + N'help may be needed. You can draw a cute face, and the rabbit can also be propped up as an '
  + N'Easter decoration or glued onto an Easter greetings card.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatAnimals);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Medium/SleepingRabbit/1.jpg',  NULL, N'This is the front of our origami paper, the origami sleeping rabbit will be this colour at the end.',     N'Other'),
(@Mid,  2, N'/diagrams/Medium/SleepingRabbit/2.jpg',  NULL, N'This is the back of our origami paper, which is often white if using origami paper. You will not see this colour in the final model.', N'Other'),
(@Mid,  3, N'/diagrams/Medium/SleepingRabbit/3.jpg',  NULL, N'Fold the paper in half from right to left.',                                                             N'Valley'),
(@Mid,  4, N'/diagrams/Medium/SleepingRabbit/4.jpg',  NULL, N'Unfold the previous step.',                                                                              N'Other'),
(@Mid,  5, N'/diagrams/Medium/SleepingRabbit/5.jpg',  NULL, N'Fold the left and right edges to meet in the middle.',                                                   N'Valley'),
(@Mid,  6, N'/diagrams/Medium/SleepingRabbit/6.jpg',  NULL, N'Fold the top edge down to the bottom edge.',                                                             N'Valley'),
(@Mid,  7, N'/diagrams/Medium/SleepingRabbit/7.jpg',  NULL, N'Unfold the previous step.',                                                                              N'Other'),
(@Mid,  8, N'/diagrams/Medium/SleepingRabbit/8.jpg',  NULL, N'Next, fold the top edge down to meet the crease you made in the previous step.',                         N'Valley'),
(@Mid,  9, N'/diagrams/Medium/SleepingRabbit/9.jpg',  NULL, N'Unfold the previous step.',                                                                              N'Other'),
(@Mid, 10, N'/diagrams/Medium/SleepingRabbit/10.jpg', NULL, N'Open out the right side, pull on the point of the right flap and pull it down to the right.',            N'Squash'),
(@Mid, 11, N'/diagrams/Medium/SleepingRabbit/11.jpg', NULL, N'Flatten the paper to this position.',                                                                    N'Squash'),
(@Mid, 12, N'/diagrams/Medium/SleepingRabbit/12.jpg', NULL, N'Repeat the same process on the left side.',                                                              N'Squash'),
(@Mid, 13, N'/diagrams/Medium/SleepingRabbit/13.jpg', NULL, N'Flip the paper over to the other side.',                                                                 N'Other'),
(@Mid, 14, N'/diagrams/Medium/SleepingRabbit/14.jpg', NULL, N'Fold the top left and right points diagonally down so that you get this arrow shape shown.',             N'Valley'),
(@Mid, 15, N'/diagrams/Medium/SleepingRabbit/15.jpg', NULL, N'Fold the left side over to the right side.',                                                             N'Valley'),
(@Mid, 16, N'/diagrams/Medium/SleepingRabbit/16.jpg', NULL, N'You should now see the rabbit taking shape.',                                                            N'Other'),
(@Mid, 17, N'/diagrams/Medium/SleepingRabbit/17.jpg', NULL, N'Rotate the paper. You can start to see the shape of the sleeping rabbit.',                               N'Other'),
(@Mid, 18, N'/diagrams/Medium/SleepingRabbit/18.jpg', NULL, N'Fold the end of the right point diagonally up to create a tail.',                                        N'Valley'),
(@Mid, 19, N'/diagrams/Medium/SleepingRabbit/19.jpg', NULL, N'Open the paper back to this position.',                                                                  N'Other'),
(@Mid, 20, N'/diagrams/Medium/SleepingRabbit/20.jpg', NULL, N'Reverse fold the tail up inside the rabbit.',                                                            N'Reverse'),
(@Mid, 21, N'/diagrams/Medium/SleepingRabbit/21.jpg', NULL, N'Flatten the paper back up.',                                                                             N'Other'),
(@Mid, 22, N'/diagrams/Medium/SleepingRabbit/22.jpg', NULL, N'You can also fold the rabbit''s nose inside to make it rounded.',                                        N'Reverse'),
(@Mid, 23, N'/diagrams/Medium/SleepingRabbit/23.jpg', NULL, N'If you''d like your origami sleeping rabbit to stand up, make a crease at the neck.',                    N'Valley');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.11  THE 8 PETAL FLOWER  (Hard / Flowers / 32 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The 8 Petal Flower', N'Traditional',
    N'/diagrams/Hard/8PetalFlower/thumb.jpg', N'/diagrams/Hard/8PetalFlower/thumb.jpg',
    N'Hard', 20, N'15x15 cm or larger, thin square paper recommended',
    N'Learn how to fold a beautiful origami flower with eight petals and a stem from a single '
  + N'sheet of square paper. This intermediate traditional origami flower is perfect to make a '
  + N'whole bouquet of paper flowers. This pretty origami flower is quite unique, having 8 petals '
  + N'and being a moderately easy origami model. Please use a large size of origami paper such as '
  + N'15x15 cm or even larger — using thinner paper is also recommended. Having a little stem at '
  + N'the back, you can use this to stand it up as well. When made with red paper this flower '
  + N'makes a perfect Christmas Poinsettia Flower.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatFlowers);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Hard/8PetalFlower/1.jpg',  NULL, N'This is the back of our origami paper which is often white, you will not see this colour on your finished flower.', N'Other'),
(@Mid,  2, N'/diagrams/Hard/8PetalFlower/2.jpg',  NULL, N'This is the front of our origami paper, your flower will end up this colour all over.',                            N'Other'),
(@Mid,  3, N'/diagrams/Hard/8PetalFlower/3.jpg',  NULL, N'Fold the paper in half from left to right. Then rotate the paper and repeat.',                                     N'Valley'),
(@Mid,  4, N'/diagrams/Hard/8PetalFlower/4.jpg',  NULL, N'Flip the paper over to the other side. This time fold the two diagonals.',                                         N'Mountain'),
(@Mid,  5, N'/diagrams/Hard/8PetalFlower/5.jpg',  NULL, N'Push your finger into the middle point to bring the left and right edges inwards and collapse the paper downwards into a triangle shape.', N'Squash'),
(@Mid,  6, N'/diagrams/Hard/8PetalFlower/6.jpg',  NULL, N'Flatten the paper.',                                                                                              N'Squash'),
(@Mid,  7, N'/diagrams/Hard/8PetalFlower/7.jpg',  NULL, N'This is an origami water bomb base.',                                                                             N'Other'),
(@Mid,  8, N'/diagrams/Hard/8PetalFlower/8.jpg',  NULL, N'Fold the front-most left and right flaps diagonally inward to align with the central vertical crease.',            N'Valley'),
(@Mid,  9, N'/diagrams/Hard/8PetalFlower/9.jpg',  NULL, N'Next, fold the two lower flaps upward, aligning with the bottom edge of the triangle.',                            N'Valley'),
(@Mid, 10, N'/diagrams/Hard/8PetalFlower/10.jpg', NULL, N'Unfold the previous step.',                                                                                      N'Other'),
(@Mid, 11, N'/diagrams/Hard/8PetalFlower/11.jpg', NULL, N'Flip the paper over to the other side.',                                                                         N'Other'),
(@Mid, 12, N'/diagrams/Hard/8PetalFlower/12.jpg', NULL, N'Repeat steps 8 to 10 on this side.',                                                                             N'Valley'),
(@Mid, 13, N'/diagrams/Hard/8PetalFlower/13.jpg', NULL, N'Open out the paper to this position.',                                                                           N'Other'),
(@Mid, 14, N'/diagrams/Hard/8PetalFlower/14.jpg', NULL, N'Fold all four corners inward. Then pick up the paper and re-fold the marked lines as mountain folds.',            N'Mountain'),
(@Mid, 15, N'/diagrams/Hard/8PetalFlower/15.jpg', NULL, N'Next re-fold these creases as valley folds.',                                                                    N'Valley'),
(@Mid, 16, N'/diagrams/Hard/8PetalFlower/16.jpg', NULL, N'Start to collapse the paper back into a folded state.',                                                          N'Squash'),
(@Mid, 17, N'/diagrams/Hard/8PetalFlower/17.jpg', NULL, N'Continue to close the paper and position it like this.',                                                         N'Squash'),
(@Mid, 18, N'/diagrams/Hard/8PetalFlower/18.jpg', NULL, N'Fold the lower diagonal edges in to the middle and then unfold.',                                                N'Valley'),
(@Mid, 19, N'/diagrams/Hard/8PetalFlower/19.jpg', NULL, N'Open the paper a little and reverse inside fold the creases you made in the previous step.',                      N'Reverse'),
(@Mid, 20, N'/diagrams/Hard/8PetalFlower/20.jpg', NULL, N'Flatten the paper down again. Repeat this process on all of the other four sides.',                              N'Squash'),
(@Mid, 21, N'/diagrams/Hard/8PetalFlower/21.jpg', NULL, N'When you flip the paper over to repeat the steps, keep this configuration of flaps consistent.',                 N'Other'),
(@Mid, 22, N'/diagrams/Hard/8PetalFlower/22.jpg', NULL, N'Flatten the paper and then fold in half as shown. This step demonstrates the need for thinner paper, as thick paper will not fold easily.', N'Valley'),
(@Mid, 23, N'/diagrams/Hard/8PetalFlower/23.jpg', NULL, N'Next, crease the top point over like this.',                                                                    N'Valley'),
(@Mid, 24, N'/diagrams/Hard/8PetalFlower/24.jpg', NULL, N'Carefully open out the paper to this position.',                                                                N'Other'),
(@Mid, 25, N'/diagrams/Hard/8PetalFlower/25.jpg', NULL, N'Use your finger to pop the centre of the paper inwards.',                                                      N'Reverse'),
(@Mid, 26, N'/diagrams/Hard/8PetalFlower/26.jpg', NULL, N'Close up the paper like this and flatten.',                                                                    N'Squash'),
(@Mid, 27, N'/diagrams/Hard/8PetalFlower/27.jpg', NULL, N'The paper will naturally want to position itself like this — use your fingers to hold it firmly in this position.', N'Other'),
(@Mid, 28, N'/diagrams/Hard/8PetalFlower/28.jpg', NULL, N'Tweak the petal section back further and fold the petals evenly around until it looks like this.',             N'Other'),
(@Mid, 29, N'/diagrams/Hard/8PetalFlower/29.jpg', NULL, N'Now you can start shaping the petals. Use your finger and thumb to push each petal from the back of the model.', N'Other'),
(@Mid, 30, N'/diagrams/Hard/8PetalFlower/30.jpg', NULL, N'Here is a view of the back of the flower whilst it''s being shaped.',                                          N'Other'),
(@Mid, 31, N'/diagrams/Hard/8PetalFlower/31.jpg', NULL, N'Once happy with the petals, carefully pinch the centre of the flower to finalise the folds — using tweezers is recommended.', N'Other'),
(@Mid, 32, N'/diagrams/Hard/8PetalFlower/32.jpg', NULL, N'This is the back of the finished flower. You can also fold a simpler version called the Origami Blossom Flower, which uses the same method minus a few steps.', N'Other');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.12  THE HEART BOOKMARK  (Hard / Objects / 23 steps)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO Models (Name, Author, ThumbnailUrl, HeroUrl, Difficulty, EstimatedMinutes, PaperSize, Description, RatingAvg, RatingCount, CompletionCount, Popularity, CreatedAt)
VALUES (N'The Heart Bookmark', N'Traditional',
    N'/diagrams/Hard/HeartBookmark/thumb.jpg', N'/diagrams/Hard/HeartBookmark/thumb.jpg',
    N'Hard', 10, N'15x7.5 cm rectangular paper (ratio ~1:3), any size works',
    N'This long origami heart bookmark is the perfect gift for friends and family who love to '
  + N'read. Made from 1 sheet of rectangular paper, this origami love heart only takes a few '
  + N'minutes to make. You can use any size of rectangular paper — our paper is about 15x7.5 cm '
  + N'with a ratio of around 1:3.',
    0.00, 0, 0, 0, SYSUTCDATETIME());
SET @Mid = SCOPE_IDENTITY();
INSERT INTO ModelCategories VALUES (@Mid, @CatObjects);
INSERT INTO FoldSteps (ModelId, StepOrder, DiagramUrl, AnimationUrl, Instruction, FoldType) VALUES
(@Mid,  1, N'/diagrams/Hard/HeartBookmark/1.jpg',  NULL, N'This is the front of our origami paper, our origami heart bookmark will end up this colour.',             N'Other'),
(@Mid,  2, N'/diagrams/Hard/HeartBookmark/2.jpg',  NULL, N'This is the back of our origami paper.',                                                                 N'Other'),
(@Mid,  3, N'/diagrams/Hard/HeartBookmark/3.jpg',  NULL, N'Fold the top right corner diagonally down to the left.',                                                 N'Valley'),
(@Mid,  4, N'/diagrams/Hard/HeartBookmark/4.jpg',  NULL, N'Unfold the previous step.',                                                                              N'Other'),
(@Mid,  5, N'/diagrams/Hard/HeartBookmark/5.jpg',  NULL, N'Fold the top left corner diagonally down to the right.',                                                 N'Valley'),
(@Mid,  6, N'/diagrams/Hard/HeartBookmark/6.jpg',  NULL, N'Unfold the previous step and flip the paper over to the other side.',                                    N'Other'),
(@Mid,  7, N'/diagrams/Hard/HeartBookmark/7.jpg',  NULL, N'Fold the top edge of the paper down to meet the end of the diagonal creases you made in the previous steps.', N'Valley'),
(@Mid,  8, N'/diagrams/Hard/HeartBookmark/8.jpg',  NULL, N'Unfold the previous step.',                                                                              N'Other'),
(@Mid,  9, N'/diagrams/Hard/HeartBookmark/9.jpg',  NULL, N'Flip the paper over to the other side.',                                                                 N'Other'),
(@Mid, 10, N'/diagrams/Hard/HeartBookmark/10.jpg', NULL, N'Create a water bomb base at the top by folding the left and right edges inwards and bringing the top edge down.', N'Squash'),
(@Mid, 11, N'/diagrams/Hard/HeartBookmark/11.jpg', NULL, N'Pull the front layer up to the top point, revealing the folds underneath.',                              N'Squash'),
(@Mid, 12, N'/diagrams/Hard/HeartBookmark/12.jpg', NULL, N'Fold the right point down to the middle whilst keeping the paper in place at the top.',                  N'Valley'),
(@Mid, 13, N'/diagrams/Hard/HeartBookmark/13.jpg', NULL, N'Repeat the last step on the left and flatten the paper.',                                                N'Valley'),
(@Mid, 14, N'/diagrams/Hard/HeartBookmark/14.jpg', NULL, N'Fold the right flap over to the left.',                                                                  N'Valley'),
(@Mid, 15, N'/diagrams/Hard/HeartBookmark/15.jpg', NULL, N'Fold the right edge left to align with the middle. Then unfold.',                                        N'Valley'),
(@Mid, 16, N'/diagrams/Hard/HeartBookmark/16.jpg', NULL, N'Create a new diagonal crease where indicated and then fold the right section back in, reverse folding the new diagonal crease.', N'Reverse'),
(@Mid, 17, N'/diagrams/Hard/HeartBookmark/17.jpg', NULL, N'Flatten the paper and then fold the top left flap back over to the right.',                              N'Valley'),
(@Mid, 18, N'/diagrams/Hard/HeartBookmark/18.jpg', NULL, N'Repeat the same process on the left side.',                                                             N'Reverse'),
(@Mid, 19, N'/diagrams/Hard/HeartBookmark/19.jpg', NULL, N'Flip the model over to the other side. Next, fold the top point down.',                                  N'Valley'),
(@Mid, 20, N'/diagrams/Hard/HeartBookmark/20.jpg', NULL, N'Flip the model back over to the other side. Next, shape the top of the heart by folding the top points diagonally down.', N'Valley'),
(@Mid, 21, N'/diagrams/Hard/HeartBookmark/21.jpg', NULL, N'Fold the top two points down a little. Then fold the left and right sides in to the middle.',           N'Mountain'),
(@Mid, 22, N'/diagrams/Hard/HeartBookmark/22.jpg', NULL, N'You can make the bookmark pointed at the bottom if you like.',                                           N'Valley'),
(@Mid, 23, N'/diagrams/Hard/HeartBookmark/23.jpg', NULL, N'The origami heart bookmark is done!',                                                                   N'Other');

-- ============================================================================
-- 3. VERIFY ROW COUNTS
-- ============================================================================
SELECT
    m.Name,
    m.Difficulty,
    COUNT(fs.Id) AS StepCount
FROM Models m
LEFT JOIN FoldSteps fs ON fs.ModelId = m.Id
WHERE m.Author = N'Traditional'
  AND m.Name IN (
      N'Water Bomb Base', N'Blinzt Base',    N'Diamond Base',
      N'Fish Base',       N'Rabbit Ear Fold',N'Frog Base',
      N'The Cross Shield',N'The Simple Flower',
      N'The Baby Chick in Egg', N'The Sleeping Rabbit',
      N'The 8 Petal Flower',    N'The Heart Bookmark')
GROUP BY m.Name, m.Difficulty
ORDER BY m.Difficulty, m.Name;

COMMIT TRANSACTION;

select * from FoldSteps where ModelId = 27