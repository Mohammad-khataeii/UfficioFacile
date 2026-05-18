import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_user.dart' as app_auth;
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  app_auth.AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return app_auth.AuthUser(
      id: user.id,
      email: user.email ?? '',
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Stream<app_auth.AuthUser?> authStateChanges() =>
      _client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
        return app_auth.AuthUser(
          id: user.id,
          email: user.email ?? '',
          isAnonymous: user.isAnonymous,
        );
      });

  @override
  Future<app_auth.AuthUser> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    try {
      await _signOutIfNeeded();
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: emailRedirectTo,
      );
      final user = response.session?.user;
      if (user == null && response.user != null) {
        return app_auth.AuthUser(
          id: '',
          email: response.user!.email ?? email.trim(),
          isAnonymous: false,
        );
      }
      if (user == null) {
        throw const AuthFailure(
          'We could not create the account. Please check your email and try again.',
        );
      }
      return app_auth.AuthUser(
        id: user.id,
        email: user.email ?? email.trim(),
        isAnonymous: user.isAnonymous,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_humanizeAuthError(error.message));
    } catch (_) {
      throw const AuthFailure(
        'We could not create the account right now. Please try again.',
      );
    }
  }

  @override
  Future<app_auth.AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _signOutIfNeeded();
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.session?.user ?? response.user;
      if (user == null) {
        throw const AuthFailure(
          'We could not sign you in. Please check your details and try again.',
        );
      }
      return app_auth.AuthUser(
        id: user.id,
        email: user.email ?? email.trim(),
        isAnonymous: user.isAnonymous,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_humanizeAuthError(error.message));
    } catch (_) {
      throw const AuthFailure(
        'We could not sign you in right now. Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (error) {
      throw AuthFailure(_humanizeAuthError(error.message));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_humanizeAuthError(error.message));
    } catch (_) {
      throw const AuthFailure(
        'We could not send the password reset email right now.',
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (error) {
      throw AuthFailure(_humanizeAuthError(error.message));
    } catch (_) {
      throw const AuthFailure(
        'We could not update your password right now. Please try again.',
      );
    }
  }

  Future<void> _signOutIfNeeded() async {
    if (_client.auth.currentSession == null) {
      return;
    }
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {}
  }
}

String _humanizeAuthError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('invalid login credentials')) {
    return 'The email or password is incorrect.';
  }
  if (normalized.contains('email not confirmed')) {
    return 'Check your email and confirm your account before signing in.';
  }
  if (normalized.contains('password should be')) {
    return 'Choose a stronger password.';
  }
  if (normalized.contains('user already registered')) {
    return 'An account with this email already exists. Try signing in instead.';
  }
  if (normalized.contains('signup is disabled')) {
    return 'Account creation is not available right now.';
  }
  return message;
}
