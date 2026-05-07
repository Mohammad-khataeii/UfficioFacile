import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/app/app_localizations.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/life_admin_phase5_services.dart';

void main() {
  group('localization support', () {
    test('supported locales include en, it, fr, es, fa, ar', () {
      final codes = AppLocalizations.supportedLocales
          .map((locale) => locale.languageCode)
          .toSet();
      expect(codes, containsAll(<String>{'en', 'it', 'fr', 'es', 'fa', 'ar'}));
    });

    test('Persian and Arabic are RTL while French is LTR', () {
      expect(AppLocalizations('fa').isRtl, isTrue);
      expect(AppLocalizations('ar').isRtl, isTrue);
      expect(AppLocalizations('fr').isRtl, isFalse);
    });

    test('localized values fall back through en and it', () {
      expect(AppLocalizations('fr').t('app_title'), 'UfficioFacile');
      expect(AppLocalizations('fr').localizedMap({'it': 'Ciao'}), 'Ciao');
    });

    test('language selection persists through repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAppLanguageRepository(prefs);

      await repository.save('fr');

      expect(repository.read(), 'fr');
      expect(LocalAppLanguageRepository.sanitize('xx'), 'en');
    });
  });
}
