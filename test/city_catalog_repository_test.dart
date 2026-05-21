import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufficiofacile/features/admin_cms/data/local_cms_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_profile_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficio_catalog_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficio_city_registry.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_copilot_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('city registry', () {
    test('torino prefers city-specific asset and keeps legacy fallback', () {
      expect(
        UfficioCityRegistry.bundledAssetCandidates('torino'),
        const <String>[
          'assets/catalog/ufficio_catalog.torino.v1.json',
          'assets/catalog/ufficio_catalog.v1.json',
        ],
      );
    });

    test('milano never falls back to torino asset', () {
      expect(
        UfficioCityRegistry.bundledAssetCandidates('milano'),
        const <String>['assets/catalog/ufficio_catalog.milano.v1.json'],
      );
    });

    test('milano availability follows the bundled asset set', () async {
      final city = await UfficioCityRegistry.resolveCity('milano');
      expect(city.slug, 'milano');
      expect(city.isAvailable, equals(city.bundledCatalogAsset != null));
    });
  });

  group('selected city persistence', () {
    test('default selected city stays torino', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAdminCopilotProfileRepository(prefs);
      final profile = await repository.getProfile();
      expect(
        UfficioCityRegistry.normalizeSlug(profile?.selectedCityPackId),
        'torino',
      );
    });

    test('selecting milano persists and reloads', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalAdminCopilotProfileRepository(prefs);
      await repository.saveProfile(
        const AdminCopilotProfile(selectedCityPackId: 'milano'),
      );

      final reloaded = await repository.getProfile();
      expect(reloaded?.selectedCityPackId, 'milano');
      expect(
        UfficioCityRegistry.normalizeSlug(reloaded?.selectedCityPackId),
        'milano',
      );
    });
  });

  group('city-aware catalog repository', () {
    final repository = UfficioCatalogRepository(
      const LocalCmsRepository(),
      selectedCitySlugLoader: () async => 'torino',
    );

    test('torino loads the existing bundled catalog', () async {
      final result = await repository.loadCatalogResult(citySlug: 'torino');
      expect(result.isSuccess, isTrue);
      expect(result.catalog, isNotNull);
      expect(result.catalog!.categories, isNotEmpty);
      expect(
        result.assetPath,
        anyOf(
          'assets/catalog/ufficio_catalog.torino.v1.json',
          'assets/catalog/ufficio_catalog.v1.json',
        ),
      );
    });

    test('milano never falls back to torino data', () async {
      final result = await repository.loadCatalogResult(citySlug: 'milano');
      expect(result.city.slug, 'milano');
      if (result.city.isAvailable) {
        expect(result.isSuccess, isTrue);
        expect(
          result.assetPath,
          'assets/catalog/ufficio_catalog.milano.v1.json',
        );
      } else {
        expect(result.isUnavailable, isTrue);
        expect(result.catalog, isNull);
      }
    });

    test(
      'future city missing asset returns unavailable without crash',
      () async {
        final result = await repository.loadCatalogResult(citySlug: 'genova');
        expect(result.isUnavailable, isTrue);
        expect(result.catalog, isNull);
        expect(result.city.slug, 'genova');
      },
    );
  });
}
