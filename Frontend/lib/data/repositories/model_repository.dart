import '../../models/origami_model.dart';
import '../sources/remote_source.dart';

/// Read-only catalog of origami models, backed by the ASP.NET Core API
/// (`GET /api/models`, `Backend/Controllers/ModelsController.cs`).
class ModelRepository {
  ModelRepository({RemoteSource? remoteSource})
    : _remote = remoteSource ?? RemoteSource();

  final RemoteSource _remote;

  /// Fetches all models (with their fold steps), optionally filtered by
  /// category and/or difficulty.
  Future<List<OrigamiModel>> getModels({
    int? categoryId,
    Difficulty? difficulty,
  }) async {
    final json = await _remote.fetchModels(
      categoryId: categoryId,
      difficulty: difficulty?.label,
    );
    return json
        .map((m) => OrigamiModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}
