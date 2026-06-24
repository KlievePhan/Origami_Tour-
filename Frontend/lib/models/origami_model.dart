import '../core/api_config.dart';
import 'fold_step.dart';

/// Relative folding difficulty of an [OrigamiModel] (CLAUDE.md §6).
enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);

  final String label;

  /// Matches the `Difficulty` enum values returned by the API
  /// (`Easy` | `Medium` | `Hard`).
  static Difficulty fromApiLabel(String label) {
    return Difficulty.values.firstWhere(
      (d) => d.label == label,
      orElse: () => Difficulty.medium,
    );
  }
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
    this.heroUrl = '',
    this.paperSize = '15cm x 15cm',
    this.ratingAvg = 4.5,
    this.ratingCount = 0,
    this.completionCount = 0,
  });

  final String id;
  final String name;
  final String author;
  final String thumbnail;

  /// Larger hero image for the Model Details screen. Falls back to
  /// [thumbnail] when empty (e.g. for placeholder models).
  final String heroUrl;
  final String paperSize;
  final String description;
  final String category;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final List<FoldStep> steps;
  final double ratingAvg;
  final int ratingCount;
  final int completionCount;

  /// Builds an [OrigamiModel] from an `OrigamiModelDto` returned by
  /// `GET /api/models` (`Backend/DTOs/OrigamiModelDto.cs`).
  factory OrigamiModel.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? const [])
        .map((c) => c.toString())
        .toList();
    final thumbnailUrl = resolveAssetUrl(json['thumbnailUrl'] as String? ?? '');
    return OrigamiModel(
      id: '${json['id']}',
      name: json['name'] as String? ?? '',
      author: json['author'] as String? ?? 'Origami Tour',
      thumbnail: thumbnailUrl,
      heroUrl: resolveAssetUrl(json['heroUrl'] as String? ?? ''),
      paperSize: json['paperSize'] as String? ?? '15cm x 15cm',
      description: json['description'] as String? ?? '',
      category: categories.isNotEmpty ? categories.first : '',
      difficulty: Difficulty.fromApiLabel(json['difficulty'] as String? ?? ''),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      completionCount: json['completionCount'] as int? ?? 0,
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .map((s) => FoldStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

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
          diagramAsset: 'https://placehold.co/362x362.png',
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
