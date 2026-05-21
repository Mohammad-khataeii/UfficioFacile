import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import 'auth_redirects.dart';

class EmailConfirmationSuccessScreen extends StatefulWidget {
  const EmailConfirmationSuccessScreen({super.key});

  @override
  State<EmailConfirmationSuccessScreen> createState() =>
      _EmailConfirmationSuccessScreenState();
}

class _EmailConfirmationSuccessScreenState
    extends State<EmailConfirmationSuccessScreen> {
  bool _signOutRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_signOutRequested) return;
    _signOutRequested = true;
    final scope = AppScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await scope.authController.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('auth_email_confirmed_title'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.t('auth_email_confirmed_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(context.l10n.t('auth_email_confirmed_body')),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.auth,
                        (route) => false,
                      ),
                      child: Text(context.l10n.t('auth_login')),
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
          appBar: AppBar(title: Text(context.l10n.t('forgot_password_title'))),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.t('forgot_password_intro')),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: context.l10n.t('auth_email'),
                          ),
                        ),
                        if (controller.errorMessage != null &&
                            controller.errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final ok = await controller
                                      .sendPasswordResetEmail(
                                        _emailController.text,
                                        redirectTo:
                                            buildPasswordResetRedirectUri(),
                                      );
                                  if (!context.mounted || !ok) return;
                                  _emailController.clear();
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t(
                                          'reset_password_sent_generic',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          child: Text(
                            controller.isLoading
                                ? context.l10n.t('auth_wait')
                                : context.l10n.t('reset_password_send_link'),
                          ),
                        ),
                      ],
                    ),
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

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          appBar: AppBar(title: Text(context.l10n.t('reset_password_title'))),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.t('reset_password_intro')),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.t('auth_password'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.t('confirm_new_password'),
                          ),
                        ),
                        if (_validationMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _validationMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ] else if (controller.errorMessage != null &&
                            controller.errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final newPassword = _newPasswordController
                                      .text
                                      .trim();
                                  final confirm = _confirmPasswordController
                                      .text
                                      .trim();
                                  if (newPassword.length < 8) {
                                    setState(
                                      () => _validationMessage = context.l10n.t(
                                        'password_min_length',
                                      ),
                                    );
                                    return;
                                  }
                                  if (newPassword != confirm) {
                                    setState(
                                      () => _validationMessage = context.l10n.t(
                                        'passwords_do_not_match',
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _validationMessage = null);
                                  final ok = await controller.updatePassword(
                                    newPassword,
                                  );
                                  if (!context.mounted || !ok) return;
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t(
                                          'password_updated_success',
                                        ),
                                      ),
                                    ),
                                  );
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    controller.isAuthenticated
                                        ? AppRoutes.dashboard
                                        : AppRoutes.auth,
                                    (route) => false,
                                  );
                                },
                          child: Text(
                            controller.isLoading
                                ? context.l10n.t('auth_wait')
                                : context.l10n.t('update_password'),
                          ),
                        ),
                      ],
                    ),
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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          appBar: AppBar(title: Text(context.l10n.t('change_password_title'))),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.t('change_password_intro')),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.t('auth_password'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.l10n.t('confirm_new_password'),
                          ),
                        ),
                        if (_validationMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _validationMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ] else if (controller.errorMessage != null &&
                            controller.errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  final newPassword = _newPasswordController
                                      .text
                                      .trim();
                                  final confirm = _confirmPasswordController
                                      .text
                                      .trim();
                                  if (newPassword.length < 8) {
                                    setState(
                                      () => _validationMessage = context.l10n.t(
                                        'password_min_length',
                                      ),
                                    );
                                    return;
                                  }
                                  if (newPassword != confirm) {
                                    setState(
                                      () => _validationMessage = context.l10n.t(
                                        'passwords_do_not_match',
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _validationMessage = null);
                                  final ok = await controller.updatePassword(
                                    newPassword,
                                  );
                                  if (!context.mounted || !ok) return;
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t(
                                          'password_updated_success',
                                        ),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                          child: Text(
                            controller.isLoading
                                ? context.l10n.t('auth_wait')
                                : context.l10n.t('change_password_title'),
                          ),
                        ),
                      ],
                    ),
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
