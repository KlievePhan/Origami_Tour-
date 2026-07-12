import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user_profile.dart';
import '../sources/auth_remote_source.dart';

/// Result of a successful login/register call.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.displayName,
    required this.email,
  });

  final String token;
  final String userId;
  final String displayName;
  final String email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
    );
  }
}

/// Owns the signed-in session: talks to [AuthRemoteSource] and persists the
/// JWT in the platform secure store (Keychain/Keystore) so it survives app
/// restarts without living in plaintext `shared_preferences`.
class AuthRepository {
  AuthRepository({AuthRemoteSource? remoteSource, FlutterSecureStorage? storage})
    : _remote = remoteSource ?? AuthRemoteSource(),
      _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  final AuthRemoteSource _remote;
  final FlutterSecureStorage _storage;

  Future<void> sendRegisterOtp(String email) {
    return _remote.sendRegisterOtp(email);
  }

  Future<AuthSession> verifyRegisterOtp({
    required String displayName,
    required String email,
    required String password,
    required String otp,
  }) async {
    final json = await _remote.verifyRegisterOtp(
      displayName: displayName,
      email: email,
      password: password,
      otp: otp,
    );
    final session = AuthSession.fromJson(json);
    await _storage.write(key: _tokenKey, value: session.token);
    return session;
  }

  Future<void> sendRecoveryOtp(String email) {
    return _remote.sendRecoveryOtp(email);
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _remote.verifyRecoveryOtp(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _remote.login(email: email, password: password);
    final session = AuthSession.fromJson(json);
    await _storage.write(key: _tokenKey, value: session.token);
    return session;
  }

  Future<AuthSession> googleLogin(String idToken) async {
    final json = await _remote.googleLogin(idToken);
    final session = AuthSession.fromJson(json);
    await _storage.write(key: _tokenKey, value: session.token);
    return session;
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);

  /// The currently stored JWT, or `null` if signed out — used by other
  /// repositories (e.g. [BookmarkRepository]) to attach the `Authorization`
  /// header to their own requests.
  Future<String?> currentToken() => _storage.read(key: _tokenKey);

  /// Restores the current user's profile from a previously stored token, or
  /// `null` if there is no token / it has expired.
  Future<UserProfile?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;
    try {
      final json = await _remote.me(token);
      return UserProfile.fromJson(json);
    } on Exception {
      await logout();
      return null;
    }
  }
}
