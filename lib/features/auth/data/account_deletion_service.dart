import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../../app/supabase_bootstrap.dart';

class AccountDeletionResult {
  const AccountDeletionResult._({required this.ok, this.errorMessage});

  const AccountDeletionResult.success() : this._(ok: true);

  const AccountDeletionResult.failure(String message)
    : this._(ok: false, errorMessage: message);

  final bool ok;
  final String? errorMessage;
}

class AccountDeletionService {
  const AccountDeletionService();

  Future<AccountDeletionResult> deleteCurrentAccount() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return const AccountDeletionResult.failure(
        'Sign in again before deleting your account.',
      );
    }

    try {
      final response = await client.functions.invoke('delete-account');
      final data = response.data;
      if (data is Map && data['ok'] == true) {
        return const AccountDeletionResult.success();
      }
      if (data is Map &&
          data['error'] is String &&
          (data['error'] as String).trim().isNotEmpty) {
        return AccountDeletionResult.failure(data['error'] as String);
      }
      return const AccountDeletionResult.failure(
        'We could not delete your account right now. Please try again or email support.',
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map &&
          details['error'] is String &&
          (details['error'] as String).trim().isNotEmpty) {
        return AccountDeletionResult.failure(details['error'] as String);
      }
      if (details is String && details.trim().isNotEmpty) {
        return AccountDeletionResult.failure(details);
      }
      return AccountDeletionResult.failure(
        _fallbackMessageForStatus(error.status),
      );
    } catch (_) {
      return const AccountDeletionResult.failure(
        'We could not delete your account right now. Please try again or email support.',
      );
    }
  }

  String _fallbackMessageForStatus(int status) {
    switch (status) {
      case 401:
        return 'Sign in again before deleting your account.';
      case 403:
        return 'This account cannot be deleted automatically right now. Please email support.';
      case 503:
        return 'Account deletion is not configured right now. Please try again later or email support.';
      default:
        return 'We could not delete your account right now. Please try again or email support.';
    }
  }
}
