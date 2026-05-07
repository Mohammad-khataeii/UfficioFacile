import 'package:flutter/foundation.dart';

import '../features/italy_admin_copilot/data/admin_config_repository.dart';
import '../features/italy_admin_copilot/data/life_admin_phase5_services.dart';
import '../features/italy_admin_copilot/data/local_analytics_service.dart';
import '../features/italy_admin_copilot/data/onboarding_repository.dart';
import '../features/italy_admin_copilot/domain/admin_config.dart';
import '../features/italy_admin_copilot/domain/onboarding_state.dart';
import 'app_config.dart';
import 'app_localizations.dart';

class AppStartupState {
  const AppStartupState({
    required this.isLoading,
    required this.isReady,
    required this.onboardingCompleted,
    required this.backendMode,
    required this.languageCode,
    required this.usedFallbackLocalMode,
    this.errorMessage,
    this.debugDetails,
  });

  const AppStartupState.initial()
    : isLoading = true,
      isReady = false,
      onboardingCompleted = false,
      backendMode = 'local',
      languageCode = 'en',
      usedFallbackLocalMode = false,
      errorMessage = null,
      debugDetails = null;

  final bool isLoading;
  final bool isReady;
  final bool onboardingCompleted;
  final String backendMode;
  final String languageCode;
  final bool usedFallbackLocalMode;
  final String? errorMessage;
  final String? debugDetails;

  AppStartupState copyWith({
    bool? isLoading,
    bool? isReady,
    bool? onboardingCompleted,
    String? backendMode,
    String? languageCode,
    bool? usedFallbackLocalMode,
    String? errorMessage,
    String? debugDetails,
  }) {
    return AppStartupState(
      isLoading: isLoading ?? this.isLoading,
      isReady: isReady ?? this.isReady,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      backendMode: backendMode ?? this.backendMode,
      languageCode: languageCode ?? this.languageCode,
      usedFallbackLocalMode:
          usedFallbackLocalMode ?? this.usedFallbackLocalMode,
      errorMessage: errorMessage,
      debugDetails: debugDetails,
    );
  }
}

enum StartupDestination { loading, error, onboarding, home }

StartupDestination decideStartupDestination(AppStartupState state) {
  if (state.isLoading) {
    return StartupDestination.loading;
  }
  if (!state.isReady) {
    return StartupDestination.error;
  }
  return state.onboardingCompleted
      ? StartupDestination.home
      : StartupDestination.onboarding;
}

class AppStartupResult {
  const AppStartupResult({
    required this.onboardingState,
    required this.adminConfig,
    required this.languageCode,
    required this.usedFallbackLocalMode,
    this.errorMessage,
    this.debugDetails,
  });

  final OnboardingState onboardingState;
  final AdminConfig adminConfig;
  final String languageCode;
  final bool usedFallbackLocalMode;
  final String? errorMessage;
  final String? debugDetails;
}

class AppStartupService {
  AppStartupService({
    required this.config,
    required this.onboardingRepository,
    required this.adminConfigRepository,
    required this.languageRepository,
    required this.analyticsService,
  });

  final UfficcioFacileConfig config;
  final OnboardingRepository onboardingRepository;
  final AdminConfigRepository adminConfigRepository;
  final LocalAppLanguageRepository languageRepository;
  final LocalAnalyticsService analyticsService;

  Future<AppStartupResult> initialize() async {
    _log('Starting ${config.appName}');
    _log('Backend mode: ${config.backendLabel}');

    final onboardingState = await _loadOnboarding();
    final adminConfig = await _loadAdminConfig();
    final languageCode = _loadLanguage();

    final usedFallbackLocalMode =
        config.backendMode == AppBackendMode.supabase &&
        !config.hasSupabaseCredentials;

    if (usedFallbackLocalMode) {
      _log('Supabase config missing. Continuing in local mode.');
    }

    try {
      await analyticsService.trackCopilotOpened().timeout(
        const Duration(seconds: 1),
      );
    } catch (error) {
      _log('Analytics init skipped: $error');
    }

    _log('Onboarding loaded: ${onboardingState.completed}');
    _log('Language loaded: $languageCode');
    _log(
      'Initial route: ${onboardingState.completed ? '/life-admin' : '/life-admin/onboarding'}',
    );
    _log('Completed');

    return AppStartupResult(
      onboardingState: onboardingState,
      adminConfig: adminConfig,
      languageCode: languageCode,
      usedFallbackLocalMode: usedFallbackLocalMode,
    );
  }

  Future<OnboardingState> _loadOnboarding() async {
    try {
      return await onboardingRepository.getState().timeout(
        const Duration(seconds: 3),
      );
    } catch (error) {
      _log('Onboarding fallback: $error');
      return const OnboardingState(completed: false);
    }
  }

  Future<AdminConfig> _loadAdminConfig() async {
    try {
      return await adminConfigRepository.getConfig().timeout(
        const Duration(seconds: 3),
      );
    } catch (error) {
      _log('Admin config fallback: $error');
      return const AdminConfig();
    }
  }

  String _loadLanguage() {
    try {
      final raw = languageRepository.read();
      if (AppLocalizations.supportedLocales.any(
        (locale) => locale.languageCode == raw,
      )) {
        return raw;
      }
    } catch (error) {
      _log('Language fallback: $error');
    }
    final deviceLanguage = PlatformDispatcher.instance.locale.languageCode;
    if (AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == deviceLanguage,
    )) {
      return deviceLanguage;
    }
    return 'en';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[Startup] $message');
    }
  }
}
