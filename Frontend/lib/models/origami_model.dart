import 'fold_step.dart';

/// Relative folding difficulty of an [OrigamiModel] (CLAUDE.md §6).
enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);

  final String label;
}

/// An origami model and its folding tutorial (CLAUDE.md §6).
class OrigamiModel {
  const OrigamiModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.steps,
    this.author = 'Origami Tour',
    this.paperSize = '15cm x 15cm',
    this.ratingAvg = 4.5,
    this.ratingCount = 0,
    this.completionCount = 0,
  });

  final String id;
  final String name;
  final String author;
  final String thumbnail;
  final String paperSize;
  final String description;
  final String category;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final List<FoldStep> steps;
  final double ratingAvg;
  final int ratingCount;
  final int completionCount;

  /// Builds a model with a generated set of placeholder folding steps.
  ///
  /// TODO(agent): replace with real model + step data from
  /// CollectionProvider/BookmarkProvider once they exist (CLAUDE.md §7).
  factory OrigamiModel.placeholder({
    required String id,
    required String name,
    required String thumbnail,
    required Difficulty difficulty,
    required int estimatedMinutes,
    int totalSteps = 12,
    String description =
        'A traditional origami project. Follow each fold carefully to '
        'bring this design to life.',
    String category = 'Models',
    double ratingAvg = 4.5,
    int ratingCount = 128,
    int completionCount = 312,
  }) {
    return OrigamiModel(
      id: id,
      name: name,
      thumbnail: thumbnail,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      ratingAvg: ratingAvg,
      ratingCount: ratingCount,
      completionCount: completionCount,
      steps: List.generate(totalSteps, (i) {
        final foldType = FoldType.values[i % (FoldType.values.length - 1)];
        return FoldStep(
          index: i + 1,
          diagramAsset: 'https://placehold.co/362x362',
          foldType: foldType,
          instruction:
              'Step ${i + 1}: perform a ${foldType.label.toLowerCase()} '
              'as shown in the diagram.',
          tip: i.isEven
              ? 'Keep your creases sharp and aligned with the edges.'
              : null,
        );
      }),
    );
  }
}
