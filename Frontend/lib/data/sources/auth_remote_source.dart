import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

/// Thrown when the API rejects a register/login request (4xx), carrying the
/// human-readable error messages from the response body.
class AuthException implements Exception {
  AuthException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join(' ');
}

/// Raw REST client for the Backend ASP.NET Core API's auth endpoints
/// (`Backend/Controllers/AuthController.cs`).
class AuthRemoteSource {
  AuthRemoteSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> register({
    required String displayName,
    required String email,
    required String password,
  }) {
    return _post('/api/auth/register', {
      'displayName': displayName,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _post('/api/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> me(String token) async {
    final uri = Uri.parse('$apiBaseUrl/api/auth/me');
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw AuthException(['Session expired. Please log in again.']);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final errors = (decoded['errors'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      throw AuthException(errors.isEmpty ? ['Something went wrong.'] : errors);
    }
    return decoded;
  }
}
