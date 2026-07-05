import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/features/admin_cms/data/local_cms_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficio_catalog_repository.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/ufficio_catalog.dart';

UfficioCatalogRepository _repository() =>
    UfficioCatalogRepository(const LocalCmsRepository());

String _sectionFingerprint(UfficioContentSection section) {
  String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  String normalizeMap(Map<String, String> value) {
    final entries = value.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map((entry) => '${normalize(entry.key)}:${normalize(entry.value)}')
        .join('|');
  }

  String normalizeItems(Map<String, List<String>> value) {
    final entries = value.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) =>
              '${normalize(entry.key)}:${entry.value.map(normalize).join(',')}',
        )
        .join('|');
  }

  return '${normalize(section.key)}|${normalize(section.type)}|'
      '${normalizeMap(section.title)}|${normalizeMap(section.body)}|'
      '${normalizeItems(section.items)}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('catalog procedure detail deduplication', () {
    test(
      'repository keeps catalog sections once for STP / ENI access',
      () async {
        final procedure = await _repository().loadProcedureDetail(
          categoryId: 'health_asl',
          subcategoryId: 'ssn_asl_access',
          procedureId: 'stp_eni_access',
        );

        expect(procedure, isNotNull);
        final sections = procedure!.sections;
        expect(
          sections.where((section) => section.title['en'] == 'Use this when'),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'Bring these documents',
          ),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'What this route can cover',
          ),
          hasLength(1),
        );
        expect(
          sections.where((section) => section.title['en'] == 'Common mistake'),
          hasLength(1),
        );

        final fingerprints = sections.map(_sectionFingerprint).toList();
        expect(fingerprints.toSet().length, fingerprints.length);
        expect(procedure.officialLinks, isNotEmpty);
        expect(procedure.contacts, isNotEmpty);
      },
    );

    test(
      'repository deduplicates another category procedure globally',
      () async {
        final procedure = await _repository().loadProcedureDetail(
          categoryId: 'housing_rent',
          subcategoryId: 'deposit_handover',
          procedureId: 'deposit_return',
        );

        expect(procedure, isNotNull);
        final sections = procedure!.sections;
        expect(
          sections.where(
            (section) => section.title['en'] == 'Before you leave',
          ),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'If the landlord delays',
          ),
          hasLength(1),
        );
        expect(
          sections.where((section) => section.title['en'] == 'Premium help'),
          hasLength(1),
        );

        final fingerprints = sections.map(_sectionFingerprint).toList();
        expect(fingerprints.toSet().length, fingerprints.length);
        expect(procedure.contacts, isNotEmpty);
      },
    );

    test('repository keeps Torino utilities sections once', () async {
      final procedure = await _repository().loadProcedureDetail(
        categoryId: 'utilities_electricity_gas',
        subcategoryId: 'high_wrong_bills',
        procedureId: 'wrong_water_bill_or_hidden_leak',
      );

      expect(procedure, isNotNull);
      final sections = procedure!.sections;
      expect(
        sections.where((section) => section.title['en'] == 'Do this fast'),
        hasLength(1),
      );
      expect(
        sections.where((section) => section.title['en'] == 'Important limit'),
        hasLength(1),
      );

      final fingerprints = sections.map(_sectionFingerprint).toList();
      expect(fingerprints.toSet().length, fingerprints.length);
      expect(procedure.officialLinks, isNotEmpty);
      expect(procedure.contacts, isNotEmpty);
    });
  });
}
