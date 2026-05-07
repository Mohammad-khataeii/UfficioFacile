import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ufficiofacile/app/app_config.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_profile_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/local_request_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/pack_generator.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_copilot_profile.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_request.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/generated_pack.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/life_admin_contact.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/life_admin_document.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/premium_config.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/reminder.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/request_status.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/sync_models.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/ufficcio_entitlement.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/ufficcio_user_settings.dart';

class _FakeAuthFacade extends UfficcioAuthFacade {
  const _FakeAuthFacade(super.config, this._state);
  final UfficcioAuthState _state;

  @override
  UfficcioAuthState get state => _state;
}

void main() {
  group('config and repository factory', () {
    const localConfig = UfficcioFacileConfig(
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

    test('app runs in local mode if Supabase env missing', () {
      expect(localConfig.isSupabaseEnabled, isFalse);
      expect(localConfig.backendLabel, 'local');
    });

    test('backend mode selects local repository', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final factory = UfficcioRepositoryFactory(
        config: localConfig,
        authFacade: const _FakeAuthFacade(
          localConfig,
          UfficcioAuthState(isConfigured: false, isAuthenticated: false),
        ),
        localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
        localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
        localSettingsRepository: LocalUfficcioUserSettingsRepository(prefs),
        localEntitlementRepository: LocalUfficcioEntitlementRepository(prefs),
      );
      expect(
        factory.profileRepository(syncEnabled: true),
        isA<LocalAdminCopilotProfileRepository>(),
      );
    });

    test(
      'backend mode selects Supabase repository when configured and signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        const config = UfficcioFacileConfig(
          appName: UfficcioFacileConfig.appNameValue,
          backendMode: AppBackendMode.supabase,
          supabaseUrl: 'https://example.supabase.co',
          supabaseAnonKey: 'anon-key',
          syncEnabledByDefault: true,
          adminDebugEnabled: false,
          betaModeEnabled: true,
          paywallEnabled: false,
          analyticsEnabledByDefault: true,
        );
        final factory = UfficcioRepositoryFactory(
          config: config,
          authFacade: const _FakeAuthFacade(
            config,
            UfficcioAuthState(
              isConfigured: true,
              isAuthenticated: true,
              userId: 'user-1',
            ),
          ),
          localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
          localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
          localSettingsRepository: LocalUfficcioUserSettingsRepository(prefs),
          localEntitlementRepository: LocalUfficcioEntitlementRepository(prefs),
          client: SupabaseClient('https://example.supabase.co', 'anon-key'),
        );
        expect(
          factory.profileRepository(syncEnabled: true),
          isA<SupabaseAdminCopilotProfileRepository>(),
        );
      },
    );
  });

  group('Supabase mapping helpers', () {
    test('profile toSupabaseJson/fromSupabaseJson', () {
      const profile = AdminCopilotProfile(
        fullName: 'Mario Rossi',
        codiceFiscale: 'RSSMRA80A01H501U',
        preferredLanguage: 'it',
      );
      final json = profile.toSupabaseJson(userId: 'user-1');
      final mapped = AdminCopilotProfileSupabaseMapper.fromSupabaseJson(json);
      expect(mapped.fullName, 'Mario Rossi');
      expect(mapped.preferredLanguage, 'it');
    });

    test('request toSupabaseJson/fromSupabaseJson', () {
      final procedure = ItalyAdminProcedureDefinitions.byId('CHANGE_DOCTOR')!;
      final pack = PackGenerator.generate(
        procedure: procedure,
        inputData: const {
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
        status: RequestStatus.generated,
        priority: RequestPriority.normal,
        inputData: pack.inputData,
        generatedPack: pack,
        subject: pack.subject,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final json = request.toSupabaseJson(userId: 'user-1');
      final mapped = AdminRequestSupabaseMapper.fromSupabaseJson(json);
      expect(mapped.procedureId, request.procedureId);
      expect(mapped.subject, request.subject);
    });

    test('generated pack toSupabaseJson/fromSupabaseJson', () {
      final procedure = ItalyAdminProcedureDefinitions.byId(
        'GENERIC_FORMAL_REQUEST',
      )!;
      final pack = PackGenerator.generate(
        procedure: procedure,
        inputData: const {
          'senderName': 'Mario Rossi',
          'recipientNameOrOffice': 'Demo Office',
          'topic': 'Topic',
          'situation': 'Situation',
          'request': 'Request',
        },
      );
      final json = pack.toSupabaseJson(userId: 'user-1', requestId: 'r1');
      final mapped = GeneratedPackSupabaseMapper.fromSupabaseJson(json);
      expect(mapped.subject, pack.subject);
      expect(mapped.fullText, isNotEmpty);
    });

    test('reminder toSupabaseJson/fromSupabaseJson', () {
      final reminder = Reminder(
        id: 'rem1',
        requestId: 'r1',
        title: 'Follow up',
        reminderDate: DateTime(2026, 5, 10),
        type: ReminderType.followUp,
        isDone: false,
        createdAt: DateTime(2026, 5, 6),
      );
      final mapped = ReminderSupabaseMapper.fromSupabaseJson(
        reminder.toSupabaseJson(userId: 'user-1'),
      );
      expect(mapped.title, reminder.title);
    });

    test('document toSupabaseJson/fromSupabaseJson', () {
      final doc = LifeAdminDocument(
        id: 'doc1',
        type: LifeAdminDocumentType.codiceFiscale,
        title: 'Codice fiscale',
        description: 'Demo',
        hasDocument: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final mapped = LifeAdminDocumentSupabaseMapper.fromSupabaseJson(
        doc.toSupabaseJson(userId: 'user-1'),
      );
      expect(mapped.title, doc.title);
    });

    test('contact toSupabaseJson/fromSupabaseJson', () {
      final contact = LifeAdminContact(
        id: 'c1',
        type: LifeAdminContactType.other,
        name: 'Demo Contact',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final mapped = LifeAdminContactSupabaseMapper.fromSupabaseJson(
        contact.toSupabaseJson(userId: 'user-1'),
      );
      expect(mapped.name, contact.name);
    });
  });

  group('sync, privacy, analytics, entitlements', () {
    test('sync status localOnly when no Supabase', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const config = UfficcioFacileConfig(
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
      final settingsRepo = LocalUfficcioUserSettingsRepository(prefs);
      final syncService = UfficcioSyncService(
        factory: UfficcioRepositoryFactory(
          config: config,
          authFacade: const _FakeAuthFacade(
            config,
            UfficcioAuthState(isConfigured: false, isAuthenticated: false),
          ),
          localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
          localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
          localSettingsRepository: settingsRepo,
          localEntitlementRepository: LocalUfficcioEntitlementRepository(prefs),
        ),
        settingsRepository: settingsRepo,
      );
      expect((await syncService.getStatus()).state, SyncStatusState.localOnly);
    });

    test('sync status disabled when sync disabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const config = UfficcioFacileConfig(
        appName: UfficcioFacileConfig.appNameValue,
        backendMode: AppBackendMode.supabase,
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'anon',
        syncEnabledByDefault: false,
        adminDebugEnabled: false,
        betaModeEnabled: true,
        paywallEnabled: false,
        analyticsEnabledByDefault: true,
      );
      final settingsRepo = LocalUfficcioUserSettingsRepository(prefs);
      await settingsRepo.saveSettings(
        const UfficcioUserSettings(syncEnabled: false),
      );
      final syncService = UfficcioSyncService(
        factory: UfficcioRepositoryFactory(
          config: config,
          authFacade: const _FakeAuthFacade(
            config,
            UfficcioAuthState(
              isConfigured: true,
              isAuthenticated: true,
              userId: 'user-1',
            ),
          ),
          localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
          localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
          localSettingsRepository: settingsRepo,
          localEntitlementRepository: LocalUfficcioEntitlementRepository(prefs),
        ),
        settingsRepository: settingsRepo,
      );
      expect((await syncService.getStatus()).state, SyncStatusState.disabled);
    });

    test('latest updatedAt conflict resolution and sync failure log', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const config = UfficcioFacileConfig(
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
      final settingsRepo = LocalUfficcioUserSettingsRepository(prefs);
      final syncService = UfficcioSyncService(
        factory: UfficcioRepositoryFactory(
          config: config,
          authFacade: const _FakeAuthFacade(
            config,
            UfficcioAuthState(isConfigured: false, isAuthenticated: false),
          ),
          localProfileRepository: LocalAdminCopilotProfileRepository(prefs),
          localRequestRepository: LocalAdminCopilotRequestRepository(prefs),
          localSettingsRepository: settingsRepo,
          localEntitlementRepository: LocalUfficcioEntitlementRepository(prefs),
        ),
        settingsRepository: settingsRepo,
      );
      final older = AdminCopilotRequest(
        id: '1',
        procedureId: 'P1',
        procedureTitle: 'P1',
        category: 'c',
        status: RequestStatus.generated,
        priority: RequestPriority.normal,
        inputData: const {},
        generatedPack: GeneratedPack.fromJson({
          'id': 'g1',
          'procedureId': 'P1',
          'procedureTitle': 'P1',
          'category': 'c',
          'status': 'generated',
          'priority': 'normal',
          'inputData': const {},
          'subject': 's',
          'bodyItalian': 'b',
          'bodyPecItalian': 'p',
          'shortMessageItalian': 's',
          'whatsappMessageItalian': 'w',
          'whatsappFollowUpItalian': 'wf',
          'whatsappStrongFollowUpItalian': 'ws',
          'ultraShortSummaryItalian': 'u',
          'followUpItalian': 'f',
          'strongFollowUpItalian': 'sf',
          'userExplanationEnglish': 'e',
          'localizedExplanations': const {'en': 'e'},
          'attachmentChecklist': const [],
          'nextSteps': const [],
          'warnings': const [],
          'deadlineSuggestions': const [],
          'fullText': 'Questo strumento',
          'createdAt': DateTime(2026, 5, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 5, 1).toIso8601String(),
        }),
        subject: 's',
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
      );
      final newer = older.copyWith(updatedAt: DateTime(2026, 5, 2));
      expect(
        (await syncService.resolveConflict(
          local: newer,
          remote: older,
        )).updatedAt,
        newer.updatedAt,
      );
      syncService.logFailure('network', 'sync failed');
      expect(syncService.lastLog?.status, 'failed');
    });

    test('analytics sanitizer removes sensitive keys', () {
      final safe = UfficcioAnalyticsSanitizer().sanitize({
        'event_source': 'button',
        'fullName': 'Mario Rossi',
        'inputData': {'bad': true},
        'status': 'ok',
      });
      expect(safe.containsKey('fullName'), isFalse);
      expect(safe.containsKey('inputData'), isFalse);
      expect(safe['status'], 'ok');
    });

    test(
      'export data includes sections and delete local data clears keys',
      () async {
        SharedPreferences.setMockInitialValues({
          'italy_life_admin_profile_v1': '{"fullName":"Mario"}',
          'italy_life_admin_requests_v1': '[]',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = LocalPrivacyCenterService(prefs);
        final export = service.exportData();
        expect(export.containsKey('profile'), isTrue);
        expect(export.containsKey('requests'), isTrue);
        await service.deleteLocalData();
        expect(prefs.getString('italy_life_admin_profile_v1'), isNull);
      },
    );

    test('privacy center service reports storage counts', () async {
      SharedPreferences.setMockInitialValues({
        'italy_life_admin_contacts_v1': '[{}]',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(LocalPrivacyCenterService(prefs).storageCounts()['contacts'], 1);
    });

    test(
      'free entitlement default, beta bypass, usage increment, limit block',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = LocalUfficcioEntitlementRepository(prefs);
        expect((await repo.getEntitlement()).plan, UfficioPlan.free);

        final betaService = UfficcioEntitlementService(
          repo,
          betaModeEnabled: true,
        );
        expect(await betaService.canGeneratePack(), isTrue);

        final strictService = UfficcioEntitlementService(
          repo,
          betaModeEnabled: false,
        );
        await repo.saveEntitlement(
          const UfficcioEntitlement(
            freePackLimit: 1,
            generatedPacksUsedThisMonth: 0,
            premiumAccess: false,
          ),
        );
        await strictService.recordPackGenerated();
        expect((await repo.getEntitlement()).freePacksUsed, 1);
        expect(await strictService.canGeneratePack(), isFalse);
      },
    );
  });

  group('migration files', () {
    test(
      'migration SQL contains RLS enable statements and user_id indexes',
      () {
        final rls = File(
          'supabase/migrations/20260506091000_create_ufficciofacile_rls.sql',
        ).readAsStringSync();
        final core = File(
          'supabase/migrations/20260506090000_create_ufficciofacile_core.sql',
        ).readAsStringSync();
        expect(rls, contains('enable row level security'));
        expect(core, contains('user_id'));
        expect(
          core,
          contains('create index if not exists idx_ufficcio_requests_user_id'),
        );
      },
    );

    test('migration SQL does not contain service role key or secrets', () {
      final core = File(
        'supabase/migrations/20260506090000_create_ufficciofacile_core.sql',
      ).readAsStringSync();
      expect(core.toLowerCase(), isNot(contains('service_role')));
      expect(core.toLowerCase(), isNot(contains('sb_secret')));
    });
  });
}
