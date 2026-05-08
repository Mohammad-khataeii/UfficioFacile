import '../../admin_cms/domain/cms_models.dart';

enum ProblemMatchConfidence { high, medium, low }

class ProblemMatchResult {
  const ProblemMatchResult({
    required this.categorySlug,
    required this.categoryTitle,
    this.procedureSlug,
    this.procedureTitle,
    required this.confidence,
    required this.reason,
    required this.matchedTerms,
    this.requiredDocuments = const [],
    this.nextAction = '',
    this.submissionChannels = const [],
    this.warnings = const [],
    this.isPremium = false,
    this.source = 'cms',
  });

  final String categorySlug;
  final String categoryTitle;
  final String? procedureSlug;
  final String? procedureTitle;
  final ProblemMatchConfidence confidence;
  final String reason;
  final List<String> matchedTerms;
  final List<String> requiredDocuments;
  final String nextAction;
  final List<String> submissionChannels;
  final List<String> warnings;
  final bool isPremium;
  final String source;
}

class IntelligentProblemRouter {
  IntelligentProblemRouter({
    required List<CmsCategory> categories,
    required List<CmsProcedure> procedures,
    required String languageCode,
  }) : _languageCode = languageCode,
       _entries = _buildEntries(categories, procedures, languageCode);

  final String _languageCode;
  final List<_IndexEntry> _entries;

  List<ProblemMatchResult> findMatches(String query, {int limit = 6}) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return const [];

    final queryTokens = _tokens(normalizedQuery);
    final results =
        _entries
            .map((entry) => _scoreEntry(entry, normalizedQuery, queryTokens))
            .where((item) => item.score > 0)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return results
        .take(limit)
        .map(
          (item) => ProblemMatchResult(
            categorySlug: item.entry.category.slug,
            categoryTitle: _localizedText(
              item.entry.category.title,
              _languageCode,
              fallback: item.entry.category.slug,
            ),
            procedureSlug: item.entry.procedure?.slug,
            procedureTitle: item.entry.procedure == null
                ? null
                : _localizedText(
                    item.entry.procedure!.title,
                    _languageCode,
                    fallback: item.entry.procedure!.slug,
                  ),
            confidence: item.confidence,
            reason:
                "Matched '${item.matchedTerms.first}' with ${_localizedText(item.entry.category.title, _languageCode, fallback: item.entry.category.slug)}"
                "${item.entry.procedure == null ? '' : ' → ${_localizedText(item.entry.procedure!.title, _languageCode, fallback: item.entry.procedure!.slug)}'}",
            matchedTerms: item.matchedTerms,
            requiredDocuments: item.entry.requiredDocuments,
            nextAction: item.entry.nextAction,
            submissionChannels: item.entry.submissionChannels,
            warnings: item.entry.warnings,
            isPremium:
                item.entry.procedure?.isPremium ??
                item.entry.category.isPremium,
            source: 'cms',
          ),
        )
        .toList();
  }

  static List<_IndexEntry> _buildEntries(
    List<CmsCategory> categories,
    List<CmsProcedure> procedures,
    String languageCode,
  ) {
    final categoryBySlug = {
      for (final category in categories) category.slug: category,
    };
    final entries = <_IndexEntry>[];

    for (final category in categories) {
      entries.add(
        _IndexEntry(
          category: category,
          procedure: null,
          texts: [
            _localizedText(
              category.title,
              languageCode,
              fallback: category.slug,
            ),
            _localizedText(category.shortDescription, languageCode),
            _localizedText(category.longDescription, languageCode),
            ...category.tags,
            ...category.synonyms,
            ...category.searchableKeywords,
            ..._categorySynonyms[category.slug] ?? const [],
          ],
          tags: [
            ...category.tags,
            ...category.synonyms,
            ...category.searchableKeywords,
            ..._categorySynonyms[category.slug] ?? const [],
          ],
          requiredDocuments: const [],
          nextAction: 'Open the category and review the suggested procedures.',
          submissionChannels: const [],
          warnings: const [],
          titleBoostText: _localizedText(
            category.title,
            languageCode,
            fallback: category.slug,
          ),
        ),
      );
    }

    for (final procedure in procedures) {
      final category = categoryBySlug[procedure.categorySlug];
      if (category == null) continue;
      final metadataBlocks =
          (procedure.metadata['blocks'] as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map((item) => item.values.join(' '))
              .join(' ');
      entries.add(
        _IndexEntry(
          category: category,
          procedure: procedure,
          texts: [
            _localizedText(
              procedure.title,
              languageCode,
              fallback: procedure.slug,
            ),
            _localizedText(procedure.subtitle, languageCode),
            _localizedText(procedure.summary, languageCode),
            _localizedText(procedure.whatIsIt, languageCode),
            _localizedText(procedure.whyYouNeedIt, languageCode),
            _localizedText(procedure.howToDoIt, languageCode),
            _localizedText(procedure.documentsNeeded, languageCode),
            _localizedText(procedure.warnings, languageCode),
            metadataBlocks,
            ...procedure.tags,
            ...procedure.synonyms,
            ...procedure.searchableKeywords,
            ..._categorySynonyms[category.slug] ?? const [],
          ],
          tags: [
            ...procedure.tags,
            ...procedure.synonyms,
            ...procedure.searchableKeywords,
            ..._categorySynonyms[category.slug] ?? const [],
          ],
          requiredDocuments: _splitLocalizedLines(
            _localizedText(procedure.documentsNeeded, languageCode),
          ),
          nextAction: _localizedText(procedure.howToDoIt, languageCode),
          submissionChannels: _extractSubmissionChannels(procedure),
          warnings: _splitLocalizedLines(
            _localizedText(procedure.warnings, languageCode),
          ),
          titleBoostText: _localizedText(
            procedure.title,
            languageCode,
            fallback: procedure.slug,
          ),
        ),
      );
    }

    return entries;
  }

  _ScoredEntry _scoreEntry(
    _IndexEntry entry,
    String normalizedQuery,
    List<String> queryTokens,
  ) {
    var score = 0;
    final matchedTerms = <String>{};
    final normalizedTitle = _normalize(entry.titleBoostText);
    final normalizedText = _normalize(entry.texts.join(' '));
    final normalizedTags = entry.tags.map(_normalize).toList();

    if (normalizedText.contains(normalizedQuery)) {
      score += 60;
      matchedTerms.add(queryTokens.join(' '));
    }
    if (normalizedTitle.contains(normalizedQuery)) {
      score += 28;
      matchedTerms.add(queryTokens.join(' '));
    }

    final indexedTokens = _tokens(normalizedText);
    for (final token in queryTokens) {
      if (token.isEmpty) continue;
      if (normalizedTags.any((item) => item.contains(token))) {
        score += 14;
        matchedTerms.add(token);
        continue;
      }
      if (indexedTokens.contains(token)) {
        score += 8;
        matchedTerms.add(token);
        continue;
      }
      final fuzzy = indexedTokens.where(
        (candidate) => _isFuzzyMatch(token, candidate),
      );
      if (fuzzy.isNotEmpty) {
        score += 4;
        matchedTerms.add(token);
      }
    }

    if (entry.procedure != null &&
        normalizedTitle.split(' ').any(queryTokens.contains)) {
      score += 12;
    }
    if (entry.category.isPremium) {
      score += 1;
    }

    final confidence = score >= 60
        ? ProblemMatchConfidence.high
        : score >= 30
        ? ProblemMatchConfidence.medium
        : ProblemMatchConfidence.low;
    return _ScoredEntry(
      entry: entry,
      score: score,
      confidence: confidence,
      matchedTerms: matchedTerms.isEmpty
          ? queryTokens.take(1).toList()
          : matchedTerms.toList(),
    );
  }
}

class _IndexEntry {
  const _IndexEntry({
    required this.category,
    required this.procedure,
    required this.texts,
    required this.tags,
    required this.requiredDocuments,
    required this.nextAction,
    required this.submissionChannels,
    required this.warnings,
    required this.titleBoostText,
  });

  final CmsCategory category;
  final CmsProcedure? procedure;
  final List<String> texts;
  final List<String> tags;
  final List<String> requiredDocuments;
  final String nextAction;
  final List<String> submissionChannels;
  final List<String> warnings;
  final String titleBoostText;
}

class _ScoredEntry {
  const _ScoredEntry({
    required this.entry,
    required this.score,
    required this.confidence,
    required this.matchedTerms,
  });

  final _IndexEntry entry;
  final int score;
  final ProblemMatchConfidence confidence;
  final List<String> matchedTerms;
}

String _localizedText(
  Map<String, dynamic> values,
  String languageCode, {
  String fallback = '',
}) {
  if (values.isEmpty) return fallback;
  final normalized = values.map(
    (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
  );
  for (final candidate in [languageCode, 'en', 'it', 'fr', 'es', 'fa', 'ar']) {
    final value = normalized[candidate];
    if (value != null && value.trim().isNotEmpty) {
      return value;
    }
  }
  return normalized.values.firstWhere(
    (value) => value.trim().isNotEmpty,
    orElse: () => fallback,
  );
}

List<String> _splitLocalizedLines(String value) {
  return value
      .split('\n')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _extractSubmissionChannels(CmsProcedure procedure) {
  final channels = <String>[];
  final metadata = procedure.metadata;
  for (final key in const [
    'submission_channels',
    'recommendedChannels',
    'channels',
  ]) {
    final raw = metadata[key];
    if (raw is List) {
      channels.addAll(raw.whereType<Object>().map((item) => item.toString()));
    }
  }
  if (channels.isEmpty) {
    final text = _localizedText(procedure.howToDoIt, 'en');
    for (final channel in const [
      'online',
      'pec',
      'email',
      'in person',
      'phone',
    ]) {
      if (text.toLowerCase().contains(channel)) {
        channels.add(channel);
      }
    }
  }
  return channels.toSet().toList();
}

String _normalize(String input) {
  var value = input.toLowerCase();
  const replacements = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ğ': 'g',
    'ş': 's',
    '’': "'",
    'ة': 'ه',
    'ي': 'ی',
    'ك': 'ک',
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ؤ': 'و',
    'ئ': 'ی',
  };
  replacements.forEach((key, replacement) {
    value = value.replaceAll(key, replacement);
  });
  value = value.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff\s]'), ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return value;
}

List<String> _tokens(String value) {
  return value
      .split(' ')
      .map((item) => item.trim())
      .where((item) => item.length > 1)
      .toList();
}

bool _isFuzzyMatch(String left, String right) {
  if (left == right) return true;
  if (left.length <= 2 || right.length <= 2) {
    return left.startsWith(right) || right.startsWith(left);
  }
  if (left.startsWith(right) || right.startsWith(left)) return true;
  return _levenshtein(left, right) <= 1;
}

int _levenshtein(String s, String t) {
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;
  final prev = List<int>.generate(t.length + 1, (index) => index);
  final curr = List<int>.filled(t.length + 1, 0);
  for (var i = 0; i < s.length; i++) {
    curr[0] = i + 1;
    for (var j = 0; j < t.length; j++) {
      final cost = s[i] == t[j] ? 0 : 1;
      curr[j + 1] = [
        curr[j] + 1,
        prev[j + 1] + 1,
        prev[j] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
    for (var j = 0; j < prev.length; j++) {
      prev[j] = curr[j];
    }
  }
  return prev[t.length];
}

const Map<String, List<String>> _categorySynonyms = {
  'health_asl': [
    'asl',
    'medico di base',
    'family doctor',
    'gp',
    'doctor',
    'tessera sanitaria',
    'health card',
    'scelta medico',
    'cambio medico',
    'pediatra',
    'ssn',
  ],
  'university_student': [
    'university',
    'student',
    'enrollment',
    'scholarship',
    'edisu',
    'isee',
    'permesso studio',
    'questura',
  ],
  'housing_rent': [
    'rent',
    'affitto',
    'contratto',
    'lease',
    'landlord',
    'coinquilino',
    'subentro',
    'deposito cauzionale',
    'residenza',
  ],
  'utilities_electricity_gas': [
    'bolletta',
    'luce',
    'gas',
    'electricity',
    'power',
    'water',
    'provider',
    'switching',
    'voltura',
    'subentro',
    'disdetta',
    'reclamo',
  ],
  'canone_rai': ['canone rai', 'tv tax', 'bolletta rai', 'esenzione rai'],
  'telecom_internet_mobile': [
    'tim',
    'vodafone',
    'windtre',
    'iliad',
    'fastweb',
    'modem',
    'fibra',
    'disdetta',
    'portabilita',
  ],
  'public_office_comune': [
    'comune',
    'anagrafe',
    'residenza',
    'carta identita',
    'stato famiglia',
    'certificato',
    'domicilio',
  ],
  'work_inps_patronato': [
    'inps',
    'naspi',
    'disoccupazione',
    'patronato',
    'caf',
    'isee',
    'lavoro',
    'busta paga',
    'dimissioni',
    'contributi',
  ],
  'general': [
    'pec',
    'spid',
    'cie',
    'codice fiscale',
    'documenti',
    'appointment',
    'appuntamento',
    'form',
    'modulo',
    'raccomandata',
    'complaint',
    'reclamo',
  ],
  'bonuses-benefits': [
    'bonus',
    'bonuses',
    'benefit',
    'benefits',
    'agevolazione',
    'agevolazioni',
    'sussidio',
    'sostegno',
    'aiuto economico',
    'contributo',
    'isee',
    'inps',
    'arera',
    'bollette',
    'bonus sociale',
    'bonus luce',
    'bonus gas',
    'bonus acqua',
    'asilo nido',
    'assegno unico',
    'bonus psicologo',
    'voucher scuola',
    'rent support',
    'tax deduction',
    'detrazione',
  ],
  'loans-credit': [
    'loan',
    'loans',
    'prestito',
    'prestiti',
    'credito',
    'student loan',
    'prestito studenti',
    'prestito onore',
    'per merito',
    'intesa',
    'unicredit',
    'consap',
    'fondo studio',
    'fondo prima casa',
    'mutuo',
    'mortgage',
    'garanzia',
    'taeg',
    'tan',
    'cauzione',
    'deposit support',
  ],
};
