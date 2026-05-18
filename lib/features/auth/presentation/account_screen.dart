import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../italy_admin_copilot/presentation/screens/notification_and_monetization_screens.dart';

String _accountPlanLabel(dynamic plan) {
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
      return 'Premium';
    case 'UfficioPlan.consultancyOneShot':
      return 'One-time support';
    case 'UfficioPlan.free':
    default:
      return 'Free';
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.authController,
      builder: (context, _) {
        final user = scope.authController.user;
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.t('account_title'))),
          body: SafeArea(
            child: FutureBuilder(
              future: scope.entitlementService.getCurrentEntitlement(),
              builder: (context, snapshot) {
                final entitlement = snapshot.data;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.t('account_email')),
                      subtitle: Text(
                        user?.email.isNotEmpty == true
                            ? user!.email
                            : context.l10n.t('account_not_signed_in'),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.t('account_plan')),
                      subtitle: Text(_accountPlanLabel(entitlement?.plan)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: user == null
                          ? () => Navigator.pushNamed(context, AppRoutes.auth)
                          : () async {
                              await scope.authController.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.t('signed_out')),
                                  ),
                                );
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.auth,
                                  (route) => false,
                                );
                              }
                            },
                      child: Text(
                        user == null
                            ? context.l10n.t('auth_login')
                            : context.l10n.t('account_log_out'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: user == null
                          ? null
                          : () => Navigator.pushNamed(
                              context,
                              AppRoutes.changePassword,
                            ),
                      child: Text(context.l10n.t('account_change_password')),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.privacy),
                      child: Text(context.l10n.t('account_privacy')),
                    ),
                    const SizedBox(height: 16),
                    const Card(child: AppMonetizationEntryTile()),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
