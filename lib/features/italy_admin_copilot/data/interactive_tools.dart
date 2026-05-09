class BonusFinderInput {
  const BonusFinderInput({
    this.city = 'Torino',
    this.region = 'Piemonte',
    this.iseeAmount,
    this.householdSize = 1,
    this.dependentChildrenCount = 0,
    this.hasChildUnder3 = false,
    this.paysNurseryFees = false,
    this.newChildThisYear = false,
    this.isStudent = false,
    this.isTenant = false,
    this.isWorker = false,
    this.isUnemployed = false,
    this.hasHighUtilityBills = false,
    this.utilityContractInOwnName = false,
    this.hasLifeSavingMedicalEquipment = false,
    this.needsPsychologistSupport = false,
    this.isPiemonteSchoolStudent = false,
    this.isUniversityStudent = false,
    this.isBehindOnRent = false,
    this.interestedInRenovationTaxDeductions = false,
  });

  final String city;
  final String region;
  final double? iseeAmount;
  final int householdSize;
  final int dependentChildrenCount;
  final bool hasChildUnder3;
  final bool paysNurseryFees;
  final bool newChildThisYear;
  final bool isStudent;
  final bool isTenant;
  final bool isWorker;
  final bool isUnemployed;
  final bool hasHighUtilityBills;
  final bool utilityContractInOwnName;
  final bool hasLifeSavingMedicalEquipment;
  final bool needsPsychologistSupport;
  final bool isPiemonteSchoolStudent;
  final bool isUniversityStudent;
  final bool isBehindOnRent;
  final bool interestedInRenovationTaxDeductions;
}

enum ToolMatchLevel { likely, maybe, monitor, unlikely }

class ToolResult {
  const ToolResult({
    required this.id,
    required this.title,
    required this.level,
    required this.score,
    required this.reason,
    this.requirements = const [],
    this.documents = const [],
    this.applicationChannel = const {},
    this.officialSources = const [],
    this.warning = const {},
    this.relatedProcedureSlug,
  });

  final String id;
  final Map<String, String> title;
  final ToolMatchLevel level;
  final double score;
  final Map<String, String> reason;
  final List<Map<String, String>> requirements;
  final List<Map<String, String>> documents;
  final Map<String, String> applicationChannel;
  final List<Map<String, String>> officialSources;
  final Map<String, String> warning;
  final String? relatedProcedureSlug;
}

class LoanComparisonInput {
  const LoanComparisonInput({
    this.isStudent = false,
    this.age = 18,
    this.studyType = 'university',
    this.amountNeeded = 5000,
    this.needsLivingCosts = false,
    this.avoidParentGuarantee = false,
    this.wantRepaymentAfterStudies = false,
    this.hasUniversityPartnerAgreement = false,
    this.isFirstHomeMortgage = false,
    this.hasExistingMortgageDifficulty = false,
    this.needsRentDepositSupport = false,
  });

  final bool isStudent;
  final int age;
  final String studyType;
  final int amountNeeded;
  final bool needsLivingCosts;
  final bool avoidParentGuarantee;
  final bool wantRepaymentAfterStudies;
  final bool hasUniversityPartnerAgreement;
  final bool isFirstHomeMortgage;
  final bool hasExistingMortgageDifficulty;
  final bool needsRentDepositSupport;
}

class BonusFinderService {
  const BonusFinderService();

  List<ToolResult> evaluate(BonusFinderInput input) {
    final results = <ToolResult>[
      _bonusSociale(input),
      _disagioFisico(input),
      _nursery(input),
      _newborn(input),
      _assegnoUnico(input),
      _psychologist(input),
      _piemonteVoucher(input),
      _rentSupport(input),
      _taxDeductions(input),
    ];
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

class LoanComparisonService {
  const LoanComparisonService();

  List<ToolResult> evaluate(LoanComparisonInput input) {
    final results = <ToolResult>[
      _perMerito(input),
      _consapStudio(input),
      _unicreditAdHonorem(input),
      _unicreditStudio(input),
      _bancaSella(input),
      _sparkasse(input),
      _firstHome(input),
      _mortgageSuspension(input),
      _rentDepositSupport(input),
    ];
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

ToolResult _bonusSociale(BonusFinderInput input) {
  final isee = input.iseeAmount ?? 999999;
  final isLargeFamily = input.dependentChildrenCount >= 4;
  final threshold = isLargeFamily ? 20000 : 9796;
  final qualifiesByIsee = isee <= threshold;
  final hasBillNeed =
      input.hasHighUtilityBills || input.utilityContractInOwnName;
  final score = qualifiesByIsee
      ? (hasBillNeed ? 0.97 : 0.88)
      : (hasBillNeed ? 0.55 : 0.2);
  return ToolResult(
    id: 'bonus-sociale-bollette',
    title: _l(
      'Bonus sociale for bills',
      'Bonus sociale bollette',
      'Bonus social pour les factures',
      'Bono social para facturas',
      'بونوس اجتماعی قبض‌ها',
      'الدعم الاجتماعي للفواتير',
    ),
    level: _level(score),
    score: score,
    reason: qualifiesByIsee
        ? _l(
            'You may match the current ISEE thresholds for utility discounts.',
            'Potresti rientrare nelle soglie ISEE attuali per gli sconti sulle bollette.',
            'Vous pourriez entrer dans les seuils ISEE actuels pour les réductions sur les factures.',
            'Podrías entrar en los umbrales ISEE actuales para descuentos en facturas.',
            'ممکن است در آستانه‌های فعلی ISEE برای تخفیف قبض‌ها قرار بگیری.',
            'قد تندرج ضمن حدود ISEE الحالية لخصومات الفواتير.',
          )
        : _l(
            'Your ISEE may be above the usual utility discount thresholds, but check the official page for updates.',
            'Il tuo ISEE potrebbe essere sopra le soglie tipiche, ma verifica eventuali aggiornamenti ufficiali.',
            'Votre ISEE peut être au-dessus des seuils habituels, mais vérifiez la page officielle pour les mises à jour.',
            'Tu ISEE puede estar por encima de los umbrales habituales, pero revisa la página oficial por si hay cambios.',
            'ممکن است ISEE تو بالاتر از حد معمول باشد، اما به‌روزرسانی‌های رسمی را بررسی کن.',
            'قد يكون ISEE الخاص بك أعلى من الحدود المعتادة، لكن تحقق من الصفحة الرسمية لأي تحديثات.',
          ),
    requirements: [
      _l(
        'Valid ISEE',
        'ISEE valido',
        'ISEE valide',
        'ISEE válido',
        'ISEE معتبر',
        'ISEE صالح',
      ),
      _l(
        'Household utility data',
        'Dati utenza del nucleo',
        'Données du contrat du foyer',
        'Datos del suministro del hogar',
        'اطلاعات قرارداد قبض خانواده',
        'بيانات عقد الخدمة للأسرة',
      ),
    ],
    documents: [
      _l(
        'DSU / ISEE receipt',
        'Ricevuta DSU / ISEE',
        'Reçu DSU / ISEE',
        'Justificante DSU / ISEE',
        'رسید DSU / ISEE',
        'إيصال DSU / ISEE',
      ),
      _l(
        'Recent bill',
        'Bolletta recente',
        'Facture récente',
        'Factura reciente',
        'قبض اخیر',
        'فاتورة حديثة',
      ),
    ],
    applicationChannel: _l(
      'Usually automatic after a valid ISEE.',
      'Di solito automatico dopo un ISEE valido.',
      'Généralement automatique après un ISEE valide.',
      'Normalmente automático tras un ISEE válido.',
      'معمولاً بعد از ISEE معتبر به‌صورت خودکار.',
      'عادةً تلقائي بعد ISEE صالح.',
    ),
    officialSources: [
      _l(
        'ARERA official pages',
        'Pagine ufficiali ARERA',
        'Pages officielles ARERA',
        'Páginas oficiales ARERA',
        'صفحات رسمی ARERA',
        'صفحات ARERA الرسمية',
      ),
    ],
    warning: _l(
      'You may be eligible. Check the official page before applying.',
      'Potresti avere diritto. Verifica sempre la pagina ufficiale prima della domanda.',
      'Vous pourriez être éligible. Vérifiez toujours la page officielle avant de demander.',
      'Podrías ser elegible. Revisa siempre la página oficial antes de solicitar.',
      'ممکن است واجد شرایط باشی. قبل از اقدام صفحه رسمی را بررسی کن.',
      'قد تكون مؤهلاً. تحقق دائماً من الصفحة الرسمية قبل التقديم.',
    ),
    relatedProcedureSlug: 'bonus-sociale-bollette',
  );
}

ToolResult _disagioFisico(BonusFinderInput input) {
  final score = input.hasLifeSavingMedicalEquipment ? 0.96 : 0.15;
  return ToolResult(
    id: 'bonus-elettrico-disagio-fisico',
    title: _l(
      'Electricity bonus for physical hardship',
      'Bonus elettrico per disagio fisico',
      'Bonus électrique pour difficulté physique',
      'Bono eléctrico por dificultad física',
      'بونوس برق برای نیاز پزشکی',
      'دعم الكهرباء للحالات الصحية',
    ),
    level: _level(score),
    score: score,
    reason: input.hasLifeSavingMedicalEquipment
        ? _l(
            'Home medical equipment is one of the strongest signals for this bonus.',
            'L’uso di apparecchiature elettromedicali a casa è uno dei segnali più forti per questo bonus.',
            'L’utilisation d’équipements médicaux à domicile est un signal fort pour cette aide.',
            'El uso de equipos médicos en casa es una señal fuerte para esta ayuda.',
            'وجود تجهیزات پزشکی حیاتی در خانه یکی از قوی‌ترین نشانه‌ها برای این بونوس است.',
            'وجود أجهزة طبية منزلية ضرورية للحياة من أقوى المؤشرات لهذا الدعم.',
          )
        : _l(
            'This bonus is usually reserved for home life-saving medical equipment.',
            'Questo bonus è di solito riservato a chi usa apparecchiature salvavita a casa.',
            'Cette aide est généralement réservée à l’usage d’équipements médicaux vitaux à domicile.',
            'Esta ayuda suele reservarse a quien usa equipos médicos vitales en casa.',
            'این بونوس معمولاً برای افرادی است که در خانه از تجهیزات پزشکی حیاتی استفاده می‌کنند.',
            'هذا الدعم مخصص عادةً لمن يستخدم أجهزة طبية ضرورية للحياة في المنزل.',
          ),
    documents: [
      _l(
        'Medical certificate',
        'Certificato medico',
        'Certificat médical',
        'Certificado médico',
        'گواهی پزشکی',
        'شهادة طبية',
      ),
      _l(
        'Electricity supply data',
        'Dati fornitura elettrica',
        'Données du contrat d’électricité',
        'Datos del suministro eléctrico',
        'اطلاعات قرارداد برق',
        'بيانات عقد الكهرباء',
      ),
    ],
    applicationChannel: _l(
      'Comune or CAF / patronato support.',
      'Comune o supporto CAF / patronato.',
      'Commune ou aide CAF / patronato.',
      'Comune o ayuda de CAF / patronato.',
      'از طریق Comune یا کمک CAF / patronato.',
      'عبر البلدية أو مساعدة CAF / patronato.',
    ),
    warning: _l(
      'Check the current form and certificate wording before applying.',
      'Verifica il modulo e il certificato richiesto prima della domanda.',
      'Vérifiez le formulaire et le certificat requis avant de demander.',
      'Verifica el formulario y el certificado exigido antes de solicitar.',
      'قبل از درخواست، فرم و متن گواهی لازم را بررسی کن.',
      'تحقق من النموذج وصيغة الشهادة المطلوبة قبل التقديم.',
    ),
    relatedProcedureSlug: 'bonus-elettrico-disagio-fisico',
  );
}

ToolResult _nursery(BonusFinderInput input) {
  final score = input.hasChildUnder3 && input.paysNurseryFees
      ? 0.95
      : (input.hasChildUnder3 ? 0.72 : 0.2);
  return ToolResult(
    id: 'bonus-asilo-nido',
    title: _l(
      'Nursery school bonus',
      'Bonus asilo nido',
      'Aide crèche',
      'Bono guardería',
      'بونوس مهدکودک',
      'دعم الحضانة',
    ),
    level: _level(score),
    score: score,
    reason: _l(
      'Children under 3 and nursery fees are the main indicators for this support.',
      'Bambini sotto i 3 anni e rette del nido sono gli indicatori principali per questo sostegno.',
      'Les enfants de moins de 3 ans et les frais de crèche sont les indicateurs principaux pour cette aide.',
      'Menores de 3 años y cuotas de guardería son las principales señales para esta ayuda.',
      'کودک زیر ۳ سال و هزینه مهدکودک نشانه‌های اصلی این کمک هستند.',
      'الأطفال دون 3 سنوات ورسوم الحضانة هي المؤشرات الأساسية لهذا الدعم.',
    ),
    documents: [
      _l(
        'Invoices and payment proof',
        'Fatture e prove di pagamento',
        'Factures et preuves de paiement',
        'Facturas y justificantes de pago',
        'فاکتورها و رسید پرداخت',
        'الفواتير وإثباتات الدفع',
      ),
      _l(
        'SPID / CIE / CNS',
        'SPID / CIE / CNS',
        'SPID / CIE / CNS',
        'SPID / CIE / CNS',
        'SPID / CIE / CNS',
        'SPID / CIE / CNS',
      ),
    ],
    applicationChannel: _l(
      'INPS online services or patronato.',
      'Servizi online INPS o patronato.',
      'Services en ligne INPS ou patronato.',
      'Servicios online INPS o patronato.',
      'خدمات آنلاین INPS یا patronato.',
      'خدمات INPS الإلكترونية أو patronato.',
    ),
    warning: _l(
      'You may be eligible. Check the current INPS window and document rules.',
      'Potresti rientrare. Controlla la finestra INPS aggiornata e le regole sui documenti.',
      'Vous pourriez correspondre. Vérifiez la fenêtre INPS et les règles documentaires actuelles.',
      'Podrías encajar. Revisa la ventana actual de INPS y las reglas de documentos.',
      'ممکن است شامل حالت شود. پنجره فعلی INPS و قوانین مدارک را بررسی کن.',
      'قد ينطبق عليك. تحقق من نافذة INPS الحالية وقواعد المستندات.',
    ),
    relatedProcedureSlug: 'bonus-asilo-nido',
  );
}

ToolResult _newborn(BonusFinderInput input) => ToolResult(
  id: 'bonus-nuovi-nati',
  title: _l(
    'Newborn bonus',
    'Bonus nuovi nati',
    'Prime nouveaux-nés',
    'Bono recién nacidos',
    'بونوس نوزادان',
    'دعم المواليد الجدد',
  ),
  level: _level(input.newChildThisYear ? 0.9 : 0.18),
  score: input.newChildThisYear ? 0.9 : 0.18,
  reason: _l(
    'A new child this year is the main trigger for this one-time support.',
    'La nascita o adozione nell’anno è il segnale principale per questo contributo una tantum.',
    'La naissance ou l’adoption dans l’année est le principal déclencheur de cette aide ponctuelle.',
    'Un nuevo hijo este año es la señal principal para esta ayuda puntual.',
    'تولد یا فرزندخواندگی در همین سال مهم‌ترین نشانه برای این کمک یک‌باره است.',
    'ولادة أو تبني طفل هذا العام هو المؤشر الأساسي لهذا الدعم لمرة واحدة.',
  ),
  applicationChannel: _l(
    'INPS application with deadline check.',
    'Domanda INPS con verifica della scadenza.',
    'Demande INPS avec vérification du délai.',
    'Solicitud INPS con verificación del plazo.',
    'درخواست INPS با بررسی مهلت.',
    'طلب INPS مع التحقق من الموعد النهائي.',
  ),
  warning: _l(
    'Check the official deadline before applying.',
    'Controlla la scadenza ufficiale prima della domanda.',
    'Vérifiez le délai officiel avant de demander.',
    'Verifica el plazo oficial antes de solicitar.',
    'قبل از اقدام، مهلت رسمی را بررسی کن.',
    'تحقق من الموعد النهائي الرسمي قبل التقديم.',
  ),
  relatedProcedureSlug: 'bonus-nuovi-nati',
);

ToolResult _assegnoUnico(BonusFinderInput input) => ToolResult(
  id: 'assegno-unico-universale',
  title: _l(
    'Universal child allowance',
    'Assegno unico universale',
    'Allocation unique universelle',
    'Asignación única universal',
    'کمک‌هزینه فرزند',
    'الإعانة الموحدة للأطفال',
  ),
  level: _level(input.dependentChildrenCount > 0 ? 0.92 : 0.18),
  score: input.dependentChildrenCount > 0 ? 0.92 : 0.18,
  reason: _l(
    'Dependent children are the main signal for this monthly family support.',
    'I figli a carico sono il segnale principale per questo sostegno mensile.',
    'Les enfants à charge sont le principal signal pour ce soutien mensuel.',
    'Los hijos a cargo son la señal principal para este apoyo mensual.',
    'فرزندان تحت تکفل نشانه اصلی برای این حمایت ماهانه هستند.',
    'الأطفال المعالون هم المؤشر الأساسي لهذا الدعم الشهري.',
  ),
  applicationChannel: _l(
    'INPS online services.',
    'Servizi online INPS.',
    'Services en ligne INPS.',
    'Servicios online INPS.',
    'خدمات آنلاین INPS.',
    'خدمات INPS الإلكترونية.',
  ),
  warning: _l(
    'You may be eligible. Use the official simulator and ISEE guidance before applying.',
    'Potresti rientrare. Usa simulatore ufficiale e guida ISEE prima della domanda.',
    'Vous pourriez correspondre. Utilisez le simulateur officiel et les indications ISEE avant de demander.',
    'Podrías encajar. Usa el simulador oficial y la guía ISEE antes de solicitar.',
    'ممکن است واجد شرایط باشی. قبل از اقدام، شبیه‌ساز رسمی و راهنمای ISEE را ببین.',
    'قد تكون مؤهلاً. استخدم المحاكي الرسمي وإرشادات ISEE قبل التقديم.',
  ),
  relatedProcedureSlug: 'assegno-unico-universale',
);

ToolResult _psychologist(BonusFinderInput input) => ToolResult(
  id: 'bonus-psicologo',
  title: _l(
    'Psychologist bonus',
    'Bonus psicologo',
    'Bonus psychologue',
    'Bono psicólogo',
    'بونوس روان‌شناس',
    'دعم العلاج النفسي',
  ),
  level: _level(input.needsPsychologistSupport ? 0.83 : 0.16),
  score: input.needsPsychologistSupport ? 0.83 : 0.16,
  reason: _l(
    'The need for psychotherapy support is the core signal for this seasonal benefit.',
    'Il bisogno di supporto psicologico è il segnale centrale per questo beneficio stagionale.',
    'Le besoin de soutien psychologique est le signal principal pour cette aide saisonnière.',
    'La necesidad de apoyo psicológico es la señal principal para esta ayuda estacional.',
    'نیاز به حمایت روان‌درمانی نشانه اصلی برای این کمک فصلی است.',
    'الحاجة إلى دعم نفسي هي المؤشر الأساسي لهذا الدعم الموسمي.',
  ),
  applicationChannel: _l(
    'Watch the INPS application window.',
    'Controlla la finestra di domanda INPS.',
    'Surveillez la fenêtre de demande INPS.',
    'Sigue la ventana de solicitud de INPS.',
    'پنجره درخواست INPS را دنبال کن.',
    'تابع نافذة التقديم لدى INPS.',
  ),
  warning: _l(
    'Application windows change every year. Check the official page before relying on it.',
    'Le finestre cambiano ogni anno. Controlla la pagina ufficiale prima di farci affidamento.',
    'Les périodes changent chaque année. Vérifiez la page officielle avant de compter dessus.',
    'Las ventanas cambian cada año. Revisa la página oficial antes de contar con ello.',
    'بازه‌های درخواست هر سال تغییر می‌کنند. قبل از حساب کردن روی آن، صفحه رسمی را بررسی کن.',
    'تتغير فترات التقديم كل سنة. تحقق من الصفحة الرسمية قبل الاعتماد عليها.',
  ),
  relatedProcedureSlug: 'bonus-psicologo',
);

ToolResult _piemonteVoucher(BonusFinderInput input) => ToolResult(
  id: 'voucher-scuola-piemonte',
  title: _l(
    'Piemonte school voucher',
    'Voucher scuola Piemonte',
    'Bon scolaire Piémont',
    'Vale escolar Piamonte',
    'کوپن مدرسه پیمونته',
    'قسيمة المدرسة في بيمونتي',
  ),
  level: _level(
    input.region == 'Piemonte' && input.isPiemonteSchoolStudent ? 0.85 : 0.22,
  ),
  score: input.region == 'Piemonte' && input.isPiemonteSchoolStudent
      ? 0.85
      : 0.22,
  reason: _l(
    'This result becomes more relevant when the student is in Piemonte.',
    'Questo risultato è più rilevante se lo studente è in Piemonte.',
    'Ce résultat devient plus pertinent si l’étudiant est dans le Piémont.',
    'Este resultado gana relevancia si el estudiante está en Piamonte.',
    'اگر دانش‌آموز در پیمونته باشد، این نتیجه مهم‌تر می‌شود.',
    'يصبح هذا الخيار أكثر صلة إذا كان الطالب في بيمونتي.',
  ),
  applicationChannel: _l(
    'Regional call / school voucher portal.',
    'Bando regionale / portale voucher scuola.',
    'Appel régional / portail du bon scolaire.',
    'Convocatoria regional / portal de vale escolar.',
    'فراخوان منطقه‌ای / درگاه کوپن مدرسه.',
    'دعوة إقليمية / بوابة القسيمة المدرسية.',
  ),
  warning: _l(
    'Regional calls open and close. Check dates before preparing documents.',
    'I bandi regionali aprono e chiudono. Verifica le date prima di preparare i documenti.',
    'Les appels régionaux ouvrent et ferment. Vérifiez les dates avant de préparer les documents.',
    'Las convocatorias regionales abren y cierran. Verifica las fechas antes de preparar documentos.',
    'فراخوان‌های منطقه‌ای باز و بسته می‌شوند. قبل از آماده کردن مدارک، تاریخ‌ها را بررسی کن.',
    'تُفتح الدعوات الإقليمية وتُغلق. تحقق من المواعيد قبل تجهيز المستندات.',
  ),
);

ToolResult _rentSupport(BonusFinderInput input) => ToolResult(
  id: 'rent-support-piemonte',
  title: _l(
    'Rent support',
    'Sostegno affitto',
    'Aide au loyer',
    'Ayuda alquiler',
    'کمک اجاره',
    'دعم الإيجار',
  ),
  level: _level(
    input.isTenant && input.isBehindOnRent
        ? 0.88
        : (input.isTenant ? 0.54 : 0.15),
  ),
  score: input.isTenant && input.isBehindOnRent
      ? 0.88
      : (input.isTenant ? 0.54 : 0.15),
  reason: _l(
    'Tenant status and rent difficulty are the strongest signals here.',
    'Essere inquilino e avere difficoltà con l’affitto sono i segnali principali.',
    'Le statut de locataire et les difficultés de loyer sont les signaux les plus forts.',
    'Ser inquilino y tener dificultad con el alquiler son las señales más fuertes.',
    'مستأجر بودن و مشکل در اجاره مهم‌ترین نشانه‌ها هستند.',
    'كونك مستأجراً ومواجهة صعوبة في الإيجار هما الإشارتان الأقوى هنا.',
  ),
  applicationChannel: _l(
    'Comune / regional housing support.',
    'Comune / sostegno abitativo regionale.',
    'Commune / aide logement régionale.',
    'Comune / apoyo regional de vivienda.',
    'Comune / حمایت مسکن منطقه‌ای.',
    'البلدية / دعم السكن الإقليمي.',
  ),
  warning: _l(
    'This is often local and seasonal. Check if funds are open in your area.',
    'Spesso è locale e stagionale. Verifica se i fondi sono aperti nella tua zona.',
    'C’est souvent local et saisonnier. Vérifiez si les fonds sont ouverts dans votre zone.',
    'Suele ser local y estacional. Revisa si hay fondos abiertos en tu zona.',
    'این کمک معمولاً محلی و فصلی است. بررسی کن که در منطقه تو بودجه باز باشد.',
    'غالباً يكون هذا الدعم محلياً وموسمياً. تحقق من فتح الصناديق في منطقتك.',
  ),
  relatedProcedureSlug: 'rent-deposit-support',
);

ToolResult _taxDeductions(BonusFinderInput input) => ToolResult(
  id: 'home-tax-deductions',
  title: _l(
    'Home and tax deductions',
    'Detrazioni casa e tasse',
    'Déductions logement et impôts',
    'Deducciones vivienda e impuestos',
    'کسر مالیاتی خانه',
    'خصومات السكن والضرائب',
  ),
  level: _level(input.interestedInRenovationTaxDeductions ? 0.78 : 0.18),
  score: input.interestedInRenovationTaxDeductions ? 0.78 : 0.18,
  reason: _l(
    'Renovation or deduction interest points to tax-saving guidance rather than an automatic benefit.',
    'L’interesse per ristrutturazioni o detrazioni indica più una guida fiscale che un bonus automatico.',
    'L’intérêt pour la rénovation ou les déductions indique plutôt un guidage fiscal qu’une aide automatique.',
    'El interés por reformas o deducciones apunta más a guía fiscal que a ayuda automática.',
    'علاقه به بازسازی یا کسر مالیاتی بیشتر به راهنمای صرفه‌جویی مالیاتی اشاره دارد تا بونوس خودکار.',
    'الاهتمام بالتجديد أو الخصومات يشير أكثر إلى إرشاد ضريبي منه إلى دعم تلقائي.',
  ),
  applicationChannel: _l(
    'CAF / commercialista / official tax guidance.',
    'CAF / commercialista / guida fiscale ufficiale.',
    'CAF / comptable / guide fiscal officiel.',
    'CAF / asesor fiscal / guía oficial de impuestos.',
    'CAF / حسابدار / راهنمای رسمی مالیات.',
    'CAF / محاسب / الإرشاد الضريبي الرسمي.',
  ),
  warning: _l(
    'Tax rules change. Check the official guidance before spending money based on this result.',
    'Le regole fiscali cambiano. Verifica la guida ufficiale prima di spendere soldi in base a questo risultato.',
    'Les règles fiscales changent. Vérifiez les indications officielles avant de dépenser de l’argent sur cette base.',
    'Las reglas fiscales cambian. Revisa la guía oficial antes de gastar dinero basándote en este resultado.',
    'قوانین مالیاتی تغییر می‌کنند. قبل از خرج کردن پول بر اساس این نتیجه، راهنمای رسمی را بررسی کن.',
    'تتغير القواعد الضريبية. تحقق من الإرشادات الرسمية قبل إنفاق المال بناءً على هذه النتيجة.',
  ),
);

ToolResult _perMerito(LoanComparisonInput input) => _loanResult(
  id: 'intesa-per-merito',
  input: input,
  title: _l(
    'Intesa Sanpaolo Per Merito',
    'Intesa Sanpaolo Per Merito',
    'Intesa Sanpaolo Per Merito',
    'Intesa Sanpaolo Per Merito',
    'Intesa Sanpaolo Per Merito',
    'Intesa Sanpaolo Per Merito',
  ),
  score: input.isStudent && input.wantRepaymentAfterStudies
      ? 0.93
      : (input.isStudent ? 0.6 : 0.16),
  reason: _l(
    'Student profile and deferred repayment are a strong match for this product.',
    'Profilo studente e rimborso differito sono una forte corrispondenza per questo prodotto.',
    'Le profil étudiant et le remboursement différé correspondent bien à ce produit.',
    'Perfil de estudiante y devolución diferida encajan bien con este producto.',
    'دانشجو بودن و تمایل به بازپرداخت پس از پایان تحصیل، تطابق خوبی با این محصول دارد.',
    'كونك طالباً مع رغبة في السداد بعد الدراسة يناسب هذا المنتج كثيراً.',
  ),
  procedureSlug: 'intesa-per-merito',
  source: 'Intesa Sanpaolo official page',
);

ToolResult _consapStudio(LoanComparisonInput input) => _loanResult(
  id: 'consap-fondo-studio',
  input: input,
  title: _l(
    'Consap Study Fund',
    'Fondo Studio Consap',
    'Fonds Études Consap',
    'Fondo de Estudios Consap',
    'صندوق تحصیلی Consap',
    'صندوق الدراسة Consap',
  ),
  score: input.isStudent && input.avoidParentGuarantee
      ? 0.88
      : (input.isStudent ? 0.58 : 0.15),
  reason: _l(
    'This can matter when the student needs support but is comparing guarantee structures through partner banks.',
    'Può contare quando lo studente ha bisogno di supporto ma sta confrontando garanzie tramite banche convenzionate.',
    'Cela compte quand l’étudiant a besoin de soutien mais compare les garanties via des banques partenaires.',
    'Puede importar cuando el estudiante necesita apoyo y compara garantías a través de bancos asociados.',
    'وقتی دانشجو به حمایت نیاز دارد و ساختارهای ضمانت بانک‌ها را مقایسه می‌کند، این گزینه مهم می‌شود.',
    'قد يكون مهماً عندما يحتاج الطالب إلى دعم ويقارن هياكل الضمان عبر البنوك الشريكة.',
  ),
  procedureSlug: 'consap-fondo-studio',
  source: 'Consap official page',
);

ToolResult _unicreditAdHonorem(LoanComparisonInput input) => _loanResult(
  id: 'unicredit-ad-honorem',
  input: input,
  title: _l(
    'UniCredit Ad Honorem',
    'UniCredit Ad Honorem',
    'UniCredit Ad Honorem',
    'UniCredit Ad Honorem',
    'UniCredit Ad Honorem',
    'UniCredit Ad Honorem',
  ),
  score: input.isStudent && input.hasUniversityPartnerAgreement
      ? 0.86
      : (input.isStudent ? 0.5 : 0.14),
  reason: _l(
    'Partner university agreements make this result more relevant.',
    'Gli accordi con l’università rendono questo risultato più rilevante.',
    'Les accords avec l’université rendent ce résultat plus pertinent.',
    'Los acuerdos con la universidad hacen este resultado más relevante.',
    'داشتن توافق دانشگاهی این نتیجه را مهم‌تر می‌کند.',
    'تجعل اتفاقيات الجامعة هذه النتيجة أكثر صلة.',
  ),
  procedureSlug: 'unicredit-ad-honorem',
  source: 'UniCredit official page',
);

ToolResult _unicreditStudio(LoanComparisonInput input) => _loanResult(
  id: 'unicredit-fondo-studio',
  input: input,
  title: _l(
    'UniCredit Study Fund',
    'UniCredit Fondo per lo Studio',
    'Fonds d’études UniCredit',
    'Fondo para estudios UniCredit',
    'صندوق تحصیل UniCredit',
    'صندوق الدراسة UniCredit',
  ),
  score: input.isStudent && input.amountNeeded >= 5000
      ? 0.8
      : (input.isStudent ? 0.48 : 0.14),
  reason: _l(
    'This can fit students comparing larger study financing needs.',
    'Può adattarsi a studenti che confrontano esigenze di finanziamento più ampie.',
    'Cela peut convenir aux étudiants comparant des besoins de financement plus importants.',
    'Puede encajar con estudiantes que comparan necesidades de financiación más amplias.',
    'برای دانشجویانی که به مبالغ بیشتر نیاز دارند، این گزینه می‌تواند مناسب باشد.',
    'قد يناسب هذا الطلاب الذين يقارنون احتياجات تمويل دراسية أكبر.',
  ),
  procedureSlug: 'unicredit-fondo-per-lo-studio',
  source: 'UniCredit official page',
);

ToolResult _bancaSella(LoanComparisonInput input) => _loanResult(
  id: 'banca-sella-prestito-onore',
  input: input,
  title: _l(
    'Banca Sella loan of honour',
    'Banca Sella prestito d’onore',
    'Prêt d’honneur Banca Sella',
    'Préstamo de honor Banca Sella',
    'وام افتخاری Banca Sella',
    'قرض شرف Banca Sella',
  ),
  score: input.isStudent && input.wantRepaymentAfterStudies
      ? 0.73
      : (input.isStudent ? 0.4 : 0.12),
  reason: _l(
    'This result becomes more relevant for students comparing delayed repayment structures.',
    'Diventa più rilevante per studenti che confrontano strutture con rimborso differito.',
    'Ce résultat devient plus pertinent pour les étudiants qui comparent des remboursements différés.',
    'Este resultado gana relevancia para estudiantes que comparan devoluciones diferidas.',
    'برای دانشجویانی که ساختار بازپرداخت با تأخیر را مقایسه می‌کنند، این گزینه مهم‌تر است.',
    'يصبح هذا الخيار أكثر صلة للطلاب الذين يقارنون هياكل السداد المؤجل.',
  ),
  procedureSlug: 'banca-sella-prestito-onore',
  source: 'Banca Sella official page',
);

ToolResult _sparkasse(LoanComparisonInput input) => _loanResult(
  id: 'sparkasse-prestito-studio',
  input: input,
  title: _l(
    'Sparkasse study loan',
    'Sparkasse Prestito Studio',
    'Prêt études Sparkasse',
    'Préstamo de estudios Sparkasse',
    'وام تحصیلی Sparkasse',
    'قرض الدراسة Sparkasse',
  ),
  score: input.isStudent && input.needsLivingCosts
      ? 0.76
      : (input.isStudent ? 0.44 : 0.12),
  reason: _l(
    'Living-cost needs make broader study-loan options more relevant.',
    'I costi di mantenimento rendono più rilevanti i prestiti studio più ampi.',
    'Les frais de vie rendent les prêts d’études plus larges plus pertinents.',
    'Las necesidades de manutención hacen más relevantes los préstamos de estudio más amplios.',
    'نیاز به هزینه‌های زندگی، وام‌های تحصیلی گسترده‌تر را مهم‌تر می‌کند.',
    'تجعل تكاليف المعيشة خيارات قروض الدراسة الأوسع أكثر صلة.',
  ),
  procedureSlug: 'sparkasse-prestito-studio-spark',
  source: 'Sparkasse official page',
);

ToolResult _firstHome(LoanComparisonInput input) => _loanResult(
  id: 'consap-first-home',
  input: input,
  title: _l(
    'Consap first-home guarantee',
    'Consap Fondo Prima Casa',
    'Garantie première maison Consap',
    'Garantía primera vivienda Consap',
    'ضمان خانه اول Consap',
    'ضمان المنزل الأول Consap',
  ),
  score: input.isFirstHomeMortgage ? 0.92 : 0.12,
  reason: _l(
    'This result is mainly for first-home mortgage guarantee cases.',
    'Questo risultato riguarda soprattutto i casi di garanzia per mutuo prima casa.',
    'Ce résultat concerne surtout les cas de garantie pour un premier logement.',
    'Este resultado se refiere sobre todo a garantías para primera vivienda.',
    'این نتیجه بیشتر برای ضمانت وام خانه اول است.',
    'هذه النتيجة تخص أساساً حالات ضمان قرض المنزل الأول.',
  ),
  procedureSlug: 'consap-fondo-prima-casa',
  source: 'Consap official page',
);

ToolResult _mortgageSuspension(LoanComparisonInput input) => _loanResult(
  id: 'mortgage-suspension',
  input: input,
  title: _l(
    'First-home mortgage suspension',
    'Sospensione mutui prima casa',
    'Suspension du prêt première maison',
    'Suspensión hipoteca primera vivienda',
    'تعلیق وام خانه اول',
    'تعليق قرض المنزل الأول',
  ),
  score: input.hasExistingMortgageDifficulty ? 0.9 : 0.14,
  reason: _l(
    'Existing mortgage difficulty is the main signal for this route.',
    'La difficoltà con un mutuo già attivo è il segnale principale per questa strada.',
    'La difficulté avec un prêt déjà actif est le signal principal pour cette voie.',
    'La dificultad con una hipoteca existente es la señal principal para esta vía.',
    'مشکل در بازپرداخت وام موجود نشانه اصلی برای این مسیر است.',
    'صعوبة سداد قرض قائم هي المؤشر الأساسي لهذا المسار.',
  ),
  procedureSlug: 'fondo-sospensione-mutui-prima-casa',
  source: 'Consap official page',
);

ToolResult _rentDepositSupport(LoanComparisonInput input) => _loanResult(
  id: 'rent-deposit-support',
  input: input,
  title: _l(
    'Rent and deposit support',
    'Sostegno affitto e cauzione',
    'Aide loyer et caution',
    'Ayuda alquiler y fianza',
    'کمک اجاره و ودیعه',
    'دعم الإيجار والوديعة',
  ),
  score: input.needsRentDepositSupport ? 0.8 : 0.18,
  reason: _l(
    'This is more relevant when the need is rent/deposit support rather than classic consumer credit.',
    'È più rilevante quando il bisogno è supporto affitto/cauzione e non credito al consumo classico.',
    'C’est plus pertinent quand le besoin porte sur le loyer/la caution plutôt que sur un crédit à la consommation classique.',
    'Es más relevante cuando la necesidad es apoyo para alquiler/fianza y no crédito al consumo clásico.',
    'وقتی نیاز مربوط به اجاره یا ودیعه باشد و نه وام مصرفی کلاسیک، این گزینه مهم‌تر است.',
    'يكون أكثر صلة عندما تكون الحاجة دعماً للإيجار أو الوديعة لا ائتماناً استهلاكياً كلاسيكياً.',
  ),
  procedureSlug: 'rent-deposit-support',
  source: 'Regional / Comune housing support',
);

ToolResult _loanResult({
  required String id,
  required LoanComparisonInput input,
  required Map<String, String> title,
  required double score,
  required Map<String, String> reason,
  required String procedureSlug,
  required String source,
}) {
  return ToolResult(
    id: id,
    title: title,
    level: _level(score),
    score: score,
    reason: reason,
    requirements: [
      _l(
        'Identity and tax code',
        'Documento e codice fiscale',
        'Pièce d’identité et code fiscal',
        'Documento e identificación fiscal',
        'مدرک هویتی و کد مالیاتی',
        'الهوية والرمز الضريبي',
      ),
      _l(
        'Latest provider or bank conditions',
        'Condizioni aggiornate del prodotto',
        'Conditions actuelles du produit',
        'Condiciones actualizadas del producto',
        'شرایط به‌روز محصول',
        'الشروط المحدثة للمنتج',
      ),
    ],
    documents: [
      _l(
        'Income or study documents',
        'Documenti reddituali o di studio',
        'Documents de revenus ou d’études',
        'Documentos de ingresos o estudios',
        'مدارک درآمد یا تحصیل',
        'مستندات الدخل أو الدراسة',
      ),
    ],
    applicationChannel: _l(
      'Compare the provider page and official references before applying.',
      'Confronta la pagina del provider e le fonti ufficiali prima della domanda.',
      'Comparez la page du fournisseur et les sources officielles avant de demander.',
      'Compara la página del proveedor y las fuentes oficiales antes de solicitar.',
      'قبل از اقدام، صفحه ارائه‌دهنده و منابع رسمی را مقایسه کن.',
      'قارن صفحة الجهة المقدمة والمصادر الرسمية قبل التقديم.',
    ),
    officialSources: [_l(source, source, source, source, source, source)],
    warning: _l(
      'This is credit, not free money. Compare TAEG, total cost, duration, guarantees and late-payment consequences before signing.',
      'Questo è credito, non denaro gratuito. Confronta TAEG, costo totale, durata, garanzie e conseguenze dei ritardi prima di firmare.',
      'Il s’agit d’un crédit, pas d’argent gratuit. Comparez TAEG, coût total, durée, garanties et conséquences des retards avant de signer.',
      'Esto es crédito, no dinero gratis. Compara TAEG, coste total, duración, garantías y consecuencias de impago antes de firmar.',
      'این اعتبار است، نه پول رایگان. قبل از امضا TAEG، هزینه کل، مدت، ضمانت‌ها و پیامدهای تأخیر را مقایسه کن.',
      'هذا ائتمان وليس مالاً مجانياً. قارن TAEG والتكلفة الإجمالية والمدة والضمانات وعواقب التأخير قبل التوقيع.',
    ),
    relatedProcedureSlug: procedureSlug,
  );
}

ToolMatchLevel _level(double score) {
  if (score >= 0.8) return ToolMatchLevel.likely;
  if (score >= 0.55) return ToolMatchLevel.maybe;
  if (score >= 0.3) return ToolMatchLevel.monitor;
  return ToolMatchLevel.unlikely;
}

Map<String, String> _l(
  String en,
  String it,
  String fr,
  String es,
  String fa,
  String ar,
) => {'en': en, 'it': it, 'fr': fr, 'es': es, 'fa': fa, 'ar': ar};
