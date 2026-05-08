import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/features/admin_cms/domain/cms_models.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/application/intelligent_problem_router.dart';

void main() {
  group('intelligent problem router', () {
    late IntelligentProblemRouter router;

    setUpAll(() {
      final raw = File(
        'apps/admin/data/seed/bonus_loans_categories.json',
      ).readAsStringSync();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final categoryMaps = (decoded['categories'] as List<dynamic>)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final categories = <CmsCategory>[
        CmsCategory.fromJson({
          'slug': 'health_asl',
          'title': {'en': 'Health / ASL', 'it': 'Salute / ASL'},
          'description': {
            'en': 'Family doctor, health card and ASL procedures.',
          },
        }),
        CmsCategory.fromJson({
          'slug': 'housing_rent',
          'title': {'en': 'Home / Rent', 'it': 'Casa / Affitto'},
          'description': {
            'en': 'Rent contracts, landlord issues and housing procedures.',
          },
        }),
        CmsCategory.fromJson({
          'slug': 'utilities_electricity_gas',
          'title': {'en': 'Utilities / Bills', 'it': 'Utenze / Bollette'},
          'description': {'en': 'Electricity, gas and utility bill issues.'},
        }),
        CmsCategory.fromJson({
          'slug': 'work_inps_patronato',
          'title': {
            'en': 'Work / INPS / Patronato',
            'it': 'Lavoro / INPS / Patronato',
          },
          'description': {'en': 'Work, unemployment and INPS procedures.'},
        }),
        ...categoryMaps.map(CmsCategory.fromJson),
      ];

      final procedures = <CmsProcedure>[
        CmsProcedure.fromJson({
          'slug': 'change-family-doctor',
          'category_slug': 'health_asl',
          'title': {
            'en': 'Choose or change your family doctor',
            'it': 'Scegli o cambia medico di base',
          },
          'summary': {
            'en':
                'Use this if you need to change your medico di base in Italy.',
          },
          'what_is_it': {
            'en': 'Request a new GP or family doctor through the ASL.',
          },
          'tags': ['doctor', 'family doctor', 'medico di base', 'gp', 'asl'],
          'synonyms': ['change doctor', 'family doctor', 'gp', 'doctor card'],
          'searchable_keywords': ['cambio medico', 'doctor choice'],
          'required_documents': ['Health card', 'ID'],
          'status': 'published',
          'is_active': true,
        }),
        CmsProcedure.fromJson({
          'slug': 'utility-bill-review',
          'category_slug': 'utilities_electricity_gas',
          'title': {
            'en': 'Review a high electricity or gas bill',
            'it': 'Controlla una bolletta luce o gas alta',
          },
          'summary': {
            'en': 'Understand why your electricity or gas bill is too high.',
          },
          'what_is_it': {
            'en':
                'Check high bill causes, social bonus options and complaint paths.',
          },
          'tags': ['bolletta', 'luce', 'gas', 'electricity', 'bill'],
          'synonyms': [
            'high bill',
            'bolletta alta',
            'electricity bill problem',
          ],
          'searchable_keywords': ['bill too high', 'gas expensive'],
          'status': 'published',
          'is_active': true,
        }),
        CmsProcedure.fromJson({
          'slug': 'rent-contract-subentro',
          'category_slug': 'housing_rent',
          'title': {
            'en': 'Add or replace a tenant on the rent contract',
            'it': 'Subentro o aggiunta nel contratto di affitto',
          },
          'summary': {
            'en':
                'Use this when you need to register a new roommate or tenant change.',
          },
          'what_is_it': {'en': 'Handle subentro and rent contract changes.'},
          'tags': ['subentro', 'rent', 'contract', 'coinquilino'],
          'synonyms': [
            'add person to rent contract',
            'registrare nuovo coinquilino',
          ],
          'searchable_keywords': ['subentro affitto'],
          'status': 'published',
          'is_active': true,
        }),
        CmsProcedure.fromJson({
          'slug': 'naspi-support',
          'category_slug': 'work_inps_patronato',
          'title': {'en': 'Apply for NASpI', 'it': 'Domanda NASpI'},
          'summary': {'en': 'Unemployment support through INPS.'},
          'what_is_it': {'en': 'INPS unemployment benefit request.'},
          'tags': ['naspi', 'inps', 'unemployment'],
          'synonyms': ['disoccupazione', 'inps benefit'],
          'status': 'published',
          'is_active': true,
        }),
        ...categoryMaps.expand((category) {
          final procedures =
              (category['procedures'] as List<dynamic>? ?? const [])
                  .whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item));
          return procedures.map(CmsProcedure.fromJson);
        }),
      ];

      router = IntelligentProblemRouter(
        categories: categories,
        procedures: procedures,
        languageCode: 'en',
      );
    });

    test('change doctor matches health asl doctor procedure', () {
      final result = router.findMatches('change doctor').first;
      expect(result.categorySlug, 'health_asl');
      expect(result.procedureSlug, 'change-family-doctor');
    });

    test('medico di base matches health asl', () {
      final result = router.findMatches('medico di base').first;
      expect(result.categorySlug, 'health_asl');
    });

    test('bolletta luce alta matches utilities or bonus bills', () {
      final result = router.findMatches('bolletta luce alta').first;
      expect(
        {
          'utilities_electricity_gas',
          'bonuses-benefits',
        }.contains(result.categorySlug),
        isTrue,
      );
    });

    test('subentro affitto matches home rent', () {
      final result = router.findMatches('subentro affitto').first;
      expect(result.categorySlug, 'housing_rent');
      expect(result.procedureSlug, 'rent-contract-subentro');
    });

    test('NASpI matches work and inps', () {
      final result = router.findMatches('NASpI').first;
      expect(result.categorySlug, 'work_inps_patronato');
    });

    test('bonus bollette matches bonus sociale bollette', () {
      final result = router.findMatches('bonus bollette').first;
      expect(result.categorySlug, 'bonuses-benefits');
      expect(result.procedureSlug, 'bonus-sociale-bollette');
    });

    test('student loan intesa matches intesa per merito', () {
      final result = router.findMatches('student loan intesa').first;
      expect(result.categorySlug, 'loans-credit');
      expect(result.procedureSlug, 'intesa-per-merito');
    });

    test('first home mortgage guarantee matches consap first home', () {
      final result = router.findMatches('first home mortgage guarantee').first;
      expect(result.categorySlug, 'loans-credit');
      expect(result.procedureSlug, 'consap-fondo-prima-casa');
    });

    test('unknown bicycle theft stays low confidence', () {
      final result = router.findMatches('my bicycle was stolen').first;
      expect(result.confidence, ProblemMatchConfidence.low);
    });
  });
}
