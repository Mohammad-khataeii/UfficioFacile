import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/italy_admin_copilot/application/admin_controller.dart';
import '../features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';
import '../features/italy_admin_copilot/application/procedure_controller.dart';
import '../features/italy_admin_copilot/application/profile_controller.dart';
import '../features/italy_admin_copilot/application/request_controller.dart';
import '../features/italy_admin_copilot/application/utility_controller.dart';
import '../features/italy_admin_copilot/data/generated_pack_quality_service.dart';
import '../features/italy_admin_copilot/data/local_admin_config_repository.dart';
import '../features/italy_admin_copilot/data/local_analytics_service.dart';
import '../features/italy_admin_copilot/data/local_draft_repository.dart';
import '../features/italy_admin_copilot/data/local_onboarding_repository.dart';
import '../features/italy_admin_copilot/data/local_profile_repository.dart';
import '../features/italy_admin_copilot/data/local_request_repository.dart';
import '../features/italy_admin_copilot/data/local_template_override_repository.dart';
import '../features/italy_admin_copilot/data/life_admin_phase5_services.dart';

class AppScope extends InheritedWidget {
  AppScope({super.key, required SharedPreferences prefs, required super.child})
    : _prefs = prefs {
    final analytics = LocalAnalyticsService(prefs);
    appController = ItalyAdminCopilotController(
      onboardingRepository: LocalOnboardingRepository(prefs),
      adminConfigRepository: LocalAdminConfigRepository(prefs),
      analyticsService: analytics,
      languageRepository: LocalAppLanguageRepository(prefs),
    );
    procedureController = ProcedureController();
    profileController = ProfileController(
      LocalAdminCopilotProfileRepository(prefs),
    );
    requestController = RequestController(
      LocalAdminCopilotRequestRepository(prefs),
      LocalDraftRepository(prefs),
      analytics,
    );
    utilityController = UtilityController();
    adminController = AdminController(
      LocalProcedureTemplateOverrideRepository(prefs),
      analytics,
      GeneratedPackQualityService(),
      requestController,
      profileController,
    );
    documentsRepository = LocalDocumentsRepository.fromPrefs(prefs);
    contactsRepository = LocalContactsRepository.fromPrefs(prefs);
    contractsRepository = LocalContractsRepository.fromPrefs(prefs);
    householdRepository = LocalHouseholdRepository.fromPrefs(prefs);
    clientsRepository = LocalClientsRepository.fromPrefs(prefs);
    deadlinesRepository = LocalDeadlinesRepository.fromPrefs(prefs);
    templatesRepository = LocalTemplatesRepository.fromPrefs(prefs);
    proofFolderRepository = LocalProofFolderRepository.fromPrefs(prefs);
    beforeSendingRepository = LocalBeforeSendingRepository.fromPrefs(prefs);
    officialLinksOverrideRepository =
        LocalOfficialLinksOverrideRepository.fromPrefs(prefs);
    telegramHandoffRepository = LocalTelegramHandoffRepository.fromPrefs(prefs);
    profileCompletenessService = ProfileCompletenessService();
    profileAutofillService = ProfileAutofillService();
    cityPackService = CityPackService();
    checklistService = ItalyLifeChecklistService();
    situationScannerService = SituationScannerService();
    attachmentRequirementEngine = AttachmentRequirementEngine();
    requestReadinessService = RequestReadinessService();
    nextActionService = NextActionService();
    calendarService = LifeAdminCalendarService();
    costInsightService = CostInsightService();
    telegramHandoffService = TelegramHandoffService();
    officialLinksDirectoryService = OfficialLinksDirectoryService();
    localizationInspectorService = LocalizationInspectorService();
  }

  final SharedPreferences _prefs;

  late final ItalyAdminCopilotController appController;
  late final ProcedureController procedureController;
  late final ProfileController profileController;
  late final RequestController requestController;
  late final UtilityController utilityController;
  late final AdminController adminController;
  late final LocalDocumentsRepository documentsRepository;
  late final LocalContactsRepository contactsRepository;
  late final LocalContractsRepository contractsRepository;
  late final LocalHouseholdRepository householdRepository;
  late final LocalClientsRepository clientsRepository;
  late final LocalDeadlinesRepository deadlinesRepository;
  late final LocalTemplatesRepository templatesRepository;
  late final LocalProofFolderRepository proofFolderRepository;
  late final LocalBeforeSendingRepository beforeSendingRepository;
  late final LocalOfficialLinksOverrideRepository
  officialLinksOverrideRepository;
  late final LocalTelegramHandoffRepository telegramHandoffRepository;
  late final ProfileCompletenessService profileCompletenessService;
  late final ProfileAutofillService profileAutofillService;
  late final CityPackService cityPackService;
  late final ItalyLifeChecklistService checklistService;
  late final SituationScannerService situationScannerService;
  late final AttachmentRequirementEngine attachmentRequirementEngine;
  late final RequestReadinessService requestReadinessService;
  late final NextActionService nextActionService;
  late final LifeAdminCalendarService calendarService;
  late final CostInsightService costInsightService;
  late final TelegramHandoffService telegramHandoffService;
  late final OfficialLinksDirectoryService officialLinksDirectoryService;
  late final LocalizationInspectorService localizationInspectorService;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(oldWidget._prefs, _prefs);
}
