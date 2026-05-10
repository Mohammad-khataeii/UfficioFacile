import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';

String buildPasswordResetRedirectUri() {
  final scheme = Uri.base.scheme;
  final origin = scheme == 'http' || scheme == 'https' ? Uri.base.origin : '';
  if (origin.isNotEmpty) {
    return '$origin${AppRoutes.resetPassword}';
  }
  return 'https://ufficio-facile.vercel.app${AppRoutes.resetPassword}';
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
          appBar: AppBar(title: const Text('Forgot password?')),
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
                        const Text(
                          'Enter your email and we will send a reset link if the account exists.',
                        ),
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'If an account exists for this email, we sent a reset link.',
                                      ),
                                    ),
                                  );
                                },
                          child: Text(
                            controller.isLoading
                                ? context.l10n.t('auth_wait')
                                : 'Send reset link',
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
          appBar: AppBar(title: const Text('Reset password')),
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
                        const Text('Choose a new password for your account.'),
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
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
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
                                      () => _validationMessage =
                                          'Choose a password with at least 8 characters.',
                                    );
                                    return;
                                  }
                                  if (newPassword != confirm) {
                                    setState(
                                      () => _validationMessage =
                                          'The passwords do not match.',
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
                                    const SnackBar(
                                      content: Text(
                                        'Password updated successfully.',
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
                                : 'Update password',
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
          appBar: AppBar(title: const Text('Change password')),
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
                        const Text('Update the password for this account.'),
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
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
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
                                      () => _validationMessage =
                                          'Choose a password with at least 8 characters.',
                                    );
                                    return;
                                  }
                                  if (newPassword != confirm) {
                                    setState(
                                      () => _validationMessage =
                                          'The passwords do not match.',
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
                                    const SnackBar(
                                      content: Text(
                                        'Password updated successfully.',
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                          child: Text(
                            controller.isLoading
                                ? context.l10n.t('auth_wait')
                                : 'Change password',
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
