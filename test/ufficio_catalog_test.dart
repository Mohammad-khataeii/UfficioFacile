import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/app/localized_text.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog_premium_marker.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/ufficio_catalog.dart';

void main() {
  group('UfficioCatalog parsing', () {
    test('parses category, subcategory, and procedure structure', () {
      final catalog = UfficioCatalog.fromJson(_sampleCatalogJson);
      final procedure = catalog.findProcedure(
        'health_asl',
        'doctor_health_card',
        'change_doctor',
      )!;

      expect(catalog.version, 1);
      expect(catalog.categories, hasLength(1));
      expect(catalog.findCategory('health_asl'), isNotNull);
      expect(
        catalog.findSubcategory('health_asl', 'doctor_health_card'),
        isNotNull,
      );
      expect(procedure, isNotNull);
      expect(procedure.officialLinks.single.owner, 'ASL Citta di Torino');
      expect(procedure.officialLinks.single.scope, 'Torino');
      expect(
        resolveLocalizedText(procedure.officialLinks.single.usedFor, 'en'),
        'Doctor choice',
      );
      expect(
        procedure.relatedProcedures.single.procedureId,
        'register_with_ssn',
      );
    });

    test('localized fallback prefers selected language, then en, then it', () {
      expect(
        resolveLocalizedText(const {'fr': 'Bonjour', 'en': 'Hello'}, 'fr'),
        'Bonjour',
      );
      expect(
        resolveLocalizedText(const {'en': 'Hello', 'it': 'Ciao'}, 'fa'),
        'Hello',
      );
      expect(resolveLocalizedText(const {'it': 'Ciao'}, 'fa'), 'Ciao');
    });

    test('premium marker is deterministic from catalog content', () {
      final catalog = UfficioCatalog.fromJson(_sampleCatalogJson);
      final category = catalog.findCategory('health_asl')!;
      final subcategory = catalog.findSubcategory(
        'health_asl',
        'doctor_health_card',
      )!;
      final procedure = catalog.findProcedure(
        'health_asl',
        'doctor_health_card',
        'change_doctor',
      )!;

      const marker = CatalogPremiumMarker();
      expect(marker.categoryHasPremiumContent(category), isTrue);
      expect(marker.subcategoryHasPremiumContent(subcategory), isTrue);
      expect(marker.procedureIsPremium(procedure), isTrue);
    });
  });
}

const _sampleCatalogJson = <String, dynamic>{
  'version': 1,
  'updatedAt': '2026-05-09',
  'languages': <String>['en', 'it', 'fr', 'fa'],
  'categories': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'health_asl',
      'icon': 'local_hospital',
      'sortOrder': 10,
      'isPremiumOnly': false,
      'hasPremiumContent': true,
      'title': <String, String>{'en': 'Health / ASL', 'it': 'Salute / ASL'},
      'description': <String, String>{
        'en': 'Doctor choice and health card help.',
        'it': 'Scelta del medico e tessera sanitaria.',
      },
      'subcategories': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'doctor_health_card',
          'sortOrder': 10,
          'isPremiumOnly': false,
          'hasPremiumContent': true,
          'title': <String, String>{
            'en': 'Doctor & health card',
            'it': 'Medico e tessera sanitaria',
          },
          'description': <String, String>{
            'en': 'Change your doctor and fix rejected requests.',
            'it': 'Cambia medico e correggi richieste respinte.',
          },
          'procedures': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'change_doctor',
              'sortOrder': 10,
              'isPremiumOnly': true,
              'requiresAuth': false,
              'title': <String, String>{
                'en': 'Change doctor',
                'it': 'Cambiare medico',
              },
              'shortDescription': <String, String>{
                'en': 'Change your GP through the health portal.',
                'it': 'Cambia il medico tramite il portale sanitario.',
              },
              'tags': <String>['doctor', 'asl'],
              'sections': <Map<String, dynamic>>[
                <String, dynamic>{
                  'type': 'text',
                  'key': 'what_it_is',
                  'title': <String, String>{'en': 'What it is'},
                  'body': <String, String>{'en': 'Choose or replace your GP.'},
                  'isPremiumOnly': false,
                },
                <String, dynamic>{
                  'type': 'text',
                  'key': 'how_to_do_it',
                  'title': <String, String>{'en': 'How to do it'},
                  'body': <String, String>{'en': 'Open the regional portal.'},
                  'isPremiumOnly': true,
                },
              ],
              'officialLinks': <Map<String, dynamic>>[
                <String, dynamic>{
                  'label': <String, String>{
                    'en': 'ASL Torino doctor choice',
                    'it': 'ASL Torino scelta medico',
                  },
                  'url': 'https://www.aslcittaditorino.it/doctor-choice',
                  'type': 'official',
                  'owner': 'ASL Citta di Torino',
                  'scope': 'Torino',
                  'usedFor': 'Doctor choice',
                  'lastVerifiedAt': '2026-05-25',
                },
              ],
              'contacts': <Map<String, dynamic>>[],
              'relatedProcedures': <Map<String, dynamic>>[
                <String, dynamic>{
                  'title': <String, String>{
                    'en': 'Register with SSN',
                    'it': 'Iscriviti al SSN',
                  },
                  'categoryId': 'health_asl',
                  'subcategoryId': 'ssn_asl_access',
                  'procedureId': 'register_with_ssn',
                },
              ],
              'warnings': <String, String>{
                'en':
                    'Always verify the official portal before sending documents.',
              },
              'premiumTeaser': <String, String>{
                'en': 'Unlock the full step-by-step guide.',
              },
            },
          ],
        },
      ],
    },
  ],
};
