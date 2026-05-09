import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/features/auth/application/auth_controller.dart';
import 'package:ufficiofacile/features/auth/data/auth_repository.dart';
import 'package:ufficiofacile/features/auth/domain/auth_user.dart';

void main() {
  group('local auth repository', () {
    test('sign up, sign in, reset, and sign out work locally', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAuthRepository(prefs);

      final created = await repository.signUp(
        email: 'demo@example.com',
        password: 'password123',
      );
      expect(created.email, 'demo@example.com');
      expect(repository.currentUser?.isAuthenticated, isTrue);

      await repository.sendPasswordResetEmail('demo@example.com');

      final signedIn = await repository.signIn(
        email: 'demo@example.com',
        password: 'password123',
      );
      expect(signedIn.email, 'demo@example.com');

      await repository.signOut();
      expect(repository.currentUser, isNull);
    });

    test('empty credentials return human auth errors', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAuthRepository(prefs);

      expect(
        () => repository.signIn(email: '', password: ''),
        throwsA(isA<AuthFailure>()),
      );
      expect(
        () => repository.sendPasswordResetEmail('', redirectTo: null),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  group('auth controller', () {
    test('controller listens to auth state and clears on sign out', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAuthRepository(prefs);
      final controller = AuthController(repository);
      addTearDown(controller.dispose);

      expect(controller.isAuthenticated, isFalse);

      final signInOk = await controller.signIn(
        email: 'controller@example.com',
        password: 'password123',
      );
      expect(signInOk, isTrue);
      expect(controller.isAuthenticated, isTrue);

      await controller.signOut();
      expect(controller.user, isNull);
      expect(controller.isAuthenticated, isFalse);
    });

    test('controller exposes human-readable failure messages', () async {
      final controller = AuthController(_FakeAuthRepository());
      addTearDown(controller.dispose);

      final success = await controller.signIn(email: 'x', password: 'y');
      expect(success, isFalse);
      expect(controller.errorMessage, 'Unable to sign in right now.');
    });

    test('sign up without session keeps user signed out', () async {
      final controller = AuthController(_ConfirmationRequiredAuthRepository());
      addTearDown(controller.dispose);

      final success = await controller.signUp(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.user, isNull);
    });

    test('session mismatch forces sign out', () async {
      final controller = AuthController(_SessionMismatchAuthRepository());
      addTearDown(controller.dispose);

      final success = await controller.signIn(
        email: 'person-b@example.com',
        password: 'password123',
      );

      expect(success, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(
        controller.errorMessage,
        'Session mismatch. Please sign in again.',
      );
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<void> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {}

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    throw const AuthFailure('Unable to sign in right now.');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    throw const AuthFailure('Unable to create your account right now.');
  }

  @override
  Future<void> updatePassword(String newPassword) async {}
}

class _ConfirmationRequiredAuthRepository implements AuthRepository {
  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<void> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {}

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    return const AuthUser(id: '', email: 'new@example.com', isAnonymous: false);
  }

  @override
  Future<void> updatePassword(String newPassword) async {}
}

class _SessionMismatchAuthRepository implements AuthRepository {
  AuthUser? _currentUser = const AuthUser(
    id: 'owner-id',
    email: 'owner@example.com',
    isAnonymous: false,
  );

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<void> sendPasswordResetEmail(
    String email, {
    String? redirectTo,
  }) async {}

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<AuthUser> signUp({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword(String newPassword) async {}
}
