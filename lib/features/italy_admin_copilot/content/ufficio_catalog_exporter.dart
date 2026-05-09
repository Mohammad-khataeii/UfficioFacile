import '../domain/ufficio_catalog.dart';

Map<String, dynamic> buildUfficioCatalogBundleFromCmsSeed(
  Map<String, dynamic> cmsSeedBundle,
) {
  final categories =
      (cmsSeedBundle['categories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );

  return <String, dynamic>{
    'version': 1,
    'updatedAt': DateTime.now().toUtc().toIso8601String().split('T').first,
    'languages': const <String>['en', 'it', 'fr', 'es', 'fa', 'ar'],
    'categories': categories.map(_buildCategory).toList(),
  };
}

Map<String, dynamic> _buildCategory(Map<String, dynamic> category) {
  final categoryId = category['slug']?.toString() ?? '';
  final procedures =
      (category['procedures'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );

  final groupedSubcategories = _groupProceduresForCategory(
    categoryId,
    procedures,
  );
  final builtSubcategories = groupedSubcategories.map((group) {
    final builtProcedures =
        group.procedures
            .map(
              (procedure) => _buildProcedure(
                categoryId: categoryId,
                subcategoryId: group.id,
                procedure: procedure,
              ),
            )
            .toList()
          ..sort(
            (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
          );
    final hasPremiumContent = builtProcedures.any(
      (item) => item['isPremiumOnly'] == true || _sectionHasPremium(item),
    );
    return <String, dynamic>{
      'id': group.id,
      'categoryId': categoryId,
      'sortOrder': group.sortOrder,
      'isPremiumOnly':
          builtProcedures.isNotEmpty &&
          builtProcedures.every((item) => item['isPremiumOnly'] == true),
      'hasPremiumContent': hasPremiumContent,
      'title': group.title,
      'description': group.description,
      'procedures': builtProcedures,
    };
  }).toList();

  final hasPremiumContent = builtSubcategories.any(
    (item) =>
        item['hasPremiumContent'] == true || item['isPremiumOnly'] == true,
  );

  return <String, dynamic>{
    'id': categoryId,
    'icon': category['icon']?.toString() ?? 'folder_open',
    'sortOrder': (category['sort_order'] as num?)?.toInt() ?? 0,
    'isPremiumOnly': category['is_premium'] as bool? ?? false,
    'hasPremiumContent': hasPremiumContent,
    'title': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(category['title']),
    ),
    'description': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(
        category['description'] ?? category['subtitle'],
      ),
    ),
    'subcategories': builtSubcategories,
  };
}

Map<String, dynamic> _buildProcedure({
  required String categoryId,
  required String subcategoryId,
  required Map<String, dynamic> procedure,
}) {
  final isPremium = procedure['is_premium'] as bool? ?? false;
  final sections = <Map<String, dynamic>>[];

  void addTextSection(
    String key,
    dynamic title,
    dynamic body, {
    required bool isPremiumOnly,
  }) {
    final localizedBody = _normalizeSectionBody(body);
    if (localizedBody.values.every((item) => item.trim().isEmpty)) return;
    sections.add(<String, dynamic>{
      'type': 'text',
      'key': key,
      'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(title)),
      'body': localizedBody,
      'isPremiumOnly': isPremiumOnly,
    });
  }

  void addChecklistSection(
    String key,
    dynamic title,
    dynamic items, {
    required bool isPremiumOnly,
  }) {
    final localizedItems = _normalizeItems(items);
    if (localizedItems.values.every((list) => list.isEmpty)) return;
    sections.add(<String, dynamic>{
      'type': 'checklist',
      'key': key,
      'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(title)),
      'items': localizedItems,
      'isPremiumOnly': isPremiumOnly,
    });
  }

  addTextSection(
    'what_it_is',
    const <String, String>{
      'en': 'What it is',
      'it': 'Cos’è',
      'fr': 'Ce que c’est',
      'es': 'Qué es',
      'fa': 'چیست',
      'ar': 'ما هو',
    },
    procedure['what_is_it'] ?? procedure['summary'],
    isPremiumOnly: false,
  );
  addChecklistSection(
    'when_you_need_it',
    const <String, String>{
      'en': 'When you need it',
      'it': 'Quando ti serve',
      'fr': 'Quand vous en avez besoin',
      'es': 'Cuándo lo necesitas',
      'fa': 'چه زمانی لازم است',
      'ar': 'متى تحتاج إليه',
    },
    procedure['why_you_may_need_it'],
    isPremiumOnly: false,
  );
  addChecklistSection(
    'how_to_do_it',
    const <String, String>{
      'en': 'How to do it',
      'it': 'Come fare',
      'fr': 'Comment faire',
      'es': 'Cómo hacerlo',
      'fa': 'چطور انجام دهی',
      'ar': 'كيفية القيام به',
    },
    procedure['how_to_do_it'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'documents_needed',
    const <String, String>{
      'en': 'Documents needed',
      'it': 'Documenti necessari',
      'fr': 'Documents nécessaires',
      'es': 'Documentos necesarios',
      'fa': 'مدارک لازم',
      'ar': 'المستندات المطلوبة',
    },
    procedure['required_documents'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'cost',
    const <String, String>{
      'en': 'Cost',
      'it': 'Costo',
      'fr': 'Coût',
      'es': 'Costo',
      'fa': 'هزینه',
      'ar': 'التكلفة',
    },
    procedure['costs'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'timeline',
    const <String, String>{
      'en': 'Timeline',
      'it': 'Tempi',
      'fr': 'Délais',
      'es': 'Plazos',
      'fa': 'زمان‌بندی',
      'ar': 'المدة',
    },
    procedure['timing'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'warnings',
    const <String, String>{
      'en': 'Warnings',
      'it': 'Avvertenze',
      'fr': 'Avertissements',
      'es': 'Advertencias',
      'fa': 'هشدارها',
      'ar': 'تحذيرات',
    },
    procedure['warnings'],
    isPremiumOnly: false,
  );

  final blocks =
      (procedure['blocks'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );
  for (final block in blocks) {
    final blockBody = _normalizeSectionBody(block['body']);
    final blockItems = _normalizeItems(block['items']);
    if (blockBody.values.every((item) => item.trim().isEmpty) &&
        blockItems.values.every((item) => item.isEmpty)) {
      continue;
    }
    final key = block['block_type']?.toString() ?? 'info';
    final isDuplicateIntro =
        key == 'intro' &&
        sections.any(
          (section) =>
              section['key'] == 'what_it_is' &&
              _sameLocalizedText(
                section['body'] as Map<String, String>? ?? const {},
                blockBody,
              ),
        );
    if (isDuplicateIntro) {
      continue;
    }
    sections.add(<String, dynamic>{
      'type': blockItems.values.any((item) => item.isNotEmpty)
          ? 'checklist'
          : 'text',
      'key': key,
      'title': _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(block['title']),
      ),
      'body': blockBody,
      'items': blockItems,
      'isPremiumOnly': (block['is_premium'] as bool? ?? false) || isPremium,
    });
  }

  final warnings = _normalizeSectionBodyFromList(procedure['warnings']);
  return <String, dynamic>{
    'id': procedure['slug'],
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'sortOrder': (procedure['sort_order'] as num?)?.toInt() ?? 0,
    'isPremiumOnly': isPremium,
    'requiresAuth': false,
    'title': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(procedure['title']),
    ),
    'shortDescription': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(
        procedure['summary'] ?? procedure['subtitle'],
      ),
    ),
    'tags': (procedure['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList(),
    'sections': sections,
    'officialLinks': _buildOfficialLinks(procedure),
    'contacts': _buildContacts(procedure),
    'warnings': warnings,
    'premiumTeaser': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(
        procedure['premium_teaser'] ?? procedure['summary'],
      ),
    ),
  };
}

bool _sectionHasPremium(Map<String, dynamic> procedure) {
  final sections =
      (procedure['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>();
  for (final section in sections) {
    if (section['isPremiumOnly'] == true) return true;
  }
  return false;
}

Map<String, String> _normalizeSectionBody(dynamic value) {
  if (value is Map) {
    final localized = ufficioLocalizedTextFromJson(value);
    if (localized.isNotEmpty) return _sanitizeLocalizedText(localized);
  }
  if (value is List) {
    return _normalizeSectionBodyFromList(value);
  }
  if (value is String && value.trim().isNotEmpty) {
    return _sanitizeLocalizedText(<String, String>{
      'en': value.trim(),
      'it': value.trim(),
    });
  }
  return const <String, String>{};
}

Map<String, String> _normalizeSectionBodyFromList(dynamic value) {
  if (value is List) {
    final texts = value
        .map((item) => _sanitizeText(item.toString().trim()))
        .where((item) => item.isNotEmpty)
        .toList();
    if (texts.isNotEmpty) {
      final joined = texts.join('\n');
      return <String, String>{'en': joined, 'it': joined};
    }
  }
  return const <String, String>{};
}

Map<String, List<String>> _normalizeItems(dynamic value) {
  if (value is Map) {
    final result = <String, List<String>>{};
    for (final entry in value.entries) {
      final itemValue = entry.value;
      if (itemValue is List) {
        result[entry.key.toString()] = itemValue
            .map((item) => _sanitizeText(item.toString().trim()))
            .where((item) => item.isNotEmpty)
            .toList();
      } else if (itemValue is String && itemValue.trim().isNotEmpty) {
        result[entry.key.toString()] = <String>[
          _sanitizeText(itemValue.trim()),
        ];
      }
    }
    return result;
  }
  if (value is List) {
    final items = value
        .map((item) => _sanitizeText(item.toString().trim()))
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isNotEmpty) {
      return <String, List<String>>{'en': items, 'it': items};
    }
  }
  if (value is String && value.trim().isNotEmpty) {
    final item = _sanitizeText(value.trim());
    return <String, List<String>>{
      'en': <String>[item],
      'it': <String>[item],
    };
  }
  return const <String, List<String>>{};
}

List<Map<String, dynamic>> _buildOfficialLinks(Map<String, dynamic> procedure) {
  final links = <Map<String, dynamic>>[];
  final sources = (procedure['sources'] as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item));
  for (final source in sources) {
    final url = source['url']?.toString() ?? '';
    if (url.trim().isEmpty) continue;
    links.add(<String, dynamic>{
      'label': _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(
          source['title'] ?? source['label'] ?? source['authority'],
        ),
      ),
      'url': url,
      'type': source['source_type']?.toString() ?? 'official',
    });
  }
  final officialLinks =
      (procedure['official_links'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty);
  for (final item in officialLinks) {
    final sanitized = _sanitizeText(item);
    if (sanitized.isEmpty) continue;
    links.add(<String, dynamic>{
      'label': <String, String>{'en': sanitized, 'it': sanitized},
      'url': '',
      'type': 'reference',
    });
  }
  return links;
}

List<Map<String, dynamic>> _buildContacts(Map<String, dynamic> procedure) {
  final contacts = <Map<String, dynamic>>[];
  final officialContacts =
      (procedure['official_contacts'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty);
  for (final item in officialContacts) {
    final sanitized = _sanitizeText(item);
    if (sanitized.isEmpty) continue;
    contacts.add(<String, dynamic>{
      'label': <String, String>{'en': sanitized, 'it': sanitized},
      'value': sanitized,
      'type': 'reference',
    });
  }
  return contacts;
}

List<_CategoryGroup> _groupProceduresForCategory(
  String categoryId,
  List<Map<String, dynamic>> procedures,
) {
  final config = _categoryGroups[categoryId];
  if (config == null) {
    return _fallbackGroups(categoryId, procedures);
  }

  final proceduresBySlug = <String, Map<String, dynamic>>{
    for (final procedure in procedures)
      procedure['slug']?.toString() ?? '': procedure,
  };
  final grouped = <_CategoryGroup>[];
  final seen = <String>{};

  for (final item in config) {
    final members = item.procedureSlugs
        .map((slug) => proceduresBySlug[slug])
        .whereType<Map<String, dynamic>>()
        .toList();
    grouped.add(
      _CategoryGroup(
        id: item.id,
        title: item.title,
        description: item.description,
        sortOrder: grouped.length + 1,
        procedures: members,
      ),
    );
    seen.addAll(item.procedureSlugs);
  }

  final leftovers = procedures
      .where((procedure) => !seen.contains(procedure['slug']?.toString() ?? ''))
      .toList();
  if (leftovers.isNotEmpty) {
    grouped.addAll(
      _fallbackGroups(categoryId, leftovers, startOrder: grouped.length + 1),
    );
  }
  return grouped;
}

List<_CategoryGroup> _fallbackGroups(
  String categoryId,
  List<Map<String, dynamic>> procedures, {
  int startOrder = 1,
}) {
  return procedures.asMap().entries.map((entry) {
    final procedure = entry.value;
    final slug = procedure['slug']?.toString() ?? 'procedure';
    return _CategoryGroup(
      id: slug,
      title: _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(procedure['title']),
      ),
      description: _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(
          procedure['summary'] ?? procedure['subtitle'],
        ),
      ),
      sortOrder: startOrder + entry.key,
      procedures: <Map<String, dynamic>>[procedure],
    );
  }).toList();
}

Map<String, String> _sanitizeLocalizedText(Map<String, String> raw) {
  return raw.map((key, value) => MapEntry(key, _sanitizeText(value)));
}

String _sanitizeText(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return value;

  const replacements = <String, String>{
    'to help the user': 'to help you',
    'the user should': 'you should',
    'do not show': '',
    'placeholder': '',
    'todo': '',
    'fake data': '',
    'lorem ipsum': '',
    'do not tell': 'Explain clearly that',
  };

  final lower = value.toLowerCase();
  if (lower.contains('do not route')) {
    value = value.replaceAllMapped(
      RegExp(r'do not route[^.]*\.?', caseSensitive: false),
      (_) =>
          'Use this path only when the competent office confirms it is the right option. ',
    );
  }

  for (final entry in replacements.entries) {
    value = value.replaceAll(
      RegExp(entry.key, caseSensitive: false),
      entry.value,
    );
  }

  value = value
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(' .', '.')
      .replaceAll(' ,', ',')
      .trim();
  return value;
}

bool _sameLocalizedText(Map<String, String> a, Map<String, String> b) {
  if (a.isEmpty || b.isEmpty) return false;
  final languages = <String>{...a.keys, ...b.keys};
  for (final language in languages) {
    final left = a[language]?.trim() ?? '';
    final right = b[language]?.trim() ?? '';
    if (left.isNotEmpty && right.isNotEmpty) {
      return left == right;
    }
  }
  return false;
}

Map<String, List<_GroupTemplate>> get _categoryGroups => {
  'health_asl': [
    _group(
      'ssn_asl_access',
      'SSN and ASL access',
      'Iscrizione SSN e accesso ASL',
      'Accès au SSN et à l’ASL',
      'Acceso al SSN y a la ASL',
      'دسترسی به SSN و ASL',
      'الوصول إلى SSN وASL',
      'Registration, enrollment, and healthcare access rules for residents, students, workers, and special cases.',
      'Iscrizione, copertura e regole di accesso alla sanità per residenti, studenti, lavoratori e casi particolari.',
      'Inscription, couverture et règles d’accès pour résidents, étudiants, travailleurs et cas particuliers.',
      'Inscripción, cobertura y reglas de acceso para residentes, estudiantes, trabajadores y casos especiales.',
      'ثبت‌نام، پوشش و قوانین دسترسی درمانی برای ساکنان، دانشجویان، کارگران و موارد خاص.',
      'التسجيل والتغطية وقواعد الوصول للمقيمين والطلاب والعمال والحالات الخاصة.',
      [
        'italian_resident_torino',
        'unemployed_torino',
        'non_resident_worker_or_student_torino',
      ],
    ),
    _group(
      'doctor_health_card',
      'Doctor and health card',
      'Medico e tessera sanitaria',
      'Médecin et carte sanitaire',
      'Médico y tarjeta sanitaria',
      'پزشک و کارت سلامت',
      'الطبيب والبطاقة الصحية',
      'Choose your doctor, renew your health card, and fix local registration details.',
      'Scegli il medico, rinnova la tessera sanitaria e sistema i dati di registrazione.',
      'Choisissez votre médecin, renouvelez la carte sanitaire et corrigez les données d’inscription.',
      'Elige médico, renueva la tarjeta sanitaria y corrige los datos de registro.',
      'پزشک را انتخاب کن، کارت سلامت را تمدید کن و اطلاعات ثبت را اصلاح کن.',
      'اختر الطبيب، جدّد البطاقة الصحية وصحّح بيانات التسجيل.',
      ['duplicate_or_renew_tessera_sanitaria'],
    ),
    _group(
      'bookings_prescriptions_cup',
      'Bookings, prescriptions, and CUP',
      'Prenotazioni, ricette e CUP',
      'Rendez-vous, ordonnances et CUP',
      'Reservas, recetas y CUP',
      'رزرو، نسخه و CUP',
      'الحجوزات والوصفات وCUP',
      'Appointments, prescriptions, and booking support for local health services.',
      'Supporto per appuntamenti, ricette e prenotazioni dei servizi sanitari.',
      'Support pour les rendez-vous, ordonnances et réservations dei servizi sanitari.',
      'Apoyo para citas, recetas y reservas de servicios sanitarios.',
      'پشتیبانی برای نوبت، نسخه و رزرو خدمات درمانی.',
      'دعم للمواعيد والوصفات وحجوزات الخدمات الصحية.',
      const <String>[],
    ),
    _group(
      'ticket_exemptions',
      'Ticket and exemptions',
      'Ticket ed esenzioni',
      'Ticket et exonérations',
      'Tickets y exenciones',
      'هزینه خدمات و معافیت‌ها',
      'الرسوم والإعفاءات',
      'Copayment rules and exemption paths for health charges.',
      'Regole sul ticket sanitario e percorsi di esenzione.',
      'Règles de ticket sanitaire et parcours d’exonération.',
      'Reglas de copago sanitario y vías de exención.',
      'قوانین پرداخت خدمات درمانی و مسیرهای معافیت.',
      'قواعد الرسوم الصحية ومسارات الإعفاء.',
      const <String>[],
    ),
    _group(
      'digital_health_record',
      'Digital health record and reports',
      'Fascicolo sanitario digitale e referti',
      'Dossier de santé numérique et résultats',
      'Historial digital y resultados',
      'پرونده سلامت دیجیتال و جواب آزمایش',
      'السجل الصحي الرقمي والنتائج',
      'Access your digital record, test results, and online health documents.',
      'Accedi al fascicolo digitale, ai referti e ai documenti sanitari online.',
      'Accéder au dossier numérique, aux résultats et aux documents de santé en ligne.',
      'Acceder al historial digital, resultados y documentos sanitarios en línea.',
      'دسترسی به پرونده دیجیتال، جواب‌ها و مدارک درمانی آنلاین.',
      'الوصول إلى السجل الرقمي والنتائج والوثائق الصحية عبر الإنترنت.',
      const <String>[],
    ),
    _group(
      'asl_problems',
      'Problems and rejected requests',
      'Problemi ASL e richieste respinte',
      'Problèmes ASL et demandes refusées',
      'Problemas ASL y solicitudes rechazadas',
      'مشکلات ASL و درخواست‌های ردشده',
      'مشكلات ASL والطلبات المرفوضة',
      'Fix blocked access, missing coverage, and rejected healthcare requests.',
      'Risolvere accessi bloccati, coperture mancanti e richieste sanitarie respinte.',
      'Résoudre les accès bloqués, la couverture manquante et les demandes refusées.',
      'Resolver accesos bloqueados, cobertura faltante y solicitudes rechazadas.',
      'حل دسترسی مسدود، نبود پوشش و درخواست درمانی ردشده.',
      'حل الوصول المقيّد أو غياب التغطية أو الطلبات المرفوضة.',
      ['no_valid_permesso_stp', 'eu_without_team_or_coverage'],
    ),
    _group(
      'student_insurance',
      'Foreign students and insurance options',
      'Studenti stranieri e opzioni assicurative',
      'Étudiants étrangers et options d’assurance',
      'Estudiantes extranjeros y opciones de seguro',
      'دانشجویان خارجی و گزینه‌های بیمه',
      'الطلاب الأجانب وخيارات التأمين',
      'Healthcare access for students, EU mobility, and private or voluntary insurance paths.',
      'Accesso sanitario per studenti, mobilità UE e percorsi assicurativi o volontari.',
      'Accès aux soins pour étudiants, mobilité UE et solutions d’assurance ou volontaires.',
      'Acceso sanitario para estudiantes, movilidad UE y opciones de seguro o inscripción voluntaria.',
      'دسترسی درمانی برای دانشجویان، جابه‌جایی اتحادیه اروپا و گزینه‌های بیمه یا ثبت داوطلبانه.',
      'الوصول الصحي للطلاب وتنقل الاتحاد الأوروبي وخيارات التأمين أو التسجيل الطوعي.',
      [
        'italian_student_domiciled_torino',
        'eu_student_torino',
        'non_eu_student_torino',
        'non_eu_worker_torino',
      ],
    ),
  ],
  'housing_rent': [
    _groupSimple(
      'rental_contracts',
      'Rental contracts',
      'Contratti di affitto',
      'Contrats de location',
      'Contratos de alquiler',
      'قراردادهای اجاره',
      'عقود الإيجار',
      'Registration, checks, and changes for rental contracts.',
      'Registrazione, controlli e modifiche dei contratti di affitto.',
      'Enregistrement, contrôles et modifications des contrats de location.',
      'Registro, controles y cambios de contratos de alquiler.',
      'ثبت، بررسی و تغییر قراردادهای اجاره.',
      'تسجيل عقود الإيجار ومراجعتها وتعديلها.',
      ['register_or_check_rental_contract', 'rental_contract_change'],
    ),
    _groupSimple(
      'tenant_changes',
      'Tenant changes',
      'Cambi intestatari e inquilini',
      'Changements de locataire',
      'Cambios de inquilino',
      'تغییرات مستأجر',
      'تغييرات المستأجرين',
      'Add, remove, or update tenants and residence details.',
      'Aggiungi, rimuovi o aggiorna inquilini e dati di residenza.',
      'Ajouter, retirer ou mettre à jour les locataires et la résidence.',
      'Añadir, quitar o actualizar inquilinos y residencia.',
      'افزودن، حذف یا به‌روزرسانی مستأجر و آدرس.',
      'إضافة أو إزالة أو تحديث المستأجرين والعنوان.',
      ['add_or_remove_tenant', 'rent_contract_termination_notice'],
    ),
    _groupSimple(
      'payments_deposit',
      'Payments and deposit',
      'Pagamenti e deposito',
      'Paiements et dépôt',
      'Pagos y depósito',
      'پرداخت‌ها و ودیعه',
      'المدفوعات والتأمين',
      'Late rent, deposit return, and shared charges.',
      'Affitto in ritardo, restituzione deposito e spese condivise.',
      'Retard de loyer, restitution du dépôt et charges partagées.',
      'Retraso de alquiler, devolución del depósito y gastos compartidos.',
      'تاخیر اجاره، بازگشت ودیعه و هزینه‌های مشترک.',
      'تأخر الإيجار واسترجاع التأمين والمصاريف المشتركة.',
      [
        'deposit_return',
        'rent_payment_delay_payment_plan',
        'wrong_expenses_spese_condominiali',
      ],
    ),
    _groupSimple(
      'repairs_landlord',
      'Repairs and landlord duties',
      'Riparazioni e doveri del proprietario',
      'Réparations et obligations du propriétaire',
      'Reparaciones y obligaciones del propietario',
      'تعمیرات و مسئولیت‌های صاحبخانه',
      'الإصلاحات وواجبات المالك',
      'Maintenance requests and written follow-up with the landlord.',
      'Richieste di manutenzione e solleciti scritti al proprietario.',
      'Demandes de réparation et relances écrites au propriétaire.',
      'Solicitudes de reparación y seguimiento escrito al propietario.',
      'درخواست تعمیر و پیگیری کتبی با صاحبخانه.',
      'طلبات الصيانة والمتابعة الكتابية مع المالك.',
      ['landlord_maintenance_repair_request', 'formal_complaint_to_landlord'],
    ),
    _groupSimple(
      'disputes_eviction',
      'Disputes and eviction',
      'Controversie e sfratto',
      'Litiges et expulsion',
      'Conflictos y desahucio',
      'اختلافات و تخلیه',
      'النزاعات والإخلاء',
      'Irregular contracts, eviction pressure, and formal support paths.',
      'Contratti irregolari, sfratto e percorsi di supporto formale.',
      'Contrats irréguliers, expulsion et voies de soutien formel.',
      'Contratos irregulares, desahucio y vías de apoyo formal.',
      'قراردادهای نامنظم، فشار تخلیه و مسیرهای رسمی حمایت.',
      'العقود غير النظامية والإخلاء ومسارات الدعم الرسمية.',
      [
        'unregistered_irregular_rental_contract',
        'eviction_sfratto_support',
        'tenant_union_appointment',
      ],
    ),
    _groupSimple(
      'student_housing',
      'Student housing',
      'Alloggio studenti',
      'Logement étudiant',
      'Vivienda estudiantil',
      'مسکن دانشجویی',
      'سكن الطلاب',
      'Student rent support and emergency housing options.',
      'Sostegno affitto studenti e soluzioni abitative di emergenza.',
      'Aides au loyer étudiant et solutions d’urgence.',
      'Ayudas al alquiler para estudiantes y soluciones de emergencia.',
      'کمک اجاره دانشجویی و راه‌حل‌های اضطراری مسکن.',
      'دعم إيجار الطلاب والحلول السكنية الطارئة.',
      ['student_rent_help', 'emergency_housing_comune_support'],
    ),
  ],
  'utilities_electricity_gas': [
    _groupSimple(
      'understand_bills',
      'Understand bills',
      'Capire le bollette',
      'Comprendre les factures',
      'Entender las facturas',
      'فهم قبض‌ها',
      'فهم الفواتير',
      'Read the bill, supplier roles, and meter data clearly.',
      'Leggere chiaramente bolletta, ruoli dei fornitori e dati del contatore.',
      'Lire clairement la facture, les rôles des opérateurs et les données du compteur.',
      'Leer con claridad la factura, los roles del proveedor y los datos del contador.',
      'خواندن روشن قبض، نقش شرکت‌ها و اطلاعات کنتور.',
      'فهم الفاتورة وأدوار الشركات وبيانات العداد.',
      [
        'understand_electricity_or_gas_bill',
        'check_supplier_vs_distributor',
        'meter_reading_correction',
      ],
    ),
    _groupSimple(
      'activation_transfer_cancellation',
      'Activation, transfer, and cancellation',
      'Attivazione, voltura, subentro e disdetta',
      'Activation, transfert et résiliation',
      'Activación, cambio y cancelación',
      'فعال‌سازی، انتقال و لغو',
      'التفعيل والنقل والإلغاء',
      'Start, transfer, or close a utility contract correctly.',
      'Attivare, trasferire o chiudere correttamente un contratto utenze.',
      'Activer, transférer ou fermer correctement un contrat de fourniture.',
      'Activar, transferir o cerrar correctamente un contrato.',
      'راه‌اندازی، انتقال یا بستن درست قرارداد خدمات.',
      'بدء عقد الخدمة أو نقله أو إغلاقه بشكل صحيح.',
      [
        'new_activation_prima_attivazione',
        'voltura',
        'subentro',
        'utility_cancellation_disdetta',
      ],
    ),
    _groupSimple(
      'provider_switching_offers',
      'Provider switching and offers',
      'Cambio fornitore e offerte',
      'Changement de fournisseur et offres',
      'Cambio de proveedor y ofertas',
      'تغییر شرکت و پیشنهادها',
      'تغيير المزوّد والعروض',
      'Compare and change provider without hidden surprises.',
      'Confrontare e cambiare fornitore senza brutte sorprese.',
      'Comparer et changer de fournisseur sans mauvaises surprises.',
      'Comparar y cambiar de proveedor sin sorpresas.',
      'مقایسه و تغییر شرکت بدون دردسر پنهان.',
      'مقارنة العروض وتغيير المزوّد بدون مفاجآت.',
      ['provider_switching', 'compare_offers_safely'],
    ),
    _groupSimple(
      'complaints_refunds',
      'Complaints and refunds',
      'Reclami e rimborsi',
      'Réclamations et remboursements',
      'Reclamaciones y reembolsos',
      'شکایت و بازپرداخت',
      'الشكاوى والاسترداد',
      'High bills, wrong charges, and written complaint paths.',
      'Bollette alte, addebiti errati e reclami formali.',
      'Factures élevées, frais erronés et voies de réclamation.',
      'Facturas altas, cargos erróneos y reclamaciones formales.',
      'قبض‌های بالا، هزینه‌های اشتباه و مسیرهای شکایت رسمی.',
      'الفواتير المرتفعة والرسوم الخاطئة ومسارات الشكوى الرسمية.',
      [
        'high_bill_complaint',
        'wrong_charge_refund',
        'unilateral_contract_change_complaint',
        'contract_not_requested_scam_activation',
      ],
    ),
    _groupSimple(
      'emergencies_faults',
      'Emergencies and faults',
      'Guasti ed emergenze',
      'Pannes et urgences',
      'Averías y emergencias',
      'خرابی و فوریت‌ها',
      'الأعطال والطوارئ',
      'Service outages, gas danger, and urgent fault handling.',
      'Interruzioni di servizio, pericoli gas e gestione urgente dei guasti.',
      'Pannes de service, danger gaz et gestion urgente.',
      'Cortes de servicio, peligro de gas y gestión urgente.',
      'قطعی سرویس، خطر گاز و رسیدگی فوری به خرابی.',
      'انقطاع الخدمة وخطر الغاز والتعامل العاجل مع الأعطال.',
      ['gas_or_electricity_emergency_fault'],
    ),
    _groupSimple(
      'arera_escalation',
      'ARERA escalation',
      'Escalation ARERA',
      'Recours ARERA',
      'Escalación ARERA',
      'ارجاع به ARERA',
      'التصعيد إلى ARERA',
      'Payment plans, conciliation, and regulator escalation.',
      'Rateizzazioni, conciliazione ed escalation al regolatore.',
      'Plans de paiement, conciliation et recours au régulateur.',
      'Planes de pago, conciliación y escalado al regulador.',
      'برنامه پرداخت، سازش و ارجاع به نهاد ناظر.',
      'خطط السداد والتسوية والتصعيد إلى الجهة المنظمة.',
      ['payment_plan_request', 'arera_complaint_and_conciliation'],
    ),
  ],
  'canone_rai': [
    _groupSimple(
      'understand_canone_rai',
      'Understand Canone RAI',
      'Capire il Canone RAI',
      'Comprendre le Canone RAI',
      'Entender el Canone RAI',
      'درک Canone RAI',
      'فهم Canone RAI',
      'Basics, when it applies, and how it appears on bills.',
      'Basi, quando si applica e come appare in bolletta.',
      'Bases, conditions d’application et présence sur la facture.',
      'Bases, cuándo se aplica y cómo aparece en la factura.',
      'مبانی، زمان اعمال و نحوه نمایش در قبض.',
      'الأساسيات ومتى يطبق وكيف يظهر في الفاتورة.',
      ['understand_if_must_pay_canone_rai'],
    ),
    _groupSimple(
      'exemptions_declarations',
      'Exemptions and declarations',
      'Esenzioni e dichiarazioni',
      'Exemptions et déclarations',
      'Exenciones y declaraciones',
      'معافیت‌ها و اظهارنامه‌ها',
      'الإعفاءات والتصريحات',
      'No-TV, over-75, and other exemption paths.',
      'Dichiarazione di non detenzione, over 75 e altre esenzioni.',
      'Déclaration sans TV, plus de 75 ans et autres exonérations.',
      'Declaración sin TV, mayores de 75 y otras exenciones.',
      'اظهار نداشتن تلویزیون، بالای ۷۵ سال و معافیت‌های دیگر.',
      'إقرار عدم وجود تلفاز وإعفاءات فوق 75 سنة وغيرها.',
      [
        'no_tv_declaration',
        'over_75_exemption',
        'diplomatic_military_exemption',
      ],
    ),
    _groupSimple(
      'refunds_wrong_charges',
      'Refunds and wrong charges',
      'Rimborsi e addebiti errati',
      'Remboursements et frais erronés',
      'Reembolsos y cargos erróneos',
      'بازپرداخت و هزینه اشتباه',
      'الاسترداد والرسوم الخاطئة',
      'Fix incorrect charges and ask for refunds when due.',
      'Correggi addebiti errati e chiedi rimborso quando dovuto.',
      'Corriger les frais erronés et demander remboursement.',
      'Corregir cargos erróneos y pedir reembolso.',
      'اصلاح هزینه‌های اشتباه و درخواست بازپرداخت.',
      'تصحيح الرسوم الخاطئة وطلب الاسترداد.',
      ['refund_wrong_charge', 'wrong_electricity_bill_charge'],
    ),
    _groupSimple(
      'forms_deadlines',
      'Forms and deadlines',
      'Moduli e scadenze',
      'Formulaires et délais',
      'Formularios y plazos',
      'فرم‌ها و مهلت‌ها',
      'النماذج والمواعيد',
      'Handle forms correctly after a new contract or changed home situation.',
      'Gestisci correttamente i moduli dopo un nuovo contratto o cambio casa.',
      'Gérer correctement les formulaires après un nouveau contrat ou un changement de logement.',
      'Gestionar bien los formularios tras un nuevo contrato o cambio de vivienda.',
      'رسیدگی درست به فرم‌ها پس از قرارداد جدید یا تغییر خانه.',
      'إدارة النماذج بشكل صحيح بعد عقد جديد أو تغيير السكن.',
      [
        'new_home_changed_electricity_contract',
        'help_filling_agenzia_entrate_form',
      ],
    ),
  ],
  'telecom_internet_mobile': [
    _groupSimple(
      'activation_switching_cancellation',
      'Activation, switching, and cancellation',
      'Attivazione, cambio e disdetta',
      'Activation, changement et résiliation',
      'Activación, cambio y cancelación',
      'فعال‌سازی، تغییر و لغو',
      'التفعيل والتغيير والإلغاء',
      'Open, move, switch, or cancel home and mobile services.',
      'Apri, trasferisci, cambia o disdici servizi casa e mobile.',
      'Ouvrir, transférer, changer ou résilier les services maison et mobile.',
      'Abrir, trasladar, cambiar o cancelar servicios de casa y móvil.',
      'باز کردن، انتقال، تغییر یا لغو خدمات خانه و موبایل.',
      'فتح أو نقل أو تغيير أو إلغاء خدمات المنزل والموبايل.',
      [
        'understand_telecom_problem',
        'internet_phone_cancellation',
        'mobile_sim_cancellation',
        'provider_switching_number_portability',
        'activation_delay_no_line',
      ],
    ),
    _groupSimple(
      'bills_refunds',
      'Bills and refunds',
      'Bollette e rimborsi',
      'Factures et remboursements',
      'Facturas y reembolsos',
      'قبض‌ها و بازپرداخت',
      'الفواتير والاسترداد',
      'Dispute wrong bills, roaming charges, and reimbursement claims.',
      'Contesta bollette errate, roaming e richieste di rimborso.',
      'Contester les factures erronées, frais de roaming et remboursements.',
      'Discutir facturas erróneas, roaming y reembolsos.',
      'اعتراض به قبض اشتباه، رومینگ و درخواست بازپرداخت.',
      'الاعتراض على الفواتير الخاطئة والرسوم الدولية وطلبات الاسترداد.',
      [
        'wrong_bill_complaint',
        'refund_or_compensation_request',
        'roaming_international_charge_dispute',
        'payment_plan_unpaid_bills',
      ],
    ),
    _groupSimple(
      'service_quality_faults',
      'Service quality and faults',
      'Qualità del servizio e guasti',
      'Qualité du service et pannes',
      'Calidad del servicio y averías',
      'کیفیت سرویس و خرابی‌ها',
      'جودة الخدمة والأعطال',
      'Low speed, no service, and fault follow-up.',
      'Velocità bassa, linea assente e follow-up dei guasti.',
      'Débit faible, service absent et suivi des pannes.',
      'Velocidad baja, sin servicio y seguimiento de averías.',
      'سرعت پایین، قطع سرویس و پیگیری خرابی.',
      'السرعة المنخفضة وانقطاع الخدمة ومتابعة الأعطال.',
      ['service_not_working_complaint', 'internet_speed_too_low'],
    ),
    _groupSimple(
      'modem_device',
      'Modem and device disputes',
      'Modem e dispositivi',
      'Modem et appareils',
      'Módem y dispositivos',
      'مودم و دستگاه',
      'المودم والأجهزة',
      'Return, charges, and disputes about equipment.',
      'Restituzione, addebiti e contestazioni sugli apparati.',
      'Retour, frais et litiges sur les équipements.',
      'Devolución, cargos y disputas sobre equipos.',
      'بازگرداندن، هزینه و اختلاف درباره تجهیزات.',
      'إرجاع الأجهزة والرسوم والنزاعات المتعلقة بها.',
      ['modem_return_or_charge_dispute'],
    ),
    _groupSimple(
      'scams_unrequested_contracts',
      'Scams and unrequested contracts',
      'Truffe e contratti non richiesti',
      'Arnaques et contrats non demandés',
      'Estafas y contratos no solicitados',
      'کلاهبرداری و قرارداد ناخواسته',
      'الاحتيال والعقود غير المطلوبة',
      'Protect yourself from scam activations and unwanted contracts.',
      'Proteggiti da attivazioni truffa e contratti non richiesti.',
      'Se protéger contre les activations frauduleuses et contrats non demandés.',
      'Protegerse de activaciones fraudulentas y contratos no solicitados.',
      'محافظت در برابر فعال‌سازی کلاهبردارانه و قرارداد ناخواسته.',
      'الحماية من التفعيلات الاحتيالية والعقود غير المطلوبة.',
      ['contract_not_requested_phone_scam'],
    ),
    _groupSimple(
      'conciliaweb_escalation',
      'ConciliaWeb escalation',
      'Escalation ConciliaWeb',
      'Recours ConciliaWeb',
      'Escalación ConciliaWeb',
      'ارجاع به ConciliaWeb',
      'التصعيد عبر ConciliaWeb',
      'Move from complaint to formal telecom conciliation.',
      'Passa dal reclamo alla conciliazione formale telecom.',
      'Passer de la réclamation à la conciliation télécom.',
      'Pasar de la reclamación a la conciliación formal.',
      'از شکایت به سازش رسمی مخابرات برو.',
      'الانتقال من الشكوى إلى التسوية الرسمية للاتصالات.',
      ['pec_formal_complaint_operator', 'agcom_corecom_conciliaweb_escalation'],
    ),
  ],
  'public_office_comune': [
    _groupSimple(
      'residence_address',
      'Residence and address',
      'Residenza e indirizzo',
      'Résidence et adresse',
      'Residencia y dirección',
      'اقامت و آدرس',
      'الإقامة والعنوان',
      'Move residence, update address, and manage temporary registration.',
      'Cambio residenza, variazione indirizzo e iscrizioni temporanee.',
      'Changer la résidence, mettre à jour l’adresse et gérer l’inscription temporaire.',
      'Cambiar residencia, actualizar dirección y gestionar registro temporal.',
      'تغییر اقامت، به‌روزرسانی آدرس و ثبت موقت.',
      'تغيير محل الإقامة وتحديث العنوان والتسجيل المؤقت.',
      [
        'understand_residenza_domicilio_temporary',
        'change_residence_from_another_comune_or_abroad',
        'change_address_inside_torino',
        'temporary_residence_popolazione_temporanea',
        'doorbell_mailbox_address_proof',
      ],
    ),
    _groupSimple(
      'certificates_autocertification',
      'Certificates and autocertification',
      'Certificati e autocertificazione',
      'Certificats et autocertification',
      'Certificados y autocertificación',
      'گواهی‌ها و خوداظهاری',
      'الشهادات والتصريح الذاتي',
      'Get demographic certificates and understand self-certification.',
      'Ottenere certificati anagrafici e usare l’autocertificazione.',
      'Obtenir des certificats administratifs et utiliser l’autocertification.',
      'Obtener certificados y usar la autocertificación.',
      'گرفتن گواهی‌های اداری و استفاده از خوداظهاری.',
      'الحصول على الشهادات واستخدام التصريح الذاتي.',
      [
        'anagrafe_certificate_request',
        'family_status_certificate',
        'residence_certificate',
        'self_certification_autocertificazione',
      ],
    ),
    _groupSimple(
      'appointments_contacts',
      'Appointments and contacts',
      'Appuntamenti e contatti',
      'Rendez-vous et contacts',
      'Citas y contactos',
      'نوبت و تماس‌ها',
      'المواعيد وجهات الاتصال',
      'Book appointments and send formal requests to the Comune.',
      'Prenota appuntamenti e invia richieste formali al Comune.',
      'Prendre rendez-vous et envoyer des demandes formelles à la mairie.',
      'Reservar citas y enviar solicitudes formales al ayuntamiento.',
      'رزرو نوبت و ارسال درخواست رسمی به شهرداری.',
      'حجز المواعيد وإرسال الطلبات الرسمية إلى البلدية.',
      [
        'book_anagrafe_appointment',
        'pec_formal_request_comune',
        'general_comune_information_request',
      ],
    ),
    _groupSimple(
      'rejected_requests',
      'Rejected requests',
      'Richieste respinte',
      'Demandes refusées',
      'Solicitudes rechazadas',
      'درخواست‌های ردشده',
      'الطلبات المرفوضة',
      'Reply to rejections and missing document issues clearly.',
      'Rispondi a rigetti e richieste di integrazione documenti.',
      'Répondre aux refus et aux demandes de documents manquants.',
      'Responder a rechazos y pedidos de documentos faltantes.',
      'پاسخ به رد درخواست و مدارک ناقص.',
      'الرد على الرفض وطلبات المستندات الناقصة.',
      ['rejected_residenza_request_reply'],
    ),
    _groupSimple(
      'online_services',
      'Online services',
      'Servizi online',
      'Services en ligne',
      'Servicios en línea',
      'خدمات آنلاین',
      'الخدمات الإلكترونية',
      'Use digital services and recover from portal issues.',
      'Usa i servizi digitali e gestisci i problemi del portale.',
      'Utiliser les services numériques et résoudre les problèmes du portail.',
      'Usar servicios digitales y resolver problemas del portal.',
      'استفاده از خدمات دیجیتال و حل مشکل پورتال.',
      'استخدام الخدمات الرقمية ومعالجة مشاكل البوابة.',
      ['online_comune_service_problem'],
    ),
  ],
  'work_inps_patronato': [
    _groupSimple(
      'naspi_unemployment',
      'NASpI and unemployment',
      'NASpI e disoccupazione',
      'NASpI et chômage',
      'NASpI y desempleo',
      'NASpI و بیکاری',
      'NASpI والبطالة',
      'Prepare, file, and follow unemployment support steps.',
      'Prepara, invia e segui le pratiche per la disoccupazione.',
      'Préparer, déposer et suivre les démarches de chômage.',
      'Preparar, presentar y seguir trámites de desempleo.',
      'آماده‌سازی، ثبت و پیگیری بیکاری.',
      'إعداد وتقديم ومتابعة إجراءات البطالة.',
      [
        'understand_job_loss_benefit_situation',
        'naspi_preparation',
        'naspi_application_followup',
        'did_and_centro_impiego',
      ],
    ),
    _groupSimple(
      'patronato_inps_contacts',
      'Patronato and INPS contacts',
      'Contatti patronato e INPS',
      'Contacts patronato et INPS',
      'Contactos patronato e INPS',
      'تماس‌های patronato و INPS',
      'جهات اتصال patronato وINPS',
      'Find the right INPS or patronato contact and prepare your request.',
      'Trova il contatto giusto e prepara la richiesta a INPS o patronato.',
      'Trouver le bon contact et préparer la demande à l’INPS ou au patronato.',
      'Encontrar el contacto correcto y preparar la solicitud a INPS o patronato.',
      'یافتن تماس درست و آماده‌سازی درخواست به INPS یا patronato.',
      'العثور على الجهة المناسبة وتحضير الطلب إلى INPS أو patronato.',
      [
        'patronato_appointment_request',
        'inps_appointment_contact_request',
        'general_inps_formal_request_pec',
      ],
    ),
    _groupSimple(
      'employment_documents',
      'Employment documents',
      'Documenti di lavoro',
      'Documents de travail',
      'Documentos laborales',
      'مدارک کاری',
      'مستندات العمل',
      'Contract end, missing documents, and formal follow-up with employers or INPS.',
      'Fine contratto, documenti mancanti e follow-up formale con datore o INPS.',
      'Fin de contrat, documents manquants et suivi formel avec l’employeur ou l’INPS.',
      'Fin de contrato, documentos faltantes y seguimiento formal con empresa o INPS.',
      'پایان قرارداد، مدارک ناقص و پیگیری رسمی با کارفرما یا INPS.',
      'انتهاء العقد والمستندات الناقصة والمتابعة الرسمية مع صاحب العمل أو INPS.',
      [
        'missing_documents_integration',
        'employer_termination_contract_end_documents',
        'reply_rejected_inps_request',
      ],
    ),
    _groupSimple(
      'workplace_payment_disputes',
      'Payment and workplace disputes',
      'Pagamenti e controversie di lavoro',
      'Paiements et litiges du travail',
      'Pagos y conflictos laborales',
      'پرداخت و اختلافات کاری',
      'المدفوعات ونزاعات العمل',
      'Payslips, TFR, disputes, and support channels.',
      'Buste paga, TFR, controversie e canali di supporto.',
      'Fiches de paie, TFR, litiges et canaux de soutien.',
      'Nóminas, TFR, conflictos y canales de apoyo.',
      'فیش حقوقی، TFR، اختلافات و مسیرهای حمایت.',
      'قسائم الرواتب وTFR والنزاعات وقنوات الدعم.',
      ['payslip_tfr_final_payment_problem', 'union_legal_work_dispute_support'],
    ),
    _groupSimple(
      'caf_isee',
      'CAF and ISEE',
      'CAF e ISEE',
      'CAF et ISEE',
      'CAF e ISEE',
      'CAF و ISEE',
      'CAF وISEE',
      'Connect work or family issues to CAF and ISEE paperwork.',
      'Collega pratiche lavoro o famiglia ai documenti CAF e ISEE.',
      'Relier les démarches travail ou famille aux documents CAF et ISEE.',
      'Relacionar trámites laborales o familiares con documentos CAF e ISEE.',
      'پیوند دادن مسائل کار یا خانواده با مدارک CAF و ISEE.',
      'ربط مسائل العمل أو الأسرة بوثائق CAF وISEE.',
      ['isee_caf_connection'],
    ),
    _groupSimple(
      'family_sick_leave_benefits',
      'Family, sick leave, and benefits',
      'Famiglia, malattia e benefici',
      'Famille, arrêt maladie et aides',
      'Familia, baja y ayudas',
      'خانواده، مرخصی بیماری و مزایا',
      'العائلة والإجازة المرضية والمزايا',
      'Sick leave, maternity, and family benefit basics.',
      'Malattia, maternità e basi dei benefici familiari.',
      'Arrêt maladie, maternité et bases des aides familiales.',
      'Baja por enfermedad, maternidad y bases de ayudas familiares.',
      'مرخصی بیماری، زایمان و مبانی مزایای خانوادگی.',
      'الإجازة المرضية والأمومة وأساسيات مزايا الأسرة.',
      ['sick_leave_malattia_inps_basics', 'maternity_family_benefit_help'],
    ),
  ],
  'university_student': [
    _groupSimple(
      'university_offices_certificates',
      'University offices and certificates',
      'Uffici universitari e certificati',
      'Bureaux universitaires et certificats',
      'Oficinas universitarias y certificados',
      'دفاتر دانشگاه و گواهی‌ها',
      'مكاتب الجامعة والشهادات',
      'Contact offices, ask for certificates, and prepare formal university requests.',
      'Contatta uffici, chiedi certificati e prepara richieste formali.',
      'Contacter les bureaux, demander des certificats et préparer des demandes formelles.',
      'Contactar oficinas, pedir certificados y preparar solicitudes formales.',
      'تماس با دفاتر، درخواست گواهی و آماده‌سازی درخواست رسمی.',
      'الاتصال بالمكاتب وطلب الشهادات وتحضير الطلبات الرسمية.',
      [
        'understand_student_administrative_problem',
        'university_office_request',
        'university_certificate_request',
        'formal_email_university_edisu_office',
      ],
    ),
    _groupSimple(
      'edisu_scholarship_housing',
      'EDISU scholarship and housing',
      'Borsa EDISU e alloggio',
      'Bourse EDISU et logement',
      'Beca EDISU y alojamiento',
      'بورسیه و خوابگاه EDISU',
      'منحة وسكن EDISU',
      'Scholarship applications, housing, and rejected EDISU cases.',
      'Domande borsa, alloggio e casi EDISU respinti.',
      'Demandes de bourse, logement et cas EDISU refusés.',
      'Solicitudes de beca, alojamiento y casos EDISU rechazados.',
      'درخواست بورسیه، اسکان و موارد ردشده EDISU.',
      'طلبات المنحة والسكن وحالات EDISU المرفوضة.',
      [
        'edisu_scholarship_application',
        'edisu_rejected_missing_documents',
        'student_housing_edisu_residence',
      ],
    ),
    _groupSimple(
      'isee_tuition',
      'ISEE and tuition',
      'ISEE e tasse universitarie',
      'ISEE et frais universitaires',
      'ISEE y tasas universitarias',
      'ISEE و شهریه',
      'ISEE والرسوم الجامعية',
      'Documents for ISEE, fee reduction, and tuition support.',
      'Documenti per ISEE, riduzione tasse e sostegni universitari.',
      'Documents pour ISEE, réduction des frais et soutien universitaire.',
      'Documentos para ISEE, reducción de tasas y apoyo universitario.',
      'مدارک ISEE، کاهش شهریه و حمایت دانشگاهی.',
      'وثائق ISEE وتخفيض الرسوم والدعم الجامعي.',
      ['isee_isee_parificato_students', 'tuition_fees_fee_reduction_documents'],
    ),
    _groupSimple(
      'permesso_student',
      'Student permit of stay',
      'Permesso di soggiorno studenti',
      'Titre de séjour étudiant',
      'Permiso de estancia de estudiante',
      'اجازه اقامت دانشجویی',
      'إقامة الطالب',
      'First request, renewal, and Questura follow-up for students.',
      'Primo rilascio, rinnovo e follow-up in Questura per studenti.',
      'Première demande, renouvellement et suivi en Questura.',
      'Primera solicitud, renovación y seguimiento en Questura.',
      'درخواست اول، تمدید و پیگیری کوئستورا برای دانشجویان.',
      'الطلب الأول والتجديد والمتابعة لدى الكويستورا.',
      [
        'permesso_first_request',
        'permesso_renewal',
        'permesso_questura_followup',
      ],
    ),
    _groupSimple(
      'student_health_residence_rent',
      'Student health, residence, and rent',
      'Sanità, residenza e affitto studenti',
      'Santé, résidence et loyer étudiant',
      'Salud, residencia y alquiler estudiantil',
      'سلامت، اقامت و اجاره دانشجو',
      'الصحة والإقامة وإيجار الطالب',
      'Healthcare access, residence, and housing documents for students.',
      'Accesso sanitario, residenza e documenti abitativi per studenti.',
      'Accès aux soins, résidence et documents de logement pour étudiants.',
      'Acceso sanitario, residencia y documentos de vivienda para estudiantes.',
      'دسترسی درمانی، اقامت و مدارک مسکن برای دانشجویان.',
      'الوصول الصحي والإقامة ووثائق السكن للطلاب.',
      [
        'student_healthcare_tessera_doctor',
        'residenza_domicile_students',
        'rental_contract_proof_students',
      ],
    ),
  ],
  'general': [
    _groupSimple(
      'find_right_office',
      'Find the right office',
      'Trova l’ufficio giusto',
      'Trouver le bon bureau',
      'Encontrar la oficina correcta',
      'پیدا کردن اداره درست',
      'العثور على الجهة الصحيحة',
      'Start here when you are not sure which office should handle your case.',
      'Inizia da qui se non sai quale ufficio deve seguire il tuo caso.',
      'Commencez ici si vous ne savez pas quel bureau doit traiter votre dossier.',
      'Empieza aquí si no sabes qué oficina debe tratar tu caso.',
      'از اینجا شروع کن اگر نمی‌دانی کدام اداره باید پرونده‌ات را رسیدگی کند.',
      'ابدأ من هنا إذا لم تكن تعرف أي جهة يجب أن تعالج ملفك.',
      ['understand_which_office_to_contact'],
    ),
    _groupSimple(
      'formal_requests',
      'Formal requests',
      'Richieste formali',
      'Demandes formelles',
      'Solicitudes formales',
      'درخواست‌های رسمی',
      'الطلبات الرسمية',
      'Write clear formal requests, appointment messages, and status updates.',
      'Scrivi richieste formali chiare, appuntamenti e aggiornamenti di stato.',
      'Rédiger des demandes formelles claires, rendez-vous et mises à jour.',
      'Redactar solicitudes formales claras, citas y actualizaciones.',
      'نوشتن درخواست رسمی، پیام نوبت و پیگیری وضعیت.',
      'صياغة الطلبات الرسمية ورسائل المواعيد وتحديثات الحالة.',
      [
        'generic_formal_request',
        'formal_appointment_request',
        'status_update_with_protocol',
      ],
    ),
    _groupSimple(
      'rejected_or_missing_documents',
      'Rejected requests and missing documents',
      'Rigetti e documenti mancanti',
      'Refus et documents manquants',
      'Rechazos y documentos faltantes',
      'رد درخواست و مدارک ناقص',
      'الرفض والمستندات الناقصة',
      'Reply to rejections, clarify requests, and send missing files correctly.',
      'Rispondi ai rigetti, chiarisci le richieste e invia integrazioni corrette.',
      'Répondre aux refus, clarifier les demandes et envoyer les pièces manquantes.',
      'Responder a rechazos, aclarar solicitudes y enviar documentos faltantes.',
      'پاسخ به رد درخواست، روشن کردن ابهام و ارسال مدارک ناقص.',
      'الرد على الرفض وتوضيح الطلبات وإرسال المستندات الناقصة.',
      [
        'reply_rejected_public_office_request',
        'missing_documents_integration',
        'ask_document_clarification',
      ],
    ),
    _groupSimple(
      'refunds_complaints',
      'Refunds and complaints',
      'Rimborsi e reclami',
      'Remboursements et réclamations',
      'Reembolsos y reclamaciones',
      'بازپرداخت و شکایت',
      'الاسترداد والشكاوى',
      'Ask for refunds, make complaints, and follow up when nobody answers.',
      'Chiedi rimborsi, fai reclami e sollecita se nessuno risponde.',
      'Demander un remboursement, déposer une réclamation et relancer.',
      'Pedir reembolso, presentar reclamación y hacer seguimiento.',
      'درخواست بازپرداخت، ثبت شکایت و پیگیری در صورت بی‌پاسخ ماندن.',
      'طلب الاسترداد وتقديم الشكوى والمتابعة عند عدم الرد.',
      ['refund_request', 'complaint_request', 'followup_unanswered_request'],
    ),
    _groupSimple(
      'pec_and_attachments',
      'PEC and attachments',
      'PEC e allegati',
      'PEC et pièces jointes',
      'PEC y adjuntos',
      'PEC و پیوست‌ها',
      'PEC والمرفقات',
      'Prepare attachments and send a formal PEC when needed.',
      'Prepara allegati e invia una PEC formale quando serve.',
      'Préparer les pièces jointes et envoyer un PEC formel si nécessaire.',
      'Preparar adjuntos y enviar un PEC formal cuando haga falta.',
      'آماده‌سازی پیوست و ارسال PEC رسمی در صورت نیاز.',
      'تحضير المرفقات وإرسال PEC رسمي عند الحاجة.',
      ['send_pec_with_attachments', 'prepare_documents_before_office'],
    ),
    _groupSimple(
      'formal_italian_writing',
      'Formal Italian writing',
      'Scrittura formale in italiano',
      'Rédaction formelle en italien',
      'Redacción formal en italiano',
      'نوشتن رسمی ایتالیایی',
      'الكتابة الرسمية بالإيطالية',
      'Turn rough notes into short, polite, or stronger formal Italian.',
      'Trasforma note confuse in italiano formale, breve o più deciso.',
      'Transformer des notes en italien formel, bref ou plus ferme.',
      'Convertir notas en italiano formal, breve o más firme.',
      'تبدیل یادداشت‌های خام به متن رسمی، کوتاه یا محکم ایتالیایی.',
      'تحويل الملاحظات إلى إيطالية رسمية قصيرة أو أقوى.',
      [
        'write_short_polite_email',
        'write_strong_formal_complaint',
        'convert_informal_to_formal_italian',
      ],
    ),
  ],
  'bonuses-benefits': [
    _groupSimple(
      'bonus_finder',
      'Bonus finder',
      'Trova bonus',
      'Chercher des aides',
      'Buscador de ayudas',
      'یابنده بونوس',
      'باحث الدعم',
      'Interactive tool to surface the most relevant support based on your situation.',
      'Strumento interattivo per trovare gli aiuti più rilevanti in base alla tua situazione.',
      'Outil interactif pour trouver les aides les plus utiles selon votre situation.',
      'Herramienta interactiva para encontrar las ayudas más útiles según tu situación.',
      'ابزار تعاملی برای یافتن کمک‌های مناسب وضعیت تو.',
      'أداة تفاعلية لإظهار المساعدات الأنسب لوضعك.',
      ['bonus-finder'],
    ),
    _groupSimple(
      'bills_family_social_bonuses',
      'Bills, family, and social bonuses',
      'Bonus bollette, famiglia e sociale',
      'Aides factures, famille et social',
      'Bonos de facturas, familia y social',
      'بونوس‌های قبض، خانواده و اجتماعی',
      'دعم الفواتير والأسرة والاجتماعي',
      'Recurring household, disability, and family support measures.',
      'Misure ricorrenti per casa, disabilità e sostegno familiare.',
      'Mesures récurrentes pour le foyer, le handicap et le soutien familial.',
      'Medidas recurrentes para hogar, discapacidad y apoyo familiar.',
      'حمایت‌های تکرارشونده برای خانواده، ناتوانی و خانه.',
      'إعانات متكررة للأسرة والإعاقة والمنزل.',
      [
        'bonus-sociale-bollette',
        'bonus-elettrico-disagio-fisico',
        'assegno-unico-universale',
        'carta-dedicata-a-te',
        'bonus-mamme',
      ],
    ),
    _groupSimple(
      'child_family_benefits',
      'Child and family benefits',
      'Aiuti per figli e famiglia',
      'Aides pour enfants et famille',
      'Ayudas para hijos y familia',
      'مزایای کودک و خانواده',
      'مزايا الأطفال والأسرة',
      'Support linked to children, childcare, and new births.',
      'Sostegni per figli, nido e nuove nascite.',
      'Soutiens pour enfants, garde et nouvelles naissances.',
      'Apoyos para hijos, guardería y nuevos nacimientos.',
      'حمایت برای فرزند، مهدکودک و تولد جدید.',
      'دعم للأطفال والحضانة والمواليد الجدد.',
      ['bonus-asilo-nido', 'bonus-nuovi-nati'],
    ),
    _groupSimple(
      'school_regional_benefits',
      'School and regional benefits',
      'Benefici scuola e regionali',
      'Aides scolaires et régionales',
      'Ayudas escolares y regionales',
      'مزایای مدرسه و منطقه‌ای',
      'المزايا المدرسية والإقليمية',
      'Regional school support and education calls.',
      'Sostegni regionali per scuola e bandi educativi.',
      'Soutiens régionaux pour l’école et appels éducatifs.',
      'Apoyos regionales para escuela y convocatorias educativas.',
      'حمایت‌های منطقه‌ای مدرسه و فراخوان‌های آموزشی.',
      'الدعم الإقليمي للمدرسة والبرامج التعليمية.',
      ['voucher-scuola-piemonte'],
    ),
    _groupSimple(
      'rent_home_support',
      'Rent and home support',
      'Aiuto affitto e casa',
      'Aides logement et loyer',
      'Ayuda de alquiler y vivienda',
      'حمایت اجاره و خانه',
      'دعم الإيجار والسكن',
      'Rent support and home-related deductions or aid.',
      'Sostegno affitto e detrazioni o aiuti per la casa.',
      'Aides au loyer et déductions liées au logement.',
      'Ayudas al alquiler y deducciones para vivienda.',
      'حمایت اجاره و کسر مالیاتی یا کمک مسکن.',
      'دعم الإيجار وخصومات أو مساعدات السكن.',
      ['rent-support-piemonte', 'home-tax-deductions'],
    ),
    _groupSimple(
      'seasonal_benefits',
      'Seasonal and monitored benefits',
      'Benefici stagionali da monitorare',
      'Aides saisonnières à surveiller',
      'Ayudas estacionales para vigilar',
      'مزایای فصلی قابل پیگیری',
      'المزايا الموسمية التي يجب متابعتها',
      'Time-limited benefits that may reopen during the year.',
      'Benefici a tempo che possono riaprire durante l’anno.',
      'Aides limitées dans le temps qui peuvent rouvrir pendant l’année.',
      'Ayudas limitadas en el tiempo que pueden reabrirse durante el año.',
      'مزایای محدود زمانی که ممکن است دوباره باز شوند.',
      'مزايا محدودة زمنياً قد تعود خلال السنة.',
      ['bonus-psicologo'],
    ),
  ],
  'loans-credit': [
    _groupSimple(
      'loan_comparison',
      'Loan comparison',
      'Confronto prestiti',
      'Comparaison de prêts',
      'Comparación de préstamos',
      'مقایسه وام',
      'مقارنة القروض',
      'Interactive tool to compare student and support credit options.',
      'Strumento interattivo per confrontare prestiti studenti e strumenti di supporto.',
      'Outil interactif pour comparer les prêts étudiants et les soutiens.',
      'Herramienta interactiva para comparar préstamos de estudio y apoyos.',
      'ابزار تعاملی برای مقایسه وام دانشجویی و گزینه‌های حمایتی.',
      'أداة تفاعلية لمقارنة قروض الدراسة وخيارات الدعم.',
      ['loan-comparison'],
    ),
    _groupSimple(
      'student_loans',
      'Student loans',
      'Prestiti per studenti',
      'Prêts étudiants',
      'Préstamos para estudiantes',
      'وام‌های دانشجویی',
      'قروض الطلاب',
      'Bank and guaranteed products for study, masters, and mobility.',
      'Prodotti bancari e garantiti per studio, master e mobilità.',
      'Produits bancaires et garantis pour études, masters et mobilité.',
      'Productos bancarios y garantizados para estudios, máster y movilidad.',
      'محصولات بانکی و تضمینی برای تحصیل، مستر و جابه‌جایی.',
      'منتجات بنكية ومضمونة للدراسة والماجستير والتنقل.',
      [
        'intesa-per-merito',
        'consap-fondo-studio',
        'unicredit-ad-honorem',
        'unicredit-fondo-per-lo-studio',
        'banca-sella-prestito-onore',
        'sparkasse-prestito-studio-spark',
      ],
    ),
    _groupSimple(
      'consap_guarantees',
      'Consap guarantees',
      'Garanzie Consap',
      'Garanties Consap',
      'Garantías Consap',
      'ضمانت‌های Consap',
      'ضمانات Consap',
      'Public guarantee tools that support access to credit.',
      'Strumenti di garanzia pubblica che supportano l’accesso al credito.',
      'Outils de garantie publique qui facilitent l’accès au crédit.',
      'Herramientas de garantía pública que ayudan al acceso al crédito.',
      'ابزارهای ضمانت عمومی برای دسترسی به اعتبار.',
      'أدوات ضمان عامة تساعد على الوصول إلى الائتمان.',
      ['consap-fondo-studio', 'consap-fondo-prima-casa'],
    ),
    _groupSimple(
      'mortgage_support',
      'Mortgage support',
      'Supporto mutuo',
      'Soutien hypothécaire',
      'Apoyo hipotecario',
      'حمایت وام مسکن',
      'دعم الرهن العقاري',
      'First-home guarantees, suspension, and rent/deposit alternatives.',
      'Garanzie prima casa, sospensione mutuo e alternative per affitto/deposito.',
      'Garanties première maison, suspension du crédit et alternatives loyer/dépôt.',
      'Garantías para primera vivienda, suspensión y alternativas de alquiler/depósito.',
      'ضمانت خانه اول، تعلیق و جایگزین‌های اجاره/ودیعه.',
      'ضمانات السكن الأول وتعليق القسط وبدائل الإيجار أو التأمين.',
      [
        'consap-fondo-prima-casa',
        'fondo-sospensione-mutui-prima-casa',
        'rent-deposit-support',
      ],
    ),
    _groupSimple(
      'credit_warnings',
      'Credit warnings',
      'Avvertenze sul credito',
      'Avertissements sur le crédit',
      'Advertencias sobre el crédito',
      'هشدارهای اعتباری',
      'تحذيرات الائتمان',
      'Read the risks, documents, and approval limits before applying.',
      'Leggi rischi, documenti e limiti di approvazione prima della domanda.',
      'Lire les risques, documents et limites avant de demander.',
      'Leer riesgos, documentos y límites antes de solicitar.',
      'پیش از درخواست، ریسک‌ها، مدارک و محدودیت‌های تأیید را بخوان.',
      'اقرأ المخاطر والوثائق وحدود الموافقة قبل التقديم.',
      ['credit-warnings-and-documents'],
    ),
  ],
};

_GroupTemplate _group(
  String id,
  String enTitle,
  String itTitle,
  String frTitle,
  String esTitle,
  String faTitle,
  String arTitle,
  String enDescription,
  String itDescription,
  String frDescription,
  String esDescription,
  String faDescription,
  String arDescription,
  List<String> procedureSlugs,
) => _GroupTemplate(
  id: id,
  title: <String, String>{
    'en': enTitle,
    'it': itTitle,
    'fr': frTitle,
    'es': esTitle,
    'fa': faTitle,
    'ar': arTitle,
  },
  description: <String, String>{
    'en': enDescription,
    'it': itDescription,
    'fr': frDescription,
    'es': esDescription,
    'fa': faDescription,
    'ar': arDescription,
  },
  procedureSlugs: procedureSlugs,
);

_GroupTemplate _groupSimple(
  String id,
  String enTitle,
  String itTitle,
  String frTitle,
  String esTitle,
  String faTitle,
  String arTitle,
  String enDescription,
  String itDescription,
  String frDescription,
  String esDescription,
  String faDescription,
  String arDescription,
  List<String> procedureSlugs,
) => _group(
  id,
  enTitle,
  itTitle,
  frTitle,
  esTitle,
  faTitle,
  arTitle,
  enDescription,
  itDescription,
  frDescription,
  esDescription,
  faDescription,
  arDescription,
  procedureSlugs,
);

class _GroupTemplate {
  const _GroupTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.procedureSlugs,
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<String> procedureSlugs;
}

class _CategoryGroup {
  const _CategoryGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.procedures,
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final int sortOrder;
  final List<Map<String, dynamic>> procedures;
}
