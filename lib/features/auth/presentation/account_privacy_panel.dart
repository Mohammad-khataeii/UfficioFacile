import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../data/account_deletion_service.dart';
import 'account_deletion_dialog.dart';

typedef AsyncVoidCallback = Future<void> Function();
typedef DeleteNowCallback = Future<AccountDeletionResult> Function();

String localizedAccountPlanLabel(BuildContext context, dynamic plan) {
  final l10n = context.l10n;
  switch (plan?.toString()) {
    case 'UfficioPlan.premiumMonthly':
    case 'UfficioPlan.premiumYearly':
    case 'UfficioPlan.plusMonthly':
    case 'UfficioPlan.plusYearly':
    case 'UfficioPlan.pro':
    case 'UfficioPlan.trial':
    case 'UfficioPlan.lifetime':
    case 'UfficioPlan.adminGrant':
    case 'UfficioPlan.consultant':
      return l10n.t('account_plan_premium');
    case 'UfficioPlan.consultancyOneShot':
      return l10n.t('account_plan_one_time_support');
    case 'UfficioPlan.free':
    default:
      return l10n.t('account_plan_free');
  }
}

Future<void> openDeletionEmailFallbackForScope(
  BuildContext context,
  AppScope scope,
) {
  final userEmail = scope.authController.user?.email.trim() ?? '';
  return openAccountDeletionSupportMail(context, userEmail);
}

Future<AccountDeletionResult> deleteCurrentAccountForScope(
  AppScope scope,
) async {
  final result = await scope.accountDeletionService.deleteCurrentAccount();
  if (!result.ok) {
    return result;
  }
  await scope.privacyCenterService.deleteLocalData();
  await scope.authController.finalizeDeletedAccountSession();
  return result;
}

Future<void> clearLocalDataForScope(
  BuildContext context,
  AppScope scope,
) async {
  await scope.privacyCenterService.deleteLocalData();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.t('account_local_data_deleted'))),
  );
}

class AccountAndPrivacyPanelContainer extends StatelessWidget {
  const AccountAndPrivacyPanelContainer({
    super.key,
    this.showPrivacyCenterButton = true,
  });

  final bool showPrivacyCenterButton;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.authController,
      builder: (context, _) => FutureBuilder(
        future: scope.entitlementService.getCurrentEntitlement(),
        builder: (context, snapshot) {
          final user = scope.authController.user;
          return AccountAndPrivacyPanel(
            email: user?.email,
            isSignedIn: user?.isAuthenticated == true,
            planLabel: localizedAccountPlanLabel(context, snapshot.data?.plan),
            showPrivacyCenterButton: showPrivacyCenterButton,
            onSignInOrCreate: () async {
              await Navigator.pushNamed(context, AppRoutes.auth);
            },
            onSignOut: () async {
              await scope.authController.signOut();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.t('signed_out'))),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auth,
                (route) => false,
              );
            },
            onChangePassword: () async {
              await Navigator.pushNamed(context, AppRoutes.changePassword);
            },
            onOpenPrivacyCenter: () async {
              await Navigator.pushNamed(context, AppRoutes.privacy);
            },
            onDeleteLocalData: () => clearLocalDataForScope(context, scope),
            onDeleteMyAccount: () => deleteCurrentAccountForScope(scope),
            onRequestDeletionByEmail: () =>
                openDeletionEmailFallbackForScope(context, scope),
            onDeletionCompleted: () async {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.t('account_deleted_signed_out')),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.auth,
                (route) => false,
              );
            },
          );
        },
      ),
    );
  }
}

class AccountAndPrivacyPanel extends StatelessWidget {
  const AccountAndPrivacyPanel({
    super.key,
    required this.email,
    required this.isSignedIn,
    required this.planLabel,
    required this.onSignInOrCreate,
    required this.onSignOut,
    required this.onChangePassword,
    required this.onOpenPrivacyCenter,
    required this.onDeleteLocalData,
    required this.onDeleteMyAccount,
    required this.onRequestDeletionByEmail,
    required this.onDeletionCompleted,
    this.showPrivacyCenterButton = true,
  });

  final String? email;
  final bool isSignedIn;
  final String planLabel;
  final AsyncVoidCallback onSignInOrCreate;
  final AsyncVoidCallback onSignOut;
  final AsyncVoidCallback onChangePassword;
  final AsyncVoidCallback onOpenPrivacyCenter;
  final AsyncVoidCallback onDeleteLocalData;
  final DeleteNowCallback onDeleteMyAccount;
  final AsyncVoidCallback onRequestDeletionByEmail;
  final AsyncVoidCallback onDeletionCompleted;
  final bool showPrivacyCenterButton;

  Future<void> _openDeleteDialog(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteAccountDialog(
        onDeleteNow: onDeleteMyAccount,
        onEmailFallback: onRequestDeletionByEmail,
      ),
    );
    if (deleted == true) {
      await onDeletionCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final emailText = email?.trim().isNotEmpty == true
        ? email!.trim()
        : l10n.t('account_not_signed_in');
    final destructiveColor = Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('account_privacy_section_title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(l10n.t('account_privacy_section_subtitle')),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.t('account_email')),
              subtitle: Text(emailText),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.t('account_plan')),
              subtitle: Text(planLabel),
            ),
            const SizedBox(height: 12),
            if (!isSignedIn)
              FilledButton(
                onPressed: onSignInOrCreate,
                child: Text(l10n.t('auth_login_or_signup')),
              )
            else
              FilledButton(
                onPressed: onSignOut,
                child: Text(l10n.t('account_log_out')),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: isSignedIn ? onChangePassword : null,
              child: Text(l10n.t('account_change_password')),
            ),
            if (showPrivacyCenterButton) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onOpenPrivacyCenter,
                child: Text(l10n.t('account_privacy')),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onDeleteLocalData,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.t('account_delete_local_data')),
            ),
            const SizedBox(height: 6),
            Text(l10n.t('account_delete_local_data_subtitle')),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: destructiveColor,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: isSignedIn ? () => _openDeleteDialog(context) : null,
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.t('account_delete_my_account')),
            ),
            const SizedBox(height: 6),
            Text(
              isSignedIn
                  ? l10n.t('account_delete_my_account_subtitle')
                  : l10n.t('account_sign_in_to_delete'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRequestDeletionByEmail,
              icon: const Icon(Icons.email_outlined),
              label: Text(l10n.t('account_request_deletion_email')),
            ),
            const SizedBox(height: 6),
            Text(l10n.t('account_deletion_email_fallback')),
          ],
        ),
      ),
    );
  }
}
