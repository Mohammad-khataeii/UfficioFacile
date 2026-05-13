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
          sections.where(
            (section) => section.title['en'] == 'What STP and ENI mean',
          ),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'Care normally covered',
          ),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'Step-by-step in Torino',
          ),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'Where to go in Torino',
          ),
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
          sections.where((section) => section.title['en'] == 'What it is'),
          hasLength(1),
        );
        expect(
          sections.where((section) => section.title['en'] == 'Legal limit'),
          hasLength(1),
        );
        expect(
          sections.where((section) => section.title['en'] == 'Proof to keep'),
          hasLength(1),
        );
        expect(
          sections.where(
            (section) => section.title['en'] == 'How to request it',
          ),
          hasLength(1),
        );

        final fingerprints = sections.map(_sectionFingerprint).toList();
        expect(fingerprints.toSet().length, fingerprints.length);
        expect(procedure.contacts, isNotEmpty);
      },
    );
  });
}
