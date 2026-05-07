import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.languageCode);

  final String languageCode;

  static const supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('fa'),
    Locale('fr'),
  ];

  static const rtlLanguages = {'fa'};

  bool get isRtl => rtlLanguages.contains(languageCode);

  static Map<String, Map<String, String>> get localizedValues =>
      _localizedValues;

  String t(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        _localizedValues['it']?[key] ??
        key;
  }

  String localizedMap(Map<String, dynamic> values, {String fallback = ''}) {
    final normalized = values.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
    return normalized[languageCode] ??
        normalized['en'] ??
        normalized['it'] ??
        normalized['fa'] ??
        normalized['fr'] ??
        fallback;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'UfficioFacile',
      'hero_title': 'Handle Italian admin without starting from zero.',
      'hero_subtitle':
          'Choose a problem, answer guided questions, and generate a formal Italian message, checklist, and follow-up.',
      'start_problem': 'Start from my problem',
      'browse_procedures': 'Browse procedures',
      'utilities_bills': 'Bills and utilities',
      'saved_requests': 'Saved requests',
      'what_help': 'What do you need help with?',
      'onboarding_title': 'Italian admin, step by step.',
      'onboarding_subtitle':
          'Organize procedures, reminders, documents, and formal messages for bills, rent, health, university, and public offices.',
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
          'Practical drafting and organization support only. Always verify the final instructions on the official website or with the competent office.',
      'upcoming_reminders': 'Upcoming reminders',
      'requests_follow_up': 'Needs follow-up',
      'drafts': 'Drafts',
      'recent_requests': 'Recent requests',
      'problem_examples': 'Examples',
      'recommendations': 'Recommended workflows',
      'no_results':
          'No close match yet. You can still use the general formal request.',
      'compare_offers': 'Compare offers',
      'understand_bill': 'Understand my bill',
      'canone_rai': 'Canone RAI',
      'telecom': 'Internet and phone',
      'admin_panel': 'Admin panel',
      'demo_data': 'Demo data',
      'scan_situation': 'Scan my situation',
      'city_packs': 'City packs',
      'student_mode': 'Student mode',
      'tenant_mode': 'Tenant mode',
      'life_checklist': 'My Italy checklist',
      'proof_folder': 'Proof folder',
      'official_links': 'Official links',
      'cost_dashboard': 'Cost dashboard',
      'document_vault': 'Document vault',
      'contacts_directory': 'Contacts directory',
      'calendar': 'Calendar',
      'plan': 'Plan',
      'free_plan': 'Free',
      'pro_plan': 'Premium',
      'consultant_plan': 'Consultant',
      'beta_access_active': 'Beta access active',
      'upgrade_to_pro': 'Upgrade to Premium',
      'premium_feature': 'Premium feature',
      'auth_account': 'Account',
      'auth_login': 'Log in',
      'auth_create_account': 'Create account',
      'auth_email': 'Email',
      'auth_password': 'Password',
      'auth_continue_public': 'Continue browsing public guides',
      'auth_login_subtitle':
          'Use your email and password to open your private workspace.',
      'auth_signup_subtitle':
          'Create an account to save and sync your requests, reminders, and document details.',
      'auth_login_or_signup': 'Log in or create account',
      'auth_required_title': 'Account required',
      'auth_required_message':
          'Create an account to save and sync your documents, requests, and reminders.',
      'auth_required_feature': 'You need an account to open this area.',
      'auth_wait': 'Please wait...',
      'auth_reset_password': 'Send password reset email',
      'auth_reset_sent': 'Password reset email sent. Check your inbox.',
      'auth_signup_success':
          'Account created. If email confirmation is enabled, confirm your email before signing in.',
      'account_title': 'My account',
      'account_email': 'Email',
      'account_not_signed_in': 'Not signed in',
      'account_plan': 'Plan',
      'account_log_out': 'Log out',
      'account_privacy': 'Privacy center',
      'access_denied_title': 'Access denied',
      'access_denied_message':
          'Your account does not have access to this area.',
      'admin_overview': 'Overview',
      'admin_users': 'Users',
      'admin_premium': 'Premium',
      'admin_catalog': 'Catalog',
      'admin_problem_requests': 'Problem requests',
      'admin_consultancy': 'Consultancy',
      'admin_content_manager': 'Content Manager',
      'admin_security_checklist': 'Security checklist',
      'admin_supabase_configured': 'Supabase configured',
      'admin_authenticated': 'Authenticated',
      'admin_rls_enabled': 'RLS-backed admin writes enabled by migration',
      'admin_anon_only': 'Client app uses the anon key only',
      'guided_selector': 'Guided selector',
      'open': 'Open',
      'cta_problem_title': 'Can’t find your problem?',
      'cta_problem_body':
          'Tell us what you need. We will review it and add it as fast as possible.',
      'cta_problem_button': 'Request a new problem',
      'cta_problem_thanks':
          'Thanks. We received your request and will review it as soon as possible.',
      'cta_consultancy_title': 'Need private help?',
      'cta_consultancy_body':
          'Premium members can request private guidance by email. Free users can request it with an extra payment when available.',
      'cta_consultancy_disclaimer':
          'UfficioFacile gives practical guidance, not legal, tax, or medical advice. Always verify final instructions on the official website or with the competent office.',
      'cta_consultancy_request': 'Request private guidance',
      'cta_consultancy_unlock': 'Unlock private guidance',
      'cta_consultancy_upgrade': 'Upgrade to Premium',
      'cta_consultancy_email': 'Send your case by email',
      'cta_payment_unavailable':
          'Premium payments are not available yet. Contact support.',
      'import_bundled_content': 'Import bundled content into CMS',
    },
    'it': {
      'app_title': 'UfficioFacile',
      'hero_title': 'Gestisci la burocrazia italiana senza partire da zero.',
      'hero_subtitle':
          'Scegli un problema, rispondi a domande guidate e genera un messaggio formale in italiano, una checklist e il follow-up.',
      'start_problem': 'Parti dal mio problema',
      'browse_procedures': 'Esplora procedure',
      'utilities_bills': 'Bollette e utenze',
      'saved_requests': 'Richieste salvate',
      'what_help': 'Di cosa hai bisogno?',
      'onboarding_title': 'Burocrazia italiana, passo dopo passo.',
      'onboarding_subtitle':
          'Organizza procedure, promemoria, documenti e messaggi formali per bollette, affitto, sanità, università e uffici pubblici.',
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
      'follow_up': 'Sollecito',
      'strong_follow_up': 'Sollecito forte',
      'attachments': 'Allegati',
      'next_steps': 'Prossimi passi',
      'warnings': 'Avvisi',
      'disclaimer_short':
          'Supporto pratico per organizzazione e scrittura. Verifica sempre le istruzioni finali sul sito ufficiale o con l’ufficio competente.',
      'upcoming_reminders': 'Promemoria in arrivo',
      'requests_follow_up': 'Da sollecitare',
      'drafts': 'Bozze',
      'recent_requests': 'Richieste recenti',
      'problem_examples': 'Esempi',
      'recommendations': 'Percorsi consigliati',
      'no_results':
          'Non c’è ancora un risultato vicino. Puoi usare comunque la richiesta formale generica.',
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
      'plan': 'Piano',
      'free_plan': 'Gratis',
      'pro_plan': 'Premium',
      'consultant_plan': 'Consulente',
      'beta_access_active': 'Accesso beta attivo',
      'upgrade_to_pro': 'Passa a Premium',
      'premium_feature': 'Funzione Premium',
      'auth_account': 'Account',
      'auth_login': 'Accedi',
      'auth_create_account': 'Crea account',
      'auth_email': 'Email',
      'auth_password': 'Password',
      'auth_continue_public': 'Continua a consultare le guide pubbliche',
      'auth_login_subtitle':
          'Usa email e password per aprire il tuo spazio privato.',
      'auth_signup_subtitle':
          'Crea un account per salvare e sincronizzare richieste, promemoria e dettagli dei documenti.',
      'auth_login_or_signup': 'Accedi o crea un account',
      'auth_required_title': 'Account richiesto',
      'auth_required_message':
          'Crea un account per salvare e sincronizzare documenti, richieste e promemoria.',
      'auth_required_feature': 'Per aprire questa sezione ti serve un account.',
      'auth_wait': 'Attendi...',
      'auth_reset_password': 'Invia email per reimpostare la password',
      'auth_reset_sent':
          'Email per reimpostare la password inviata. Controlla la tua casella.',
      'auth_signup_success':
          'Account creato. Se la conferma email è attiva, conferma l’indirizzo prima di accedere.',
      'account_title': 'Il mio account',
      'account_email': 'Email',
      'account_not_signed_in': 'Non hai effettuato l’accesso',
      'account_plan': 'Piano',
      'account_log_out': 'Esci',
      'account_privacy': 'Centro privacy',
      'access_denied_title': 'Accesso negato',
      'access_denied_message':
          'Il tuo account non ha accesso a questa sezione.',
      'admin_overview': 'Panoramica',
      'admin_users': 'Utenti',
      'admin_premium': 'Premium',
      'admin_catalog': 'Catalogo',
      'admin_problem_requests': 'Richieste problema',
      'admin_consultancy': 'Consulenze',
      'admin_content_manager': 'Gestione contenuti',
      'admin_security_checklist': 'Checklist sicurezza',
      'admin_supabase_configured': 'Supabase configurato',
      'admin_authenticated': 'Autenticato',
      'admin_rls_enabled':
          'Scritture admin protette da RLS abilitate tramite migrazione',
      'admin_anon_only': 'L’app client usa solo la chiave anon',
      'guided_selector': 'Selettore guidato',
      'open': 'Apri',
      'cta_problem_title': 'Non trovi il tuo problema?',
      'cta_problem_body':
          'Raccontaci di cosa hai bisogno. Lo controlleremo e lo aggiungeremo il prima possibile.',
      'cta_problem_button': 'Richiedi un nuovo problema',
      'cta_problem_thanks':
          'Grazie. Abbiamo ricevuto la tua richiesta e la controlleremo al più presto.',
      'cta_consultancy_title': 'Hai bisogno di aiuto privato?',
      'cta_consultancy_body':
          'I membri Premium possono richiedere assistenza privata via email. Gli utenti free possono richiederla con un pagamento extra quando disponibile.',
      'cta_consultancy_disclaimer':
          'UfficioFacile offre guida pratica, non consulenza legale, fiscale o medica. Verifica sempre le istruzioni finali sul sito ufficiale o con l’ufficio competente.',
      'cta_consultancy_request': 'Richiedi assistenza privata',
      'cta_consultancy_unlock': 'Sblocca assistenza privata',
      'cta_consultancy_upgrade': 'Passa a Premium',
      'cta_consultancy_email': 'Invia il caso via email',
      'cta_payment_unavailable':
          'I pagamenti Premium non sono ancora disponibili. Contatta il supporto.',
      'import_bundled_content': 'Importa i contenuti inclusi nel CMS',
    },
    'fa': {
      'app_title': 'UfficioFacile',
      'hero_title': 'کارهای اداری ایتالیا را بدون شروع از صفر مدیریت کنید.',
      'hero_subtitle':
          'مشکل را انتخاب کنید، به پرسش‌های مرحله‌ای پاسخ دهید و متن رسمی، چک‌لیست و پیگیری بسازید.',
      'start_problem': 'از مشکل من شروع کن',
      'browse_procedures': 'مرور فرایندها',
      'utilities_bills': 'قبض‌ها و خدمات',
      'saved_requests': 'درخواست‌های ذخیره‌شده',
      'what_help': 'در چه چیزی کمک می‌خواهید؟',
      'onboarding_title': 'کارهای اداری ایتالیا، مرحله به مرحله.',
      'onboarding_subtitle':
          'برای قبض، اجاره، درمان، دانشگاه و اداره‌های عمومی، فرایندها، یادآورها، مدارک و پیام‌های رسمی را مدیریت کنید.',
      'privacy_title': 'حریم خصوصی و توضیحات',
      'skip': 'رد کردن',
      'next': 'بعدی',
      'done': 'تمام',
      'profile': 'پروفایل',
      'help': 'راهنما',
      'admin': 'مدیر',
      'generate_pack': 'ساخت بسته',
      'save_request': 'ذخیره درخواست',
      'copied': 'کپی شد',
      'request_saved': 'درخواست ذخیره شد',
      'short_message': 'پیام کوتاه',
      'email': 'ایمیل',
      'pec': 'PEC / رسمی',
      'follow_up': 'پیگیری',
      'strong_follow_up': 'پیگیری جدی‌تر',
      'attachments': 'پیوست‌ها',
      'next_steps': 'قدم‌های بعدی',
      'warnings': 'هشدارها',
      'disclaimer_short':
          'فقط پشتیبانی عملی برای نوشتن و سازمان‌دهی. همیشه دستور نهایی را در سایت رسمی یا با اداره مربوط بررسی کنید.',
      'upcoming_reminders': 'یادآورهای پیش رو',
      'requests_follow_up': 'نیازمند پیگیری',
      'drafts': 'پیش‌نویس‌ها',
      'recent_requests': 'درخواست‌های اخیر',
      'problem_examples': 'نمونه‌ها',
      'recommendations': 'مسیرهای پیشنهادی',
      'no_results':
          'هنوز نتیجه نزدیک پیدا نشد. می‌توانید از درخواست رسمی عمومی استفاده کنید.',
      'compare_offers': 'مقایسه پیشنهادها',
      'understand_bill': 'قبض من را توضیح بده',
      'canone_rai': 'Canone RAI',
      'telecom': 'اینترنت و تلفن',
      'admin_panel': 'پنل مدیریت',
      'demo_data': 'داده آزمایشی',
      'scan_situation': 'وضعیت من را بررسی کن',
      'city_packs': 'بسته‌های شهری',
      'student_mode': 'حالت دانشجویی',
      'tenant_mode': 'حالت مستأجر',
      'life_checklist': 'چک‌لیست زندگی در ایتالیا',
      'proof_folder': 'پوشه مدارک',
      'official_links': 'لینک‌های رسمی',
      'cost_dashboard': 'داشبورد هزینه‌ها',
      'document_vault': 'آرشیو مدارک',
      'contacts_directory': 'دفترچه مخاطبان',
      'calendar': 'تقویم',
      'plan': 'پلن',
      'free_plan': 'رایگان',
      'pro_plan': 'پریمیوم',
      'consultant_plan': 'مشاور',
      'beta_access_active': 'دسترسی بتا فعال است',
      'upgrade_to_pro': 'ارتقا به پریمیوم',
      'premium_feature': 'ویژگی پریمیوم',
      'auth_account': 'حساب کاربری',
      'auth_login': 'ورود',
      'auth_create_account': 'ساخت حساب',
      'auth_email': 'ایمیل',
      'auth_password': 'رمز عبور',
      'auth_continue_public': 'ادامه مرور راهنماهای عمومی',
      'auth_login_subtitle': 'با ایمیل و رمز عبور وارد فضای خصوصی خود شوید.',
      'auth_signup_subtitle':
          'برای ذخیره و همگام‌سازی درخواست‌ها، یادآورها و جزئیات مدارک حساب بسازید.',
      'auth_login_or_signup': 'ورود یا ساخت حساب',
      'auth_required_title': 'حساب لازم است',
      'auth_required_message':
          'برای ذخیره و همگام‌سازی مدارک، درخواست‌ها و یادآورها حساب بسازید.',
      'auth_required_feature': 'برای باز کردن این بخش به حساب نیاز دارید.',
      'auth_wait': 'لطفاً صبر کنید...',
      'auth_reset_password': 'ایمیل بازنشانی رمز عبور را ارسال کن',
      'auth_reset_sent':
          'ایمیل بازنشانی رمز عبور ارسال شد. صندوق ورودی را بررسی کنید.',
      'auth_signup_success':
          'حساب ساخته شد. اگر تأیید ایمیل فعال باشد، قبل از ورود ایمیل خود را تأیید کنید.',
      'account_title': 'حساب من',
      'account_email': 'ایمیل',
      'account_not_signed_in': 'وارد نشده‌اید',
      'account_plan': 'پلن',
      'account_log_out': 'خروج',
      'account_privacy': 'مرکز حریم خصوصی',
      'access_denied_title': 'دسترسی مجاز نیست',
      'access_denied_message': 'حساب شما به این بخش دسترسی ندارد.',
      'admin_overview': 'نمای کلی',
      'admin_users': 'کاربران',
      'admin_premium': 'پریمیوم',
      'admin_catalog': 'کاتالوگ',
      'admin_problem_requests': 'درخواست‌های مشکل',
      'admin_consultancy': 'مشاوره',
      'admin_content_manager': 'مدیریت محتوا',
      'admin_security_checklist': 'چک‌لیست امنیت',
      'admin_supabase_configured': 'Supabase پیکربندی شده است',
      'admin_authenticated': 'احراز هویت شده',
      'admin_rls_enabled': 'نوشتن‌های مدیریتی با RLS محافظت می‌شوند',
      'admin_anon_only': 'برنامه فقط از کلید anon در سمت کاربر استفاده می‌کند',
      'guided_selector': 'انتخاب‌گر مرحله‌ای',
      'open': 'باز کردن',
      'cta_problem_title': 'مشکل شما اینجا نیست؟',
      'cta_problem_body':
          'آنچه نیاز دارید را برای ما بفرستید. بررسی می‌کنیم و هرچه سریع‌تر اضافه می‌کنیم.',
      'cta_problem_button': 'ثبت مشکل جدید',
      'cta_problem_thanks':
          'ممنون. درخواست شما دریافت شد و خیلی زود بررسی می‌شود.',
      'cta_consultancy_title': 'به کمک خصوصی نیاز دارید؟',
      'cta_consultancy_body':
          'اعضای پریمیوم می‌توانند راهنمایی خصوصی ایمیلی بگیرند. کاربران رایگان در صورت فعال بودن پرداخت اضافه می‌توانند درخواست بدهند.',
      'cta_consultancy_disclaimer':
          'UfficioFacile راهنمای عملی ارائه می‌دهد، نه مشاوره حقوقی، مالیاتی یا پزشکی. همیشه دستور نهایی را در سایت رسمی یا با اداره مربوط بررسی کنید.',
      'cta_consultancy_request': 'درخواست راهنمایی خصوصی',
      'cta_consultancy_unlock': 'فعال‌سازی راهنمایی خصوصی',
      'cta_consultancy_upgrade': 'ارتقا به پریمیوم',
      'cta_consultancy_email': 'ارسال پرونده با ایمیل',
      'cta_payment_unavailable':
          'پرداخت‌های پریمیوم هنوز فعال نیستند. با پشتیبانی تماس بگیرید.',
      'import_bundled_content': 'وارد کردن محتوای پیش‌فرض به CMS',
    },
    'fr': {
      'app_title': 'UfficioFacile',
      'hero_title': 'Gérez les démarches italiennes sans repartir de zéro.',
      'hero_subtitle':
          'Choisissez un problème, répondez aux questions guidées et générez un message formel, une checklist et un suivi.',
      'start_problem': 'Partir de mon problème',
      'browse_procedures': 'Parcourir les démarches',
      'utilities_bills': 'Factures et contrats',
      'saved_requests': 'Demandes enregistrées',
      'what_help': 'De quoi avez-vous besoin ?',
      'onboarding_title': 'Les démarches italiennes, étape par étape.',
      'onboarding_subtitle':
          'Organisez vos démarches, rappels, documents et messages formels pour les factures, le logement, la santé, l’université et les bureaux publics.',
      'privacy_title': 'Confidentialité et avertissement',
      'skip': 'Passer',
      'next': 'Suivant',
      'done': 'Terminé',
      'profile': 'Profil',
      'help': 'Aide',
      'admin': 'Admin',
      'generate_pack': 'Générer le pack',
      'save_request': 'Enregistrer la demande',
      'copied': 'Copié',
      'request_saved': 'Demande enregistrée',
      'short_message': 'Message court',
      'email': 'Email',
      'pec': 'PEC / Formel',
      'follow_up': 'Relance',
      'strong_follow_up': 'Relance formelle',
      'attachments': 'Pièces jointes',
      'next_steps': 'Prochaines étapes',
      'warnings': 'Points d’attention',
      'disclaimer_short':
          'Aide pratique à la rédaction et à l’organisation uniquement. Vérifiez toujours les instructions finales sur le site officiel ou auprès du bureau compétent.',
      'upcoming_reminders': 'Rappels à venir',
      'requests_follow_up': 'À relancer',
      'drafts': 'Brouillons',
      'recent_requests': 'Demandes récentes',
      'problem_examples': 'Exemples',
      'recommendations': 'Parcours recommandés',
      'no_results':
          'Aucun résultat proche pour le moment. Vous pouvez quand même utiliser la demande formelle générale.',
      'compare_offers': 'Comparer les offres',
      'understand_bill': 'Comprendre ma facture',
      'canone_rai': 'Canone RAI',
      'telecom': 'Internet et téléphone',
      'admin_panel': 'Panneau admin',
      'demo_data': 'Données de démonstration',
      'scan_situation': 'Analyser ma situation',
      'city_packs': 'Packs ville',
      'student_mode': 'Mode étudiant',
      'tenant_mode': 'Mode locataire',
      'life_checklist': 'Ma checklist Italie',
      'proof_folder': 'Dossier de preuves',
      'official_links': 'Liens officiels',
      'cost_dashboard': 'Tableau des coûts',
      'document_vault': 'Coffre de documents',
      'contacts_directory': 'Répertoire de contacts',
      'calendar': 'Calendrier',
      'plan': 'Offre',
      'free_plan': 'Gratuit',
      'pro_plan': 'Premium',
      'consultant_plan': 'Consultant',
      'beta_access_active': 'Accès bêta actif',
      'upgrade_to_pro': 'Passer à Premium',
      'premium_feature': 'Fonction Premium',
      'auth_account': 'Compte',
      'auth_login': 'Se connecter',
      'auth_create_account': 'Créer un compte',
      'auth_email': 'Email',
      'auth_password': 'Mot de passe',
      'auth_continue_public': 'Continuer à parcourir les guides publics',
      'auth_login_subtitle':
          'Utilisez votre email et votre mot de passe pour ouvrir votre espace privé.',
      'auth_signup_subtitle':
          'Créez un compte pour enregistrer et synchroniser vos demandes, rappels et détails de documents.',
      'auth_login_or_signup': 'Se connecter ou créer un compte',
      'auth_required_title': 'Compte requis',
      'auth_required_message':
          'Créez un compte pour enregistrer et synchroniser vos documents, demandes et rappels.',
      'auth_required_feature':
          'Vous avez besoin d’un compte pour ouvrir cette section.',
      'auth_wait': 'Veuillez patienter...',
      'auth_reset_password': 'Envoyer un email de réinitialisation',
      'auth_reset_sent':
          'Email de réinitialisation envoyé. Vérifiez votre boîte de réception.',
      'auth_signup_success':
          'Compte créé. Si la confirmation par email est active, confirmez votre adresse avant de vous connecter.',
      'account_title': 'Mon compte',
      'account_email': 'Email',
      'account_not_signed_in': 'Non connecté',
      'account_plan': 'Offre',
      'account_log_out': 'Se déconnecter',
      'account_privacy': 'Centre de confidentialité',
      'access_denied_title': 'Accès refusé',
      'access_denied_message': 'Votre compte n’a pas accès à cette section.',
      'admin_overview': 'Vue d’ensemble',
      'admin_users': 'Utilisateurs',
      'admin_premium': 'Premium',
      'admin_catalog': 'Catalogue',
      'admin_problem_requests': 'Demandes de problème',
      'admin_consultancy': 'Consultations',
      'admin_content_manager': 'Gestionnaire de contenu',
      'admin_security_checklist': 'Checklist sécurité',
      'admin_supabase_configured': 'Supabase configuré',
      'admin_authenticated': 'Authentifié',
      'admin_rls_enabled': 'Écritures admin protégées par RLS via migration',
      'admin_anon_only': 'L’application cliente utilise uniquement la clé anon',
      'guided_selector': 'Sélecteur guidé',
      'open': 'Ouvrir',
      'cta_problem_title': 'Vous ne trouvez pas votre problème ?',
      'cta_problem_body':
          'Dites-nous ce dont vous avez besoin. Nous le vérifierons et l’ajouterons aussi vite que possible.',
      'cta_problem_button': 'Demander un nouveau problème',
      'cta_problem_thanks':
          'Merci. Nous avons reçu votre demande et nous allons l’examiner rapidement.',
      'cta_consultancy_title': 'Besoin d’une aide privée ?',
      'cta_consultancy_body':
          'Les membres Premium peuvent demander une aide privée par email. Les utilisateurs gratuits peuvent la demander avec un paiement supplémentaire quand il est disponible.',
      'cta_consultancy_disclaimer':
          'UfficioFacile fournit une aide pratique, pas un conseil juridique, fiscal ou médical. Vérifiez toujours les instructions finales sur le site officiel ou auprès du bureau compétent.',
      'cta_consultancy_request': 'Demander une aide privée',
      'cta_consultancy_unlock': 'Débloquer l’aide privée',
      'cta_consultancy_upgrade': 'Passer à Premium',
      'cta_consultancy_email': 'Envoyer mon dossier par email',
      'cta_payment_unavailable':
          'Les paiements Premium ne sont pas encore disponibles. Contactez le support.',
      'import_bundled_content': 'Importer le contenu intégré dans le CMS',
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
