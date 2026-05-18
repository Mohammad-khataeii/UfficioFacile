import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import 'password_screens.dart';

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
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  bool _rememberMe = true;
  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;

  static const _rememberedEmailKey = 'ufficiofacile_auth_remembered_email_v1';

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedEmail = prefs.getString(_rememberedEmailKey) ?? '';
    if (!mounted || rememberedEmail.isEmpty) return;
    setState(() {
      _emailController.text = rememberedEmail;
      _rememberMe = true;
    });
  }

  Future<void> _persistRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_rememberedEmailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
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
                              passwordVisible: _loginPasswordVisible,
                              onTogglePasswordVisibility: () {
                                setState(
                                  () => _loginPasswordVisible =
                                      !_loginPasswordVisible,
                                );
                              },
                              isLoading: controller.isLoading,
                              errorMessage: controller.errorMessage,
                              primaryLabel: context.l10n.t('auth_login'),
                              rememberMe: _rememberMe,
                              onRememberMeChanged: (value) {
                                setState(() => _rememberMe = value);
                              },
                              onPrimary: () async {
                                final ok = await controller.signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                                if (ok && context.mounted) {
                                  TextInput.finishAutofillContext(
                                    shouldSave: true,
                                  );
                                  await _persistRememberedEmail();
                                  await scope.profileController.load();
                                  await scope.entitlementService
                                      .getCurrentEntitlement();
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.dashboard,
                                    (route) => false,
                                  );
                                }
                              },
                              onSecondary: () async {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
                              secondaryLabel: context.l10n.t(
                                'forgot_password_title',
                              ),
                            ),
                            _AuthFormCard(
                              title: context.l10n.t('auth_create_account'),
                              subtitle: context.l10n.t('auth_signup_subtitle'),
                              emailController: _signupEmailController,
                              passwordController: _signupPasswordController,
                              passwordVisible: _signupPasswordVisible,
                              onTogglePasswordVisibility: () {
                                setState(
                                  () => _signupPasswordVisible =
                                      !_signupPasswordVisible,
                                );
                              },
                              isLoading: controller.isLoading,
                              errorMessage: controller.errorMessage,
                              primaryLabel: context.l10n.t(
                                'auth_create_account',
                              ),
                              onPrimary: () async {
                                final ok = await controller.signUp(
                                  email: _signupEmailController.text,
                                  password: _signupPasswordController.text,
                                  emailRedirectTo:
                                      buildEmailConfirmationRedirectUri(),
                                );
                                if (ok && context.mounted) {
                                  if (controller.isAuthenticated) {
                                    TextInput.finishAutofillContext(
                                      shouldSave: true,
                                    );
                                    await scope.profileController.load();
                                    await scope.entitlementService
                                        .getCurrentEntitlement();
                                    if (!context.mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.dashboard,
                                      (route) => false,
                                    );
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n.t(
                                          'auth_confirm_email_message',
                                        ),
                                      ),
                                    ),
                                  );
                                  _tabController.animateTo(0);
                                }
                              },
                            ),
                          ],
                        ),
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
    required this.passwordVisible,
    required this.onTogglePasswordVisibility,
    required this.isLoading,
    required this.errorMessage,
    required this.primaryLabel,
    required this.onPrimary,
    this.rememberMe,
    this.onRememberMeChanged,
    this.onSecondary,
    this.secondaryLabel,
  });

  final String title;
  final String subtitle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onTogglePasswordVisibility;
  final bool isLoading;
  final String? errorMessage;
  final String primaryLabel;
  final Future<void> Function() onPrimary;
  final bool? rememberMe;
  final ValueChanged<bool>? onRememberMeChanged;
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
            AutofillGroup(
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.t('auth_email'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: context.l10n.t('auth_password'),
                      suffixIcon: IconButton(
                        onPressed: onTogglePasswordVisibility,
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (rememberMe != null && onRememberMeChanged != null) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: rememberMe,
                onChanged: isLoading
                    ? null
                    : (value) => onRememberMeChanged!(value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(context.l10n.t('auth_remember_me')),
                subtitle: Text(context.l10n.t('auth_remember_me_hint')),
              ),
            ],
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
