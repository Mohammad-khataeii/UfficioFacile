import 'dart:io';

void main() {
  final localizationFile = File('lib/app/app_localizations.dart');
  final localizationText = localizationFile.readAsStringSync();
  const requiredLocales = ['en', 'it', 'fr', 'es', 'fa', 'ar'];

  for (final locale in requiredLocales) {
    if (!localizationText.contains("Locale('$locale')")) {
      stderr.writeln('Missing supported locale: $locale');
      exitCode = 1;
    }
  }

  final phraseTargets = [
    File('docs/generated/cms_bundled_content_export.json'),
    File('apps/admin/data/seed/bonus_loans_categories.json'),
  ];
  const forbidden = [
    'to help the user',
    'the user should',
    'do not show',
    'internal note',
    'for codex',
  ];

  for (final file in phraseTargets) {
    if (!file.existsSync()) continue;
    final text = file.readAsStringSync().toLowerCase();
    for (final phrase in forbidden) {
      if (text.contains(phrase)) {
        stderr.writeln(
          'Forbidden public phrase "$phrase" found in ${file.path}',
        );
        exitCode = 1;
      }
    }
  }

  if (exitCode == 0) {
    stdout.writeln('Translation checks passed.');
  }
}
