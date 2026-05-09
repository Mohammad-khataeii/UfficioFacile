import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Loans & Credit and General categories avoid banned stale phrases', () {
    final raw = File(
      'assets/catalog/ufficio_catalog.v1.json',
    ).readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = (json['categories'] as List<dynamic>)
        .whereType<Map<String, dynamic>>();

    final targets = categories.where(
      (item) => item['id'] == 'loans-credit' || item['id'] == 'general',
    );

    final text = jsonEncode(targets.toList()).toLowerCase();
    expect(text.contains('this page helps'), isFalse);
    expect(text.contains('the user should'), isFalse);
    expect(text.contains('to help the user'), isFalse);
    expect(text.contains('todo'), isFalse);
    expect(text.contains('placeholder'), isFalse);
    expect(text.contains('internal'), isFalse);
  });
}
