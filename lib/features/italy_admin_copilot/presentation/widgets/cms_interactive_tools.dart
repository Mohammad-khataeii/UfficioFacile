import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/localized_text.dart';
import '../../data/interactive_tools.dart';

class BonusFinderTool extends StatefulWidget {
  const BonusFinderTool({super.key, required this.fullAccess});

  final bool fullAccess;

  @override
  State<BonusFinderTool> createState() => _BonusFinderToolState();
}

class _BonusFinderToolState extends State<BonusFinderTool> {
  final _service = const BonusFinderService();
  final _iseeController = TextEditingController();
  int _householdSize = 1;
  int _children = 0;
  bool _childUnder3 = false;
  bool _nursery = false;
  bool _newChild = false;
  bool _student = false;
  bool _tenant = false;
  bool _worker = false;
  bool _unemployed = false;
  bool _highBills = false;
  bool _utilityInName = false;
  bool _medicalEquipment = false;
  bool _psychologist = false;
  bool _schoolPiemonte = false;
  bool _university = false;
  bool _rentArrears = false;
  bool _taxDeductions = false;

  @override
  void dispose() {
    _iseeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = BonusFinderInput(
      iseeAmount: double.tryParse(_iseeController.text.trim()),
      householdSize: _householdSize,
      dependentChildrenCount: _children,
      hasChildUnder3: _childUnder3,
      paysNurseryFees: _nursery,
      newChildThisYear: _newChild,
      isStudent: _student,
      isTenant: _tenant,
      isWorker: _worker,
      isUnemployed: _unemployed,
      hasHighUtilityBills: _highBills,
      utilityContractInOwnName: _utilityInName,
      hasLifeSavingMedicalEquipment: _medicalEquipment,
      needsPsychologistSupport: _psychologist,
      isPiemonteSchoolStudent: _schoolPiemonte,
      isUniversityStudent: _university,
      isBehindOnRent: _rentArrears,
      interestedInRenovationTaxDeductions: _taxDeductions,
    );
    final results = _service.evaluate(input);
    final visibleResults = widget.fullAccess
        ? results
        : results.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _iseeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: _toolLabel(context, 'isee')),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _counterRow(
          context,
          _toolLabel(context, 'household_size'),
          _householdSize,
          (next) => setState(() => _householdSize = next.clamp(1, 12)),
        ),
        const SizedBox(height: 8),
        _counterRow(
          context,
          _toolLabel(context, 'dependent_children'),
          _children,
          (next) => setState(() => _children = next.clamp(0, 10)),
        ),
        const SizedBox(height: 12),
        ...[
          (
            _toolLabel(context, 'child_under_3'),
            _childUnder3,
            (bool v) => _childUnder3 = v,
          ),
          (
            _toolLabel(context, 'nursery_fees'),
            _nursery,
            (bool v) => _nursery = v,
          ),
          (
            _toolLabel(context, 'new_child_this_year'),
            _newChild,
            (bool v) => _newChild = v,
          ),
          (_toolLabel(context, 'student'), _student, (bool v) => _student = v),
          (_toolLabel(context, 'tenant'), _tenant, (bool v) => _tenant = v),
          (_toolLabel(context, 'worker'), _worker, (bool v) => _worker = v),
          (
            _toolLabel(context, 'unemployed'),
            _unemployed,
            (bool v) => _unemployed = v,
          ),
          (
            _toolLabel(context, 'high_utility_bills'),
            _highBills,
            (bool v) => _highBills = v,
          ),
          (
            _toolLabel(context, 'utility_contract_own_name'),
            _utilityInName,
            (bool v) => _utilityInName = v,
          ),
          (
            _toolLabel(context, 'medical_equipment_home'),
            _medicalEquipment,
            (bool v) => _medicalEquipment = v,
          ),
          (
            _toolLabel(context, 'psychologist_support'),
            _psychologist,
            (bool v) => _psychologist = v,
          ),
          (
            _toolLabel(context, 'piemonte_school_student'),
            _schoolPiemonte,
            (bool v) => _schoolPiemonte = v,
          ),
          (
            _toolLabel(context, 'university_student'),
            _university,
            (bool v) => _university = v,
          ),
          (
            _toolLabel(context, 'behind_on_rent'),
            _rentArrears,
            (bool v) => _rentArrears = v,
          ),
          (
            _toolLabel(context, 'tax_deductions_interest'),
            _taxDeductions,
            (bool v) => _taxDeductions = v,
          ),
        ].map(
          (item) => SwitchListTile(
            value: item.$2,
            onChanged: (value) => setState(() => item.$3(value)),
            contentPadding: EdgeInsets.zero,
            title: Text(item.$1),
          ),
        ),
        if (!widget.fullAccess)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              context.l10n.t('payment_setup_message'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ...visibleResults.map((result) => _ToolResultCard(result: result)),
      ],
    );
  }
}

class LoanComparisonTool extends StatefulWidget {
  const LoanComparisonTool({super.key, required this.fullAccess});

  final bool fullAccess;

  @override
  State<LoanComparisonTool> createState() => _LoanComparisonToolState();
}

class _LoanComparisonToolState extends State<LoanComparisonTool> {
  final _service = const LoanComparisonService();
  final _amountController = TextEditingController(text: '5000');
  int _age = 21;
  String _studyType = 'university';
  bool _student = true;
  bool _livingCosts = false;
  bool _noGuarantee = false;
  bool _repaymentLater = false;
  bool _partnerAgreement = false;
  bool _firstHome = false;
  bool _mortgageDifficulty = false;
  bool _rentDeposit = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = LoanComparisonInput(
      isStudent: _student,
      age: _age,
      studyType: _studyType,
      amountNeeded: int.tryParse(_amountController.text.trim()) ?? 5000,
      needsLivingCosts: _livingCosts,
      avoidParentGuarantee: _noGuarantee,
      wantRepaymentAfterStudies: _repaymentLater,
      hasUniversityPartnerAgreement: _partnerAgreement,
      isFirstHomeMortgage: _firstHome,
      hasExistingMortgageDifficulty: _mortgageDifficulty,
      needsRentDepositSupport: _rentDeposit,
    );
    final results = _service.evaluate(input);
    final visibleResults = widget.fullAccess
        ? results
        : results.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _counterRow(
          context,
          _toolLabel(context, 'age'),
          _age,
          (next) => setState(() => _age = next.clamp(16, 80)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _toolLabel(context, 'amount_needed_eur'),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _studyType,
          decoration: InputDecoration(
            labelText: _toolLabel(context, 'study_type'),
          ),
          items: [
            DropdownMenuItem(
              value: 'university',
              child: Text(_toolLabel(context, 'study_university')),
            ),
            DropdownMenuItem(
              value: 'master',
              child: Text(_toolLabel(context, 'study_master')),
            ),
            DropdownMenuItem(
              value: 'phd',
              child: Text(_toolLabel(context, 'study_phd')),
            ),
            DropdownMenuItem(
              value: 'its',
              child: Text(_toolLabel(context, 'study_its')),
            ),
            DropdownMenuItem(
              value: 'abroad',
              child: Text(_toolLabel(context, 'study_abroad')),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Text(_toolLabel(context, 'study_other')),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _studyType = value);
          },
        ),
        const SizedBox(height: 12),
        ...[
          (_toolLabel(context, 'student'), _student, (bool v) => _student = v),
          (
            _toolLabel(context, 'rent_living_costs'),
            _livingCosts,
            (bool v) => _livingCosts = v,
          ),
          (
            _toolLabel(context, 'avoid_parent_guarantee'),
            _noGuarantee,
            (bool v) => _noGuarantee = v,
          ),
          (
            _toolLabel(context, 'repayment_after_studies'),
            _repaymentLater,
            (bool v) => _repaymentLater = v,
          ),
          (
            _toolLabel(context, 'partner_agreement'),
            _partnerAgreement,
            (bool v) => _partnerAgreement = v,
          ),
          (
            _toolLabel(context, 'first_home_mortgage'),
            _firstHome,
            (bool v) => _firstHome = v,
          ),
          (
            _toolLabel(context, 'existing_mortgage_difficulty'),
            _mortgageDifficulty,
            (bool v) => _mortgageDifficulty = v,
          ),
          (
            _toolLabel(context, 'rent_deposit_support'),
            _rentDeposit,
            (bool v) => _rentDeposit = v,
          ),
        ].map(
          (item) => SwitchListTile(
            value: item.$2,
            onChanged: (value) => setState(() => item.$3(value)),
            contentPadding: EdgeInsets.zero,
            title: Text(item.$1),
          ),
        ),
        if (!widget.fullAccess)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Text(
              context.l10n.t('payment_setup_message'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ...visibleResults.map((result) => _ToolResultCard(result: result)),
      ],
    );
  }
}

class _ToolResultCard extends StatelessWidget {
  const _ToolResultCard({required this.result});

  final ToolResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizedMap(context, result.title),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _levelBadge(context, result.level),
              ],
            ),
            const SizedBox(height: 8),
            Text(localizedMap(context, result.reason)),
            if (result.requirements.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                result.requirements
                    .map((item) => localizedMap(context, item))
                    .join(' • '),
              ),
            ],
            if (result.warning.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                localizedMap(context, result.warning),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _levelBadge(BuildContext context, ToolMatchLevel level) {
  final label = switch (level) {
    ToolMatchLevel.likely => _toolLabel(context, 'level_likely'),
    ToolMatchLevel.maybe => _toolLabel(context, 'level_maybe'),
    ToolMatchLevel.monitor => _toolLabel(context, 'level_monitor'),
    ToolMatchLevel.unlikely => _toolLabel(context, 'level_unlikely'),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelMedium),
  );
}

String _toolLabel(BuildContext context, String key) {
  const values = <String, Map<String, String>>{
    'isee': {
      'en': 'ISEE',
      'it': 'ISEE',
      'fr': 'ISEE',
      'es': 'ISEE',
      'fa': 'ISEE',
      'ar': 'ISEE',
    },
    'household_size': {
      'en': 'Household size',
      'it': 'Componenti del nucleo',
      'fr': 'Taille du foyer',
      'es': 'Tamaño del hogar',
      'fa': 'تعداد اعضای خانواده',
      'ar': 'حجم الأسرة',
    },
    'dependent_children': {
      'en': 'Dependent children',
      'it': 'Figli a carico',
      'fr': 'Enfants à charge',
      'es': 'Hijos a cargo',
      'fa': 'فرزندان تحت تکفل',
      'ar': 'الأطفال المعالون',
    },
    'child_under_3': {
      'en': 'Child under 3',
      'it': 'Figlio sotto i 3 anni',
      'fr': 'Enfant de moins de 3 ans',
      'es': 'Hijo menor de 3 años',
      'fa': 'کودک زیر ۳ سال',
      'ar': 'طفل دون 3 سنوات',
    },
    'nursery_fees': {
      'en': 'Paying nursery fees',
      'it': 'Paghi rette del nido',
      'fr': 'Vous payez la crèche',
      'es': 'Pagas guardería',
      'fa': 'هزینه مهدکودک می‌پردازی',
      'ar': 'تدفع رسوم الحضانة',
    },
    'new_child_this_year': {
      'en': 'New child this year',
      'it': 'Nuovo figlio quest’anno',
      'fr': 'Nouvel enfant cette année',
      'es': 'Nuevo hijo este año',
      'fa': 'فرزند جدید در امسال',
      'ar': 'طفل جديد هذا العام',
    },
    'student': {
      'en': 'Student',
      'it': 'Studente',
      'fr': 'Étudiant',
      'es': 'Estudiante',
      'fa': 'دانشجو',
      'ar': 'طالب',
    },
    'tenant': {
      'en': 'Tenant',
      'it': 'Inquilino',
      'fr': 'Locataire',
      'es': 'Inquilino',
      'fa': 'مستأجر',
      'ar': 'مستأجر',
    },
    'worker': {
      'en': 'Worker',
      'it': 'Lavoratore',
      'fr': 'Travailleur',
      'es': 'Trabajador',
      'fa': 'کارگر / شاغل',
      'ar': 'عامل',
    },
    'unemployed': {
      'en': 'Unemployed',
      'it': 'Disoccupato',
      'fr': 'Sans emploi',
      'es': 'Desempleado',
      'fa': 'بیکار',
      'ar': 'عاطل عن العمل',
    },
    'high_utility_bills': {
      'en': 'High utility bills',
      'it': 'Bollette alte',
      'fr': 'Factures élevées',
      'es': 'Facturas altas',
      'fa': 'قبض‌های بالا',
      'ar': 'فواتير مرتفعة',
    },
    'utility_contract_own_name': {
      'en': 'Utility contract in your name',
      'it': 'Contratto utenza a tuo nome',
      'fr': 'Contrat à votre nom',
      'es': 'Contrato a tu nombre',
      'fa': 'قرارداد قبض به نام تو',
      'ar': 'العقد باسمك',
    },
    'medical_equipment_home': {
      'en': 'Life-saving medical equipment at home',
      'it': 'Apparecchiature elettromedicali a casa',
      'fr': 'Équipement médical vital à domicile',
      'es': 'Equipos médicos vitales en casa',
      'fa': 'تجهیزات پزشکی حیاتی در خانه',
      'ar': 'أجهزة طبية منزلية ضرورية للحياة',
    },
    'psychologist_support': {
      'en': 'Need psychologist support',
      'it': 'Hai bisogno di supporto psicologico',
      'fr': 'Besoin de soutien psychologique',
      'es': 'Necesitas apoyo psicológico',
      'fa': 'به حمایت روان‌شناسی نیاز داری',
      'ar': 'تحتاج إلى دعم نفسي',
    },
    'piemonte_school_student': {
      'en': 'School student in Piemonte',
      'it': 'Studente scolastico in Piemonte',
      'fr': 'Élève en Piémont',
      'es': 'Estudiante escolar en Piamonte',
      'fa': 'دانش‌آموز در پیمونته',
      'ar': 'طالب مدرسة في بيمونتي',
    },
    'university_student': {
      'en': 'University student',
      'it': 'Studente universitario',
      'fr': 'Étudiant universitaire',
      'es': 'Estudiante universitario',
      'fa': 'دانشجوی دانشگاه',
      'ar': 'طالب جامعي',
    },
    'behind_on_rent': {
      'en': 'Behind on rent',
      'it': 'In ritardo con l’affitto',
      'fr': 'Retard de loyer',
      'es': 'Atrasado con el alquiler',
      'fa': 'عقب‌افتادگی اجاره',
      'ar': 'متأخر في الإيجار',
    },
    'tax_deductions_interest': {
      'en': 'Interested in home / tax deductions',
      'it': 'Interesse per detrazioni casa / tasse',
      'fr': 'Intérêt pour déductions logement / impôts',
      'es': 'Interés en deducciones de vivienda / impuestos',
      'fa': 'علاقه‌مند به کسرهای مالیاتی خانه',
      'ar': 'مهتم بخصومات السكن / الضرائب',
    },
    'amount_needed_eur': {
      'en': 'Amount needed (EUR)',
      'it': 'Importo necessario (EUR)',
      'fr': 'Montant nécessaire (EUR)',
      'es': 'Importe necesario (EUR)',
      'fa': 'مبلغ موردنیاز (یورو)',
      'ar': 'المبلغ المطلوب (يورو)',
    },
    'study_type': {
      'en': 'Study type',
      'it': 'Tipo di studio',
      'fr': 'Type d’études',
      'es': 'Tipo de estudios',
      'fa': 'نوع تحصیل',
      'ar': 'نوع الدراسة',
    },
    'age': {
      'en': 'Age',
      'it': 'Età',
      'fr': 'Âge',
      'es': 'Edad',
      'fa': 'سن',
      'ar': 'العمر',
    },
    'study_university': {
      'en': 'University',
      'it': 'Università',
      'fr': 'Université',
      'es': 'Universidad',
      'fa': 'دانشگاه',
      'ar': 'جامعة',
    },
    'study_master': {
      'en': 'Master',
      'it': 'Master',
      'fr': 'Master',
      'es': 'Máster',
      'fa': 'مستر',
      'ar': 'ماجستير',
    },
    'study_phd': {
      'en': 'PhD',
      'it': 'Dottorato',
      'fr': 'Doctorat',
      'es': 'Doctorado',
      'fa': 'دکتری',
      'ar': 'دكتوراه',
    },
    'study_its': {
      'en': 'ITS',
      'it': 'ITS',
      'fr': 'ITS',
      'es': 'ITS',
      'fa': 'ITS',
      'ar': 'ITS',
    },
    'study_abroad': {
      'en': 'Abroad',
      'it': 'Estero',
      'fr': 'À l’étranger',
      'es': 'En el extranjero',
      'fa': 'خارج از کشور',
      'ar': 'في الخارج',
    },
    'study_other': {
      'en': 'Other',
      'it': 'Altro',
      'fr': 'Autre',
      'es': 'Otro',
      'fa': 'سایر',
      'ar': 'أخرى',
    },
    'rent_living_costs': {
      'en': 'Need rent / living costs',
      'it': 'Serve coprire affitto / mantenimento',
      'fr': 'Besoin de loyer / frais de vie',
      'es': 'Necesitas alquiler / manutención',
      'fa': 'نیاز به اجاره / هزینه زندگی',
      'ar': 'تحتاج إلى الإيجار / المعيشة',
    },
    'avoid_parent_guarantee': {
      'en': 'Avoid parent guarantee',
      'it': 'Evitare garanzia dei genitori',
      'fr': 'Éviter la garantie des parents',
      'es': 'Evitar aval de los padres',
      'fa': 'بدون ضمانت والدین',
      'ar': 'تجنب ضمان الوالدين',
    },
    'repayment_after_studies': {
      'en': 'Prefer repayment after studies',
      'it': 'Preferisci rimborso dopo gli studi',
      'fr': 'Remboursement après les études',
      'es': 'Prefieres pagar después de estudiar',
      'fa': 'ترجیح بازپرداخت بعد از تحصیل',
      'ar': 'تفضيل السداد بعد الدراسة',
    },
    'partner_agreement': {
      'en': 'University partner agreement',
      'it': 'Accordo con università partner',
      'fr': 'Accord université partenaire',
      'es': 'Convenio con universidad asociada',
      'fa': 'توافق با دانشگاه همکار',
      'ar': 'اتفاقية مع جامعة شريكة',
    },
    'first_home_mortgage': {
      'en': 'First home mortgage',
      'it': 'Mutuo prima casa',
      'fr': 'Prêt première maison',
      'es': 'Hipoteca primera vivienda',
      'fa': 'وام خانه اول',
      'ar': 'قرض المنزل الأول',
    },
    'existing_mortgage_difficulty': {
      'en': 'Existing mortgage difficulty',
      'it': 'Difficoltà con mutuo attivo',
      'fr': 'Difficulté avec prêt en cours',
      'es': 'Dificultad con hipoteca actual',
      'fa': 'مشکل با وام مسکن موجود',
      'ar': 'صعوبة مع قرض قائم',
    },
    'rent_deposit_support': {
      'en': 'Need rent / deposit support',
      'it': 'Serve supporto affitto / cauzione',
      'fr': 'Besoin d’aide loyer / caution',
      'es': 'Necesitas ayuda alquiler / fianza',
      'fa': 'نیاز به کمک اجاره / ودیعه',
      'ar': 'تحتاج إلى دعم الإيجار / الوديعة',
    },
    'level_likely': {
      'en': 'Likely',
      'it': 'Probabile',
      'fr': 'Probable',
      'es': 'Probable',
      'fa': 'احتمال بالا',
      'ar': 'مرجح',
    },
    'level_maybe': {
      'en': 'Maybe',
      'it': 'Possibile',
      'fr': 'Possible',
      'es': 'Posible',
      'fa': 'ممکن',
      'ar': 'محتمل',
    },
    'level_monitor': {
      'en': 'Monitor',
      'it': 'Da monitorare',
      'fr': 'À surveiller',
      'es': 'Vigilar',
      'fa': 'نیاز به پیگیری',
      'ar': 'تحتاج متابعة',
    },
    'level_unlikely': {
      'en': 'Unlikely',
      'it': 'Poco probabile',
      'fr': 'Peu probable',
      'es': 'Poco probable',
      'fa': 'احتمال کم',
      'ar': 'غير مرجح',
    },
  };
  return resolveLocalizedText(
    values[key],
    context.l10n.languageCode,
    fallback: key,
  );
}

Widget _counterRow(
  BuildContext context,
  String label,
  int value,
  void Function(int next) onChanged,
) {
  return Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(
        onPressed: () => onChanged(value - 1),
        icon: const Icon(Icons.remove_circle_outline),
      ),
      Text('$value'),
      IconButton(
        onPressed: () => onChanged(value + 1),
        icon: const Icon(Icons.add_circle_outline),
      ),
    ],
  );
}
