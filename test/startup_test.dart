import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/app/app_config.dart';
import 'package:ufficiofacile/app/app_startup.dart';
import 'package:ufficiofacile/app/app_startup_widgets.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/admin_config_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_admin_config_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_analytics_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_onboarding_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_request_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/life_admin_phase5_services.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/onboarding_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_config.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/onboarding_state.dart';

const _localConfig = UfficcioFacileConfig(
  appName: UfficcioFacileConfig.appNameValue,
  backendMode: AppBackendMode.local,
  supabaseUrl: '',
  supabaseAnonKey: '',
  syncEnabledByDefault: false,
  adminDebugEnabled: false,
  betaModeEnabled: true,
  paywallEnabled: false,
  analyticsEnabledByDefault: true,
);

void main() {
  group('startup config and service', () {
    test('AppConfig falls back to local when Supabase env missing', () {
      expect(UfficcioFacileConfig.fromEnv.backendLabel, 'local');
      expect(UfficcioFacileConfig.fromEnv.hasSupabaseCredentials, isFalse);
    });

    test('StartupService completes in local mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final result = await AppStartupService(
        config: _localConfig,
        onboardingRepository: LocalOnboardingRepository(prefs),
        adminConfigRepository: LocalAdminConfigRepository(prefs),
        languageRepository: LocalAppLanguageRepository(prefs),
        analyticsService: LocalAnalyticsService(prefs),
      ).initialize();

      expect(result.onboardingState.completed, isFalse);
      expect(result.languageCode, 'en');
      expect(result.usedFallbackLocalMode, isFalse);
    });

    test('StartupService does not require Supabase in local mode', () async {
      final result = await AppStartupService(
        config: _localConfig,
        onboardingRepository: const _FakeOnboardingRepository(
          state: OnboardingState(completed: true),
        ),
        adminConfigRepository: const _FakeAdminConfigRepository(),
        languageRepository: _FakeLanguageRepository('it'),
        analyticsService: _NoopAnalyticsService(),
      ).initialize();

      expect(result.onboardingState.completed, isTrue);
      expect(result.languageCode, 'it');
      expect(result.usedFallbackLocalMode, isFalse);
    });

    test(
      'StartupService returns default onboarding state if local storage empty',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final result = await AppStartupService(
          config: _localConfig,
          onboardingRepository: LocalOnboardingRepository(prefs),
          adminConfigRepository: LocalAdminConfigRepository(prefs),
          languageRepository: LocalAppLanguageRepository(prefs),
          analyticsService: LocalAnalyticsService(prefs),
        ).initialize();

        expect(result.onboardingState, const OnboardingState(completed: false));
      },
    );

    test(
      'StartupService handles corrupted onboarding and settings JSON',
      () async {
        SharedPreferences.setMockInitialValues({
          LocalOnboardingRepository.storageKey: '{bad json',
          LocalAdminConfigRepository.storageKey: '[bad json',
          LocalAppLanguageRepository.storageKey: 'invalid',
        });
        final prefs = await SharedPreferences.getInstance();

        final result = await AppStartupService(
          config: _localConfig,
          onboardingRepository: LocalOnboardingRepository(prefs),
          adminConfigRepository: LocalAdminConfigRepository(prefs),
          languageRepository: LocalAppLanguageRepository(prefs),
          analyticsService: LocalAnalyticsService(prefs),
        ).initialize();

        expect(result.onboardingState.completed, isFalse);
        expect(result.adminConfig, const AdminConfig());
        expect(result.languageCode, 'en');
      },
    );

    test('No startup test waits forever', () async {
      final result = await AppStartupService(
        config: _localConfig,
        onboardingRepository: const _NeverResolvingOnboardingRepository(),
        adminConfigRepository: const _FakeAdminConfigRepository(),
        languageRepository: _FakeLanguageRepository('en'),
        analyticsService: _NoopAnalyticsService(),
      ).initialize().timeout(const Duration(seconds: 5));

      expect(result.onboardingState.completed, isFalse);
    });
  });

  group('startup-safe local storage handling', () {
    test('Local request repository handles corrupted JSON', () async {
      SharedPreferences.setMockInitialValues({
        LocalAdminCopilotRequestRepository.requestsStorageKey: '{bad json',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminCopilotRequestRepository(prefs);
      expect(await repo.listRequests(), isEmpty);
    });

    test('Localization falls back to English for invalid language', () async {
      SharedPreferences.setMockInitialValues({
        LocalAppLanguageRepository.storageKey: 'xx',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAppLanguageRepository(prefs);
      expect(repo.read(), 'en');
    });
  });

  group('startup routing and loading UI', () {
    test('Route decision goes to onboarding when onboarding false', () {
      expect(
        decideStartupDestination(
          const AppStartupState(
            isLoading: false,
            isReady: true,
            onboardingCompleted: false,
            backendMode: 'local',
            languageCode: 'en',
            usedFallbackLocalMode: false,
          ),
        ),
        StartupDestination.onboarding,
      );
    });

    test('Route decision goes to home when onboarding true', () {
      expect(
        decideStartupDestination(
          const AppStartupState(
            isLoading: false,
            isReady: true,
            onboardingCompleted: true,
            backendMode: 'local',
            languageCode: 'en',
            usedFallbackLocalMode: false,
          ),
        ),
        StartupDestination.home,
      );
    });

    testWidgets('Loading screen timeout shows fallback state', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = ItalyAdminCopilotController(
        appConfig: _localConfig,
        onboardingRepository: LocalOnboardingRepository(prefs),
        adminConfigRepository: LocalAdminConfigRepository(prefs),
        analyticsService: LocalAnalyticsService(prefs),
        languageRepository: LocalAppLanguageRepository(prefs),
      );

      await tester.pumpWidget(
        MaterialApp(home: StartupLoadingScreen(controller: controller)),
      );

      expect(find.text('Continue in local mode'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Continue in local mode'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository({required this.state});

  final OnboardingState state;

  @override
  Future<OnboardingState> getState() async => state;

  @override
  Future<void> setCompleted(bool completed) async {}
}

class _NeverResolvingOnboardingRepository implements OnboardingRepository {
  const _NeverResolvingOnboardingRepository();

  @override
  Future<OnboardingState> getState() => Completer<OnboardingState>().future;

  @override
  Future<void> setCompleted(bool completed) async {}
}

class _FakeAdminConfigRepository implements AdminConfigRepository {
  const _FakeAdminConfigRepository();

  @override
  Future<AdminConfig> getConfig() async => const AdminConfig();

  @override
  Future<AdminConfig> saveConfig(AdminConfig config) async => config;
}

class _FakeLanguageRepository extends LocalAppLanguageRepository {
  _FakeLanguageRepository(this.value) : super(_UnavailablePrefs.instance);

  final String value;

  @override
  String read() => LocalAppLanguageRepository.sanitize(value);
}

class _NoopAnalyticsService extends LocalAnalyticsService {
  _NoopAnalyticsService() : super(_UnavailablePrefs.instance);

  @override
  Future<void> trackCopilotOpened() async {}
}

class _UnavailablePrefs implements SharedPreferences {
  _UnavailablePrefs._();

  static final instance = _UnavailablePrefs._();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Test stub only');
}
