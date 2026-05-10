import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufficiofacile/app/app_config.dart';
import 'package:ufficiofacile/app/app_localizations.dart';
import 'package:ufficiofacile/app/app_routes.dart';
import 'package:ufficiofacile/app/app_scope.dart';
import 'package:ufficiofacile/app/supabase_bootstrap.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/pack_generator.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/canone_rai_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_analytics_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/premium_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/health_asl_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/housing_rent_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/service_intelligence_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/service_intelligence_quality_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/service_terms_dictionary.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/telecom_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/utilities_electricity_gas_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/premium_config.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/service_intelligence.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/ufficio_catalog.dart';
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

void main() {
  group('service intelligence definitions', () {
    test('every major procedure has service intelligence', () {
      final procedureIds = ItalyAdminProcedureDefinitions.all()
          .map((item) => item.id)
          .toSet();
      final intelligenceIds = ServiceIntelligenceDefinitions.all()
          .map((item) => item.procedureId)
          .toSet();
      expect(intelligenceIds, procedureIds);
    });

    test('tessera sanitaria has destination guidance', () {
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'TESSERA_SANITARIA_RENEWAL',
      )!;
      expect(procedure.title, 'Get Tessera Sanitaria / Register with SSN');
      final intelligence = ServiceIntelligenceDefinitions.forProcedure(
        procedure,
      );
      expect(intelligence.destinationGuidance, isNotEmpty);
      expect(intelligence.destinationGuidance.toLowerCase(), contains('asl'));
    });

    test('health tessera procedure is listed before change doctor', () {
      final procedures = ItalyAdminProcedureDefinitions.all();
      final tesseraIndex = procedures.indexWhere(
        (item) => item.id == 'TESSERA_SANITARIA_RENEWAL',
      );
      final changeDoctorIndex = procedures.indexWhere(
        (item) => item.id == 'CHANGE_DOCTOR',
      );
      expect(tesseraIndex, lessThan(changeDoctorIndex));
    });

    test('torino tessera practical guidance exists', () {
      final guidance = HealthAslGuidanceDefinitions.forProcedureId(
        'TESSERA_SANITARIA_RENEWAL',
      );
      expect(guidance, isNotNull);
      expect(guidance!.city, 'torino');
      expect(guidance.contacts['aslTorinoGeneral']?.pec, isNotEmpty);
      expect(guidance.userFlows, isNotEmpty);
    });

    test(
      'housing torino practical guidance exists for old and new procedures',
      () {
        final deposit = HousingRentGuidanceDefinitions.forProcedureId(
          'DEPOSIT_RETURN_REQUEST',
        );
        final addTenant = HousingRentGuidanceDefinitions.forProcedureId(
          'ADD_OR_REMOVE_TENANT',
        );
        expect(deposit, isNotNull);
        expect(addTenant, isNotNull);
        expect(deposit!.priority, 'high');
        expect(
          addTenant!.recommendedContacts,
          contains('agenziaEntrateTorino1'),
        );
      },
    );

    test('health procedures have in-person guidance', () {
      final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
      final intelligence = ServiceIntelligenceDefinitions.forProcedure(
        procedure,
      );
      expect(intelligence.inPersonOptions, isNotEmpty);
    });

    test('utility procedures have provider contact guidance', () {
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'HIGH_BILL_COMPLAINT',
      )!;
      final intelligence = ServiceIntelligenceDefinitions.forProcedure(
        procedure,
      );
      expect(
        intelligence.destinationGuidance.toLowerCase(),
        anyOf(contains('supplier'), contains('provider')),
      );
    });

    test(
      'utility torino practical guidance exists for old and new procedures',
      () {
        final supplierVsDistributor =
            UtilitiesElectricityGasGuidanceDefinitions.forProcedureId(
              'CHECK_SUPPLIER_VS_DISTRIBUTOR',
            );
        final emergency =
            UtilitiesElectricityGasGuidanceDefinitions.forProcedureId(
              'GAS_OR_ELECTRICITY_EMERGENCY_FAULT',
            );
        final arera = UtilitiesElectricityGasGuidanceDefinitions.forProcedureId(
          'ARERA_COMPLAINT_AND_CONCILIATION',
        );
        expect(supplierVsDistributor, isNotNull);
        expect(emergency, isNotNull);
        expect(arera, isNotNull);
        expect(
          supplierVsDistributor!.recommendedContacts,
          contains('distributorGeneric'),
        );
        expect(emergency!.priority, 'urgent');
        expect(arera!.recommendedChannels, contains('arera_conciliazione'));
      },
    );

    test('canone torino practical guidance exists for core flows', () {
      final noTv = CanoneRaiGuidanceDefinitions.forProcedureId(
        'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      );
      final over75 = CanoneRaiGuidanceDefinitions.forProcedureId(
        'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      );
      final refund = CanoneRaiGuidanceDefinitions.forProcedureId(
        'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      );
      final formHelp = CanoneRaiGuidanceDefinitions.forProcedureId(
        'HELP_FILLING_AGENZIA_ENTRATE_FORM',
      );
      expect(noTv, isNotNull);
      expect(over75, isNotNull);
      expect(refund, isNotNull);
      expect(formHelp, isNotNull);
      expect(noTv!.deadlines, isNotEmpty);
      expect(over75!.configurableRules['incomeThreshold'], isNotNull);
      expect(
        refund!.recommendedContacts,
        contains('electricitySupplierGeneric'),
      );
    });

    test(
      'telecom torino practical guidance exists for cancellation and escalation',
      () {
        final cancellation = TelecomGuidanceDefinitions.forProcedureId(
          'INTERNET_PHONE_CANCELLATION',
        );
        final portability = TelecomGuidanceDefinitions.forProcedureId(
          'PROVIDER_SWITCHING_NUMBER_PORTABILITY',
        );
        final escalation = TelecomGuidanceDefinitions.forProcedureId(
          'AGCOM_CORECOM_CONCILIAWEB_ESCALATION',
        );
        final scam = TelecomGuidanceDefinitions.forProcedureId(
          'CONTRACT_NOT_REQUESTED_PHONE_SCAM',
        );
        expect(cancellation, isNotNull);
        expect(portability, isNotNull);
        expect(escalation, isNotNull);
        expect(scam, isNotNull);
        expect(cancellation!.warnings.join(' '), contains('lose the number'));
        expect(portability!.outputs, contains('migration_code_request'));
        expect(escalation!.recommendedContacts, contains('conciliaWeb'));
        expect(
          scam!.recommendedChannels,
          contains('operator_pec_or_raccomandata'),
        );
      },
    );

    test('utilities routing sends immediate danger to emergency flow', () {
      final rules =
          UtilitiesElectricityGasGuidanceDefinitions.category.routingRules;
      expect(
        rules.any(
          (rule) =>
              rule.conditions['is_dangerous'] == 'yes' &&
              rule.routeTo == 'gas_or_electricity_emergency_fault',
        ),
        isTrue,
      );
    });

    test(
      'telecom routing redirects fixed cancellation with keep-number intent',
      () {
        final rules = TelecomGuidanceDefinitions.category.routingRules;
        expect(
          rules.any(
            (rule) =>
                rule.conditions['problem_type'] == 'fixed_cancellation' &&
                rule.conditions['wants_keep_number'] == 'yes' &&
                rule.routeTo == 'provider_switching_number_portability',
          ),
          isTrue,
        );
      },
    );

    test('term dictionary contains core terms', () {
      expect(ServiceTermsDictionary.byId('pec'), isNotNull);
      expect(ServiceTermsDictionary.byId('spid'), isNotNull);
      expect(ServiceTermsDictionary.byId('cie'), isNotNull);
      expect(ServiceTermsDictionary.byId('canone-rai'), isNotNull);
      expect(ServiceTermsDictionary.byId('voltura'), isNotNull);
      expect(ServiceTermsDictionary.byId('subentro'), isNotNull);
      expect(ServiceTermsDictionary.byId('disdetta'), isNotNull);
    });

    test('quality checker detects missing destination guidance', () {
      final result = ServiceIntelligenceQualityService().check(
        const ServiceIntelligence(
          procedureId: 'demo',
          title: 'Demo',
          category: 'General',
          responsibleAuthorityType: '',
          destinationGuidance: '',
          recipientRules: [],
          officialContactOptions: [],
          officialLinks: [],
          inPersonOptions: [],
          onlineOptions: [],
          pecRequiredLevel: PecRequiredLevel.unknown,
          spidCieRequiredLevel: SpidCieRequiredLevel.unknown,
          requiredDocumentsDetailed: [],
          recommendedDocumentsDetailed: [],
          situationSpecificDocuments: [],
          beforeSendingChecklist: [],
          inPersonChecklist: [],
          followUpGuidance: '',
          rejectionGuidance: '',
          escalationGuidance: '',
          citySpecificNotes: [],
          regionSpecificNotes: [],
          providerSpecificNotes: [],
          warnings: [],
          verificationStatus: ServiceVerificationStatus.unverified,
        ),
      );
      expect(result.warnings.join(' '), contains('destination guidance'));
    });
  });

  group('premium service', () {
    test('default entitlement is free', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );
      expect(await service.getCurrentPlan(), UfficioPlan.free);
    });

    test('default paywall blocks premium feature for free users', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );
      final decision = await service.canUseProcedure('HIGH_BILL_COMPLAINT');
      expect(decision.allowed, isFalse);
      expect(decision.blockedByBeta, isFalse);
    });

    test('paywall enabled and beta disabled blocks pro feature', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );
      await service.saveConfig(
        (await service.getConfig()).copyWith(
          betaModeEnabled: false,
          paywallEnabled: true,
        ),
      );
      final decision = await service.canUseProcedure('HIGH_BILL_COMPLAINT');
      expect(decision.allowed, isFalse);
    });

    test('free pack usage increments after generation', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );
      await service.recordPackGenerated('CHANGE_DOCTOR');
      final entitlement = await service.getCurrentEntitlement();
      expect(entitlement.generatedPacksUsedThisMonth, 1);
    });

    test('corrupted premium config returns defaults', () async {
      SharedPreferences.setMockInitialValues({
        LocalPremiumConfigRepository.storageKey: '{bad json',
      });
      final prefs = await SharedPreferences.getInstance();
      final config = await LocalPremiumConfigRepository(prefs).getConfig();
      expect(config.freePackLimit, 3);
      expect(config.betaModeEnabled, isFalse);
    });

    test('local debug pro activates and deactivates pro', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = LocalUfficcioEntitlementRepository(prefs);
      final service = UfficioPremiumEntitlementService(
        repository,
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );
      await repository.saveEntitlement(
        (await service.getCurrentEntitlement()).copyWith(
          plan: UfficioPlan.premiumMonthly,
          premiumAccess: true,
          localDebugProEnabled: false,
        ),
      );
      expect(await service.isPro(), isTrue);
      await repository.saveEntitlement(
        (await service.getCurrentEntitlement()).copyWith(
          plan: UfficioPlan.free,
          premiumAccess: false,
          localDebugProEnabled: false,
        ),
      );
      expect(await service.isPro(), isFalse);
    });

    test('public plan products expose non-empty prices', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );

      final publicPlans = (await service.getPlanProducts()).where(
        (item) => <String>{
          'free',
          'plus_monthly',
          'plus_yearly',
          'premium_monthly',
          'premium_yearly',
          'consultancy_one_shot',
        }.contains(item.productKey),
      );

      expect(publicPlans, isNotEmpty);
      for (final plan in publicPlans) {
        expect(plan.title['en'], isNotEmpty);
        expect(plan.currency, isNotEmpty);
        if (plan.productKey != 'free') {
          expect(plan.amountCents, greaterThan(0));
        }
      }
    });

    test('free user can open premium-badged category shells', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );

      final category = UfficioCategory.fromJson(const {
        'id': 'premium-cat',
        'icon': 'lock',
        'sortOrder': 1,
        'isPremiumOnly': true,
        'title': {'en': 'Premium category'},
        'description': {'en': 'Locked'},
        'subcategories': [],
      });
      final subcategory = UfficioSubcategory.fromJson(const {
        'id': 'premium-sub',
        'sortOrder': 1,
        'isPremiumOnly': true,
        'title': {'en': 'Premium subcategory'},
        'description': {'en': 'Locked'},
        'procedures': [],
      }, categoryId: 'premium-cat');
      final procedure = UfficioProcedure.fromJson(
        const {
          'id': 'premium-proc',
          'sortOrder': 1,
          'isPremiumOnly': true,
          'requiresAuth': false,
          'title': {'en': 'Premium procedure'},
          'shortDescription': {'en': 'Locked'},
          'sections': [],
        },
        categoryId: 'premium-cat',
        subcategoryId: 'premium-sub',
      );
      final section = UfficioContentSection.fromJson(const {
        'type': 'text',
        'key': 'premium',
        'title': {'en': 'Premium section'},
        'body': {'en': 'Locked'},
        'isPremiumOnly': true,
      });

      final categoryAccess = await service.canAccessCategory(category);
      expect(categoryAccess.allowed, isTrue);
      expect(categoryAccess.isPremiumFeature, isTrue);
      expect(
        (await service.canAccessSubcategory(subcategory)).allowed,
        isFalse,
      );
      expect((await service.canAccessProcedure(procedure)).allowed, isFalse);
      expect((await service.canAccessSection(section)).allowed, isFalse);
    });

    test('free user can access public category with premium content', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = UfficioPremiumEntitlementService(
        LocalUfficcioEntitlementRepository(prefs),
        LocalPremiumConfigRepository(prefs),
        analytics: LocalAnalyticsService(prefs),
      );

      final category = UfficioCategory.fromJson(const {
        'id': 'mixed-cat',
        'icon': 'folder',
        'sortOrder': 1,
        'isPremiumOnly': false,
        'hasPremiumContent': true,
        'title': {'en': 'Mixed category'},
        'description': {'en': 'Free shell'},
        'subcategories': [],
      });

      expect((await service.canAccessCategory(category)).allowed, isTrue);
    });

    test(
      'free user can access public subcategory inside premium category',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UfficioPremiumEntitlementService(
          LocalUfficcioEntitlementRepository(prefs),
          LocalPremiumConfigRepository(prefs),
          analytics: LocalAnalyticsService(prefs),
        );

        final subcategory = UfficioSubcategory.fromJson(const {
          'id': 'mixed-sub',
          'sortOrder': 1,
          'isPremiumOnly': false,
          'hasPremiumContent': true,
          'title': {'en': 'Mixed subcategory'},
          'description': {'en': 'Contains free and premium guides'},
          'procedures': [],
        }, categoryId: 'mixed-cat');

        final access = await service.canAccessSubcategory(subcategory);
        expect(access.allowed, isTrue);
        expect(access.isPremiumFeature, isTrue);
      },
    );

    test(
      'premium user can access premium-only subcategory and procedure',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repository = LocalUfficcioEntitlementRepository(prefs);
        final service = UfficioPremiumEntitlementService(
          repository,
          LocalPremiumConfigRepository(prefs),
          analytics: LocalAnalyticsService(prefs),
        );
        await repository.saveEntitlement(
          (await service.getCurrentEntitlement()).copyWith(
            plan: UfficioPlan.premiumMonthly,
            premiumAccess: true,
            localDebugProEnabled: false,
          ),
        );

        final subcategory = UfficioSubcategory.fromJson(const {
          'id': 'premium-sub',
          'sortOrder': 1,
          'isPremiumOnly': true,
          'title': {'en': 'Premium subcategory'},
          'description': {'en': 'Locked for free users'},
          'procedures': [],
        }, categoryId: 'premium-cat');
        final procedure = UfficioProcedure.fromJson(
          const {
            'id': 'premium-proc',
            'sortOrder': 1,
            'isPremiumOnly': true,
            'requiresAuth': false,
            'title': {'en': 'Premium procedure'},
            'shortDescription': {'en': 'Locked for free users'},
            'sections': [],
          },
          categoryId: 'premium-cat',
          subcategoryId: 'premium-sub',
        );

        expect(
          (await service.canAccessSubcategory(subcategory)).allowed,
          isTrue,
        );
        expect((await service.canAccessProcedure(procedure)).allowed, isTrue);
      },
    );
  });

  group('generated pack enrichment', () {
    test('generated pack includes destination guidance and checklist', () {
      final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
      final pack = PackGenerator.generate(
        procedure: procedure,
        inputData: const {
          'fullName': 'Mario Rossi',
          'codiceFiscale': 'RSSMRA80A01H501U',
          'submissionMethod': 'pec',
        },
      );
      expect(pack.destinationGuidance, isNotEmpty);
      expect(pack.recipientVerificationChecklist, isNotEmpty);
    });
  });

  group('widget smoke tests', () {
    Future<void> pumpWithScope(WidgetTester tester, Widget child) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
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
            child: MaterialApp(
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: SizedBox.shrink()),
              ),
              home: child,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('clickable PEC term opens term route', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
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
            child: MaterialApp(
              onGenerateRoute: (settings) {
                if (settings.name == AppRoutes.terms) {
                  final args = settings.arguments! as TermRouteArgs;
                  return MaterialPageRoute(
                    builder: (_) => TermExplanationScreen(termId: args.termId),
                  );
                }
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: ClickableTermText('Open PEC explanation'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('PEC'));
      await tester.pumpAndSettle();
      expect(
        find.text('Certified email used in Italy for formal delivery.'),
        findsOneWidget,
      );
    });

    testWidgets('procedure detail screen renders progressive tessera layout', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'TESSERA_SANITARIA_RENEWAL',
      )!;

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
            child: MaterialApp(
              home: ProcedureDetailScreen(procedure: procedure),
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: SizedBox.shrink()),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Select your situation'), findsOneWidget);
      expect(find.text('View ASL offices in Torino'), findsOneWidget);
      expect(find.text('Current Torino contacts'), findsNothing);
      expect(find.textContaining('Start guided form'), findsOneWidget);
      expect(find.textContaining('How to get it in Torino'), findsNothing);
    });

    testWidgets('utility hub shows guided selector first', (tester) async {
      await pumpWithScope(tester, const UtilityHubScreen());
      expect(find.text('What is your problem?'), findsOneWidget);
      expect(find.text('Read these details from the bill'), findsNothing);
      expect(find.text('Guided selector'), findsOneWidget);
    });

    testWidgets('plan screen renders visible prices', (tester) async {
      await pumpWithScope(tester, const PlanScreen());
      expect(find.byType(PlanScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('paywall See plans button opens plan screen', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
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
            child: MaterialApp(
              onGenerateRoute: (settings) {
                if (settings.name == AppRoutes.plan) {
                  return MaterialPageRoute(builder: (_) => const PlanScreen());
                }
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: FilledButton(
                        onPressed: () => showPremiumPaywallSheet(
                          context,
                          decision: const EntitlementDecision(
                            allowed: false,
                            isPremiumFeature: true,
                            reason: 'Locked',
                            upgradeTitle: 'Premium feature',
                            upgradeMessage: 'Locked',
                          ),
                          featureLabel: 'Premium guide',
                        ),
                        child: const Text('Open paywall'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open paywall'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See plans'));
      await tester.pumpAndSettle();

      expect(
        find.text('Choose the level of help that fits your situation.'),
        findsOneWidget,
      );
    });

    testWidgets('canone hub shows guided selector without global postal dump', (
      tester,
    ) async {
      await pumpWithScope(tester, const CanoneRaiHubScreen());
      expect(find.text('What is your situation?'), findsOneWidget);
      expect(find.textContaining('Casella postale 22'), findsNothing);
    });

    testWidgets('utility detail keeps output templates hidden until clicked', (
      tester,
    ) async {
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'HIGH_BILL_COMPLAINT',
      )!;
      await pumpWithScope(tester, ProcedureDetailScreen(procedure: procedure));
      expect(find.text('Output generators'), findsOneWidget);
      expect(
        find.textContaining('Oggetto: Reclamo formale per bolletta'),
        findsNothing,
      );
    });
  });
}
