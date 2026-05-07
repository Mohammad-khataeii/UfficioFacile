import 'dart:io';

const forbiddenPhrases = <String>[
  'to help the user',
  'the user should',
  'the user can',
  'do not show',
  'do not dump',
  'developer note',
  'todo show',
  'lorem',
  'random stuff',
];

const userFacingRoots = <String>[
  'lib/app',
  'lib/features/auth',
  'lib/features/admin',
  'lib/features/admin_cms',
  'lib/features/italy_admin_copilot/presentation',
  'lib/features/italy_admin_copilot/data/health_asl_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/housing_rent_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/utilities_electricity_gas_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/telecom_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/canone_rai_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/public_office_comune_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/work_inps_patronato_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/university_student_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/general_guidance_definitions.dart',
  'lib/features/italy_admin_copilot/data/procedure_definitions.dart',
  'lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart',
];

const allowedPathFragments = <String>[
  '/tool/',
  '/test/',
  'generated_pack_quality_service.dart',
  'service_intelligence_quality_service.dart',
  'red_flag_service.dart',
  'official_contacts_policy.md',
  'UFFICIOFACILE_FULL_CATEGORY_DATA_INVENTORY',
  'ufficiofacile_category_data_inventory',
];

Future<void> main() async {
  final violations = <String>[];

  for (final root in userFacingRoots) {
    final entity = FileSystemEntity.typeSync(root);
    if (entity == FileSystemEntityType.notFound) {
      continue;
    }

    if (entity == FileSystemEntityType.file) {
      final file = File(root);
      final hits = await _scanFile(file);
      violations.addAll(hits);
      continue;
    }

    final directory = Directory(root);
    await for (final item in directory.list(recursive: true)) {
      if (item is! File) continue;
      if (!_isSupportedFile(item.path)) continue;
      final hits = await _scanFile(item);
      violations.addAll(hits);
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Copy audit failed:');
    for (final item in violations) {
      stderr.writeln('- $item');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Copy audit passed.');
}

bool _isSupportedFile(String path) {
  return path.endsWith('.dart') ||
      path.endsWith('.json') ||
      path.endsWith('.sql') ||
      path.endsWith('.md');
}

Future<List<String>> _scanFile(File file) async {
  final normalizedPath = file.path.replaceAll('\\', '/');
  if (allowedPathFragments.any(normalizedPath.contains)) {
    return const [];
  }

  final content = await file.readAsString();
  final lower = content.toLowerCase();
  final hits = <String>[];
  for (final phrase in forbiddenPhrases) {
    if (lower.contains(phrase)) {
      hits.add('${file.path}: contains "$phrase"');
    }
  }
  return hits;
}
