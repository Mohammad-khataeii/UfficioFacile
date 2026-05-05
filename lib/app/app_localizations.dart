import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.languageCode);

  final String languageCode;

  static const supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fa'),
    Locale('ar'),
  ];

  static const rtlLanguages = {'fa', 'ar'};

  bool get isRtl => rtlLanguages.contains(languageCode);

  static Map<String, Map<String, String>> get localizedValues =>
      _localizedValues;

  String t(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Italy Life Admin Copilot',
      'hero_title': 'Handle Italian admin without starting from zero.',
      'hero_subtitle':
          'Choose a problem, answer guided questions, and generate a formal Italian message, PEC-style version, checklist, and follow-up.',
      'start_problem': 'Start from my problem',
      'browse_procedures': 'Browse procedures',
      'utilities_bills': 'Bills & utilities',
      'saved_requests': 'Saved requests',
      'what_help': 'What do you need help with?',
      'onboarding_title': 'Italy life admin, step by step.',
      'onboarding_subtitle':
          'Generate formal Italian messages, checklists, reminders, and follow-ups for bills, rent, ASL, Canone RAI, telecom, university, and more.',
      'privacy_title': 'Privacy and disclaimer',
      'skip': 'Skip',
      'next': 'Next',
      'done': 'Done',
      'profile': 'Profile',
      'help': 'Help',
      'admin': 'Admin',
      'generate_pack': 'Generate pack',
      'save_request': 'Save request',
      'copied': 'Copied',
      'request_saved': 'Request saved',
      'short_message': 'Short message',
      'email': 'Email',
      'pec': 'PEC / Formal',
      'follow_up': 'Follow-up',
      'strong_follow_up': 'Stronger follow-up',
      'attachments': 'Attachments',
      'next_steps': 'Next steps',
      'warnings': 'Warnings',
      'disclaimer_short':
          'Drafting and organization support only. Always verify official rules before sending.',
      'upcoming_reminders': 'Upcoming reminders',
      'requests_follow_up': 'Need follow-up',
      'drafts': 'Drafts',
      'recent_requests': 'Recent requests',
      'problem_examples': 'Examples',
      'recommendations': 'Recommended workflows',
      'no_results':
          'No close result yet. You can still use the generic formal request.',
      'compare_offers': 'Compare offers',
      'understand_bill': 'Understand my bill',
      'canone_rai': 'Canone RAI',
      'telecom': 'Internet & phone',
      'admin_panel': 'Admin panel',
      'demo_data': 'Demo data',
      'scan_situation': 'Scan my situation',
      'city_packs': 'City packs',
      'student_mode': 'Student mode',
      'tenant_mode': 'Tenant mode',
      'life_checklist': 'My Italy Life Checklist',
      'proof_folder': 'Proof folder',
      'official_links': 'Official links',
      'cost_dashboard': 'Cost dashboard',
      'document_vault': 'Document vault',
      'contacts_directory': 'Contacts directory',
      'calendar': 'Calendar',
    },
    'it': {
      'app_title': 'Italy Life Admin Copilot',
      'hero_title': 'Gestisci la burocrazia italiana senza partire da zero.',
      'hero_subtitle':
          'Scegli un problema, rispondi a domande guidate e genera email formali, versione PEC, checklist e follow-up.',
      'start_problem': 'Parti dal mio problema',
      'browse_procedures': 'Esplora procedure',
      'utilities_bills': 'Bollette e utenze',
      'saved_requests': 'Richieste salvate',
      'what_help': 'Di cosa hai bisogno?',
      'onboarding_title': 'Italy life admin, passo dopo passo.',
      'onboarding_subtitle':
          'Genera messaggi formali in italiano, checklist, promemoria e follow-up per bollette, affitto, ASL, Canone RAI, telecom, università e altro.',
      'privacy_title': 'Privacy e disclaimer',
      'skip': 'Salta',
      'next': 'Avanti',
      'done': 'Fine',
      'profile': 'Profilo',
      'help': 'Aiuto',
      'admin': 'Admin',
      'generate_pack': 'Genera pack',
      'save_request': 'Salva richiesta',
      'copied': 'Copiato',
      'request_saved': 'Richiesta salvata',
      'short_message': 'Messaggio breve',
      'email': 'Email',
      'pec': 'PEC / Formale',
      'follow_up': 'Follow-up',
      'strong_follow_up': 'Follow-up forte',
      'attachments': 'Allegati',
      'next_steps': 'Prossimi passi',
      'warnings': 'Avvisi',
      'disclaimer_short':
          'Solo supporto di organizzazione e scrittura. Verifica sempre regole e canali ufficiali prima dell’invio.',
      'upcoming_reminders': 'Promemoria in arrivo',
      'requests_follow_up': 'Da sollecitare',
      'drafts': 'Bozze',
      'recent_requests': 'Richieste recenti',
      'problem_examples': 'Esempi',
      'recommendations': 'Workflow consigliati',
      'no_results':
          'Nessun risultato forte. Puoi comunque usare la richiesta formale generica.',
      'compare_offers': 'Confronta offerte',
      'understand_bill': 'Capisci la bolletta',
      'canone_rai': 'Canone RAI',
      'telecom': 'Internet e telefono',
      'admin_panel': 'Pannello admin',
      'demo_data': 'Dati demo',
      'scan_situation': 'Analizza la mia situazione',
      'city_packs': 'City pack',
      'student_mode': 'Modalità studente',
      'tenant_mode': 'Modalità inquilino',
      'life_checklist': 'Checklist vita in Italia',
      'proof_folder': 'Cartella prove',
      'official_links': 'Link ufficiali',
      'cost_dashboard': 'Dashboard costi',
      'document_vault': 'Archivio documenti',
      'contacts_directory': 'Rubrica contatti',
      'calendar': 'Calendario',
    },
    'es': {
      'app_title': 'Italy Life Admin Copilot',
      'hero_title':
          'Gestiona la administración italiana sin empezar desde cero.',
      'hero_subtitle':
          'Elige un problema, responde preguntas guiadas y genera mensajes formales en italiano, versión PEC, checklist y seguimiento.',
      'start_problem': 'Empezar por mi problema',
      'browse_procedures': 'Ver procedimientos',
      'utilities_bills': 'Facturas y suministros',
      'saved_requests': 'Solicitudes guardadas',
      'what_help': '¿Con qué necesitas ayuda?',
      'skip': 'Omitir',
      'next': 'Siguiente',
      'done': 'Listo',
      'scan_situation': 'Analizar mi situación',
      'city_packs': 'Packs de ciudad',
      'student_mode': 'Modo estudiante',
      'tenant_mode': 'Modo inquilino',
      'life_checklist': 'Checklist de vida en Italia',
      'proof_folder': 'Carpeta de pruebas',
      'official_links': 'Enlaces oficiales',
      'cost_dashboard': 'Panel de costes',
      'document_vault': 'Bóveda de documentos',
      'contacts_directory': 'Directorio de contactos',
      'calendar': 'Calendario',
    },
    'fa': {
      'app_title': 'Italy Life Admin Copilot',
      'hero_title': 'کارهای اداری ایتالیا را بدون شروع از صفر مدیریت کنید.',
      'hero_subtitle':
          'مشکل را انتخاب کنید، به سوالات مرحله‌ای پاسخ دهید و متن رسمی ایتالیایی، نسخه PEC، چک‌لیست و پیگیری بسازید.',
      'start_problem': 'از مشکل من شروع کن',
      'browse_procedures': 'مرور فرایندها',
      'utilities_bills': 'قبض‌ها و خدمات',
      'saved_requests': 'درخواست‌های ذخیره‌شده',
      'what_help': 'در چه چیزی کمک می‌خواهید؟',
      'skip': 'رد کردن',
      'next': 'بعدی',
      'done': 'تمام',
      'scan_situation': 'وضعیت من را بررسی کن',
      'city_packs': 'بسته‌های شهری',
      'student_mode': 'حالت دانشجویی',
      'tenant_mode': 'حالت مستأجر',
      'life_checklist': 'چک‌لیست زندگی در ایتالیا',
      'proof_folder': 'پوشه مدارک',
      'official_links': 'لینک‌های رسمی',
      'cost_dashboard': 'داشبورد هزینه‌ها',
      'document_vault': 'آرشیو اسناد',
      'contacts_directory': 'دفترچه مخاطبان',
      'calendar': 'تقویم',
    },
    'ar': {
      'app_title': 'Italy Life Admin Copilot',
      'hero_title': 'أنجز الشؤون الإدارية في إيطاليا خطوة بخطوة.',
      'hero_subtitle':
          'اختر المشكلة، أجب عن أسئلة موجهة، وأنشئ رسالة إيطالية رسمية ونسخة PEC وقائمة تحقق ومتابعة.',
      'start_problem': 'ابدأ من مشكلتي',
      'browse_procedures': 'تصفح الإجراءات',
      'utilities_bills': 'الفواتير والمرافق',
      'saved_requests': 'الطلبات المحفوظة',
      'what_help': 'بماذا تحتاج المساعدة؟',
      'skip': 'تخطي',
      'next': 'التالي',
      'done': 'تم',
      'scan_situation': 'افحص حالتي',
      'city_packs': 'حزم المدن',
      'student_mode': 'وضع الطالب',
      'tenant_mode': 'وضع المستأجر',
      'life_checklist': 'قائمة حياتي في إيطاليا',
      'proof_folder': 'مجلد الإثبات',
      'official_links': 'روابط رسمية',
      'cost_dashboard': 'لوحة التكاليف',
      'document_vault': 'خزنة المستندات',
      'contacts_directory': 'دليل الجهات',
      'calendar': 'التقويم',
    },
  };
}

class AppLocalizationsScope extends InheritedWidget {
  const AppLocalizationsScope({
    super.key,
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  static AppLocalizations of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLocalizationsScope>();
    assert(scope != null, 'AppLocalizationsScope not found');
    return scope!.localizations;
  }

  @override
  bool updateShouldNotify(AppLocalizationsScope oldWidget) {
    return oldWidget.localizations.languageCode != localizations.languageCode;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizationsScope.of(this);
}
