import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

/// Raw REST client for the Backend ASP.NET Core API's model catalog
/// (`Backend/Controllers/ModelsController.cs`).
class RemoteSource {
  RemoteSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// `GET /api/models`, optionally filtered by category and/or difficulty.
  Future<List<dynamic>> fetchModels({int? categoryId, String? difficulty}) async {
    final query = <String, String>{
      if (categoryId != null) 'categoryId': '$categoryId',
      if (difficulty != null) 'difficulty': difficulty,
    };
    final uri = Uri.parse(
      '$apiBaseUrl/api/models',
    ).replace(queryParameters: query.isEmpty ? null : query);

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'GET ${uri.path} failed with status ${response.statusCode}',
      );
    }
    return jsonDecode(response.body) as List<dynamic>;
  }
}
