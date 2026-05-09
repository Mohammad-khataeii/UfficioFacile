import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/content/cms_seed_exporter.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/content/ufficio_catalog_exporter.dart';

Map<String, dynamic> _runtimeSignature(Map<String, dynamic> category) {
  final subcategories =
      (category['subcategories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map((subcategory) {
            final procedures =
                (subcategory['procedures'] as List<dynamic>? ?? const <dynamic>[])
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .map(
                      (procedure) => <String, dynamic>{
                        'id': procedure['id'],
                        'title': procedure['title'],
                        'shortDescription': procedure['shortDescription'],
                      },
                    )
                    .toList();
            return <String, dynamic>{
              'id': subcategory['id'],
              'title': subcategory['title'],
              'description': subcategory['description'],
              'sortOrder': subcategory['sortOrder'],
              'procedureCount': procedures.length,
              'procedures': procedures,
            };
          })
          .toList();
  return <String, dynamic>{
    'id': category['id'],
    'title': category['title'],
    'description': category['description'],
    'sortOrder': category['sortOrder'],
    'subcategories': subcategories,
  };
}

void main() {
  test('runtime catalog navigation matches canonical catalog asset', () {
    final raw = File('assets/catalog/ufficio_catalog.v1.json').readAsStringSync();
    final canonical = jsonDecode(raw) as Map<String, dynamic>;
    final canonicalCategories =
        (canonical['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    final bundle = buildCmsSeedBundle(
      externalSeedLoader: (sourcePath, categorySlug) {
        final seedRaw = File(sourcePath).readAsStringSync();
        return loadCategoryFromJsonText(seedRaw, categorySlug);
      },
    );
    final runtimeBundle = buildUfficioCatalogBundleFromCmsSeed(bundle);
    final runtimeCategories =
        (runtimeBundle['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    expect(
      runtimeCategories.map((item) => item['id']).toList(),
      canonicalCategories.map((item) => item['id']).toList(),
    );

    for (var index = 0; index < canonicalCategories.length; index += 1) {
      expect(
        _runtimeSignature(runtimeCategories[index]),
        _runtimeSignature(canonicalCategories[index]),
      );
    }

    final runtimeJson = jsonEncode(runtimeBundle).toLowerCase();
    const forbiddenPhrases = <String>[
      'use this area for public healthcare access',
      'foreign students and insurance options',
      'registration, enrollment, and healthcare access rules',
      'registration, enrolment, and healthcare access rules',
      'choose your doctor, renew your health card',
    ];
    for (final phrase in forbiddenPhrases) {
      expect(runtimeJson.contains(phrase), isFalse, reason: phrase);
    }

    const legacyHealthIds = <String>[
      'italian_resident_torino',
      'unemployed_torino',
      'non_resident_worker_or_student_torino',
      'duplicate_or_renew_tessera_sanitaria',
      'no_valid_permesso_stp',
      'eu_without_team_or_coverage',
      'italian_student_domiciled_torino',
      'eu_student_torino',
      'non_eu_student_torino',
      'non_eu_worker_torino',
    ];
    for (final id in legacyHealthIds) {
      expect(runtimeJson.contains(id), isFalse, reason: id);
    }

    final health = runtimeCategories.firstWhere(
      (item) => item['id'] == 'health_asl',
    );
    final subcategories =
        (health['subcategories'] as List<dynamic>).whereType<Map>().toList();
    expect(subcategories.length, 7);

    final expectedCounts = <String, int>{
      'ssn_asl_access': 4,
      'doctor_health_card': 4,
      'bookings_prescriptions_cup': 2,
      'ticket_exemptions': 2,
      'digital_health_record': 1,
      'asl_problems': 2,
      'student_insurance': 1,
    };
    for (final entry in expectedCounts.entries) {
      final subcategory = subcategories.firstWhere((item) => item['id'] == entry.key);
      final procedures =
          (subcategory['procedures'] as List<dynamic>? ?? const <dynamic>[]);
      expect(procedures.length, entry.value, reason: entry.key);
    }
  });
}
