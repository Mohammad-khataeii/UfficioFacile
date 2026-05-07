import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';
import '../features/italy_admin_copilot/application/admin_controller.dart';
import '../features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';
import '../features/italy_admin_copilot/application/procedure_controller.dart';
import '../features/italy_admin_copilot/application/profile_controller.dart';
import '../features/italy_admin_copilot/application/request_controller.dart';
import '../features/italy_admin_copilot/application/utility_controller.dart';
import '../features/italy_admin_copilot/data/generated_pack_quality_service.dart';
import '../features/italy_admin_copilot/data/bundled_catalog_repository.dart';
import '../features/italy_admin_copilot/data/hybrid_catalog_repository.dart';
import '../features/italy_admin_copilot/data/local_admin_config_repository.dart';
import '../features/italy_admin_copilot/data/local_analytics_service.dart';
import '../features/italy_admin_copilot/data/local_draft_repository.dart';
import '../features/italy_admin_copilot/data/local_onboarding_repository.dart';
import '../features/italy_admin_copilot/data/local_profile_repository.dart';
import '../features/italy_admin_copilot/data/local_request_repository.dart';
import '../features/italy_admin_copilot/data/local_template_override_repository.dart';
import '../features/italy_admin_copilot/data/life_admin_phase5_services.dart';
import '../features/italy_admin_copilot/data/premium_service.dart';
import '../features/italy_admin_copilot/data/supabase_catalog_repository.dart';
import '../features/italy_admin_copilot/data/ufficio_product_services.dart';
import '../features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart';
import 'supabase_bootstrap.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required SharedPreferences prefs,
    required this.config,
    required this.supabaseBootstrapResult,
    required super.child,
  }) : _prefs = prefs {
    final analytics = LocalAnalyticsService(prefs);
    appController = ItalyAdminCopilotController(
      appConfig: config,
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
    problemRequestsRepository = LocalProblemRequestsRepository.fromPrefs(prefs);
    consultancyRequestsRepository = LocalConsultancyRequestsRepository.fromPrefs(
      prefs,
    );
    costItemsRepository = LocalCostItemsRepository.fromPrefs(prefs);
    directoryContactsRepository = LocalDirectoryContactsRepository.fromPrefs(
      prefs,
    );
    directoryDocumentsRepository = LocalDirectoryDocumentsRepository.fromPrefs(
      prefs,
    );
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
    authFacade = UfficcioAuthFacade(config);
    bundledCatalogRepository = const BundledCatalogRepository();
    catalogRepository = HybridCatalogRepository(
      bundled: bundledCatalogRepository,
      remote: config.isSupabaseEnabled && SupabaseBootstrap.client != null
          ? SupabaseCatalogRepository(SupabaseBootstrap.client!)
          : null,
      prefs: prefs,
    );
    userSettingsRepository = LocalUfficcioUserSettingsRepository(prefs);
    entitlementRepository = LocalUfficcioEntitlementRepository(prefs);
    premiumConfigRepository = LocalPremiumConfigRepository(
      prefs,
      remoteLoader: catalogRepository.getPremiumPublicConfig,
    );
    repositoryFactory = UfficcioRepositoryFactory(
      config: config,
      authFacade: authFacade,
      localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
      localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
      localSettingsRepository: userSettingsRepository,
      localEntitlementRepository: entitlementRepository,
    );
    syncService = UfficcioSyncService(
      factory: repositoryFactory,
      settingsRepository: userSettingsRepository,
    );
    privacyCenterService = LocalPrivacyCenterService(prefs);
    entitlementService = UfficioPremiumEntitlementService(
      entitlementRepository,
      premiumConfigRepository,
      analytics: analytics,
    );
    productEntitlementsService = EntitlementsService(entitlementService);
    problemRequestsService = ProblemRequestsService(problemRequestsRepository);
    consultancyService = ConsultancyService(consultancyRequestsRepository);
    costDashboardService = CostDashboardService(costItemsRepository);
    contactsDirectoryService = ContactsDirectoryService(
      directoryContactsRepository,
    );
    documentsService = DocumentsService(directoryDocumentsRepository);
  }

  final SharedPreferences _prefs;
  final UfficcioFacileConfig config;
  final SupabaseBootstrapResult supabaseBootstrapResult;

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
  late final LocalProblemRequestsRepository problemRequestsRepository;
  late final LocalConsultancyRequestsRepository consultancyRequestsRepository;
  late final LocalCostItemsRepository costItemsRepository;
  late final LocalDirectoryContactsRepository directoryContactsRepository;
  late final LocalDirectoryDocumentsRepository directoryDocumentsRepository;
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
  late final BundledCatalogRepository bundledCatalogRepository;
  late final HybridCatalogRepository catalogRepository;
  late final UfficcioAuthFacade authFacade;
  late final LocalUfficcioUserSettingsRepository userSettingsRepository;
  late final LocalUfficcioEntitlementRepository entitlementRepository;
  late final LocalPremiumConfigRepository premiumConfigRepository;
  late final UfficcioRepositoryFactory repositoryFactory;
  late final UfficcioSyncService syncService;
  late final LocalPrivacyCenterService privacyCenterService;
  late final UfficioPremiumEntitlementService entitlementService;
  late final EntitlementsService productEntitlementsService;
  late final ProblemRequestsService problemRequestsService;
  late final ConsultancyService consultancyService;
  late final CostDashboardService costDashboardService;
  late final ContactsDirectoryService contactsDirectoryService;
  late final DocumentsService documentsService;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(oldWidget._prefs, _prefs);
}
