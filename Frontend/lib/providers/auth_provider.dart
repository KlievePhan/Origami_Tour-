import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../data/sources/auth_remote_source.dart';
import '../models/user_profile.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

/// Holds the signed-in session and orchestrates login/register/logout
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  AuthStatus status = AuthStatus.unknown;
  UserProfile? currentUser;

  /// Tries to restore a previously saved session (app startup). Always
  /// resolves to either [AuthStatus.authenticated] or
  /// [AuthStatus.unauthenticated].
  Future<void> restoreSession() async {
    final profile = await _repository.restoreSession();
    currentUser = profile;
    status = profile == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  /// Returns an error message on failure, or `null` on success.
  Future<String?> login({required String email, required String password}) {
    return _run(() => _repository.login(email: email, password: password));
  }

  Future<String?> googleLogin(String idToken) {
    return _run(() => _repository.googleLogin(idToken));
  }

  Future<String?> sendRegisterOtp(String email) async {
    try {
      await _repository.sendRegisterOtp(email);
      return null;
    } on AuthException catch (e) {
      return e.toString();
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> verifyRegisterOtp({
    required String displayName,
    required String email,
    required String password,
    required String otp,
  }) {
    return _run(
      () => _repository.verifyRegisterOtp(
        displayName: displayName,
        email: email,
        password: password,
        otp: otp,
      ),
    );
  }

  Future<String?> sendRecoveryOtp(String email) async {
    try {
      await _repository.sendRecoveryOtp(email);
      return null;
    } on AuthException catch (e) {
      return e.toString();
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> verifyRecoveryOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _repository.verifyRecoveryOtp(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return null;
    } on AuthException catch (e) {
      return e.toString();
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> _run(Future<AuthSession> Function() action) async {
    status = AuthStatus.authenticating;
    notifyListeners();
    try {
      final session = await action();
      currentUser = UserProfile(
        id: session.userId,
        displayName: session.displayName,
        email: session.email,
      );
      status = AuthStatus.authenticated;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return e.toString();
    } catch (e) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return 'An unexpected error occurred.';
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
