import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/app/app_config.dart';
import 'package:ufficiofacile/app/app_localizations.dart';
import 'package:ufficiofacile/app/app_scope.dart';
import 'package:ufficiofacile/app/supabase_bootstrap.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart';

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

Future<void> _pumpProfile(WidgetTester tester, SharedPreferences prefs) async {
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
        child: const MaterialApp(home: ProfileScreen()),
      ),
    ),
  );
  final scope = AppScope.of(tester.element(find.byType(ProfileScreen)));
  await scope.appController.initialize();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'profile language dropdown reflects saved language after reopen',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await _pumpProfile(tester, prefs);

      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Italiano').last);
      await tester.pumpAndSettle();

      var scope = AppScope.of(tester.element(find.byType(ProfileScreen)));
      expect(scope.appController.languageCode, 'it');

      await _pumpProfile(tester, prefs);

      scope = AppScope.of(tester.element(find.byType(ProfileScreen)));
      expect(scope.appController.languageCode, 'it');
      expect(find.text('Italiano'), findsWidgets);
    },
  );
}
