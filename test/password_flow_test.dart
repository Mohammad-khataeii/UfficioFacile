import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/app/app_config.dart';
import 'package:ufficiofacile/app/app_localizations.dart';
import 'package:ufficiofacile/app/app_scope.dart';
import 'package:ufficiofacile/app/supabase_bootstrap.dart';
import 'package:ufficiofacile/features/auth/presentation/auth_screen.dart';
import 'package:ufficiofacile/features/auth/presentation/password_screens.dart';

const _localConfig = UfficcioFacileConfig(
  appName: UfficcioFacileConfig.appNameValue,
  backendMode: AppBackendMode.local,
  supabaseUrl: '',
  supabaseAnonKey: '',
  syncEnabledByDefault: false,
  adminDebugEnabled: true,
  betaModeEnabled: true,
  paywallEnabled: false,
  analyticsEnabledByDefault: true,
);

Future<void> _pumpWithScope(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    AppScope(
      prefs: prefs,
      config: _localConfig,
      supabaseBootstrapResult: const SupabaseBootstrapResult(
        configured: false,
        initialized: false,
      ),
      child: AppLocalizationsScope(
        localizations: AppLocalizations('en'),
        child: MaterialApp(home: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('auth screen shows Forgot password?', (tester) async {
    await _pumpWithScope(tester, const AuthScreen());
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('forgot password screen sends generic message', (tester) async {
    await _pumpWithScope(tester, const ForgotPasswordScreen());
    await tester.enterText(find.byType(TextField).first, 'person@example.com');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();
    expect(
      find.text('If an account exists for this email, we sent a reset link.'),
      findsOneWidget,
    );
  });

  testWidgets('reset password validation catches mismatch', (tester) async {
    await _pumpWithScope(tester, const ResetPasswordScreen());
    await tester.enterText(find.byType(TextField).at(0), 'password123');
    await tester.enterText(find.byType(TextField).at(1), 'password999');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();
    expect(find.text('The passwords do not match.'), findsOneWidget);
  });

  testWidgets('change password validation catches mismatch', (tester) async {
    await _pumpWithScope(tester, const ChangePasswordScreen());
    await tester.enterText(find.byType(TextField).at(0), 'password123');
    await tester.enterText(find.byType(TextField).at(1), 'password999');
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pumpAndSettle();
    expect(find.text('The passwords do not match.'), findsOneWidget);
  });
}
