import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

String t(BuildContext context, String key) => context.l10n.t(key);

String localizedMap(
  BuildContext context,
  Map<String, dynamic> values, {
  String fallback = '',
}) => context.l10n.localizedMap(values, fallback: fallback);
