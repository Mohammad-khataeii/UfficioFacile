import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

String t(BuildContext context, String key) => context.l10n.t(key);

String resolveLocalizedText(
  Map<String, dynamic>? values,
  String selectedLanguage, {
  String fallback = '',
}) {
  if (values == null || values.isEmpty) return fallback;
  final normalized = values.map(
    (key, value) => MapEntry(key.toString(), value?.toString().trim() ?? ''),
  );

  String? pick(String languageCode) {
    final value = normalized[languageCode];
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  final selected = pick(selectedLanguage);
  if (selected != null) return selected;

  final english = pick('en');
  if (english != null) return english;

  final italian = pick('it');
  if (italian != null) return italian;

  for (final value in normalized.values) {
    if (value.trim().isNotEmpty) return value.trim();
  }

  return fallback;
}

String localizedMap(
  BuildContext context,
  Map<String, dynamic> values, {
  String fallback = '',
}) => resolveLocalizedText(
  values,
  context.l10n.languageCode,
  fallback: fallback,
);
