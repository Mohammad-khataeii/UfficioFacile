import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_official_contacts.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_official_links.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_procedure_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_source_references.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/pack_generator.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/catalog_models.dart';

void main() {
  group('verified catalog import', () {
    test('verified official links were imported', () {
      expect(
        bundledOfficialLinks.any(
          (item) => item.id == 'ae-canone-tv-dichiarazione-online',
        ),
        isTrue,
      );
      expect(
        bundledOfficialLinks.any(
          (item) => item.id == 'salute-piemonte-il-mio-medico',
        ),
        isTrue,
      );
    });

    test('verified official contacts keep source url and date', () {
      final contact = bundledOfficialContacts.firstWhere(
        (item) => item.id == 'asl-citta-torino-general',
      );
      expect(contact.verificationStatus, CatalogVerificationStatus.verified);
      expect(contact.sourceUrl, isNotEmpty);
      expect(contact.lastVerifiedAt, isNotNull);
      expect(contact.notes['pec'], contains('@'));
    });

    test('telecom providers include imported contacts and forms', () {
      final tim = bundledServiceProviders.firstWhere(
        (item) => item.id == 'tim',
      );
      final vodafone = bundledServiceProviders.firstWhere(
        (item) => item.id == 'vodafone',
      );
      expect(
        tim.contactOptions.any((item) => item.contactType == 'pec'),
        isTrue,
      );
      expect(tim.forms, isNotEmpty);
      expect(
        vodafone.contactOptions.any((item) => item.contactType == 'pec'),
        isTrue,
      );
    });

    test('energy provider ids are normalized for existing app categories', () {
      expect(
        bundledServiceProviders.any((item) => item.id == 'edison-energia'),
        isTrue,
      );
      expect(
        bundledServiceProviders.any((item) => item.id == 'a2a-energia'),
        isTrue,
      );
    });

    test('tessera sanitaria guidance uses imported links and contacts', () {
      final guidance = bundledProcedureGuidance.firstWhere(
        (item) => item.procedureId == 'TESSERA_SANITARIA_RENEWAL',
      );
      expect(
        guidance.officialLinkIds,
        contains('ae-tessera-sanitaria-duplicato'),
      );
      expect(guidance.officialContactIds, contains('asl-citta-torino-general'));
      expect(guidance.submissionChannelIds, contains('pec'));
    });

    test(
      'internet cancellation guidance includes provider-specific channels',
      () {
        final guidance = bundledProcedureGuidance.firstWhere(
          (item) => item.procedureId == 'INTERNET_PHONE_CANCELLATION',
        );
        expect(
          guidance.providerIds,
          containsAll(['tim', 'vodafone', 'windtre']),
        );
        expect(
          guidance.submissionChannelIds,
          containsAll(['provider-customer-area', 'official-form', 'pec']),
        );
      },
    );

    test('energy and naspi guidance have stronger source references', () {
      final highBill = bundledProcedureGuidance.firstWhere(
        (item) => item.procedureId == 'HIGH_BILL_COMPLAINT',
      );
      final naspi = bundledProcedureGuidance.firstWhere(
        (item) => item.procedureId == 'NASPI_PREPARATION',
      );
      expect(
        highBill.sourceReferenceIds,
        contains('sportello-consumatore-ref'),
      );
      expect(naspi.sourceReferenceIds, contains('inps-naspi-ref'));
    });

    test(
      'pack generator resolves official links instead of placeholder ids',
      () {
        final procedure = ItalyAdminProcedureDefinitions.byId(
          'INTERNET_PHONE_CANCELLATION',
        )!;
        final pack = PackGenerator.generate(
          procedure: procedure,
          inputData: const {
            'provider': 'TIM',
            'providerId': 'tim',
            'submissionMethod': 'pec',
          },
        );
        expect(pack.officialLinksToCheck, isNotEmpty);
        expect(
          pack.officialLinksToCheck.any((item) => item.contains('AGCOM')),
          isTrue,
        );
        expect(
          pack.officialLinksToCheck.any((item) => item.contains('https://')),
          isTrue,
        );
      },
    );

    test('imported source references exist', () {
      expect(
        bundledSourceReferences.any((item) => item.id == 'inps-naspi-ref'),
        isTrue,
      );
      expect(
        bundledSourceReferences.any(
          (item) => item.id == 'sportello-consumatore-ref',
        ),
        isTrue,
      );
    });

    test('verified seed migration file was generated', () {
      final migration = File(
        'supabase/migrations/20260506100000_seed_verified_catalog_v1.sql',
      ).readAsStringSync();
      expect(migration, contains('insert into public.ufficio_official_links'));
      expect(migration, contains('insert into public.ufficio_provider_forms'));
      expect(
        migration,
        contains('insert into public.ufficio_procedure_guidance'),
      );
    });
  });
}
