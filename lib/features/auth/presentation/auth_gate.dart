import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.child,
    this.featureTitle = 'private area',
  });

  final Widget child;
  final String featureTitle;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.authController,
      builder: (context, _) {
        if (scope.authController.isAuthenticated) {
          return child;
        }
        return AuthRequiredScreen(featureTitle: featureTitle);
      },
    );
  }
}

class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({
    super.key,
    this.featureTitle = 'this area',
    this.showContinueBrowsing = false,
  });

  final String featureTitle;
  final bool showContinueBrowsing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('auth_required_title'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.t('auth_required_message'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${context.l10n.t('auth_required_feature')} ($featureTitle)',
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.auth),
                      child: Text(context.l10n.t('auth_login_or_signup')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('access_denied_title'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.t('access_denied_message'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
