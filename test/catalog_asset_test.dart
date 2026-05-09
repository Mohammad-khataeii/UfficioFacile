import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical catalog asset exists and has grouped content', () async {
    final file = File('assets/catalog/ufficio_catalog.v1.json');
    expect(file.existsSync(), isTrue);

    final raw = await file.readAsString();
    expect(raw.trim(), isNotEmpty);

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    expect(decoded['version'], isNotNull);

    final categories =
        (decoded['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    expect(categories, isNotEmpty);

    final health = categories.firstWhere(
      (category) => category['id'] == 'health_asl',
      orElse: () => <String, dynamic>{},
    );
    expect(health, isNotEmpty);

    final healthSubcategories =
        (health['subcategories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    expect(healthSubcategories, isNotEmpty);

    const forbiddenPhrases = <String>[
      'to help the user',
      'the user should',
      'do not show',
      'internal',
      'placeholder',
      'todo',
      'fake data',
      'lorem ipsum',
      'do not route',
      'do not tell',
    ];

    for (final category in categories) {
      expect('${category['id'] ?? ''}', isNotEmpty);
      expect(category['title'], isA<Map>());
      expect(category['description'], isA<Map>());
      expect(category['subcategories'], isA<List>());

      final rawCategoryText = jsonEncode(category).toLowerCase();
      for (final phrase in forbiddenPhrases) {
        final escapedPhrase = RegExp.escape(phrase);
        final pattern = phrase.contains(' ')
            ? RegExp(escapedPhrase)
            : RegExp('\\b$escapedPhrase\\b');
        expect(
          pattern.hasMatch(rawCategoryText),
          isFalse,
          reason: 'Category ${category['id']} still contains `$phrase`',
        );
      }
    }
  });
}
