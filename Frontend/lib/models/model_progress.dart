import 'origami_model.dart';

/// A model's saved resume point, as returned by
/// `GET /api/bookmarks/in-progress` (`Backend/DTOs/Bookmarks/ProgressDto.cs`).
class ModelProgress {
  const ModelProgress({
    required this.model,
    required this.currentStep,
    required this.totalSteps,
    required this.completed,
    required this.lastSessionDate,
    this.expGained = 0,
    this.newExp = 0,
    this.newLevel = 0,
  });

  final OrigamiModel model;
  final int currentStep;
  final int totalSteps;
  final bool completed;
  final DateTime lastSessionDate;
  final int expGained;
  final int newExp;
  final int newLevel;

  double get progress => totalSteps == 0 ? 0 : currentStep / totalSteps;

  factory ModelProgress.fromJson(Map<String, dynamic> json) {
    return ModelProgress(
      model: OrigamiModel.fromJson(json['model'] as Map<String, dynamic>),
      currentStep: json['currentStep'] as int? ?? 1,
      totalSteps: json['totalSteps'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      lastSessionDate:
          DateTime.tryParse(json['lastSessionDate'] as String? ?? '') ??
          DateTime.now(),
      expGained: json['expGained'] as int? ?? 0,
      newExp: json['newExp'] as int? ?? 0,
      newLevel: json['newLevel'] as int? ?? 0,
    );
  }
}
