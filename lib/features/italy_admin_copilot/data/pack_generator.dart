import '../domain/admin_procedure.dart';
import '../domain/catalog_models.dart';
import '../domain/generated_pack.dart';
import '../domain/service_intelligence.dart';
import 'generators/appointment_request_generator.dart';
import 'generators/change_doctor_generator.dart';
import 'generators/comune_residence_generator.dart';
import 'generators/generic_formal_request_generator.dart';
import 'generators/landlord_issue_generator.dart';
import 'generators/naspi_generator.dart';
import 'generators/permesso_documents_generator.dart';
import 'generators/refund_complaint_generator.dart';
import 'generators/rejected_request_generator.dart';
import 'generators/rental_contract_generator.dart';
import 'generators/tessera_sanitaria_generator.dart';
import 'generators/university_office_generator.dart';
import 'generators/shared_generator_helpers.dart';
import 'catalog/bundled_official_contacts.dart';
import 'catalog/bundled_official_links.dart';
import 'catalog/bundled_procedure_guidance.dart';
import 'service_intelligence_definitions.dart';

class PackGenerator {
  static GeneratedPack generate({
    required AdminProcedure procedure,
    required Map<String, dynamic> inputData,
  }) {
    late final GeneratedPack basePack;
    switch (procedure.id) {
      case 'CHANGE_DOCTOR':
        basePack = ChangeDoctorGenerator.generate(procedure, inputData);
        break;
      case 'TESSERA_SANITARIA_RENEWAL':
        basePack = TesseraSanitariaGenerator.generate(procedure, inputData);
        break;
      case 'ASL_REJECTED_REQUEST_REPLY':
        basePack = RejectedRequestGenerator.generate(procedure, inputData);
        break;
      case 'ASL_APPOINTMENT_REQUEST':
        basePack = AppointmentRequestGenerator.generate(procedure, inputData);
        break;
      case 'RENTAL_CONTRACT_CHANGE':
        basePack = RentalContractGenerator.generate(procedure, inputData);
        break;
      case 'DEPOSIT_RETURN_REQUEST':
      case 'RENT_CONTRACT_TERMINATION_NOTICE':
        basePack = LandlordIssueGenerator.generate(procedure, inputData);
        break;
      case 'NASPI_PREPARATION':
        basePack = NaspiGenerator.generate(procedure, inputData);
        break;
      case 'PATRONATO_APPOINTMENT_REQUEST':
        basePack = AppointmentRequestGenerator.generate(procedure, inputData);
        break;
      case 'REJECTED_REQUEST_REPLY':
        basePack = RejectedRequestGenerator.generate(procedure, inputData);
        break;
      case 'UNIVERSITY_OFFICE_REQUEST':
        basePack = UniversityOfficeGenerator.generate(procedure, inputData);
        break;
      case 'LANDLORD_MAINTENANCE_OR_CONTRACT':
        basePack = LandlordIssueGenerator.generate(procedure, inputData);
        break;
      case 'GENERIC_FORMAL_REQUEST':
        basePack = GenericFormalRequestGenerator.generate(procedure, inputData);
        break;
      case 'COMUNE_RESIDENCE_REQUEST':
      case 'ANAGRAFE_CERTIFICATE_REQUEST':
        basePack = ComuneResidenceGenerator.generate(procedure, inputData);
        break;
      case 'PERMESSO_DOCUMENT_CHECKLIST':
        basePack = PermessoDocumentsGenerator.generate(procedure, inputData);
        break;
      case 'REFUND_OR_COMPLAINT_REQUEST':
        basePack = RefundComplaintGenerator.generate(procedure, inputData);
        break;
      case 'APPOINTMENT_REQUEST':
        basePack = AppointmentRequestGenerator.generate(procedure, inputData);
        break;
      case 'ENERGY_BILL_ANALYZER_CHECKLIST':
      case 'ENERGY_SUPPLIER_COMPARISON':
      case 'ELECTRICITY_GAS_SWITCH_REQUEST':
      case 'VOLTURA_REQUEST':
      case 'SUBENTRO_REQUEST':
      case 'UTILITY_CANCELLATION_DISDETTA':
      case 'HIGH_BILL_COMPLAINT':
      case 'METER_READING_CORRECTION':
      case 'PAYMENT_PLAN_REQUEST':
      case 'WRONG_CHARGE_REFUND_REQUEST':
      case 'UNILATERAL_CONTRACT_CHANGE_COMPLAINT':
      case 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST':
      case 'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST':
      case 'CANONE_RAI_REFUND_OR_WRONG_CHARGE':
      case 'INTERNET_PHONE_CANCELLATION':
      case 'TELECOM_WRONG_BILL_COMPLAINT':
      case 'SERVICE_NOT_WORKING_COMPLAINT':
      case 'MODEM_RETURN_OR_CHARGE_DISPUTE':
        basePack = buildStandardPack(
          procedure: procedure,
          inputData: inputData,
          subject: procedure.title,
          recipientLabel: 'provider',
          requestSummary:
              'ricevere supporto in merito a ${procedure.subcategory.toLowerCase()} per ${valueOrPlaceholder(inputData, 'provider', valueOrPlaceholder(inputData, 'officeName', 'il caso indicato'))}',
          englishExplanation:
              'This pack helps organize the case, draft the formal Italian request, and prepare the follow-up for this life-admin situation.',
          warnings: [
            if (procedure.id.startsWith('CANONE_RAI'))
              'Submit only truthful declarations and verify eligibility through official Agenzia Entrate instructions.',
            if (procedure.category == ProcedureCategory.utilities)
              'This does not guarantee the cheapest provider or definitive contract interpretation.',
          ],
        );
        break;
      default:
        basePack = GenericFormalRequestGenerator.generate(procedure, inputData);
    }
    return _applyServiceIntelligence(
      procedure: procedure,
      inputData: inputData,
      pack: basePack,
    );
  }

  static GeneratedPack _applyServiceIntelligence({
    required AdminProcedure procedure,
    required Map<String, dynamic> inputData,
    required GeneratedPack pack,
  }) {
    final intelligence = ServiceIntelligenceDefinitions.forProcedure(procedure);
    final catalogGuidance = bundledProcedureGuidance
        .where((item) => item.procedureId == procedure.id)
        .cast<ProcedureGuidance?>()
        .firstOrNull;
    final submissionMethod =
        (inputData['submissionMethod'] as String?)?.trim().isNotEmpty == true
        ? inputData['submissionMethod'] as String
        : 'unknown';
    final officialLinkIds = {
      ...intelligence.officialLinks,
      ...?catalogGuidance?.officialLinkIds,
    };
    final officialLinks = bundledOfficialLinks
        .where((item) => officialLinkIds.contains(item.id))
        .map(
          (item) =>
              item.url.isNotEmpty ? '${item.title}: ${item.url}' : item.title,
        )
        .toList();
    final firstCatalogContact = bundledOfficialContacts
        .where(
          (item) =>
              catalogGuidance?.officialContactIds.contains(item.id) == true,
        )
        .cast<OfficialContact?>()
        .firstOrNull;
    return pack.copyWith(
      destinationGuidance: catalogGuidance == null
          ? intelligence.destinationGuidance
          : (catalogGuidance.destinationGuidance['en'] ??
                intelligence.destinationGuidance),
      recipientVerificationChecklist: [
        ...?catalogGuidance?.beforeSendingChecklist,
        ...intelligence.beforeSendingChecklist,
      ],
      submissionMethod: submissionMethod,
      inPersonChecklist: [
        ...intelligence.inPersonChecklist,
        ...intelligence.inPersonOptions.expand((item) => item.documentsToBring),
      ],
      onlinePortalChecklist: [
        'Verify the exact official portal for your city, region, office, or provider.',
        if (intelligence.spidCieRequiredLevel != SpidCieRequiredLevel.notNeeded)
          'Check whether SPID or CIE is required before starting.',
      ],
      officialLinksToCheck: officialLinks,
      selectedContactSnapshot: {
        'recipientName':
            inputData['recipientName'] ??
            inputData['officeName'] ??
            firstCatalogContact?.label,
        'recipientEmail':
            inputData['recipientEmail'] ?? firstCatalogContact?.notes['email'],
        'recipientPec':
            inputData['recipientPec'] ?? firstCatalogContact?.notes['pec'],
        'recipientAddress': inputData['recipientAddress'],
      },
      serviceIntelligenceWarnings: intelligence.warnings,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
