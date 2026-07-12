import 'package:flutter/foundation.dart';

import '../data/repositories/bookmark_repository.dart';
import '../models/model_progress.dart';
import '../models/origami_model.dart';

enum BookmarkLoadStatus { initial, loading, loaded, error }

/// Holds the signed-in user's favorites and in-progress models, and
/// orchestrates add/remove/resume actions against [BookmarkRepository].
class BookmarkProvider extends ChangeNotifier {
  BookmarkProvider({BookmarkRepository? repository})
    : _repository = repository ?? BookmarkRepository();

  final BookmarkRepository _repository;

  BookmarkLoadStatus status = BookmarkLoadStatus.initial;
  String? errorMessage;
  List<OrigamiModel> favorites = [];
  List<ModelProgress> inProgress = [];

  bool isFavorite(String modelId) => favorites.any((m) => m.id == modelId);

  /// Loads both lists from the server. Call after sign-in and whenever the
  /// Bookmark screen is opened.
  Future<void> load() async {
    status = BookmarkLoadStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getFavorites(),
        _repository.getInProgress(),
      ]);
      favorites = results[0] as List<OrigamiModel>;
      inProgress = results[1] as List<ModelProgress>;
      status = BookmarkLoadStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = BookmarkLoadStatus.error;
    }
    notifyListeners();
  }

  /// Clears locally held lists (e.g. on logout) without calling the server.
  void clear() {
    favorites = [];
    inProgress = [];
    status = BookmarkLoadStatus.initial;
    notifyListeners();
  }

  /// Adds or removes [model] from favorites, optimistically updating the UI.
  Future<void> toggleFavorite(OrigamiModel model) async {
    final modelId = int.tryParse(model.id);
    if (modelId == null) return;

    final wasFavorite = isFavorite(model.id);
    favorites = wasFavorite
        ? favorites.where((m) => m.id != model.id).toList()
        : [...favorites, model];
    notifyListeners();

    try {
      if (wasFavorite) {
        await _repository.removeFavorite(modelId);
      } else {
        await _repository.addFavorite(modelId);
      }
    } catch (_) {
      // Roll back on failure.
      favorites = wasFavorite
          ? [...favorites, model]
          : favorites.where((m) => m.id != model.id).toList();
      notifyListeners();
    }
  }

  /// Persists the current fold step as the resume point for [model].
  Future<ModelProgress?> saveProgress(
    OrigamiModel model,
    int currentStep, {
    bool completed = false,
    int? accumulatedTimeSeconds,
  }) async {
    final modelId = int.tryParse(model.id);
    if (modelId == null) return null;

    try {
      final progress = await _repository.upsertProgress(
        modelId,
        currentStep: currentStep,
        completed: completed,
        accumulatedTimeSeconds: accumulatedTimeSeconds,
      );
      inProgress = [
        ...inProgress.where((p) => p.model.id != model.id),
        if (!completed) progress,
      ];
      notifyListeners();
      return progress;
    } catch (_) {
      // Best-effort: progress is also held locally by ProcessViewScreen, so
      // a failed save here doesn't block the user from continuing.
      return null;
    }
  }

  /// Removes [model] from the In Progress list (e.g. once it's completed).
  Future<void> removeProgress(OrigamiModel model) async {
    final modelId = int.tryParse(model.id);
    if (modelId == null) return;

    inProgress = inProgress.where((p) => p.model.id != model.id).toList();
    notifyListeners();

    try {
      await _repository.removeProgress(modelId);
    } catch (_) {
      // Ignore — next load() will reconcile.
    }
  }
}
