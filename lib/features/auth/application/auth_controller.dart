import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(
    this._repository, {
    this.beforeAuthChange,
    this.afterAuthenticated,
    this.afterSignedOut,
  }) {
    user = _repository.currentUser;
    _subscription = _repository.authStateChanges().listen((nextUser) {
      user = nextUser;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  final Future<void> Function()? beforeAuthChange;
  final Future<void> Function(AuthUser user)? afterAuthenticated;
  final Future<void> Function()? afterSignedOut;
  StreamSubscription<AuthUser?>? _subscription;

  AuthUser? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => user?.isAuthenticated == true;

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await beforeAuthChange?.call();
      final signedInUser = await _repository.signIn(
        email: email,
        password: password,
      );
      final sessionUser = _repository.currentUser ?? signedInUser;
      if (!_matchesExpectedSession(email, sessionUser)) {
        return await _handleSessionMismatch();
      }
      user = sessionUser;
      if (sessionUser.isAuthenticated) {
        try {
          await afterAuthenticated?.call(sessionUser);
        } on AuthFailure catch (error) {
          await _signOutAfterAuthFailure(error.message);
          return false;
        }
      }
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await beforeAuthChange?.call();
      final createdUser = await _repository.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );
      final sessionUser = _repository.currentUser;
      if (!createdUser.isAuthenticated || sessionUser == null) {
        user = null;
        return true;
      }
      if (!_matchesExpectedSession(email, sessionUser)) {
        return await _handleSessionMismatch();
      }
      user = sessionUser;
      try {
        await afterAuthenticated?.call(sessionUser);
      } on AuthFailure catch (error) {
        await _signOutAfterAuthFailure(error.message);
        return false;
      }
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.sendPasswordResetEmail(email, redirectTo: redirectTo);
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
      user = null;
      await afterSignedOut?.call();
    } on AuthFailure catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.updatePassword(newPassword);
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _matchesExpectedSession(String expectedEmail, AuthUser? sessionUser) {
    if (sessionUser == null || !sessionUser.isAuthenticated) {
      return false;
    }
    return sessionUser.email.trim().toLowerCase() ==
        expectedEmail.trim().toLowerCase();
  }

  Future<bool> _handleSessionMismatch() async {
    try {
      await _repository.signOut();
    } catch (_) {}
    user = null;
    await afterSignedOut?.call();
    errorMessage = 'Session mismatch. Please sign in again.';
    return false;
  }

  Future<void> _signOutAfterAuthFailure(String message) async {
    try {
      await _repository.signOut();
    } catch (_) {}
    user = null;
    await afterSignedOut?.call();
    errorMessage = message;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
