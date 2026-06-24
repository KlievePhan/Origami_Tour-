import 'package:flutter/foundation.dart';

import '../core/api_config.dart';

/// The kind of fold described by a [FoldStep], shown as the step heading
/// above the diagram in Process View (CLAUDE.md §6).
enum FoldType {
  valley('Valley Fold'),
  mountain('Mountain Fold'),
  squash('Squash Fold'),
  reverse('Reverse Fold'),
  other('Fold');

  const FoldType(this.label);

  /// Display label shown as the step heading.
  final String label;

  /// Matches the `FoldType` enum names returned by the API
  /// (`Valley` | `Mountain` | `Squash` | `Reverse` | `Other`).
  static FoldType fromApiName(String name) {
    return FoldType.values.firstWhere(
      (f) => f.name.toLowerCase() == name.toLowerCase(),
      orElse: () => FoldType.other,
    );
  }
}

/// A single step of an [OrigamiModel]'s folding tutorial (CLAUDE.md §6).
@immutable
class FoldStep {
  const FoldStep({
    required this.index,
    required this.diagramAsset,
    required this.instruction,
    required this.foldType,
    this.animationAsset,
    this.tip,
  });

  /// 1-based position of this step within the tutorial.
  final int index;

  final String diagramAsset;
  final String? animationAsset;
  final String instruction;
  final FoldType foldType;

  /// Optional folding hint shown in the tip card.
  final String? tip;

  /// Builds a [FoldStep] from a `FoldStepDto` returned by
  /// `GET /api/models` (`Backend/DTOs/FoldStepDto.cs`).
  factory FoldStep.fromJson(Map<String, dynamic> json) {
    final animationUrl = json['animationUrl'] as String?;
    return FoldStep(
      index: json['stepOrder'] as int,
      diagramAsset: resolveAssetUrl(json['diagramUrl'] as String? ?? ''),
      animationAsset: animationUrl == null ? null : resolveAssetUrl(animationUrl),
      instruction: json['instruction'] as String? ?? '',
      foldType: FoldType.fromApiName(json['foldType'] as String? ?? ''),
    );
  }
}
