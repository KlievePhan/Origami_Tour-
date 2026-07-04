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
  });

  final OrigamiModel model;
  final int currentStep;
  final int totalSteps;
  final bool completed;
  final DateTime lastSessionDate;

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
    );
  }
}
