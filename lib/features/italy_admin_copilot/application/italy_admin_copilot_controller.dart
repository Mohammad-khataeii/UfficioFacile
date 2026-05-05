import 'package:flutter/foundation.dart';

import '../data/admin_config_repository.dart';
import '../data/local_analytics_service.dart';
import '../data/life_admin_phase5_services.dart';
import '../data/onboarding_repository.dart';
import '../domain/admin_config.dart';
import '../domain/onboarding_state.dart';

class ItalyAdminCopilotController extends ChangeNotifier {
  ItalyAdminCopilotController({
    required OnboardingRepository onboardingRepository,
    required AdminConfigRepository adminConfigRepository,
    required LocalAnalyticsService analyticsService,
    required LocalAppLanguageRepository languageRepository,
  }) : _onboardingRepository = onboardingRepository,
       _adminConfigRepository = adminConfigRepository,
       _analyticsService = analyticsService,
       _languageRepository = languageRepository;

  final OnboardingRepository _onboardingRepository;
  final AdminConfigRepository _adminConfigRepository;
  final LocalAnalyticsService _analyticsService;
  final LocalAppLanguageRepository _languageRepository;

  OnboardingState onboardingState = const OnboardingState(completed: false);
  AdminConfig config = const AdminConfig();
  String languageCode = 'en';
  bool initialized = false;

  Future<void> initialize() async {
    onboardingState = await _onboardingRepository.getState();
    config = await _adminConfigRepository.getConfig();
    languageCode = _languageRepository.read();
    await _analyticsService.trackCopilotOpened();
    initialized = true;
    notifyListeners();
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
    languageCode = code;
    await _languageRepository.save(code);
    notifyListeners();
  }

  Future<void> updateConfig(AdminConfig newConfig) async {
    config = await _adminConfigRepository.saveConfig(newConfig);
    notifyListeners();
  }
}
