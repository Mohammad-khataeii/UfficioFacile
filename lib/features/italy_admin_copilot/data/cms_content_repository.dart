import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/supabase_bootstrap.dart';
import '../domain/rich_category_models.dart';

class CmsContentRepository {
  const CmsContentRepository();

  static const _forbiddenSnippets = <String>[
    'do not show',
    'internal note',
    'for codex',
    'implementationnotesforcodex',
  ];

  Future<RichCategoryGuidance?> getRichCategory(String slug) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return null;

    try {
      final row = await client
          .from('ufficio_cms_categories')
          .select(
            'slug, title, subtitle, description, public_snapshot, is_active',
          )
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();
      if (row == null) return null;
      final procedures = await client
          .from('ufficio_cms_procedures')
          .select(
            'slug, title, subtitle, summary, what_is_it, why_you_may_need_it, '
            'how_to_do_it, online_process, in_person_process, pec_process, '
            'email_process, normal_mail_process, phone_process, '
            'required_documents, optional_documents, costs, timing, deadlines, '
            'addresses, offices, official_links, forms, pec_addresses, '
            'email_addresses, phone_numbers, opening_hours, common_mistakes, '
            'warnings, proof_to_keep, next_steps, faq, premium_only_guidance, '
            'consultancy_cta, problem_request_cta, metadata, public_snapshot, '
            'verification_status, is_active, status, sort_order',
          )
          .eq('category_slug', slug)
          .eq('is_active', true)
          .eq('status', 'published')
          .order('sort_order', ascending: true);
      final blocks = await client
          .from('ufficio_cms_content_blocks')
          .select(
            'procedure_slug, block_type, title, body, items, sort_order, '
            'is_active, is_premium, visibility, warning_level, metadata',
          )
          .eq('is_active', true)
          .eq('visibility', 'public')
          .order('sort_order', ascending: true);
      final snapshot = row['public_snapshot'];
      final base = snapshot is Map
          ? Map<String, dynamic>.from(snapshot)
          : <String, dynamic>{'id': slug};
      final merged = _mergeCategoryWithProcedures(
        categorySlug: slug,
        base: base,
        categoryRow: Map<String, dynamic>.from(row),
        procedureRows: procedures
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
        blockRows: blocks
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
      final sanitized = _sanitizeMap(merged);
      if (sanitized.isEmpty) return null;
      return RichCategoryGuidance.fromMap(sanitized);
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _mergeCategoryWithProcedures({
    required String categorySlug,
    required Map<String, dynamic> base,
    required Map<String, dynamic> categoryRow,
    required List<Map<String, dynamic>> procedureRows,
    required List<Map<String, dynamic>> blockRows,
  }) {
    final result = Map<String, dynamic>.from(base);
    result['id'] = result['id'] ?? categorySlug;
    result['title'] =
        _localizedString(categoryRow['title'], fallback: result['title']) ??
        categorySlug;
    result['titleIt'] =
        _localizedString(
          categoryRow['title'],
          language: 'it',
          fallback: result['titleIt'] ?? result['title'],
        ) ??
        result['title'];
    result['shortDescription'] =
        _localizedString(
          categoryRow['description'],
          fallback: result['shortDescription'],
        ) ??
        result['shortDescription'] ??
        '';

    final baseSubcategories = <String, Map<String, dynamic>>{};
    final rawSubcategories =
        (result['subcategories'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    for (final subcategory in rawSubcategories) {
      final id = subcategory['id'] as String?;
      if (id != null && id.isNotEmpty) {
        baseSubcategories[id] = subcategory;
      }
    }

    final blocksByProcedure = <String, List<Map<String, dynamic>>>{};
    for (final row in blockRows) {
      final slug = row['procedure_slug'] as String?;
      if (slug == null || slug.isEmpty) continue;
      blocksByProcedure
          .putIfAbsent(slug, () => <Map<String, dynamic>>[])
          .add(row);
    }

    if (procedureRows.isNotEmpty) {
      result['subcategories'] = procedureRows.map((row) {
        final slug = row['slug'] as String? ?? '';
        final snapshot = row['public_snapshot'];
        final baseSnapshot = snapshot is Map
            ? Map<String, dynamic>.from(snapshot)
            : <String, dynamic>{};
        final baseSubcategory = Map<String, dynamic>.from({
          ...baseSubcategories[slug] ?? const <String, dynamic>{},
          ...baseSnapshot,
        });
        final procedureBlocks =
            blocksByProcedure[slug] ?? const <Map<String, dynamic>>[];
        baseSubcategory['id'] = slug;
        baseSubcategory['title'] =
            _localizedString(
              row['title'],
              fallback: baseSubcategory['title'],
            ) ??
            slug;
        baseSubcategory['titleIt'] =
            _localizedString(
              row['title'],
              language: 'it',
              fallback: baseSubcategory['titleIt'] ?? baseSubcategory['title'],
            ) ??
            baseSubcategory['title'];
        baseSubcategory['whatIsIt'] =
            _localizedString(
              row['what_is_it'],
              fallback:
                  _blockPrimaryText(procedureBlocks, 'what_is_it') ??
                  _localizedString(row['summary']) ??
                  baseSubcategory['whatIsIt'],
            ) ??
            '';
        baseSubcategory['whyDoYouNeedIt'] = _mergeStringLists([
          _stringList(
            row['why_you_may_need_it'],
            baseSubcategory['whyDoYouNeedIt'],
          ),
          _blockStringList(procedureBlocks, 'why_you_need_it'),
          _blockStringList(procedureBlocks, 'eligibility'),
        ]);
        baseSubcategory['documents'] = _mergeStringLists([
          _stringList(row['required_documents'], baseSubcategory['documents']),
          _blockStringList(procedureBlocks, 'documents'),
        ]);
        baseSubcategory['extraDocuments'] = _mergeStringLists([
          _stringList(
            row['optional_documents'],
            baseSubcategory['extraDocuments'],
          ),
          _prefixedList('Proof to keep', row['proof_to_keep']),
          _prefixedList('Official links', row['official_links']),
          _prefixedList('Forms', row['forms']),
        ]);
        baseSubcategory['warnings'] = _mergeStringLists([
          _stringList(row['warnings'], baseSubcategory['warnings']),
          _stringList(row['common_mistakes'], const []),
          _blockStringList(procedureBlocks, 'warning'),
          _blockStringList(procedureBlocks, 'common_mistakes'),
        ]);
        baseSubcategory['userQuestions'] = _mergeStringLists([
          _prefixedList('How to do it', row['how_to_do_it']),
          _prefixedList('Online', row['online_process']),
          _prefixedList('In person', row['in_person_process']),
          _prefixedList('PEC', row['pec_process']),
          _prefixedList('Email', row['email_process']),
          _prefixedList('Normal mail', row['normal_mail_process']),
          _prefixedList('Phone', row['phone_process']),
          _prefixedList('Addresses', row['addresses']),
          _prefixedList('Offices', row['offices']),
          _prefixedList('Phone numbers', row['phone_numbers']),
          _prefixedList('Opening hours', row['opening_hours']),
          _prefixedList('Next steps', row['next_steps']),
          _blockStringList(procedureBlocks, 'steps'),
          _blockStringList(procedureBlocks, 'faq'),
        ]);
        baseSubcategory['deadlines'] = _deadlineMaps(row['deadlines']);
        baseSubcategory['configurableRules'] = _configurableRules(
          costs: row['costs'],
          timing: row['timing'],
          premium: row['premium_only_guidance'],
          faq: row['faq'],
        );
        final metadata = row['metadata'];
        if (metadata is Map) {
          final map = Map<String, dynamic>.from(metadata);
          if (map['recommendedChannels'] is List) {
            baseSubcategory['recommendedChannels'] = map['recommendedChannels'];
          }
          if (map['recommendedContacts'] is List) {
            baseSubcategory['recommendedContacts'] = map['recommendedContacts'];
          }
          if (map['outputs'] is List) {
            baseSubcategory['outputs'] = map['outputs'];
          }
        }
        return baseSubcategory;
      }).toList();
    }

    return result;
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    for (final entry in source.entries) {
      final value = _sanitizeValue(entry.value);
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is List && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;
      result[entry.key] = value;
    }
    result.remove('implementationNotesForCodex');
    final topWarning = result['topWarning'];
    if (topWarning is String && _containsForbiddenSnippet(topWarning)) {
      result.remove('topWarning');
    }
    return result;
  }

  dynamic _sanitizeValue(dynamic value) {
    if (value is Map) {
      return _sanitizeMap(Map<String, dynamic>.from(value));
    }
    if (value is List) {
      return value.map(_sanitizeValue).where((item) => item != null).toList();
    }
    if (value is String) {
      return _containsForbiddenSnippet(value) ? null : value;
    }
    return value;
  }

  bool _containsForbiddenSnippet(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '');
    for (final snippet in _forbiddenSnippets) {
      if (normalized.contains(snippet.replaceAll(' ', ''))) {
        return true;
      }
    }
    return false;
  }

  String? _localizedString(
    dynamic source, {
    String language = 'en',
    dynamic fallback,
  }) {
    if (source is Map) {
      final value = source[language] ?? source['en'];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    if (fallback is String && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return null;
  }

  List<String> _stringList(dynamic source, dynamic fallback) {
    if (source is List) {
      return source.whereType<String>().toList();
    }
    if (fallback is List) {
      return fallback.whereType<String>().toList();
    }
    return const <String>[];
  }

  List<String> _mergeStringLists(List<List<String>> groups) {
    final values = <String>[];
    final seen = <String>{};
    for (final group in groups) {
      for (final item in group) {
        final trimmed = item.trim();
        if (trimmed.isEmpty || !seen.add(trimmed)) continue;
        values.add(trimmed);
      }
    }
    return values;
  }

  List<String> _blockStringList(
    List<Map<String, dynamic>> blocks,
    String blockType,
  ) {
    return _mergeStringLists(
      blocks
          .where((block) => block['block_type'] == blockType)
          .map(
            (block) => [
              ..._dynamicStringList(block['items']),
              ..._dynamicStringList(block['body']),
              ..._dynamicStringList(block['title']),
            ],
          )
          .toList(),
    );
  }

  String? _blockPrimaryText(
    List<Map<String, dynamic>> blocks,
    String blockType,
  ) {
    final matches = blocks.where((block) => block['block_type'] == blockType);
    for (final block in matches) {
      final body = _firstString(block['body']);
      if (body != null) return body;
      final title = _firstString(block['title']);
      if (title != null) return title;
    }
    return null;
  }

  List<String> _prefixedList(String label, dynamic source) {
    final items = _dynamicStringList(source);
    if (items.isEmpty) return const <String>[];
    return items.map((item) => '$label: $item').toList();
  }

  List<Map<String, dynamic>> _deadlineMaps(dynamic source) {
    final items = _dynamicStringList(source);
    var index = 0;
    return items
        .map(
          (item) => {
            'id': 'deadline_${index++}',
            'label': 'Deadline',
            'rule': item,
          },
        )
        .toList();
  }

  Map<String, dynamic> _configurableRules({
    dynamic costs,
    dynamic timing,
    dynamic premium,
    dynamic faq,
  }) {
    final result = <String, dynamic>{};
    var index = 0;
    for (final item in _dynamicStringList(costs)) {
      result['cost_${index++}'] = {'label': 'Cost', 'value': item};
    }
    index = 0;
    for (final item in _dynamicStringList(timing)) {
      result['timing_${index++}'] = {'label': 'Timing', 'value': item};
    }
    index = 0;
    for (final item in _dynamicStringList(premium)) {
      result['premium_${index++}'] = {'label': 'Premium help', 'value': item};
    }
    index = 0;
    for (final item in _dynamicStringList(faq)) {
      result['faq_${index++}'] = {'label': 'FAQ', 'value': item};
    }
    return result;
  }

  List<String> _dynamicStringList(dynamic source) {
    if (source is List) {
      return source.expand(_dynamicStringList).toList();
    }
    if (source is Map) {
      return source.values.expand(_dynamicStringList).toList();
    }
    if (source is String && source.trim().isNotEmpty) {
      return [source.trim()];
    }
    return const <String>[];
  }

  String? _firstString(dynamic source) {
    final items = _dynamicStringList(source);
    if (items.isEmpty) return null;
    return items.first;
  }
}
