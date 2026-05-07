import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    user = _repository.currentUser;
    _subscription = _repository.authStateChanges().listen((nextUser) {
      user = nextUser;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
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
      user = await _repository.signIn(email: email, password: password);
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _repository.signUp(email: email, password: password);
      return true;
    } on AuthFailure catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.sendPasswordResetEmail(email);
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
    } on AuthFailure catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
