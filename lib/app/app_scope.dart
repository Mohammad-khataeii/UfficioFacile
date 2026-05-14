import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';
import '../features/admin/application/admin_panel_controller.dart';
import '../features/admin/data/admin_repository.dart';
import '../features/admin/data/local_admin_repository.dart';
import '../features/admin/data/supabase_admin_repository.dart';
import '../features/admin_cms/application/cms_content_controller.dart';
import '../features/admin_cms/data/cms_repository.dart';
import '../features/admin_cms/data/local_cms_repository.dart';
import '../features/admin_cms/data/supabase_cms_repository.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/device_binding_service.dart';
import '../features/auth/data/supabase_auth_repository.dart';
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
import '../features/italy_admin_copilot/data/ufficio_catalog_repository.dart';
import '../features/italy_admin_copilot/data/ufficio_city_registry.dart';
import '../features/italy_admin_copilot/data/ufficio_product_services.dart';
import '../features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart';
import 'supabase_bootstrap.dart';
import 'screenshot_protection_service.dart';

class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required SharedPreferences prefs,
    required this.config,
    required this.supabaseBootstrapResult,
    required super.child,
  }) : _prefs = prefs {
    authRepository =
        config.isSupabaseEnabled && SupabaseBootstrap.client != null
        ? SupabaseAuthRepository(SupabaseBootstrap.client!)
        : LocalAuthRepository(prefs);
    deviceBindingService = DeviceBindingService(prefs);
    screenshotProtectionService = ScreenshotProtectionService();
    final analytics = LocalAnalyticsService(prefs);
    appController = ItalyAdminCopilotController(
      appConfig: config,
      onboardingRepository: LocalOnboardingRepository(prefs),
      adminConfigRepository: LocalAdminConfigRepository(prefs),
      analyticsService: analytics,
      languageRepository: LocalAppLanguageRepository(prefs),
    );
    procedureController = ProcedureController();
    localProfileRepository = LocalAdminCopilotProfileRepository(prefs);
    requestController = RequestController(
      LocalAdminCopilotRequestRepository(prefs),
      LocalDraftRepository(prefs),
      analytics,
    );
    utilityController = UtilityController();
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
    consultancyRequestsRepository =
        LocalConsultancyRequestsRepository.fromPrefs(prefs);
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
    adminRepository =
        config.isSupabaseEnabled && SupabaseBootstrap.client != null
        ? SupabaseAdminRepository(SupabaseBootstrap.client!)
        : const LocalAdminRepository();
    adminPanelController = AdminPanelController(adminRepository);
    cmsRepository = config.isSupabaseEnabled && SupabaseBootstrap.client != null
        ? SupabaseCmsRepository(SupabaseBootstrap.client!)
        : const LocalCmsRepository();
    cmsContentController = CmsContentController(cmsRepository);
    hybridProblemRequestsRepository = HybridProblemRequestsRepository(
      local: problemRequestsRepository,
      config: config,
      authFacade: authFacade,
    );
    hybridConsultancyRequestsRepository = HybridConsultancyRequestsRepository(
      local: consultancyRequestsRepository,
      config: config,
      authFacade: authFacade,
    );
    bundledCatalogRepository = const BundledCatalogRepository();
    catalogRepository = HybridCatalogRepository(
      bundled: bundledCatalogRepository,
      remote: config.isSupabaseEnabled && SupabaseBootstrap.client != null
          ? SupabaseCatalogRepository(SupabaseBootstrap.client!)
          : null,
      prefs: prefs,
    );
    ufficioCatalogRepository = UfficioCatalogRepository(
      cmsRepository,
      selectedCitySlugLoader: () async => UfficioCityRegistry.normalizeSlug(
        profileController.profile.selectedCityPackId,
      ),
    );
    userSettingsRepository = LocalUfficcioUserSettingsRepository(prefs);
    entitlementRepository = LocalUfficcioEntitlementRepository(prefs);
    repositoryFactory = UfficcioRepositoryFactory(
      config: config,
      authFacade: authFacade,
      localProfileRepository: localProfileRepository,
      localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
      localSettingsRepository: userSettingsRepository,
      localEntitlementRepository: entitlementRepository,
    );
    profileController = ProfileController(
      MergedAdminCopilotProfileRepository(
        factory: repositoryFactory,
        settingsRepository: userSettingsRepository,
        localRepository: localProfileRepository,
        authFacade: authFacade,
      ),
    );
    adminController = AdminController(
      LocalProcedureTemplateOverrideRepository(prefs),
      analytics,
      GeneratedPackQualityService(),
      requestController,
      profileController,
    );
    mergedEntitlementRepository = MergedUfficcioEntitlementRepository(
      factory: repositoryFactory,
      settingsRepository: userSettingsRepository,
      localRepository: entitlementRepository,
    );
    premiumConfigRepository = LocalPremiumConfigRepository(
      prefs,
      remoteLoader: catalogRepository.getPremiumPublicConfig,
    );
    syncService = UfficcioSyncService(
      factory: repositoryFactory,
      settingsRepository: userSettingsRepository,
    );
    privacyCenterService = LocalPrivacyCenterService(prefs);
    entitlementService = UfficioPremiumEntitlementService(
      mergedEntitlementRepository,
      premiumConfigRepository,
      analytics: analytics,
    );
    productEntitlementsService = EntitlementsService(entitlementService);
    problemRequestsService = ProblemRequestsService(
      hybridProblemRequestsRepository,
      entitlementService,
    );
    consultancyService = ConsultancyService(
      hybridConsultancyRequestsRepository,
      entitlementService,
    );
    costDashboardService = CostDashboardService(costItemsRepository);
    contactsDirectoryService = ContactsDirectoryService(
      directoryContactsRepository,
    );
    documentsService = DocumentsService(directoryDocumentsRepository);
    authController = AuthController(
      authRepository,
      beforeAuthChange: clearAuthSensitiveState,
      afterAuthenticated: (user) async {
        await deviceBindingService.enforceForSignedInUser(user);
        await reloadAuthSensitiveState();
      },
      afterSignedOut: () async {
        await clearAuthSensitiveState();
        await updateScreenshotProtection();
      },
    );
    unawaited(updateScreenshotProtection());
  }

  final SharedPreferences _prefs;
  final UfficcioFacileConfig config;
  final SupabaseBootstrapResult supabaseBootstrapResult;

  late final AuthRepository authRepository;
  late final AuthController authController;
  late final DeviceBindingService deviceBindingService;
  late final ScreenshotProtectionService screenshotProtectionService;
  late final ItalyAdminCopilotController appController;
  late final ProcedureController procedureController;
  late final LocalAdminCopilotProfileRepository localProfileRepository;
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
  late final HybridProblemRequestsRepository hybridProblemRequestsRepository;
  late final HybridConsultancyRequestsRepository
  hybridConsultancyRequestsRepository;
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
  late final UfficioCatalogRepository ufficioCatalogRepository;
  late final UfficcioAuthFacade authFacade;
  late final AdminRepository adminRepository;
  late final AdminPanelController adminPanelController;
  late final CmsRepository cmsRepository;
  late final CmsContentController cmsContentController;
  late final LocalUfficcioUserSettingsRepository userSettingsRepository;
  late final LocalUfficcioEntitlementRepository entitlementRepository;
  late final MergedUfficcioEntitlementRepository mergedEntitlementRepository;
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

  Future<void> clearAuthSensitiveState() async {
    const keysToRemove = <String>[
      LocalAdminCopilotProfileRepository.profileStorageKey,
      LocalAdminCopilotRequestRepository.requestsStorageKey,
      LocalAdminCopilotRequestRepository.draftsStorageKey,
      'italy_life_admin_documents_v1',
      'italy_life_admin_contacts_v1',
      'italy_life_admin_household_members_v1',
      'italy_life_admin_household_contracts_v1',
      'italy_life_admin_deadlines_v1',
      'italy_life_admin_templates_v1',
      'italy_life_admin_proof_cases_v1',
      'italy_life_admin_proof_items_v1',
      'italy_life_admin_before_sending_v1',
      'italy_life_admin_cost_items_v1',
      'italy_life_admin_directory_contacts_v1',
      'italy_life_admin_directory_documents_v1',
      'italy_life_admin_problem_requests_v1',
      'italy_life_admin_consultancy_requests_v1',
      'italy_life_admin_telegram_handoff_v1',
      LocalUfficcioEntitlementRepository.storageKey,
    ];
    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
    profileController.resetLocalState();
    await requestController.clearLocalState();
    await adminPanelController.reset();
    await updateScreenshotProtection();
  }

  Future<void> reloadAuthSensitiveState() async {
    await Future.wait([
      profileController.load(),
      requestController.load(),
      adminPanelController.load(),
      entitlementService.getCurrentEntitlement(),
    ]);
    await updateScreenshotProtection();
  }

  Future<void> updateScreenshotProtection() async {
    final entitlement = await entitlementService.getCurrentEntitlement();
    await screenshotProtectionService.setFreeAccountProtectionEnabled(
      !entitlement.hasActivePremiumEntitlement,
    );
  }

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(oldWidget._prefs, _prefs);
}
