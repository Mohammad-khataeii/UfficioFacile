import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  });
  Future<AuthUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo});
  Future<void> updatePassword(String newPassword);
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs) {
    final cached = _prefs.getString(_storageKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final json = Map<String, dynamic>.from(jsonDecode(cached) as Map);
        _currentUser = AuthUser(
          id: json['id'] as String? ?? '',
          email: json['email'] as String? ?? '',
          isAnonymous: false,
        );
      } catch (_) {}
    }
  }

  static const _storageKey = 'ufficiofacile_local_auth_user_v1';

  final SharedPreferences _prefs;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const AuthFailure('Enter your email and password.');
    }
    final user = AuthUser(
      id: email.trim().toLowerCase(),
      email: email.trim(),
      isAnonymous: false,
    );
    _currentUser = user;
    await _prefs.setString(
      _storageKey,
      jsonEncode({'id': user.id, 'email': user.email}),
    );
    _controller.add(user);
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) => signIn(email: email, password: password);

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(_storageKey);
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {
    if (email.trim().isEmpty) {
      throw const AuthFailure('Enter your email first.');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    if (_currentUser == null) {
      throw const AuthFailure('Sign in before changing your password.');
    }
    if (newPassword.trim().length < 8) {
      throw const AuthFailure('Choose a stronger password.');
    }
  }
}
