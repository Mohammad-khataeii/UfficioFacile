import 'package:uuid/uuid.dart';

import '../domain/admin_copilot_profile.dart';
import '../domain/admin_request.dart';
import '../domain/community_template.dart';
import '../domain/household_contract.dart';
import '../domain/household_member.dart';
import '../domain/life_admin_client.dart';
import '../domain/life_admin_contact.dart';
import '../domain/life_admin_document.dart';
import '../domain/proof_folder.dart';
import '../domain/reminder.dart';
import '../domain/request_status.dart';
import '../domain/utility_comparison.dart';
import '../domain/utility_offer.dart';
import 'pack_generator.dart';
import 'procedure_definitions.dart';

class DemoDataBundle {
  const DemoDataBundle({
    required this.requests,
    required this.reminders,
    required this.profile,
    required this.utilityComparisonInput,
    required this.documents,
    required this.contacts,
    required this.contracts,
    required this.householdMembers,
    required this.clients,
    required this.proofCases,
    required this.templates,
  });

  final List<AdminCopilotRequest> requests;
  final List<Reminder> reminders;
  final AdminCopilotProfile profile;
  final UtilityComparisonInput utilityComparisonInput;
  final List<LifeAdminDocument> documents;
  final List<LifeAdminContact> contacts;
  final List<HouseholdContract> contracts;
  final List<HouseholdMember> householdMembers;
  final List<LifeAdminClient> clients;
  final List<ProofCase> proofCases;
  final List<CommunityTemplate> templates;
}

class DemoDataService {
  DemoDataBundle build() {
    final uuid = const Uuid();
    final requestIds = [
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'HIGH_BILL_COMPLAINT',
      'CHANGE_DOCTOR',
      'LANDLORD_MAINTENANCE_OR_CONTRACT',
      'INTERNET_PHONE_CANCELLATION',
      'NASPI_PREPARATION',
    ];
    final requests = <AdminCopilotRequest>[];
    for (final procedureId in requestIds) {
      final procedure = ItalyAdminProcedureDefinitions.byId(procedureId);
      if (procedure == null) continue;
      final input = {
        'fullName': 'Mario Rossi',
        'senderName': 'Mario Rossi',
        'codiceFiscale': 'RSSMRA80A01H501U',
        'city': 'Torino',
        'email': 'mario.rossi@example.com',
        'reason': 'demo request',
        'provider': 'Demo Provider',
        'recipient': 'Demo Office',
        'landlordOrAgencyName': 'Casa Torino SRL',
        'propertyAddress': 'Via Roma 10, Torino',
        'issueType': 'Heating problem',
      };
      final pack = PackGenerator.generate(
        procedure: procedure,
        inputData: input,
      );
      final requestId = uuid.v4();
      final request = AdminCopilotRequest(
        id: requestId,
        procedureId: procedure.id,
        procedureTitle: procedure.title,
        category: procedure.category.name,
        status: RequestStatus.generated,
        priority: RequestPriority.normal,
        inputData: input,
        generatedPack: pack.copyWith(updatedAt: DateTime.now()),
        subject: pack.subject,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reminders: [],
      );
      requests.add(request);
    }
    final reminders = [
      Reminder(
        id: uuid.v4(),
        requestId: requests.first.id,
        title: 'Follow up in 7 days',
        reminderDate: DateTime.now().add(const Duration(days: 7)),
        type: ReminderType.followUp,
        isDone: false,
        createdAt: DateTime.now(),
      ),
      Reminder(
        id: uuid.v4(),
        requestId: requests[1].id,
        title: 'Bill deadline in 14 days',
        reminderDate: DateTime.now().add(const Duration(days: 14)),
        type: ReminderType.deadline,
        isDone: false,
        createdAt: DateTime.now(),
      ),
      Reminder(
        id: uuid.v4(),
        requestId: requests.last.id,
        title: 'Appointment reminder in 3 days',
        reminderDate: DateTime.now().add(const Duration(days: 3)),
        type: ReminderType.appointment,
        isDone: false,
        createdAt: DateTime.now(),
      ),
    ];

    return DemoDataBundle(
      requests: requests,
      reminders: reminders,
      profile: const AdminCopilotProfile(
        fullName: 'Mario Rossi',
        codiceFiscale: 'RSSMRA80A01H501U',
        city: 'Torino',
        email: 'mario.rossi@example.com',
        selectedCityPackId: 'torino',
        activeMode: 'student',
      ),
      documents: [
        LifeAdminDocument(
          id: uuid.v4(),
          type: LifeAdminDocumentType.identityCardPassport,
          title: 'Demo carta identita',
          description: 'Safe demo identity record',
          hasDocument: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LifeAdminDocument(
          id: uuid.v4(),
          type: LifeAdminDocumentType.codiceFiscale,
          title: 'Demo codice fiscale',
          description: 'Safe demo tax code record',
          hasDocument: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LifeAdminDocument(
          id: uuid.v4(),
          type: LifeAdminDocumentType.billElectricity,
          title: 'Demo electricity bill',
          description: 'Safe demo utility bill',
          hasDocument: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      contacts: [
        LifeAdminContact(
          id: uuid.v4(),
          type: LifeAdminContactType.landlord,
          name: 'Demo Landlord',
          email: 'landlord-demo@example.invalid',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LifeAdminContact(
          id: uuid.v4(),
          type: LifeAdminContactType.utilityProvider,
          name: 'Demo Utility Provider',
          email: 'support-demo@example.invalid',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      contracts: [
        HouseholdContract(
          id: uuid.v4(),
          type: HouseholdContractType.electricity,
          providerName: 'Demo Energia',
          contractName: 'Casa Luce',
          monthlyCost: 70,
          annualCost: 840,
          renewalDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HouseholdContract(
          id: uuid.v4(),
          type: HouseholdContractType.internet,
          providerName: 'Demo Fibra',
          contractName: 'Fibra Max',
          monthlyCost: 35,
          annualCost: 420,
          renewalDate: DateTime.now().add(const Duration(days: 45)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      householdMembers: [
        HouseholdMember(
          id: uuid.v4(),
          displayName: 'Mario Rossi',
          relationship: HouseholdRelationship.self,
          fullName: 'Mario Rossi',
          codiceFiscale: 'RSSMRA80A01H501U',
          isPrimary: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HouseholdMember(
          id: uuid.v4(),
          displayName: 'Demo Roommate',
          relationship: HouseholdRelationship.roommate,
          isPrimary: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      clients: [
        LifeAdminClient(
          id: uuid.v4(),
          displayName: 'Demo Client',
          fullName: 'Demo Client',
          city: 'Torino',
          preferredLanguage: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      proofCases: [
        ProofCase(
          id: uuid.v4(),
          title: 'Demo heating issue',
          category: 'housing',
          status: ProofCaseStatus.open,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      templates: [
        CommunityTemplate(
          id: uuid.v4(),
          title: 'Demo generic request',
          category: 'general',
          language: 'it',
          officialTextItalian: 'Testo demo per richiesta generica.',
          explanationLocalized: const {'en': 'Demo local template'},
          tags: const ['demo', 'generic'],
          status: CommunityTemplateStatus.local,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      utilityComparisonInput: UtilityComparisonInput(
        utilityType: UtilityType.electricity,
        currentProvider: 'Current Energia',
        currentAnnualCost: 1200,
        currentMonthlyCost: 100,
        currentConsumptionKwh: 2400,
        residentDomestic: true,
        hasCanoneRaiCharge: true,
        currentPriceType: UtilityPriceType.variable,
        offers: const [
          UtilityOffer(
            providerName: 'Offer A Energy',
            offerName: 'Offer A',
            utilityType: UtilityType.electricity,
            priceType: UtilityPriceType.fixed,
            estimatedAnnualCost: 900,
            fixedMonthlyFee: 12,
          ),
          UtilityOffer(
            providerName: 'Offer B Energy',
            offerName: 'Offer B',
            utilityType: UtilityType.electricity,
            priceType: UtilityPriceType.fixed,
            estimatedAnnualCost: 1100,
            fixedMonthlyFee: 10,
          ),
        ],
      ),
    );
  }
}
