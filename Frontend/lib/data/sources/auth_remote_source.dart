import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

class AuthException implements Exception {
  AuthException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join(' ');
}

class AuthRemoteSource {
  AuthRemoteSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> sendRegisterOtp(String email) async {
    await _post('/api/auth/register/send-otp', {'email': email});
  }

  Future<Map<String, dynamic>> verifyRegisterOtp({
    required String displayName,
    required String email,
    required String password,
    required String otp,
  }) async {
    return _post('/api/auth/register/verify', {
      'registerDto': {
        'displayName': displayName,
        'email': email,
        'password': password,
      },
      'otp': otp,
    });
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _post('/api/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) {
    return _post('/api/auth/google-login', {'idToken': idToken});
  }

  Future<void> sendRecoveryOtp(String email) async {
    await _post('/api/auth/recover/send-otp', {'email': email});
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _post('/api/auth/recover/verify', {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
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
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // If there is no response body (e.g. 200 OK for SendRegisterOtp)
    if (response.body.isEmpty) {
      if (response.statusCode >= 400) {
        throw AuthException(['Something went wrong.']);
      }
      return {};
    }

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
