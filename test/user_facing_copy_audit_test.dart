import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _auditPaths = <String>[
  'lib/features/italy_admin_copilot/content',
  'lib/features/admin_cms/data',
  'lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart',
  'lib/features/italy_admin_copilot/data/health_asl_guidance_definitions.dart',
];

const _ignoredFileSuffixes = <String>[
  'test/user_facing_copy_audit_test.dart',
  'test/catalog_runtime_consistency_test.dart',
  'test/catalog_asset_test.dart',
];

void main() {
  test('active catalog source files do not contain banned stale phrases', () {
    final failures = <String>[];
    final phrasePatterns = <MapEntry<String, RegExp>>[
      MapEntry(
        'This page helps',
        RegExp(r'this page helps', caseSensitive: false),
      ),
      MapEntry(
        'to help the user',
        RegExp(r'to help the user', caseSensitive: false),
      ),
      MapEntry(
        'the user should',
        RegExp(r'the user should', caseSensitive: false),
      ),
      MapEntry('Do not route', RegExp(r'do not route', caseSensitive: false)),
      MapEntry(
        'TODO',
        RegExp(r'(^|[^a-z])todo([^a-z]|$)', caseSensitive: false),
      ),
      MapEntry('placeholder', RegExp(r'\bplaceholder\b', caseSensitive: false)),
    ];

    for (final target in _auditPaths) {
      final entity = FileSystemEntity.typeSync(target);
      if (entity == FileSystemEntityType.notFound) continue;
      final files = <File>[];
      if (entity == FileSystemEntityType.file) {
        files.add(File(target));
      } else {
        for (final child in Directory(target).listSync(recursive: true)) {
          if (child is! File) continue;
          final path = child.path.replaceAll('\\', '/');
          if (path.contains('/.dart_tool/') ||
              path.contains('/build/') ||
              path.contains('/.git/')) {
            continue;
          }
          if (_ignoredFileSuffixes.any(path.endsWith)) continue;
          files.add(child);
        }
      }

      for (final file in files) {
        final content = file.readAsStringSync();
        final lowerPath = file.path.replaceAll('\\', '/');
        final lines = content.split('\n');
        for (var index = 0; index < lines.length; index += 1) {
          final line = lines[index];
          if (line.trimLeft().startsWith('//')) continue;
          if (line.contains('problem_input_placeholder') ||
              line.contains('search_placeholder_generic') ||
              line.contains('question.placeholder') ||
              line.contains('internal_label')) {
            continue;
          }
          for (final entry in phrasePatterns) {
            if (entry.value.hasMatch(line)) {
              failures.add('$lowerPath:${index + 1} -> ${entry.key}');
            }
          }
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
