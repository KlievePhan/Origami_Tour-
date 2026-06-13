import 'package:flutter/foundation.dart';

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
}
