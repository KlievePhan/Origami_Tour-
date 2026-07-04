import '../../models/model_progress.dart';
import '../../models/origami_model.dart';
import '../sources/bookmark_remote_source.dart';
import 'auth_repository.dart';

/// Per-user favorites and in-progress fold tracking, backed by the ASP.NET
/// Core API (`Backend/Controllers/BookmarksController.cs`). Every call needs
/// the signed-in user's JWT, read from [AuthRepository]'s secure storage.
class BookmarkRepository {
  BookmarkRepository({
    BookmarkRemoteSource? remoteSource,
    AuthRepository? authRepository,
  }) : _remote = remoteSource ?? BookmarkRemoteSource(),
       _auth = authRepository ?? AuthRepository();

  final BookmarkRemoteSource _remote;
  final AuthRepository _auth;

  Future<String> _requireToken() async {
    final token = await _auth.currentToken();
    if (token == null) {
      throw BookmarkException('You must be signed in to use bookmarks.');
    }
    return token;
  }

  Future<List<OrigamiModel>> getFavorites() async {
    final token = await _requireToken();
    final json = await _remote.fetchFavorites(token);
    return json
        .map(
          (f) => OrigamiModel.fromJson(
            (f as Map<String, dynamic>)['model'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addFavorite(int modelId) async {
    final token = await _requireToken();
    await _remote.addFavorite(token, modelId);
  }

  Future<void> removeFavorite(int modelId) async {
    final token = await _requireToken();
    await _remote.removeFavorite(token, modelId);
  }

  Future<List<ModelProgress>> getInProgress() async {
    final token = await _requireToken();
    final json = await _remote.fetchInProgress(token);
    return json
        .map((p) => ModelProgress.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<ModelProgress> upsertProgress(
    int modelId, {
    required int currentStep,
    int? accumulatedTimeSeconds,
    bool completed = false,
  }) async {
    final token = await _requireToken();
    final json = await _remote.upsertProgress(
      token,
      modelId,
      currentStep: currentStep,
      accumulatedTimeSeconds: accumulatedTimeSeconds,
      completed: completed,
    );
    return ModelProgress.fromJson(json);
  }

  Future<void> removeProgress(int modelId) async {
    final token = await _requireToken();
    await _remote.removeProgress(token, modelId);
  }
}
