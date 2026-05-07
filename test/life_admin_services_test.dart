import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:ufficiofacile/features/italy_admin_copilot/data/bill_analysis_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/canone_rai_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/demo_data_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/generated_pack_quality_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_admin_config_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_draft_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_onboarding_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_request_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/life_admin_phase5_services.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/pack_generator.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_recommendation_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_validator.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/red_flag_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/utility_comparison_service.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_config.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_copilot_profile.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_request.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/before_sending_checklist.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/bill_analysis.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/canone_rai_models.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/community_template.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/deadline_watch.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/draft.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/household_contract.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/household_member.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/life_admin_contact.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/life_admin_document.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/life_admin_mode.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/official_link.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/request_status.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/telegram_handoff.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/utility_comparison.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/utility_offer.dart';
import 'package:ufficiofacile/app/app_localizations.dart';

void main() {
  group('procedure catalog', () {
    test('contains at least 36 procedures with unique ids', () {
      final procedures = ItalyAdminProcedureDefinitions.all();
      expect(procedures.length, greaterThanOrEqualTo(36));
      expect(
        procedures.map((item) => item.id).toSet().length,
        procedures.length,
      );
    });

    test('search and recommender cover canone and electricity', () {
      final service = ProcedureRecommendationService();
      expect(
        service.recommend('remove canone rai').first.procedureId,
        'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      );
      expect(
        service.recommend('cheap electricity').first.procedureId,
        'ENERGY_SUPPLIER_COMPARISON',
      );
    });

    test(
      'multilingual recommender works for italian, spanish, persian, arabic',
      () {
        final service = ProcedureRecommendationService();
        expect(
          service.recommend('bolletta gas alta').first.procedureId,
          anyOf('HIGH_BILL_COMPLAINT', 'ENERGY_SUPPLIER_COMPARISON'),
        );
        expect(
          service.recommend('cancelar internet').first.procedureId,
          'INTERNET_PHONE_CANCELLATION',
        );
        expect(
          service.recommend('قبض برق بالا').first.procedureId,
          anyOf(
            'HIGH_BILL_COMPLAINT',
            'ENERGY_BILL_ANALYZER_CHECKLIST',
            'ENERGY_SUPPLIER_COMPARISON',
          ),
        );
        expect(
          service.recommend('إلغاء الإنترنت').first.procedureId,
          'INTERNET_PHONE_CANCELLATION',
        );
      },
    );
  });

  group('localization and profile', () {
    test('localization supports it/en/fa/fr and RTL for Persian', () {
      expect(
        AppLocalizations.supportedLocales.map((item) => item.languageCode),
        containsAll(['it', 'en', 'fa', 'fr']),
      );
      expect(AppLocalizations.rtlLanguages.contains('fa'), isTrue);
      expect(AppLocalizations.rtlLanguages.contains('fr'), isFalse);
    });

    test('selected language persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAppLanguageRepository(prefs);
      await repo.save('fa');
      expect(repo.read(), 'fa');
    });

    test('profile completeness and autofill work', () {
      const profile = AdminCopilotProfile(
        fullName: 'Mario Rossi',
        codiceFiscale: 'RSSMRA80A01H501U',
        city: 'Torino',
        email: 'mario@example.com',
        defaultComune: 'Torino',
        defaultAsl: 'ASL Torino',
        electricityProvider: 'Demo Energia',
      );
      expect(ProfileCompletenessService().score(profile), greaterThan(0));
      final autofill = ProfileAutofillService().autofill(profile);
      expect(autofill['fullName'], 'Mario Rossi');
      expect(autofill['cityOrComune'], 'Torino');
    });
  });

  group('validation and generation', () {
    test('validator catches missing required fields', () {
      final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
      final result = ProcedureValidator.validate(procedure, {});
      expect(result.ok, isFalse);
      expect(result.fieldErrors, isNotEmpty);
    });

    test('each procedure generates a complete pack', () {
      for (final procedure in ItalyAdminProcedureDefinitions.all()) {
        final input = <String, dynamic>{
          'fullName': 'Mario Rossi',
          'senderName': 'Mario Rossi',
          'codiceFiscale': 'RSSMRA80A01H501U',
          'provider': 'Demo Provider',
          'officeName': 'Demo Office',
          'recipient': 'Demo Recipient',
          'recipientNameOrOffice': 'Demo Office',
          'landlordOrAgencyName': 'Casa Torino',
          'propertyAddress': 'Via Roma 1',
          'topic': 'Support request',
          'request': 'I need help with this case',
          'reason': 'I need administrative support with this case',
          'situation': 'Demo situation',
          'billHolderName': 'Mario Rossi',
          'requestType': 'support',
          'cityOrComune': 'Torino',
          'utilityType': 'electricity',
          'offerAProvider': 'Offer A',
          'offerAName': 'Offer A',
          'offerBProvider': 'Offer B',
          'offerBName': 'Offer B',
          'desiredSolution': 'Please review and fix the issue',
          'issueDescription': 'Detailed issue description',
        };
        final pack = PackGenerator.generate(
          procedure: procedure,
          inputData: input,
        );
        expect(pack.subject, isNotEmpty);
        expect(pack.bodyItalian, isNotEmpty);
        expect(pack.bodyPecItalian, isNotEmpty);
        expect(pack.shortMessageItalian, isNotEmpty);
        expect(pack.whatsappMessageItalian, isNotEmpty);
        expect(pack.localizedExplanations['en'], isNotEmpty);
        expect(pack.fullText, contains('Questo strumento'));
      }
    });

    test('quality checker catches missing disclaimer and null', () {
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'GENERIC_FORMAL_REQUEST',
      )!;
      final pack = PackGenerator.generate(
        procedure: procedure,
        inputData: {
          'senderName': 'Mario Rossi',
          'recipientNameOrOffice': 'Demo Office',
          'topic': 'Topic',
          'situation': 'Situation',
          'request': 'Request',
        },
      ).copyWith(fullText: 'null');
      final quality = GeneratedPackQualityService().check(pack);
      expect(quality.ok, isFalse);
      expect(quality.warnings.join(' '), contains('Mandatory disclaimer'));
      expect(quality.warnings.join(' '), contains('null'));
    });
  });

  group('utility and bill helpers', () {
    test(
      'utility comparison chooses lower annual cost and annualizes monthly',
      () {
        final result = UtilityComparisonService().compare(
          UtilityComparisonInput(
            utilityType: UtilityType.electricity,
            currentProvider: 'Current',
            currentMonthlyCost: 100,
            residentDomestic: true,
            offers: const [
              UtilityOffer(
                providerName: 'A',
                offerName: 'Offer A',
                utilityType: UtilityType.electricity,
                priceType: UtilityPriceType.fixed,
                estimatedAnnualCost: 900,
              ),
              UtilityOffer(
                providerName: 'B',
                offerName: 'Offer B',
                utilityType: UtilityType.electricity,
                priceType: UtilityPriceType.fixed,
                estimatedAnnualCost: 1100,
              ),
            ],
          ),
        );
        expect(result.bestOfferName, 'Offer A');
        expect(result.estimatedAnnualSavings, 300);
        expect(result.estimatedMonthlySavings, 25);
      },
    );

    test('utility comparison flags missing data', () {
      final result = UtilityComparisonService().compare(
        UtilityComparisonInput(
          utilityType: UtilityType.electricity,
          currentProvider: 'Current',
          offers: const [
            UtilityOffer(
              providerName: 'A',
              offerName: 'Offer A',
              utilityType: UtilityType.electricity,
              priceType: UtilityPriceType.unknown,
            ),
          ],
        ),
      );
      expect(result.missingData, isNotEmpty);
      expect(result.riskFlags, isNotEmpty);
    });

    test('bill analyzer flags canone rai and conguaglio', () {
      final result = BillAnalysisService().analyze(
        const BillAnalysisInput(
          billType: 'electricity',
          providerName: 'Demo',
          amount: 240,
          previousBillAmount: 110,
          readingType: 'estimated',
          hasCanoneRai: true,
          hasConguaglio: true,
        ),
      );
      expect(result.redFlags.join(' '), contains('Canone RAI'));
      expect(result.redFlags.join(' '), contains('Conguaglio'));
      expect(result.redFlags.join(' '), contains('Lettura stimata'));
    });
  });

  group('canone rai and red flags', () {
    test('canone flow shows truthful declaration warning', () {
      final result = CanoneRaiService().evaluate(
        const CanoneRaiDecisionInput(hasTv: false, requestType: 'no-tv'),
      );
      expect(result.warnings.join(' '), contains('truthful declarations'));
    });

    test('red flag detector catches false no-tv case', () {
      final flags = RedFlagService().evaluate(
        procedureId: 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
        inputData: {'hasTv': true},
      );
      expect(flags.map((item) => item.message).join(' '), contains('truthful'));
      expect(
        RedFlagService().hasBlockingRisk(
          procedureId: 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
          inputData: {'hasTv': true},
        ),
        isTrue,
      );
    });
  });

  group('phase 5 services', () {
    test('situation scanner maps landlord and utility/canone cases', () {
      final service = SituationScannerService();
      final rentResult = service.scan(
        'My landlord wants 300 euro to add my friend to the rent contract.',
        languageCode: 'en',
      );
      expect(
        rentResult.recommendedProcedures,
        contains('DEPOSIT_RETURN_REQUEST'),
      );

      final utilityResult = service.scan(
        'My electricity bill is too high and I also see Canone RAI.',
        languageCode: 'en',
      );
      expect(
        utilityResult.recommendedProcedures,
        contains('HIGH_BILL_COMPLAINT'),
      );
      expect(
        utilityResult.recommendedProcedures,
        contains('CANONE_RAI_NO_TV_DECLARATION_CHECKLIST'),
      );
    });

    test('city packs include required cities', () {
      final cities = CityPackService()
          .all()
          .map((item) => item.cityName)
          .toList();
      expect(
        cities,
        containsAll([
          'Torino',
          'Milano',
          'Roma',
          'Bologna',
          'Firenze',
          'Napoli',
        ]),
      );
    });

    test('student and tenant checklist contain expected items', () {
      final service = ItalyLifeChecklistService();
      final student = service.itemsForMode(LifeAdminMode.student);
      final tenant = service.itemsForMode(LifeAdminMode.tenant);
      expect(
        student.map((item) => item.title),
        contains('University enrollment'),
      );
      expect(student.map((item) => item.title), contains('ISEE'));
      expect(tenant.map((item) => item.title), contains('Deposit proof'));
      expect(tenant.map((item) => item.title), contains('Landlord contact'));
      expect(service.progress(student), equals(0));
    });

    test('attachment engine returns expected proof items', () {
      final engine = AttachmentRequirementEngine();
      final billPlan = engine.build(
        procedureId: 'HIGH_BILL_COMPLAINT',
        availableDocuments: const [],
      );
      expect(
        billPlan.requiredAttachments.map((item) => item.title),
        contains('Bill copy'),
      );
      expect(billPlan.proofItems.join(' '), contains('provider screenshots'));

      final aslPlan = engine.build(
        procedureId: 'ASL_REJECTED_REQUEST_REPLY',
        availableDocuments: const [],
      );
      expect(
        aslPlan.requiredAttachments.map((item) => item.title),
        contains('Rejection notice'),
      );
    });

    test('calendar includes document expiry item', () {
      final items = LifeAdminCalendarService().build(
        reminders: const [],
        documents: [
          LifeAdminDocument(
            id: 'doc1',
            type: LifeAdminDocumentType.tesseraSanitaria,
            title: 'Tessera sanitaria',
            description: 'Demo',
            hasDocument: true,
            expiryDate: DateTime(2026, 6, 1),
            createdAt: DateTime(2026, 5, 1),
            updatedAt: DateTime(2026, 5, 1),
          ),
        ],
        contracts: const [],
        deadlines: const [],
      );
      expect(items.any((item) => item.relatedDocumentId == 'doc1'), isTrue);
    });

    test(
      'readiness score catches missing recipient and next action follows status',
      () {
        final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
        final pack = PackGenerator.generate(
          procedure: procedure,
          inputData: {
            'fullName': 'Mario Rossi',
            'codiceFiscale': 'RSSMRA80A01H501U',
            'addressOrDomicile': 'Via Roma 1',
            'city': 'Torino',
            'aslOrOfficeName': 'ASL Torino',
            'reason': 'Need to change doctor',
          },
        );
        final request = AdminCopilotRequest(
          id: 'r1',
          procedureId: procedure.id,
          procedureTitle: procedure.title,
          category: procedure.category.name,
          status: RequestStatus.sent,
          priority: RequestPriority.normal,
          inputData: pack.inputData,
          generatedPack: pack,
          subject: pack.subject,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final readiness = RequestReadinessService().calculate(
          request: request,
          redFlags: const [],
        );
        expect(readiness.missingRequiredFields, contains('recipient'));
        expect(
          NextActionService().fromRequest(request).title,
          contains('Wait for reply'),
        );
      },
    );

    test('cost dashboard calculates totals', () {
      final contracts = [
        HouseholdContract(
          id: '1',
          type: HouseholdContractType.electricity,
          providerName: 'A',
          contractName: 'A',
          monthlyCost: 50,
          annualCost: 600,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HouseholdContract(
          id: '2',
          type: HouseholdContractType.internet,
          providerName: 'B',
          contractName: 'B',
          monthlyCost: 30,
          annualCost: 360,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final service = CostInsightService();
      expect(service.monthlyTotal(contracts), 80);
      expect(service.annualTotal(contracts), 960);
    });

    test('telegram handoff serializes correctly', () {
      final payload = TelegramHandoffService().build(
        procedureId: 'CHANGE_DOCTOR',
        title: 'Change Doctor',
        language: 'en',
      );
      expect(
        TelegramHandoffPayload.fromJson(payload.toJson()).procedureId,
        'CHANGE_DOCTOR',
      );
    });

    test('official links include unverified or needs review states', () {
      final links = OfficialLinksDirectoryService().builtIns();
      expect(
        links.any(
          (item) =>
              item.verificationStatus ==
                  OfficialLinkVerificationStatus.needsReview ||
              item.verificationStatus ==
                  OfficialLinkVerificationStatus.unverified,
        ),
        isTrue,
      );
    });

    test('localization inspector detects missing keys', () {
      final missing = LocalizationInspectorService().missingKeys({
        'en': {'a': 'A', 'b': 'B'},
        'it': {'a': 'A'},
      });
      expect(missing, contains('it:b'));
    });
  });

  group('repositories and demo data', () {
    test('onboarding local flag persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalOnboardingRepository(prefs);
      await repo.setCompleted(true);
      final state = await repo.getState();
      expect(state.completed, isTrue);
    });

    test('local draft repository persists draft', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalDraftRepository(prefs);
      await repo.saveDraft(
        DraftEntry(
          id: '1',
          procedureId: 'CHANGE_DOCTOR',
          inputData: const {'reason': 'draft'},
          updatedAt: DateTime.now(),
        ),
      );
      expect(await repo.getDraft('CHANGE_DOCTOR'), isNotNull);
    });

    test(
      'local request repository persists request and status events',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = LocalAdminCopilotRequestRepository(prefs);
        final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
        final pack = PackGenerator.generate(
          procedure: procedure,
          inputData: {
            'fullName': 'Mario Rossi',
            'codiceFiscale': 'RSSMRA80A01H501U',
            'addressOrDomicile': 'Via Roma 1',
            'city': 'Torino',
            'aslOrOfficeName': 'ASL Torino',
            'reason': 'Need to change doctor',
          },
        );
        final request = AdminCopilotRequest(
          id: const Uuid().v4(),
          procedureId: procedure.id,
          procedureTitle: procedure.title,
          category: procedure.category.name,
          status: RequestStatus.generated,
          priority: RequestPriority.normal,
          inputData: pack.inputData,
          generatedPack: pack,
          subject: pack.subject,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.createRequest(request);
        expect((await repo.listRequests()).length, 1);
        final updated = await repo.updateStatus(request.id, RequestStatus.sent);
        expect(updated.status, RequestStatus.sent);
        expect(updated.statusEvents, isNotEmpty);
      },
    );

    test('admin config persists feature flags', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalAdminConfigRepository(prefs);
      await repo.saveConfig(
        const AdminConfig(
          adminModeEnabled: true,
          featureFlags: AdminFeatureFlags(enableUtilities: false),
        ),
      );
      final config = await repo.getConfig();
      expect(config.adminModeEnabled, isTrue);
      expect(config.featureFlags.enableUtilities, isFalse);
    });

    test(
      'document vault, contacts, deadlines, templates, and before-sending persist',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final documents = LocalDocumentsRepository.fromPrefs(prefs);
        await documents.save(
          LifeAdminDocument(
            id: 'doc1',
            type: LifeAdminDocumentType.codiceFiscale,
            title: 'Codice fiscale',
            description: 'Demo',
            hasDocument: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect((await documents.list()).length, 1);

        final contacts = LocalContactsRepository.fromPrefs(prefs);
        await contacts.save(
          LifeAdminContact(
            id: 'c1',
            type: LifeAdminContactType.other,
            name: 'Demo Contact',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect((await contacts.list()).length, 1);

        final deadlines = LocalDeadlinesRepository.fromPrefs(prefs);
        await deadlines.save(
          UserDeadline(
            id: 'd1',
            title: 'Demo deadline',
            date: DateTime.now(),
            category: 'general',
            isDone: false,
          ),
        );
        expect((await deadlines.list()).length, 1);

        final templates = LocalTemplatesRepository.fromPrefs(prefs);
        await templates.save(
          CommunityTemplate(
            id: 't1',
            title: 'Demo Template',
            category: 'general',
            language: 'it',
            officialTextItalian: 'Testo demo',
            explanationLocalized: const {'en': 'Demo'},
            tags: const ['demo'],
            status: CommunityTemplateStatus.local,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect((await templates.list()).length, 1);

        final beforeSending = LocalBeforeSendingRepository.fromPrefs(prefs);
        await beforeSending.save(
          BeforeSendingChecklist(
            requestId: 'req1',
            personalDataChecked: true,
            recipientVerified: false,
            attachmentsReady: true,
            placeholdersRemoved: true,
            statementTruthful: true,
            officialRulesVerified: true,
            proofSaved: true,
            skipFuturePrompt: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        final saved = await beforeSending.get('req1');
        expect(saved?.canMarkSent, isFalse);
      },
    );

    test('household member json roundtrip', () {
      final member = HouseholdMember(
        id: 'h1',
        displayName: 'Roommate',
        relationship: HouseholdRelationship.roommate,
        fullName: 'Demo Roommate',
        isPrimary: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(HouseholdMember.fromJson(member.toJson()).displayName, 'Roommate');
    });

    test('demo data seeding creates phase 5 bundle data', () {
      final bundle = DemoDataService().build();
      expect(bundle.requests.length, greaterThanOrEqualTo(4));
      expect(bundle.reminders.length, greaterThanOrEqualTo(3));
      expect(bundle.documents, isNotEmpty);
      expect(bundle.contacts, isNotEmpty);
      expect(bundle.contracts, isNotEmpty);
      expect(bundle.householdMembers, isNotEmpty);
    });
  });
}
