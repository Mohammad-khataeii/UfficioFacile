import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_scope.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.authController,
      builder: (context, _) {
        final controller = scope.authController;
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.t('auth_account')),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: context.l10n.t('auth_login')),
                Tab(text: context.l10n.t('auth_create_account')),
              ],
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _AuthFormCard(
                              title: context.l10n.t('auth_login'),
                              subtitle: context.l10n.t('auth_login_subtitle'),
                              emailController: _emailController,
                              passwordController: _passwordController,
                              isLoading: controller.isLoading,
                              errorMessage: controller.errorMessage,
                              primaryLabel: context.l10n.t('auth_login'),
                              onPrimary: () async {
                                final ok = await controller.signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (ok && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              onSecondary: () async {
                                final ok = await controller
                                    .sendPasswordResetEmail(
                                      _emailController.text,
                                    );
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t('auth_reset_sent'),
                                      ),
                                    ),
                                  );
                                }
                              },
                              secondaryLabel: context.l10n.t(
                                'auth_reset_password',
                              ),
                            ),
                            _AuthFormCard(
                              title: context.l10n.t('auth_create_account'),
                              subtitle: context.l10n.t('auth_signup_subtitle'),
                              emailController: _emailController,
                              passwordController: _passwordController,
                              isLoading: controller.isLoading,
                              errorMessage: controller.errorMessage,
                              primaryLabel: context.l10n.t(
                                'auth_create_account',
                              ),
                              onPrimary: () async {
                                final ok = await controller.signUp(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t('auth_signup_success'),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.t('auth_continue_public')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.title,
    required this.subtitle,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.primaryLabel,
    required this.onPrimary,
    this.onSecondary,
    this.secondaryLabel,
  });

  final String title;
  final String subtitle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final String primaryLabel;
  final Future<void> Function() onPrimary;
  final Future<void> Function()? onSecondary;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.t('auth_email'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.t('auth_password'),
              ),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isLoading ? null : onPrimary,
              child: Text(
                isLoading ? context.l10n.t('auth_wait') : primaryLabel,
              ),
            ),
            if (onSecondary != null && secondaryLabel != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: isLoading ? null : onSecondary,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
