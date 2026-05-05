import 'package:shared_preferences/shared_preferences.dart';
import '../domain/admin_copilot_profile.dart';
import '../domain/admin_request.dart';
import '../domain/attachment_plan.dart';
import '../domain/before_sending_checklist.dart';
import '../domain/city_pack.dart';
import '../domain/community_template.dart';
import '../domain/deadline_watch.dart';
import '../domain/household_contract.dart';
import '../domain/household_member.dart';
import '../domain/life_admin_calendar.dart';
import '../domain/life_admin_client.dart';
import '../domain/life_admin_contact.dart';
import '../domain/life_admin_document.dart';
import '../domain/life_admin_mode.dart';
import '../domain/life_checklist_item.dart';
import '../domain/next_action.dart';
import '../domain/official_link.dart';
import '../domain/proof_folder.dart';
import '../domain/red_flag.dart';
import '../domain/reminder.dart';
import '../domain/request_readiness.dart';
import '../domain/request_status.dart';
import '../domain/situation_scan.dart';
import '../domain/telegram_handoff.dart';
import 'local_storage_list_repository.dart';

class LocalAppLanguageRepository {
  const LocalAppLanguageRepository(this._prefs);

  static const storageKey = 'italy_life_admin_selected_language_v1';
  final SharedPreferences _prefs;

  String read() => _prefs.getString(storageKey) ?? 'en';

  Future<void> save(String languageCode) =>
      _prefs.setString(storageKey, languageCode);
}

class LocalDocumentsRepository {
  const LocalDocumentsRepository(this._repo);
  factory LocalDocumentsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalDocumentsRepository(
        LocalStorageListRepository<LifeAdminDocument>(
          prefs: prefs,
          storageKey: 'italy_life_admin_documents_v1',
          fromJson: LifeAdminDocument.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<LifeAdminDocument> _repo;
  Future<List<LifeAdminDocument>> list() async => _repo.readAll();
  Future<void> save(LifeAdminDocument item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalContactsRepository {
  const LocalContactsRepository(this._repo);
  factory LocalContactsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalContactsRepository(
        LocalStorageListRepository<LifeAdminContact>(
          prefs: prefs,
          storageKey: 'italy_life_admin_contacts_v1',
          fromJson: LifeAdminContact.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<LifeAdminContact> _repo;
  Future<List<LifeAdminContact>> list() async => _repo.readAll();
  Future<void> save(LifeAdminContact item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalContractsRepository {
  const LocalContractsRepository(this._repo);
  factory LocalContractsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalContractsRepository(
        LocalStorageListRepository<HouseholdContract>(
          prefs: prefs,
          storageKey: 'italy_life_admin_household_contracts_v1',
          fromJson: HouseholdContract.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<HouseholdContract> _repo;
  Future<List<HouseholdContract>> list() async => _repo.readAll();
  Future<void> save(HouseholdContract item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalHouseholdRepository {
  const LocalHouseholdRepository(this._repo);
  factory LocalHouseholdRepository.fromPrefs(SharedPreferences prefs) =>
      LocalHouseholdRepository(
        LocalStorageListRepository<HouseholdMember>(
          prefs: prefs,
          storageKey: 'italy_life_admin_household_members_v1',
          fromJson: HouseholdMember.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<HouseholdMember> _repo;
  Future<List<HouseholdMember>> list() async => _repo.readAll();
  Future<void> save(HouseholdMember item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalClientsRepository {
  const LocalClientsRepository(this._repo);
  factory LocalClientsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalClientsRepository(
        LocalStorageListRepository<LifeAdminClient>(
          prefs: prefs,
          storageKey: 'italy_life_admin_clients_v1',
          fromJson: LifeAdminClient.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<LifeAdminClient> _repo;
  Future<List<LifeAdminClient>> list() async => _repo.readAll();
  Future<void> save(LifeAdminClient item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalDeadlinesRepository {
  const LocalDeadlinesRepository(this._repo);
  factory LocalDeadlinesRepository.fromPrefs(SharedPreferences prefs) =>
      LocalDeadlinesRepository(
        LocalStorageListRepository<UserDeadline>(
          prefs: prefs,
          storageKey: 'italy_life_admin_deadlines_v1',
          fromJson: UserDeadline.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<UserDeadline> _repo;
  Future<List<UserDeadline>> list() async => _repo.readAll();
  Future<void> save(UserDeadline item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalTemplatesRepository {
  const LocalTemplatesRepository(this._repo);
  factory LocalTemplatesRepository.fromPrefs(SharedPreferences prefs) =>
      LocalTemplatesRepository(
        LocalStorageListRepository<CommunityTemplate>(
          prefs: prefs,
          storageKey: 'italy_life_admin_templates_v1',
          fromJson: CommunityTemplate.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<CommunityTemplate> _repo;
  Future<List<CommunityTemplate>> list() async => _repo.readAll();
  Future<void> save(CommunityTemplate item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalProofFolderRepository {
  const LocalProofFolderRepository(this._caseRepo, this._itemRepo);
  factory LocalProofFolderRepository.fromPrefs(SharedPreferences prefs) =>
      LocalProofFolderRepository(
        LocalStorageListRepository<ProofCase>(
          prefs: prefs,
          storageKey: 'italy_life_admin_proof_cases_v1',
          fromJson: ProofCase.fromJson,
          toJson: (item) => item.toJson(),
        ),
        LocalStorageListRepository<ProofItem>(
          prefs: prefs,
          storageKey: 'italy_life_admin_proof_items_v1',
          fromJson: ProofItem.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<ProofCase> _caseRepo;
  final LocalStorageListRepository<ProofItem> _itemRepo;
  Future<List<ProofCase>> listCases() async => _caseRepo.readAll();
  Future<List<ProofItem>> listItems() async => _itemRepo.readAll();
  Future<void> saveCase(ProofCase item) async {
    final items = _caseRepo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _caseRepo.writeAll(items);
  }

  Future<void> saveItem(ProofItem item) async {
    final items = _itemRepo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _itemRepo.writeAll(items);
  }
}

class LocalBeforeSendingRepository {
  const LocalBeforeSendingRepository(this._repo);
  factory LocalBeforeSendingRepository.fromPrefs(SharedPreferences prefs) =>
      LocalBeforeSendingRepository(
        LocalStorageListRepository<BeforeSendingChecklist>(
          prefs: prefs,
          storageKey: 'italy_life_admin_before_sending_v1',
          fromJson: BeforeSendingChecklist.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<BeforeSendingChecklist> _repo;
  Future<List<BeforeSendingChecklist>> list() async => _repo.readAll();
  Future<BeforeSendingChecklist?> get(String requestId) async {
    for (final item in _repo.readAll()) {
      if (item.requestId == requestId) return item;
    }
    return null;
  }

  Future<void> save(BeforeSendingChecklist item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.requestId == item.requestId)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalOfficialLinksOverrideRepository {
  const LocalOfficialLinksOverrideRepository(this._repo);
  factory LocalOfficialLinksOverrideRepository.fromPrefs(
    SharedPreferences prefs,
  ) => LocalOfficialLinksOverrideRepository(
    LocalStorageListRepository<OfficialLink>(
      prefs: prefs,
      storageKey: 'italy_life_admin_official_links_overrides_v1',
      fromJson: OfficialLink.fromJson,
      toJson: (item) => item.toJson(),
    ),
  );
  final LocalStorageListRepository<OfficialLink> _repo;
  Future<List<OfficialLink>> list() async => _repo.readAll();
  Future<void> save(OfficialLink item) async {
    final items = _repo.readAll()
      ..removeWhere((it) => it.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

class LocalTelegramHandoffRepository {
  const LocalTelegramHandoffRepository(this._repo);
  factory LocalTelegramHandoffRepository.fromPrefs(SharedPreferences prefs) =>
      LocalTelegramHandoffRepository(
        LocalStorageListRepository<TelegramHandoffPayload>(
          prefs: prefs,
          storageKey: 'italy_life_admin_telegram_handoffs_v1',
          fromJson: TelegramHandoffPayload.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );
  final LocalStorageListRepository<TelegramHandoffPayload> _repo;
  Future<List<TelegramHandoffPayload>> list() async => _repo.readAll();
  Future<void> save(TelegramHandoffPayload item) async {
    final items = _repo.readAll()..add(item);
    await _repo.writeAll(items);
  }
}

class ProfileCompletenessService {
  int score(AdminCopilotProfile profile) => profile.completenessScore;
  List<String> suggestions(AdminCopilotProfile profile) =>
      profile.completenessSuggestions;
}

class ProfileAutofillService {
  Map<String, dynamic> autofill(
    AdminCopilotProfile profile, {
    HouseholdMember? member,
  }) {
    final sourceName = member?.fullName ?? profile.fullName;
    return {
      if ((sourceName ?? '').isNotEmpty) 'fullName': sourceName,
      if ((member?.codiceFiscale ?? profile.codiceFiscale ?? '').isNotEmpty)
        'codiceFiscale': member?.codiceFiscale ?? profile.codiceFiscale,
      if ((profile.email ?? '').isNotEmpty) 'email': profile.email,
      if ((profile.phone ?? '').isNotEmpty) 'phone': profile.phone,
      if ((profile.city ?? '').isNotEmpty) 'city': profile.city,
      if ((profile.address ?? '').isNotEmpty) 'address': profile.address,
      if ((profile.defaultComune ?? '').isNotEmpty)
        'cityOrComune': profile.defaultComune,
      if ((profile.defaultAsl ?? '').isNotEmpty)
        'aslOrOfficeName': profile.defaultAsl,
      if ((profile.universityName ?? '').isNotEmpty)
        'universityName': profile.universityName,
      if ((profile.landlordName ?? '').isNotEmpty)
        'landlordOrAgencyName': profile.landlordName,
    };
  }
}

class CityPackService {
  List<CityPack> all() => const [
    CityPack(
      id: 'torino',
      cityName: 'Torino',
      region: 'Piemonte',
      descriptionLocalized: {
        'en': 'Useful workflows for Turin life admin.',
        'it': 'Workflow utili per la vita amministrativa a Torino.',
      },
      recommendedProcedures: [
        'COMUNE_RESIDENCE_REQUEST',
        'CHANGE_DOCTOR',
        'ELECTRICITY_GAS_SWITCH_REQUEST',
        'UNIVERSITY_OFFICE_REQUEST',
      ],
      commonTopics: ['residenza', 'doctor', 'utilities', 'student housing'],
      officialLinks: ['Verify Comune di Torino official website'],
      localNotes: ['Verify official addresses before sending.'],
      studentTips: ['Check university enrollment and rent paperwork.'],
      tenantTips: ['Keep landlord and contract proof ready.'],
      utilityTips: ['Prepare POD/PDR and last bill before switching.'],
      healthTips: ['Verify ASL and doctor change channels.'],
      universityTips: ['Use the university office workflow for fees and ISEE.'],
      warnings: ['Always verify the official office website first.'],
      isActive: true,
    ),
    CityPack(
      id: 'milano',
      cityName: 'Milano',
      region: 'Lombardia',
      descriptionLocalized: {
        'en': 'Useful workflows for Milan.',
        'it': 'Workflow utili per Milano.',
      },
      recommendedProcedures: [
        'COMUNE_RESIDENCE_REQUEST',
        'RENTAL_CONTRACT_CHANGE',
      ],
      commonTopics: ['housing', 'residence', 'utilities'],
      officialLinks: ['Verify Comune di Milano official website'],
      localNotes: ['Double-check office instructions on official channels.'],
      studentTips: ['Keep enrollment and rent documents ready.'],
      tenantTips: ['Track deposit and repair evidence.'],
      utilityTips: ['Check bill details before switching.'],
      healthTips: ['Verify your regional ASL path.'],
      universityTips: ['Use university office requests for admin issues.'],
      warnings: ['Verify official instructions first.'],
      isActive: true,
    ),
    CityPack(
      id: 'roma',
      cityName: 'Roma',
      region: 'Lazio',
      descriptionLocalized: {
        'en': 'Useful workflows for Rome.',
        'it': 'Workflow utili per Roma.',
      },
      recommendedProcedures: [
        'COMUNE_RESIDENCE_REQUEST',
        'TESSERA_SANITARIA_RENEWAL',
      ],
      commonTopics: ['residence', 'health card', 'rent'],
      officialLinks: ['Verify Roma Capitale official website'],
      localNotes: ['Keep protocol numbers if available.'],
      studentTips: ['Check university and scholarship deadlines.'],
      tenantTips: ['Keep repair and contract evidence.'],
      utilityTips: ['Verify provider terms before switching.'],
      healthTips: ['Check ASL channels before sending.'],
      universityTips: ['Use the university workflow for corrections.'],
      warnings: ['Verify official channels before sending.'],
      isActive: true,
    ),
    CityPack(
      id: 'bologna',
      cityName: 'Bologna',
      region: 'Emilia-Romagna',
      descriptionLocalized: {
        'en': 'Useful workflows for Bologna.',
        'it': 'Workflow utili per Bologna.',
      },
      recommendedProcedures: [
        'UNIVERSITY_OFFICE_REQUEST',
        'COMUNE_RESIDENCE_REQUEST',
      ],
      commonTopics: ['university', 'residence'],
      officialLinks: ['Verify Comune di Bologna official website'],
      localNotes: ['Review official instructions first.'],
      studentTips: ['Track deadlines for enrollment and ISEE.'],
      tenantTips: ['Keep lease and deposit proof ready.'],
      utilityTips: ['Keep bills and provider notes ready.'],
      healthTips: ['Verify health office channels first.'],
      universityTips: ['Use university admin templates for corrections.'],
      warnings: ['Verify official links before sending.'],
      isActive: true,
    ),
    CityPack(
      id: 'firenze',
      cityName: 'Firenze',
      region: 'Toscana',
      descriptionLocalized: {
        'en': 'Useful workflows for Florence.',
        'it': 'Workflow utili per Firenze.',
      },
      recommendedProcedures: [
        'COMUNE_RESIDENCE_REQUEST',
        'INTERNET_PHONE_CANCELLATION',
      ],
      commonTopics: ['residence', 'utilities', 'telecom'],
      officialLinks: ['Verify Comune di Firenze official website'],
      localNotes: ['Verify office and provider details first.'],
      studentTips: ['Track student deadlines and rent papers.'],
      tenantTips: ['Keep landlord messages in proof folder.'],
      utilityTips: ['Review current offer conditions.'],
      healthTips: ['Verify Tuscany health office instructions.'],
      universityTips: ['Use university templates if enrolled locally.'],
      warnings: ['Official verification required.'],
      isActive: true,
    ),
    CityPack(
      id: 'napoli',
      cityName: 'Napoli',
      region: 'Campania',
      descriptionLocalized: {
        'en': 'Useful workflows for Naples.',
        'it': 'Workflow utili per Napoli.',
      },
      recommendedProcedures: ['CHANGE_DOCTOR', 'COMUNE_RESIDENCE_REQUEST'],
      commonTopics: ['ASL', 'residence', 'housing'],
      officialLinks: ['Verify Comune di Napoli official website'],
      localNotes: ['Keep document proof and office names ready.'],
      studentTips: ['Track university and housing documents.'],
      tenantTips: ['Save repair proof and rent papers.'],
      utilityTips: ['Verify tariffs before changing provider.'],
      healthTips: ['Check local ASL channels before sending.'],
      universityTips: ['Use admin requests for corrections and fees.'],
      warnings: ['Verify the official website before sending.'],
      isActive: true,
    ),
  ];
}

class ItalyLifeChecklistService {
  List<LifeChecklistItem> itemsForMode(LifeAdminMode mode) {
    final base = <LifeChecklistItem>[
      _item(
        'cf',
        'Identity & access',
        'Codice fiscale',
        ['CHANGE_DOCTOR'],
        ['codiceFiscale'],
      ),
      _item('spid', 'Identity & access', 'SPID / CIE', [
        'GENERIC_FORMAL_REQUEST',
      ], const []),
      _item(
        'health_card',
        'Health',
        'Tessera sanitaria',
        ['TESSERA_SANITARIA_RENEWAL'],
        ['tesseraSanitaria'],
      ),
      _item('doctor', 'Health', 'Medico di base', ['CHANGE_DOCTOR'], const []),
      _item('residence', 'Comune', 'Residenza', [
        'COMUNE_RESIDENCE_REQUEST',
      ], const []),
      _item(
        'utility',
        'Money & bills',
        'Utility providers reviewed',
        ['ENERGY_SUPPLIER_COMPARISON'],
        ['billElectricity'],
      ),
    ];
    if (mode == LifeAdminMode.student) {
      return [
        ...base,
        _item(
          'university',
          'Student',
          'University enrollment',
          ['UNIVERSITY_OFFICE_REQUEST'],
          ['universityEnrollment'],
        ),
        _item(
          'isee',
          'Student',
          'ISEE',
          ['UNIVERSITY_OFFICE_REQUEST'],
          ['isee'],
        ),
        _item(
          'rent',
          'Housing',
          'Rental contract',
          ['RENTAL_CONTRACT_CHANGE'],
          ['rentalContract'],
        ),
      ];
    }
    if (mode == LifeAdminMode.tenant) {
      return [
        ...base,
        _item(
          'contract',
          'Housing',
          'Rental contract',
          ['RENTAL_CONTRACT_CHANGE'],
          ['rentalContract'],
        ),
        _item(
          'deposit',
          'Housing',
          'Deposit proof',
          ['DEPOSIT_RETURN_REQUEST'],
          ['paymentReceipt'],
        ),
        _item('landlord', 'Housing', 'Landlord contact', [
          'LANDLORD_MAINTENANCE_OR_CONTRACT',
        ], const []),
        _item(
          'utilities',
          'Housing',
          'Utilities setup',
          ['VOLTURA_REQUEST'],
          ['billElectricity'],
        ),
      ];
    }
    return base;
  }

  int progress(List<LifeChecklistItem> items) {
    if (items.isEmpty) return 0;
    final done = items
        .where((item) => item.status == LifeChecklistStatus.done)
        .length;
    return ((done / items.length) * 100).round();
  }

  LifeChecklistItem _item(
    String id,
    String category,
    String title,
    List<String> relatedProcedureIds,
    List<String> relatedDocumentTypes,
  ) {
    return LifeChecklistItem(
      id: id,
      category: category,
      title: title,
      descriptionLocalized: {
        'en': title,
        'it': title,
        'es': title,
        'fa': title,
        'ar': title,
      },
      status: LifeChecklistStatus.notStarted,
      relatedProcedureIds: relatedProcedureIds,
      relatedDocumentTypes: relatedDocumentTypes,
      priority: 1,
    );
  }
}

class SituationScannerService {
  SituationScanResult scan(String text, {required String languageCode}) {
    final input = text.toLowerCase();
    final categories = <SituationDetectedCategory>[];
    final procedures = <String>[];
    final risks = <SituationDetectedRisk>[];
    final documents = <String>[];
    final deadlines = <String>[];
    final nextActions = <String>[];
    final contacts = <String>[];

    void addCategory(String id, String label) {
      if (categories.any((item) => item.id == id)) return;
      categories.add(SituationDetectedCategory(id: id, localizedName: label));
    }

    if (_containsAny(input, [
      'landlord',
      'rent',
      'deposit',
      'affitto',
      'cauzione',
      'موجر',
      'اجاره',
      'alquiler',
    ])) {
      addCategory('housing', _localized('Housing issue', languageCode));
      procedures.addAll([
        'DEPOSIT_RETURN_REQUEST',
        'LANDLORD_MAINTENANCE_OR_CONTRACT',
      ]);
      documents.addAll(['rental contract', 'previous messages', 'photos']);
      contacts.add('landlord');
    }
    if (_containsAny(input, [
      'electricity',
      'gas',
      'bill',
      'bolletta',
      'luce',
      'غاز',
      'كهرباء',
      'برق',
      'gas bill',
      'fattura',
      'luz',
    ])) {
      addCategory('utilities', _localized('Utilities issue', languageCode));
      procedures.addAll([
        'HIGH_BILL_COMPLAINT',
        'ENERGY_BILL_ANALYZER_CHECKLIST',
      ]);
      documents.addAll(['bill copy', 'previous bill', 'meter photo']);
      contacts.add('provider');
    }
    if (_containsAny(input, ['canone rai', 'tv', 'televisione', 'rai'])) {
      addCategory('canone_rai', _localized('Canone RAI', languageCode));
      procedures.addAll([
        'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
        'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      ]);
      documents.addAll(['electricity bill', 'proof of payment']);
      if (_containsAny(input, ['no tv', 'no television']) &&
          _containsAny(input, ['have tv', 'i have tv'])) {
        risks.add(
          SituationDetectedRisk(
            id: 'false_declaration',
            localizedMessage: _localized(
              'Possible false declaration risk detected.',
              languageCode,
            ),
            severity: 3,
          ),
        );
      }
    }
    if (_containsAny(input, [
      'asl',
      'doctor',
      'medico',
      'tessera sanitaria',
      'health card',
      'پزشک',
      'طبيب',
    ])) {
      addCategory('health', _localized('Health / ASL', languageCode));
      procedures.addAll(['CHANGE_DOCTOR', 'TESSERA_SANITARIA_RENEWAL']);
      documents.addAll(['ID', 'codice fiscale', 'health card']);
      contacts.add('ASL');
    }
    if (_containsAny(input, ['rejected', 'rejection', 'rigett', 'رفض'])) {
      addCategory(
        'rejected_request',
        _localized('Rejected request', languageCode),
      );
      procedures.addAll([
        'REJECTED_REQUEST_REPLY',
        'ASL_REJECTED_REQUEST_REPLY',
      ]);
      documents.addAll(['rejection notice', 'missing document']);
    }
    if (_containsAny(input, [
      'internet',
      'modem',
      'telecom',
      'إلغاء الإنترنت',
      'کنسلی اینترنت',
    ])) {
      addCategory('telecom', _localized('Telecom issue', languageCode));
      procedures.addAll([
        'INTERNET_PHONE_CANCELLATION',
        'MODEM_RETURN_OR_CHARGE_DISPUTE',
      ]);
      documents.addAll(['invoice', 'cancellation proof', 'screenshots']);
      contacts.add('provider support');
    }
    if (_containsAny(input, ['residenza', 'comune', 'anagrafe'])) {
      addCategory('comune', _localized('Residence / Comune', languageCode));
      procedures.add('COMUNE_RESIDENCE_REQUEST');
      documents.addAll(['ID', 'rental contract', 'previous protocol']);
      contacts.add('Comune');
    }
    if (_containsAny(input, [
      'university',
      'scholarship',
      'isee',
      'università',
      'دانشگاه',
      'جامعة',
    ])) {
      addCategory('university', _localized('University', languageCode));
      procedures.add('UNIVERSITY_OFFICE_REQUEST');
      documents.addAll(['student ID', 'ISEE', 'enrollment proof']);
      contacts.add('University office');
    }
    if (_containsAny(input, [
      'naspi',
      'patronato',
      'unemployment',
      'disoccupazione',
      'بیکاری',
      'بطالة',
    ])) {
      addCategory('work', _localized('Work / INPS', languageCode));
      procedures.addAll(['NASPI_PREPARATION', 'PATRONATO_APPOINTMENT_REQUEST']);
      documents.addAll(['termination letter', 'payslips']);
      contacts.add('Patronato');
    }

    if (_containsAny(input, [
      'urgent',
      'deadline',
      'scadenza',
      'urgent deadline',
    ])) {
      deadlines.add(
        _localized('Check if an urgent deadline applies.', languageCode),
      );
      risks.add(
        SituationDetectedRisk(
          id: 'deadline',
          localizedMessage: _localized(
            'Urgent deadline risk detected.',
            languageCode,
          ),
          severity: 2,
        ),
      );
    }
    if (_containsAny(input, ['eviction', 'sfratto', 'court', 'tribunale'])) {
      risks.add(
        SituationDetectedRisk(
          id: 'legal',
          localizedMessage: _localized(
            'This may require professional legal advice.',
            languageCode,
          ),
          severity: 3,
        ),
      );
    }
    if (_containsAny(input, ['medical emergency', 'emergenza medica'])) {
      risks.add(
        SituationDetectedRisk(
          id: 'medical',
          localizedMessage: _localized(
            'Medical emergency language detected. Contact the competent service urgently.',
            languageCode,
          ),
          severity: 3,
        ),
      );
    }

    if (procedures.isEmpty) {
      procedures.add('GENERIC_FORMAL_REQUEST');
      nextActions.add(
        _localized(
          'Use the generic formal request as a fallback.',
          languageCode,
        ),
      );
    } else {
      nextActions.add(
        _localized(
          'Open the most relevant workflow and review attachments.',
          languageCode,
        ),
      );
    }

    return SituationScanResult(
      detectedCategories: categories,
      recommendedProcedures: procedures.toSet().toList(),
      detectedRisks: risks,
      suggestedDocuments: documents.toSet().toList(),
      suggestedDeadlines: deadlines,
      suggestedNextActions: nextActions,
      suggestedContacts: contacts.toSet().toList(),
      explanationLocalized: _localized(
        'The app scanned your situation locally and matched it to likely categories, documents, and next steps.',
        languageCode,
      ),
      confidence: categories.isEmpty
          ? 0.25
          : (0.5 + (categories.length * 0.1)).clamp(0.5, 0.92),
      requiresProfessionalAdvice: risks.any((item) => item.severity >= 3),
      safetyWarning: risks.isEmpty
          ? null
          : _localized(
              'Review warnings carefully before sending anything official.',
              languageCode,
            ),
    );
  }

  bool _containsAny(String input, List<String> tokens) =>
      tokens.any((token) => input.contains(token.toLowerCase()));

  String _localized(String text, String languageCode) {
    switch (languageCode) {
      case 'it':
        return text
            .replaceAll('Housing issue', 'Problema abitativo')
            .replaceAll('Utilities issue', 'Problema utenze')
            .replaceAll('Health / ASL', 'Salute / ASL')
            .replaceAll('Rejected request', 'Richiesta respinta')
            .replaceAll('Telecom issue', 'Problema telecom')
            .replaceAll('Residence / Comune', 'Residenza / Comune')
            .replaceAll('University', 'Università')
            .replaceAll('Work / INPS', 'Lavoro / INPS')
            .replaceAll(
              'The app scanned your situation locally and matched it to likely categories, documents, and next steps.',
              'L’app ha analizzato localmente la tua situazione e l’ha collegata a categorie, documenti e prossimi passi probabili.',
            )
            .replaceAll(
              'Open the most relevant workflow and review attachments.',
              'Apri il workflow più rilevante e controlla gli allegati.',
            )
            .replaceAll(
              'Use the generic formal request as a fallback.',
              'Usa la richiesta formale generica come fallback.',
            )
            .replaceAll(
              'Review warnings carefully before sending anything official.',
              'Controlla attentamente gli avvisi prima di inviare qualcosa di ufficiale.',
            )
            .replaceAll(
              'Possible false declaration risk detected.',
              'Possibile rischio di dichiarazione falsa rilevato.',
            )
            .replaceAll(
              'Urgent deadline risk detected.',
              'Rilevato possibile rischio di scadenza urgente.',
            )
            .replaceAll(
              'This may require professional legal advice.',
              'Questo caso potrebbe richiedere consulenza legale professionale.',
            )
            .replaceAll(
              'Medical emergency language detected. Contact the competent service urgently.',
              'Rilevato linguaggio da emergenza medica. Contatta urgentemente il servizio competente.',
            )
            .replaceAll(
              'Check if an urgent deadline applies.',
              'Verifica se è presente una scadenza urgente.',
            );
      case 'es':
        return text
            .replaceAll('Housing issue', 'Problema de vivienda')
            .replaceAll('Utilities issue', 'Problema de suministros')
            .replaceAll('Health / ASL', 'Salud / ASL')
            .replaceAll('University', 'Universidad');
      case 'fa':
        return text
            .replaceAll('Housing issue', 'مشکل مسکن')
            .replaceAll('Utilities issue', 'مشکل قبوض و خدمات')
            .replaceAll('Health / ASL', 'سلامت / ASL')
            .replaceAll('University', 'دانشگاه');
      case 'ar':
        return text
            .replaceAll('Housing issue', 'مشكلة سكن')
            .replaceAll('Utilities issue', 'مشكلة مرافق')
            .replaceAll('Health / ASL', 'الصحة / ASL')
            .replaceAll('University', 'الجامعة');
      default:
        return text;
    }
  }
}

class AttachmentRequirementEngine {
  AttachmentPlan build({
    required String procedureId,
    required List<String> availableDocuments,
  }) {
    final required = <AttachmentRequirement>[];
    final recommended = <AttachmentRequirement>[];
    final proofItems = <String>[];

    if (procedureId == 'HIGH_BILL_COMPLAINT') {
      required.addAll([
        const AttachmentRequirement(
          title: 'Bill copy',
          description: 'Current bill PDF or clear photo',
          required: true,
        ),
        const AttachmentRequirement(
          title: 'Previous bill',
          description: 'Useful comparison bill',
          required: true,
        ),
      ]);
      recommended.addAll([
        const AttachmentRequirement(
          title: 'Meter reading photo',
          description: 'Photo of the current meter reading',
          required: false,
        ),
        const AttachmentRequirement(
          title: 'Contract conditions',
          description: 'Offer summary or tariff conditions',
          required: false,
        ),
      ]);
      proofItems.addAll([
        'provider screenshots',
        'payment proof if already paid',
      ]);
    } else if (procedureId == 'ASL_REJECTED_REQUEST_REPLY') {
      required.addAll([
        const AttachmentRequirement(
          title: 'Rejection notice',
          description: 'Previous rejection message',
          required: true,
        ),
        const AttachmentRequirement(
          title: 'Missing document now attached',
          description: 'The document that was missing before',
          required: true,
        ),
      ]);
      recommended.addAll([
        const AttachmentRequirement(
          title: 'ID',
          description: 'Identity document',
          required: false,
        ),
        const AttachmentRequirement(
          title: 'Codice fiscale',
          description: 'Tax code document',
          required: false,
        ),
        const AttachmentRequirement(
          title: 'Health card',
          description: 'Tessera sanitaria',
          required: false,
        ),
      ]);
      proofItems.add('previous receipt/protocol');
    } else {
      required.add(
        const AttachmentRequirement(
          title: 'Core supporting documents',
          description: 'Prepare the main documents relevant to the case.',
          required: true,
        ),
      );
    }

    final missingCritical = required
        .where(
          (item) => !availableDocuments.any(
            (doc) => doc.toLowerCase().contains(item.title.toLowerCase()),
          ),
        )
        .map((item) => item.title)
        .toList();
    final readiness = required.isEmpty
        ? 80
        : (((required.length - missingCritical.length) / required.length) * 100)
              .round();

    return AttachmentPlan(
      requiredAttachments: required,
      recommendedAttachments: recommended,
      optionalAttachments: const [],
      proofItems: proofItems,
      missingCriticalItems: missingCritical,
      readinessScore: readiness,
      warnings: missingCritical.isEmpty
          ? const []
          : ['Some critical supporting items are still missing.'],
      nextSteps: const [
        'Verify which attachments are mandatory on the official source.',
        'Keep copies of what you send for your records.',
      ],
    );
  }
}

class RequestReadinessService {
  RequestReadiness calculate({
    required AdminCopilotRequest request,
    required List<RedFlag> redFlags,
  }) {
    var score = 100;
    final missingRequiredFields = <String>[];
    final missingAttachments = <String>[];
    final warnings = <String>[];

    if ((request.recipientEmail ??
            request.recipientPec ??
            request.recipientName ??
            '')
        .isEmpty) {
      score -= 20;
      missingRequiredFields.add('recipient');
    }
    if (request.subject.trim().isEmpty) {
      score -= 15;
      missingRequiredFields.add('subject');
    }
    final checked = request.generatedPack.attachmentChecklist
        .where((item) => item.userHasIt)
        .length;
    if (checked == 0 && request.generatedPack.attachmentChecklist.isNotEmpty) {
      score -= 20;
      missingAttachments.addAll(
        request.generatedPack.attachmentChecklist.map((item) => item.name),
      );
    }
    if (!request.generatedPack.fullText.contains('Questo strumento')) {
      score -= 15;
      warnings.add('Mandatory disclaimer missing.');
    }
    if (redFlags.isNotEmpty) {
      score -= redFlags.length * 10;
      warnings.addAll(redFlags.map((item) => item.message));
    }
    score = score.clamp(0, 100);
    final level = score >= 90
        ? RequestReadinessLevel.ready
        : score >= 70
        ? RequestReadinessLevel.high
        : score >= 40
        ? RequestReadinessLevel.medium
        : RequestReadinessLevel.low;
    return RequestReadiness(
      score: score,
      level: level,
      missingRequiredFields: missingRequiredFields,
      missingRecommendedAttachments: missingAttachments,
      warnings: warnings,
      nextBestAction: missingRequiredFields.contains('recipient')
          ? 'Verify the official recipient address before sending.'
          : missingAttachments.isNotEmpty
          ? 'Prepare the missing supporting documents.'
          : 'Review the draft one last time and send it.',
    );
  }
}

class NextActionService {
  NextAction fromRequest(AdminCopilotRequest request) {
    if (request.status == RequestStatus.generated) {
      return const NextAction(
        title: 'Send or copy the email',
        description:
            'Review the draft and send it after verifying the recipient.',
        actionType: 'send',
        relatedRoute: '/life-admin/generated',
        priority: 3,
      );
    }
    if (request.status == RequestStatus.sent) {
      return const NextAction(
        title: 'Wait for reply or set follow-up',
        description: 'Prepare a follow-up if no reply arrives soon.',
        actionType: 'follow_up_wait',
        relatedRoute: '/life-admin/requests',
        priority: 2,
      );
    }
    if (request.status == RequestStatus.rejected) {
      return const NextAction(
        title: 'Prepare a reply to rejection',
        description: 'Collect the missing proof and respond formally.',
        actionType: 'rejected_reply',
        relatedRoute: '/life-admin/procedures',
        priority: 4,
      );
    }
    return const NextAction(
      title: 'Review request status',
      description: 'Keep the timeline and reminders updated.',
      actionType: 'review',
      relatedRoute: '/life-admin/requests',
      priority: 1,
    );
  }
}

class LifeAdminCalendarService {
  List<LifeAdminCalendarItem> build({
    required List<Reminder> reminders,
    required List<LifeAdminDocument> documents,
    required List<HouseholdContract> contracts,
    required List<UserDeadline> deadlines,
  }) {
    final items = <LifeAdminCalendarItem>[
      ...reminders.map(
        (item) => LifeAdminCalendarItem(
          id: item.id,
          type: LifeAdminCalendarType.reminder,
          title: item.title,
          description: 'Request reminder',
          date: item.reminderDate,
          relatedRequestId: item.requestId,
          isDone: item.isDone,
          priority: CalendarPriority.normal,
        ),
      ),
      ...documents
          .where((item) => item.expiryDate != null)
          .map(
            (item) => LifeAdminCalendarItem(
              id: item.id,
              type: LifeAdminCalendarType.documentExpiry,
              title: '${item.title} expiry',
              description: item.description,
              date: item.expiryDate!,
              relatedDocumentId: item.id,
              isDone: false,
              priority: CalendarPriority.high,
            ),
          ),
      ...contracts
          .where((item) => item.renewalDate != null)
          .map(
            (item) => LifeAdminCalendarItem(
              id: item.id,
              type: LifeAdminCalendarType.utilityRenewal,
              title: '${item.providerName} renewal',
              description: item.contractName,
              date: item.renewalDate!,
              isDone: false,
              priority: CalendarPriority.normal,
            ),
          ),
      ...deadlines.map(
        (item) => LifeAdminCalendarItem(
          id: item.id,
          type: LifeAdminCalendarType.custom,
          title: item.title,
          description: item.category,
          date: item.date,
          relatedRequestId: item.relatedRequestId,
          relatedDocumentId: item.relatedDocumentId,
          isDone: item.isDone,
          priority: CalendarPriority.normal,
        ),
      ),
    ];
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }
}

class CostInsight {
  const CostInsight({
    required this.title,
    required this.description,
    this.relatedContractId,
    this.actionProcedureId,
    required this.severity,
    this.estimatedSaving,
    required this.confidence,
  });

  final String title;
  final String description;
  final String? relatedContractId;
  final String? actionProcedureId;
  final int severity;
  final double? estimatedSaving;
  final double confidence;
}

class CostInsightService {
  double monthlyTotal(List<HouseholdContract> contracts) => contracts.fold(
    0,
    (sum, item) => sum + (item.monthlyCost ?? ((item.annualCost ?? 0) / 12)),
  );

  double annualTotal(List<HouseholdContract> contracts) => contracts.fold(
    0,
    (sum, item) => sum + (item.annualCost ?? ((item.monthlyCost ?? 0) * 12)),
  );

  List<CostInsight> insights(List<HouseholdContract> contracts) {
    final result = <CostInsight>[];
    for (final contract in contracts) {
      if ((contract.monthlyCost ?? 0) > 60 &&
          (contract.type == HouseholdContractType.internet ||
              contract.type == HouseholdContractType.mobile)) {
        result.add(
          CostInsight(
            title: 'Possible saving opportunity',
            description:
                'This ${contract.type.name} contract looks relatively expensive. Review options before renewal.',
            relatedContractId: contract.id,
            actionProcedureId: 'INTERNET_PHONE_CANCELLATION',
            severity: 2,
            confidence: 0.55,
          ),
        );
      }
    }
    return result;
  }
}

class TelegramHandoffService {
  TelegramHandoffPayload build({
    required String procedureId,
    required String title,
    required String language,
  }) {
    return TelegramHandoffPayload(
      procedureId: procedureId,
      title: title,
      summary: 'I created a $title pack in Italy Life Admin Copilot.',
      language: language,
      suggestedInput: '/start ${procedureId.toLowerCase()}',
      createdAt: DateTime.now(),
    );
  }
}

class OfficialLinksDirectoryService {
  List<OfficialLink> builtIns() => const [
    OfficialLink(
      id: 'agenzia_entrate',
      title: 'Agenzia Entrate',
      category: 'Taxes',
      descriptionLocalized: {
        'en': 'Official tax and Canone RAI reference.',
        'it': 'Riferimento ufficiale fiscale e Canone RAI.',
      },
      url: 'https://www.agenziaentrate.gov.it/',
      country: 'Italy',
      relatedProcedureIds: [
        'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
        'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      ],
      verificationStatus: OfficialLinkVerificationStatus.verified,
      warningLocalized: {
        'en': 'Verify the exact page before using it.',
        'it': 'Verifica la pagina esatta prima di usarla.',
      },
    ),
    OfficialLink(
      id: 'arera_portale_offerte',
      title: 'ARERA / Portale Offerte',
      category: 'Utilities',
      descriptionLocalized: {
        'en': 'Official comparison reference for energy offers.',
        'it': 'Riferimento ufficiale per il confronto delle offerte energia.',
      },
      url: 'https://www.ilportaleofferte.it/',
      country: 'Italy',
      relatedProcedureIds: ['ENERGY_SUPPLIER_COMPARISON'],
      verificationStatus: OfficialLinkVerificationStatus.verified,
      warningLocalized: {
        'en': 'Verify official comparison conditions directly on the portal.',
        'it': 'Verifica direttamente sul portale le condizioni ufficiali.',
      },
    ),
    OfficialLink(
      id: 'generic_comune_search',
      title: 'Comune official search',
      category: 'Comune',
      descriptionLocalized: {
        'en': 'Use the official Comune website for your city.',
        'it': 'Usa il sito ufficiale del Comune della tua città.',
      },
      url: 'https://www.comune.italia.it/',
      country: 'Italy',
      relatedProcedureIds: ['COMUNE_RESIDENCE_REQUEST'],
      verificationStatus: OfficialLinkVerificationStatus.needsReview,
      warningLocalized: {
        'en': 'Placeholder reference. Verify the exact city website.',
        'it': 'Riferimento segnaposto. Verifica il sito esatto del Comune.',
      },
    ),
  ];
}

class LocalizationInspectorService {
  List<String> missingKeys(Map<String, Map<String, String>> localizedValues) {
    final english = localizedValues['en'] ?? const {};
    final missing = <String>[];
    for (final locale in localizedValues.keys) {
      if (locale == 'en') continue;
      for (final key in english.keys) {
        if (!(localizedValues[locale]?.containsKey(key) ?? false)) {
          missing.add('$locale:$key');
        }
      }
    }
    return missing;
  }
}
