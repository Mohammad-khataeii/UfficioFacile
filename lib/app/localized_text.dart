import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'localization_utils.dart';

String t(BuildContext context, String key) => context.l10n.t(key);

String resolveLocalizedText(
  Map<String, dynamic>? values,
  String selectedLanguage, {
  String fallback = '',
}) => resolveLocalizedTextValue(values, selectedLanguage, fallback: fallback);

String localizedMap(
  BuildContext context,
  Map<String, dynamic> values, {
  String fallback = '',
}) =>
    resolveLocalizedText(values, context.l10n.languageCode, fallback: fallback);
