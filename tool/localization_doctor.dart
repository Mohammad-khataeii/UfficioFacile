import 'dart:io';

const _supportedLocales = ['en', 'it', 'fr', 'es', 'fa', 'ar'];
const _screenFiles = [
  'lib/app/app_startup_widgets.dart',
  'lib/features/auth/presentation/auth_screen.dart',
  'lib/features/auth/presentation/password_screens.dart',
  'lib/features/auth/presentation/account_screen.dart',
  'lib/features/italy_admin_copilot/presentation/screens/catalog_screens.dart',
];

final _localeHeader = RegExp(r"^    '([a-z]{2})': \{$");
final _localeEntry = RegExp(r"^      '([^']+)':");
final _hardcodedText = RegExp(r"Text\(\s*'([^']{8,})'");
final _rawKeyLeak = RegExp(r"Text\(\s*'([a-z0-9_\.]{3,})'");

void main() {
  final file = File('lib/app/app_localizations.dart');
  if (!file.existsSync()) {
    stderr.writeln('Missing lib/app/app_localizations.dart');
    exitCode = 1;
    return;
  }

  final problems = <String>[];
  final localeKeys = <String, Set<String>>{};
  String? currentLocale;

  for (final line in file.readAsLinesSync()) {
    final headerMatch = _localeHeader.firstMatch(line);
    if (headerMatch != null) {
      currentLocale = headerMatch.group(1)!;
      localeKeys.putIfAbsent(currentLocale, () => <String>{});
      continue;
    }
    if (currentLocale == null) continue;
    final entryMatch = _localeEntry.firstMatch(line);
    if (entryMatch != null) {
      localeKeys[currentLocale]!.add(entryMatch.group(1)!);
      continue;
    }
    if (line.trim() == '},') {
      currentLocale = null;
    }
  }

  for (final locale in _supportedLocales) {
    if (!localeKeys.containsKey(locale)) {
      problems.add('Missing supported locale block: $locale');
    }
  }

  final canonicalKeys = localeKeys['en'] ?? const <String>{};
  for (final locale in _supportedLocales) {
    final keys = localeKeys[locale] ?? const <String>{};
    final missing = canonicalKeys.difference(keys).toList()..sort();
    if (missing.isNotEmpty) {
      problems.add(
        'Locale $locale is missing ${missing.length} key(s): ${missing.take(12).join(", ")}${missing.length > 12 ? " ..." : ""}',
      );
    }
  }

  for (final path in _screenFiles) {
    final entity = File(path);
    if (!entity.existsSync()) continue;
    final text = entity.readAsStringSync();
    for (final match in _rawKeyLeak.allMatches(text)) {
      final value = match.group(1)!;
      if (canonicalKeys.contains(value)) {
        problems.add(
          'Possible raw localization key shown directly in ${entity.path}: `$value`',
        );
      }
    }
    for (final match in _hardcodedText.allMatches(text)) {
      final value = match.group(1)!.trim();
      if (value.startsWith('http') ||
          value.startsWith('/') ||
          value.contains(r'$') ||
          value.toLowerCase().contains('debug') ||
          value.toLowerCase().contains('error')) {
        continue;
      }
      problems.add(
        'Hardcoded UI text candidate in ${entity.path}: `${value.length > 80 ? "${value.substring(0, 80)}..." : value}`',
      );
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Localization doctor failed:');
    for (final problem in problems) {
      stderr.writeln('- $problem');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Localization doctor passed.');
}
