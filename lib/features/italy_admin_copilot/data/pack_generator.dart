import '../domain/admin_procedure.dart';
import '../domain/generated_pack.dart';
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

class PackGenerator {
  static GeneratedPack generate({
    required AdminProcedure procedure,
    required Map<String, dynamic> inputData,
  }) {
    switch (procedure.id) {
      case 'CHANGE_DOCTOR':
        return ChangeDoctorGenerator.generate(procedure, inputData);
      case 'TESSERA_SANITARIA_RENEWAL':
        return TesseraSanitariaGenerator.generate(procedure, inputData);
      case 'ASL_REJECTED_REQUEST_REPLY':
        return RejectedRequestGenerator.generate(procedure, inputData);
      case 'ASL_APPOINTMENT_REQUEST':
        return AppointmentRequestGenerator.generate(procedure, inputData);
      case 'RENTAL_CONTRACT_CHANGE':
        return RentalContractGenerator.generate(procedure, inputData);
      case 'DEPOSIT_RETURN_REQUEST':
      case 'RENT_CONTRACT_TERMINATION_NOTICE':
        return LandlordIssueGenerator.generate(procedure, inputData);
      case 'NASPI_PREPARATION':
        return NaspiGenerator.generate(procedure, inputData);
      case 'PATRONATO_APPOINTMENT_REQUEST':
        return AppointmentRequestGenerator.generate(procedure, inputData);
      case 'REJECTED_REQUEST_REPLY':
        return RejectedRequestGenerator.generate(procedure, inputData);
      case 'UNIVERSITY_OFFICE_REQUEST':
        return UniversityOfficeGenerator.generate(procedure, inputData);
      case 'LANDLORD_MAINTENANCE_OR_CONTRACT':
        return LandlordIssueGenerator.generate(procedure, inputData);
      case 'GENERIC_FORMAL_REQUEST':
        return GenericFormalRequestGenerator.generate(procedure, inputData);
      case 'COMUNE_RESIDENCE_REQUEST':
      case 'ANAGRAFE_CERTIFICATE_REQUEST':
        return ComuneResidenceGenerator.generate(procedure, inputData);
      case 'PERMESSO_DOCUMENT_CHECKLIST':
        return PermessoDocumentsGenerator.generate(procedure, inputData);
      case 'REFUND_OR_COMPLAINT_REQUEST':
        return RefundComplaintGenerator.generate(procedure, inputData);
      case 'APPOINTMENT_REQUEST':
        return AppointmentRequestGenerator.generate(procedure, inputData);
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
        return buildStandardPack(
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
      default:
        return GenericFormalRequestGenerator.generate(procedure, inputData);
    }
  }
}
