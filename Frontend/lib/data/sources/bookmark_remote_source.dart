import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

/// Thrown when a bookmark request fails (e.g. not signed in, or the model
/// doesn't exist).
class BookmarkException implements Exception {
  BookmarkException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Raw REST client for the Backend ASP.NET Core API's per-user bookmark
/// endpoints (`Backend/Controllers/BookmarksController.cs`). Every call needs
/// the signed-in user's JWT — there is no public bookmark data.
class BookmarkRemoteSource {
  BookmarkRemoteSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<dynamic>> fetchFavorites(String token) async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/api/bookmarks/favorites'),
      headers: _authHeaders(token),
    );
    _checkOk(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> addFavorite(String token, int modelId) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/bookmarks/favorites/$modelId'),
      headers: _authHeaders(token),
    );
    _checkOk(response);
  }

  Future<void> removeFavorite(String token, int modelId) async {
    final response = await _client.delete(
      Uri.parse('$apiBaseUrl/api/bookmarks/favorites/$modelId'),
      headers: _authHeaders(token),
    );
    _checkOk(response);
  }

  Future<List<dynamic>> fetchInProgress(String token) async {
    final response = await _client.get(
      Uri.parse('$apiBaseUrl/api/bookmarks/in-progress'),
      headers: _authHeaders(token),
    );
    _checkOk(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> upsertProgress(
    String token,
    int modelId, {
    required int currentStep,
    int? accumulatedTimeSeconds,
    bool completed = false,
  }) async {
    final response = await _client.put(
      Uri.parse('$apiBaseUrl/api/bookmarks/progress/$modelId'),
      headers: {..._authHeaders(token), 'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentStep': currentStep,
        'accumulatedTimeSeconds': accumulatedTimeSeconds,
        'completed': completed,
      }),
    );
    _checkOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> removeProgress(String token, int modelId) async {
    final response = await _client.delete(
      Uri.parse('$apiBaseUrl/api/bookmarks/progress/$modelId'),
      headers: _authHeaders(token),
    );
    _checkOk(response);
  }

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  void _checkOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookmarkException(
        'Request failed with status ${response.statusCode}',
      );
    }
  }
}
