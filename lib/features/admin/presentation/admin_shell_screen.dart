import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../auth/presentation/auth_gate.dart';
import '../../../../app/app_scope.dart';
import 'admin_dashboard_screen.dart';

class AdminShellScreen extends StatelessWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AuthGate(
      featureTitle: context.l10n.t('admin_panel'),
      child: AnimatedBuilder(
        animation: scope.adminPanelController,
        builder: (context, _) {
          if (scope.adminPanelController.isLoading &&
              !scope.adminPanelController.isAdmin) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!scope.adminPanelController.isAdmin) {
            return const AccessDeniedScreen();
          }
          return const AdminDashboardScreen();
        },
      ),
    );
  }
}
