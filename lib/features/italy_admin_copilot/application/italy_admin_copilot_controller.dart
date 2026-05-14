import 'package:flutter/foundation.dart';

import '../../../app/app_config.dart';
import '../../../app/app_startup.dart';
import '../data/admin_config_repository.dart';
import '../data/local_analytics_service.dart';
import '../data/life_admin_phase5_services.dart';
import '../data/onboarding_repository.dart';
import '../domain/admin_config.dart';
import '../domain/onboarding_state.dart';

class ItalyAdminCopilotController extends ChangeNotifier {
  ItalyAdminCopilotController({
    required UfficcioFacileConfig appConfig,
    required OnboardingRepository onboardingRepository,
    required AdminConfigRepository adminConfigRepository,
    required LocalAnalyticsService analyticsService,
    required LocalAppLanguageRepository languageRepository,
  }) : _onboardingRepository = onboardingRepository,
       _adminConfigRepository = adminConfigRepository,
       _analyticsService = analyticsService,
       _languageRepository = languageRepository,
       _appConfig = appConfig;

  final OnboardingRepository _onboardingRepository;
  final AdminConfigRepository _adminConfigRepository;
  final LocalAnalyticsService _analyticsService;
  final LocalAppLanguageRepository _languageRepository;
  final UfficcioFacileConfig _appConfig;

  OnboardingState onboardingState = const OnboardingState(completed: false);
  AdminConfig config = const AdminConfig();
  String languageCode = 'en';
  bool initialized = false;
  bool _initializing = false;
  AppStartupState startupState = const AppStartupState.initial();

  bool get canContinueWithFallbackLocalMode => false;

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;
    initialized = false;
    startupState = startupState.copyWith(
      isLoading: true,
      isReady: false,
      backendMode: _appConfig.backendLabel,
      flavor: _appConfig.flavorLabel,
      errorMessage: null,
      debugDetails: null,
      usedFallbackLocalMode: false,
      canFallbackToLocalMode: _appConfig.canFallbackToLocalMode,
      supabaseConfigured: _appConfig.hasSupabaseCredentials,
      supabaseInitialized: _appConfig.isSupabaseEnabled,
      remoteCatalogAvailable: _appConfig.isSupabaseEnabled,
    );
    notifyListeners();

    try {
      final result = await AppStartupService(
        config: _appConfig,
        onboardingRepository: _onboardingRepository,
        adminConfigRepository: _adminConfigRepository,
        languageRepository: _languageRepository,
        analyticsService: _analyticsService,
      ).initialize().timeout(const Duration(seconds: 5));
      onboardingState = result.onboardingState;
      config = result.adminConfig;
      languageCode = result.languageCode;
      startupState = AppStartupState(
        isLoading: false,
        isReady: true,
        onboardingCompleted: onboardingState.completed,
        backendMode: _appConfig.backendLabel,
        flavor: _appConfig.flavorLabel,
        languageCode: languageCode,
        usedFallbackLocalMode: result.usedFallbackLocalMode,
        canFallbackToLocalMode: _appConfig.canFallbackToLocalMode,
        supabaseConfigured: result.supabaseConfigured,
        supabaseInitialized: result.supabaseInitialized,
        remoteCatalogAvailable: result.remoteCatalogAvailable,
        errorMessage: result.errorMessage,
        debugDetails: result.debugDetails,
      );
    } catch (error, stackTrace) {
      startupState = AppStartupState(
        isLoading: false,
        isReady: false,
        onboardingCompleted: false,
        backendMode: _appConfig.backendLabel,
        flavor: _appConfig.flavorLabel,
        languageCode: 'en',
        usedFallbackLocalMode: false,
        canFallbackToLocalMode: _appConfig.canFallbackToLocalMode,
        supabaseConfigured: _appConfig.hasSupabaseCredentials,
        supabaseInitialized: false,
        remoteCatalogAvailable: false,
        errorMessage: 'Startup timed out or failed.',
        debugDetails: '$error\n$stackTrace',
      );
    } finally {
      initialized = true;
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    await _onboardingRepository.setCompleted(true);
    onboardingState = await _onboardingRepository.getState();
    await _analyticsService.trackStatusUpdated('onboarding_completed');
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _onboardingRepository.setCompleted(false);
    onboardingState = await _onboardingRepository.getState();
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    languageCode = LocalAppLanguageRepository.sanitize(code);
    await _languageRepository.save(languageCode);
    notifyListeners();
  }

  Future<void> updateConfig(AdminConfig newConfig) async {
    config = await _adminConfigRepository.saveConfig(newConfig);
    notifyListeners();
  }

  Future<void> retryStartup() => initialize();

  Future<void> continueWithFallbackLocalMode() async {
    startupState = startupState.copyWith(
      isLoading: false,
      isReady: false,
      usedFallbackLocalMode: false,
      errorMessage:
          'UfficioFacile requires a live Supabase connection for this build.',
    );
    notifyListeners();
  }

  Future<void> resetStartupData() async {
    try {
      await _onboardingRepository.setCompleted(false);
    } catch (_) {}
    try {
      await _adminConfigRepository.saveConfig(const AdminConfig());
    } catch (_) {}
    try {
      await _languageRepository.save('en');
    } catch (_) {}
    await initialize();
  }
}
