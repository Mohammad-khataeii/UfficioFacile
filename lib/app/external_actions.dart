import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum ExternalValueKind { website, email, phone, pec, address, auto }

class ExternalActionService {
  static final RegExp _urlPattern = RegExp(
    r'((?:https?:\/\/|www\.)[^\s]+)',
    caseSensitive: false,
  );
  static final RegExp _emailPattern = RegExp(
    r'([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})',
    caseSensitive: false,
  );

  static Uri? uriFor(String rawValue, ExternalValueKind kind) {
    final value = rawValue.trim();
    if (value.isEmpty) return null;

    switch (kind) {
      case ExternalValueKind.website:
        return _websiteUri(value);
      case ExternalValueKind.email:
      case ExternalValueKind.pec:
        if (value.startsWith('mailto:')) {
          return Uri.tryParse(value);
        }
        return Uri(scheme: 'mailto', path: value);
      case ExternalValueKind.phone:
        final normalized = value.replaceAll(RegExp(r'[^\d+]'), '');
        if (normalized.isEmpty) return null;
        return Uri(scheme: 'tel', path: normalized);
      case ExternalValueKind.address:
        return Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(value)}',
        );
      case ExternalValueKind.auto:
        return _autoUri(value);
    }
  }

  static Future<bool> open(
    BuildContext context,
    String rawValue,
    ExternalValueKind kind, {
    String? failureMessage,
  }) async {
    final uri = uriFor(rawValue, kind);
    if (uri == null) {
      _showFailure(context, failureMessage ?? 'Could not open this item.');
      return false;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showFailure(
        context,
        failureMessage ?? 'Could not open ${uri.toString()}.',
      );
    }
    return launched;
  }

  static Future<void> copy(
    BuildContext context,
    String value, {
    String? label,
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label == null ? 'Copied' : '$label copied')),
    );
  }

  static List<_ExternalTextSegment> _splitTextSegments(String text) {
    final matches = <RegExpMatch>[
      ..._urlPattern.allMatches(text),
      ..._emailPattern.allMatches(text),
    ]..sort((a, b) => a.start.compareTo(b.start));

    final segments = <_ExternalTextSegment>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start < cursor) continue;
      if (match.start > cursor) {
        segments.add(
          _ExternalTextSegment.text(text.substring(cursor, match.start)),
        );
      }
      final value = match.group(0);
      if (value != null && value.isNotEmpty) {
        final kind = _urlPattern.hasMatch(value)
            ? ExternalValueKind.website
            : ExternalValueKind.email;
        segments.add(_ExternalTextSegment.link(value, kind));
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      segments.add(_ExternalTextSegment.text(text.substring(cursor)));
    }
    if (segments.isEmpty) {
      segments.add(_ExternalTextSegment.text(text));
    }
    return segments;
  }

  static Uri? _autoUri(String value) {
    if (_urlPattern.hasMatch(value)) {
      final match = _urlPattern.firstMatch(value);
      if (match != null) {
        return _websiteUri(match.group(0)!);
      }
    }
    if (_emailPattern.hasMatch(value)) {
      final match = _emailPattern.firstMatch(value);
      if (match != null) {
        return uriFor(match.group(0)!, ExternalValueKind.email);
      }
    }
    return null;
  }

  static Uri? _websiteUri(String value) {
    final normalized =
        value.startsWith(RegExp(r'https?:\/\/', caseSensitive: false))
        ? value
        : 'https://$value';
    return Uri.tryParse(normalized);
  }

  static void _showFailure(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class ExternalValueText extends StatelessWidget {
  const ExternalValueText(
    this.value, {
    super.key,
    required this.kind,
    this.style,
  });

  final String value;
  final ExternalValueKind kind;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle =
        style ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        );
    return InkWell(
      onTap: () => ExternalActionService.open(context, value, kind),
      child: Text(value, style: effectiveStyle),
    );
  }
}

class ExternalValueRow extends StatelessWidget {
  const ExternalValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.kind,
    this.copyLabel,
  });

  final String label;
  final String value;
  final ExternalValueKind kind;
  final String? copyLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              children: [
                Text('$label: '),
                ExternalValueText(value, kind: kind),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy $label',
            onPressed: () => ExternalActionService.copy(
              context,
              value,
              label: copyLabel ?? label,
            ),
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
    );
  }
}

class AutoLinkText extends StatelessWidget {
  const AutoLinkText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final segments = ExternalActionService._splitTextSegments(text);
    return Wrap(
      children: segments.map((segment) {
        if (segment.kind == null) {
          return Text(segment.text, style: style);
        }
        return ExternalValueText(
          segment.text,
          kind: segment.kind!,
          style: style?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        );
      }).toList(),
    );
  }
}

class _ExternalTextSegment {
  const _ExternalTextSegment._(this.text, this.kind);

  const _ExternalTextSegment.text(String text) : this._(text, null);

  const _ExternalTextSegment.link(String text, ExternalValueKind kind)
    : this._(text, kind);

  final String text;
  final ExternalValueKind? kind;
}
