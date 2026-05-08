import '../domain/admin_procedure.dart';
import '../domain/attachment_item.dart';
import '../domain/procedure_field.dart';
import 'generators/shared_generator_helpers.dart';

class ItalyAdminProcedureDefinitions {
  static List<AdminProcedure> all() => _procedures;

  static AdminProcedure? byId(String id) {
    for (final procedure in _procedures) {
      if (procedure.id == id) return procedure;
    }
    return null;
  }

  static final List<AdminProcedure> _procedures = [
    _health(
      'TESSERA_SANITARIA_RENEWAL',
      'Get Tessera Sanitaria / Register with SSN',
      'Get Tessera Sanitaria / Register with SSN',
      _tesseraFields(),
      _tesseraAttachments(),
      shortDescription:
          'Understand the Torino SSN registration path, recommended channel, documents, and when to go in person instead of relying only on email or PEC.',
    ),
    _health(
      'CHANGE_DOCTOR',
      'Change Doctor / Medico di Base Request',
      'Change doctor',
      _changeDoctorFields(),
      _healthAttachments(),
    ),
    _health(
      'ASL_REJECTED_REQUEST_REPLY',
      'ASL Rejected Request Reply',
      'Rejected ASL request',
      _rejectedFields(),
      _rejectedAttachments(),
    ),
    _health(
      'ASL_APPOINTMENT_REQUEST',
      'ASL Appointment Request',
      'ASL appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _housing(
      'REGISTER_OR_CHECK_RENTAL_CONTRACT',
      'Register or Check Rental Contract',
      'Register or check rental contract',
      _rentalFields(),
      _rentalAttachments(),
      shortDescription:
          'Check whether the contract is registered, ask for proof, and understand when Agenzia Entrate is the correct next step.',
    ),
    _housing(
      'RENTAL_CONTRACT_CHANGE',
      'Rental Contract Change',
      'Rental contract change',
      _rentalFields(),
      _rentalAttachments(),
      shortDescription:
          'Handle official contract changes such as subentro, cessione, proroga, rent changes, or early termination registration.',
    ),
    _housing(
      'ADD_OR_REMOVE_TENANT',
      'Add or Remove Tenant from Contract',
      'Add or remove tenant',
      _rentalFields(),
      _rentalAttachments(),
      shortDescription:
          'Update who is on the contract and understand when landlord approval and Agenzia Entrate registration are needed.',
    ),
    _housing(
      'LANDLORD_MAINTENANCE_OR_CONTRACT',
      'Landlord Maintenance / Repair Request',
      'Landlord repair request',
      _landlordFields(),
      _landlordAttachments(),
      shortDescription:
          'Ask for repairs with proof, understand when a friendly message is enough, and when to escalate to formal written notice.',
    ),
    _housing(
      'DEPOSIT_RETURN_REQUEST',
      'Deposit Return Request',
      'Deposit return',
      _depositFields(),
      _depositAttachments(),
      shortDescription:
          'Request the return of your rental deposit and prepare proof before escalating to a tenant union.',
    ),
    _housing(
      'RENT_CONTRACT_TERMINATION_NOTICE',
      'Rent Contract Termination Notice',
      'Rent contract termination notice',
      _terminationFields(),
      _rentalAttachments(),
      shortDescription:
          'Prepare a formal termination notice, check the notice period in the contract, and keep proof of sending.',
    ),
    _housing(
      'RENT_PAYMENT_DELAY_PAYMENT_PLAN',
      'Rent Payment Delay / Payment Plan',
      'Rent payment delay',
      _landlordFields(),
      _landlordAttachments(),
      shortDescription:
          'Communicate rent delay clearly, propose a payment plan, and reduce escalation risk before eviction becomes urgent.',
    ),
    _housing(
      'WRONG_EXPENSES_SPESE_CONDOMINIALI',
      'Wrong Expenses / Spese Condominiali Dispute',
      'Spese condominiali dispute',
      _landlordFields(),
      _landlordAttachments(),
      shortDescription:
          'Ask for a detailed breakdown of expenses and contest unclear or tenant-inappropriate charges.',
    ),
    _housing(
      'UNREGISTERED_IRREGULAR_RENTAL_CONTRACT',
      'Unregistered or Irregular Rental Contract',
      'Irregular rental contract',
      _rentalFields(),
      _rentalAttachments(),
      shortDescription:
          'Collect proof, ask for registration evidence, and understand when tenant-union support is safer than informal messaging.',
    ),
    _housing(
      'EVICTION_SFRATTO_SUPPORT',
      'Eviction / Sfratto Support',
      'Eviction support',
      _terminationFields(),
      _rentalAttachments(),
      shortDescription:
          'Time-sensitive support for eviction notices, court documents, and urgent referral to Comune housing support and tenant unions.',
    ),
    _housing(
      'EMERGENCY_HOUSING_COMUNE_SUPPORT',
      'Emergency Housing / Comune Support',
      'Emergency housing',
      _genericHousingSupportFields(),
      _rentalAttachments(),
      shortDescription:
          'Ask Comune di Torino for urgent housing support when eviction, homelessness risk, or serious housing instability is involved.',
    ),
    _housing(
      'STUDENT_RENT_HELP',
      'Student Rent Help',
      'Student rent help',
      _rentalFields(),
      _rentalAttachments(),
      shortDescription:
          'Handle student-specific rent problems such as registration proof, deposit disputes, roommate changes, and irregular contracts.',
    ),
    _housing(
      'FORMAL_COMPLAINT_TO_LANDLORD',
      'Formal Complaint to Landlord',
      'Formal complaint to landlord',
      _landlordFields(),
      _landlordAttachments(),
      shortDescription:
          'Create a stronger written complaint for landlord disputes when simple messages are no longer enough.',
    ),
    _housing(
      'TENANT_UNION_APPOINTMENT',
      'Tenant Union Appointment',
      'Tenant union appointment',
      _genericHousingSupportFields(),
      _rentalAttachments(),
      shortDescription:
          'Prepare a SUNIA or SICET appointment and gather the documents needed for housing support.',
    ),
    _utility(
      'ENERGY_BILL_ANALYZER_CHECKLIST',
      'Energy Bill Analyzer Checklist',
      'Bill understanding',
      _energyBillFields(),
      _billAttachments(),
      shortDescription:
          'Read the bill first, extract supplier and distributor details, and identify suspicious charges before filing a complaint.',
    ),
    _utility(
      'ENERGY_SUPPLIER_COMPARISON',
      'Energy Supplier Comparison',
      'Offer comparison',
      _energyComparisonFields(),
      _billAttachments(),
      shortDescription:
          'Compare offers safely without relying only on monthly estimates or sales-call promises.',
    ),
    _utility(
      'ELECTRICITY_GAS_SWITCH_REQUEST',
      'Electricity / Gas Switch Request',
      'Provider switching',
      _utilitySwitchFields(),
      _utilityAttachments(),
      shortDescription:
          'Switch supplier while the supply remains active and prepare the information needed before confirming the new offer.',
    ),
    _utility(
      'VOLTURA_REQUEST',
      'Voltura Request',
      'Voltura',
      _utilitySwitchFields(),
      _utilityAttachments(),
      shortDescription:
          'Transfer an active utility contract into your name and avoid confusion with subentro or provider switching.',
    ),
    _utility(
      'SUBENTRO_REQUEST',
      'Subentro Request',
      'Subentro',
      _utilitySwitchFields(),
      _utilityAttachments(),
      shortDescription:
          'Reactivate an inactive supply with an existing meter and understand what the supplier will usually ask for.',
    ),
    _utility(
      'UTILITY_CANCELLATION_DISDETTA',
      'Utility Cancellation / Disdetta',
      'Disdetta',
      _utilityCancellationFields(),
      _utilityAttachments(),
      shortDescription:
          'Close the contract correctly, capture the final meter reading, and avoid leaving the next user with the wrong flow.',
    ),
    _utility(
      'HIGH_BILL_COMPLAINT',
      'High Bill Complaint',
      'High bill complaint',
      _highBillFields(),
      _billAttachments(),
      shortDescription:
          'Compare bills, verify readings, and prepare the written complaint path before escalating to ARERA.',
    ),
    _utility(
      'METER_READING_CORRECTION',
      'Meter Reading Correction',
      'Reading correction',
      _meterCorrectionFields(),
      _billAttachments(),
      shortDescription:
          'Correct an estimated or wrong reading with evidence and keep the supplier/distributor distinction clear.',
    ),
    _utility(
      'PAYMENT_PLAN_REQUEST',
      'Payment Plan Request',
      'Payment plan',
      _paymentPlanFields(),
      _billAttachments(),
      shortDescription:
          'Ask for installments before disconnection risk becomes urgent and keep the request focused on the supplier.',
    ),
    _utility(
      'WRONG_CHARGE_REFUND_REQUEST',
      'Wrong Charge Refund Request',
      'Wrong charge refund',
      _wrongChargeFields(),
      _billAttachments(),
      shortDescription:
          'Request a refund for an incorrect utility charge and keep the written trail needed for escalation if refused.',
    ),
    _utility(
      'UNILATERAL_CONTRACT_CHANGE_COMPLAINT',
      'Unilateral Contract Change Complaint',
      'Contract change complaint',
      _contractChangeComplaintFields(),
      _billAttachments(),
      shortDescription:
          'Contest a unilateral supplier change or use the flow to decide whether switching is the safer next step.',
    ),
    _utility(
      'CHECK_SUPPLIER_VS_DISTRIBUTOR',
      'Check Supplier vs Distributor',
      'Supplier vs distributor',
      _energyBillFields(),
      _billAttachments(),
      shortDescription:
          'Understand who handles bills and contracts versus faults and emergencies before contacting the wrong company.',
    ),
    _utility(
      'NEW_ACTIVATION_PRIMA_ATTIVAZIONE',
      'New Activation / Prima Attivazione',
      'New activation',
      _utilitySwitchFields(),
      _utilityAttachments(),
      shortDescription:
          'Start a new supply correctly and distinguish prima attivazione from voltura or subentro.',
    ),
    _utility(
      'CONTRACT_NOT_REQUESTED_SCAM_ACTIVATION',
      'Contract Not Requested / Scam Activation',
      'Contract not requested',
      _highBillFields(),
      _billAttachments(),
      shortDescription:
          'Challenge an unsolicited activation, ask for proof of consent, and prepare escalation if the supplier does not fix it.',
    ),
    _utility(
      'GAS_OR_ELECTRICITY_EMERGENCY_FAULT',
      'Gas or Electricity Emergency / Fault',
      'Emergency fault',
      _meterCorrectionFields(),
      _utilityAttachments(),
      shortDescription:
          'Urgent technical flow for gas smell, dangerous faults, or network issues that should go to the distributor immediately.',
    ),
    _utility(
      'ARERA_COMPLAINT_AND_CONCILIATION',
      'ARERA Complaint and Conciliation',
      'ARERA escalation',
      _highBillFields(),
      _billAttachments(),
      shortDescription:
          'Escalate unresolved utility disputes after the supplier complaint step using Sportello Consumatore and conciliation guidance.',
    ),
    _canone(
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'Canone RAI No-TV Declaration Checklist',
      'No-TV declaration',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Prepare the no-TV declaration with the right channel, documents, and annual deadline logic.',
    ),
    _canone(
      'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      'Canone RAI Over-75 Exemption Checklist',
      'Over-75 exemption',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Check the over-75 exemption path carefully, including household and current official threshold requirements.',
    ),
    _canone(
      'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      'Canone RAI Refund or Wrong Charge',
      'Refund / wrong charge',
      _canoneRefundFields(),
      _canoneAttachments(),
      shortDescription:
          'Handle a wrong Canone charge or refund request through Agenzia Entrate instead of relying on the electricity supplier.',
    ),
    _canone(
      'UNDERSTAND_IF_MUST_PAY_CANONE_RAI',
      'Understand if You Must Pay Canone RAI',
      'Understand if you must pay',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Work out whether the right path is payment, exemption, no-TV declaration, or refund based on the household situation.',
    ),
    _canone(
      'DIPLOMATIC_MILITARY_EXEMPTION',
      'Diplomatic / Military Exemption',
      'Diplomatic or military exemption',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Route special-status users toward the official exemption form or intermediary instead of guessing eligibility in-app.',
    ),
    _canone(
      'WRONG_ELECTRICITY_BILL_CHARGE',
      'Wrong Electricity Bill Charge',
      'Wrong bill charge',
      _canoneRefundFields(),
      _canoneAttachments(),
      shortDescription:
          'Resolve duplicate or wrong household Canone charges and decide when refund is needed.',
    ),
    _canone(
      'NEW_HOME_CHANGED_ELECTRICITY_CONTRACT',
      'New Home / Changed Electricity Contract',
      'New home or changed contract',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Understand how moving home, voltura, or a new residential contract changes the Canone RAI path.',
    ),
    _canone(
      'HELP_FILLING_AGENZIA_ENTRATE_FORM',
      'Help Filling Agenzia Entrate Form',
      'Form help',
      _canoneFields(),
      _canoneAttachments(),
      shortDescription:
          'Choose the correct Canone form and submission channel without exposing every deadline and address at once.',
    ),
    _telecom(
      'INTERNET_PHONE_CANCELLATION',
      'Internet / Phone Cancellation',
      'Cancellation',
      _telecomCancellationFields(),
      _telecomAttachments(),
      shortDescription:
          'Cancel a fixed-line contract carefully and avoid losing the number when portability is actually needed.',
    ),
    _telecom(
      'TELECOM_WRONG_BILL_COMPLAINT',
      'Telecom Wrong Bill Complaint',
      'Wrong bill',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Challenge a telecom bill with written proof first, then prepare for escalation if the operator does not fix it.',
    ),
    _telecom(
      'SERVICE_NOT_WORKING_COMPLAINT',
      'Service Not Working Complaint',
      'Service issue',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Document outages or failures, open a ticket first, and move to a formal complaint only when needed.',
    ),
    _telecom(
      'MODEM_RETURN_OR_CHARGE_DISPUTE',
      'Modem Return or Charge Dispute',
      'Modem dispute',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Handle modem return instructions and contest modem charges without promising more than the contract supports.',
    ),
    _telecom(
      'UNDERSTAND_TELECOM_PROBLEM',
      'Understand Telecom Problem',
      'Understand telecom problem',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Classify the issue before sending the wrong complaint and gather the right proof for the correct flow.',
    ),
    _telecom(
      'MOBILE_SIM_CANCELLATION',
      'Mobile SIM Cancellation',
      'Mobile SIM cancellation',
      _telecomCancellationFields(),
      _telecomAttachments(),
      shortDescription:
          'Deactivate a mobile SIM while checking whether number portability or residual credit handling matters first.',
    ),
    _telecom(
      'PROVIDER_SWITCHING_NUMBER_PORTABILITY',
      'Provider Switching / Number Portability',
      'Switching or portability',
      _telecomCancellationFields(),
      _telecomAttachments(),
      shortDescription:
          'Keep the number while switching operator and avoid direct cancellation when portability is the safer path.',
    ),
    _telecom(
      'INTERNET_SPEED_TOO_LOW',
      'Internet Speed Too Low',
      'Internet too slow',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Collect speed evidence, compare it with the contract, and prepare the complaint path if performance stays below expectations.',
    ),
    _telecom(
      'ACTIVATION_DELAY_NO_LINE',
      'No Line Activation / Activation Delay',
      'Activation delay',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Track delayed activation, missed appointments, and any charges that arrived before the service actually started.',
    ),
    _telecom(
      'CONTRACT_NOT_REQUESTED_PHONE_SCAM',
      'Contract Not Requested / Phone Scam',
      'Contract not requested',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Contest a phone scam or unauthorized activation immediately and ask for proof of consent.',
    ),
    _telecom(
      'REFUND_OR_COMPENSATION_REQUEST',
      'Refund or Compensation Request',
      'Refund or compensation',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Ask clearly for refund or indennizzo and preserve the evidence needed for ConciliaWeb if refused.',
    ),
    _telecom(
      'PAYMENT_PLAN_UNPAID_BILLS',
      'Payment Plan / Unpaid Bills',
      'Payment plan',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Request installments or clarify debt before suspension risk grows, while separating disputes from payment plans.',
    ),
    _telecom(
      'ROAMING_INTERNATIONAL_CHARGE_DISPUTE',
      'Roaming or International Charge Dispute',
      'Roaming dispute',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Contest roaming or international charges with travel evidence, warnings, and usage details.',
    ),
    _telecom(
      'PEC_FORMAL_COMPLAINT_OPERATOR',
      'PEC / Formal Complaint to Operator',
      'Formal complaint',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Generate a stronger operator complaint without guessing the operator’s PEC or postal address.',
    ),
    _telecom(
      'AGCOM_CORECOM_CONCILIAWEB_ESCALATION',
      'AGCOM / Corecom / ConciliaWeb Escalation',
      'Escalation',
      _telecomComplaintFields(),
      _telecomAttachments(),
      shortDescription:
          'Escalate unresolved telecom disputes after the written complaint step with ConciliaWeb and local Corecom guidance.',
    ),
    _publicOffice(
      'UNDERSTAND_RESIDENZA_DOMICILIO_TEMPORARY',
      'Understand Residenza / Domicilio / Temporary Residence',
      'Comune / orientation',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Clarify whether the user needs residenza, address change, temporary residence, certificate, or autocertificazione before choosing a channel.',
    ),
    _publicOffice(
      'CHANGE_RESIDENCE_FROM_ANOTHER_COMUNE_OR_ABROAD',
      'Change Residence from Another Comune or Abroad',
      'Residence change',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Guide a Torino residence transfer from another Italian comune or from abroad, including documents and channel choice.',
    ),
    _publicOffice(
      'CHANGE_ADDRESS_INSIDE_TORINO',
      'Change Address Inside Torino',
      'Address change',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Handle an address change for someone already resident in Torino without mixing it with inter-comune residence transfer.',
    ),
    _publicOffice(
      'TEMPORARY_RESIDENCE_POPOLAZIONE_TEMPORANEA',
      'Temporary Residence / Popolazione Temporanea',
      'Temporary residence',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Route users who are temporarily living in Torino without full habitual residence transfer.',
    ),
    _publicOffice(
      'DOORBELL_MAILBOX_ADDRESS_PROOF',
      'Doorbell / Mailbox / Address Proof Help',
      'Address proof',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Prepare address proof and residence-check readiness before a Comune verification fails.',
    ),
    _publicOffice(
      'REJECTED_RESIDENZA_REQUEST_REPLY',
      'Reply to Rejected Residenza Request',
      'Rejected residence request',
      _rejectedFields(),
      _comuneAttachments(),
      shortDescription:
          'Reply to suspended or rejected residence/address practices with missing documents or clarification.',
    ),
    _publicOffice(
      'COMUNE_RESIDENCE_REQUEST',
      'Comune / Residenza / Anagrafe Request',
      'Residence',
      _comuneFields(),
      _comuneAttachments(),
      shortDescription:
          'Legacy Comune residence entrypoint kept for compatibility with the richer Torino guidance.',
    ),
    _publicOffice(
      'ANAGRAFE_CERTIFICATE_REQUEST',
      'Anagrafe Certificate Request',
      'Certificate request',
      _anagrafeFields(),
      _comuneAttachments(),
    ),
    _publicOffice(
      'FAMILY_STATUS_CERTIFICATE',
      'Family Status Certificate',
      'Stato di famiglia',
      _anagrafeFields(),
      _comuneAttachments(),
      shortDescription:
          'Explain when stato di famiglia is needed and when autocertificazione may be enough.',
    ),
    _publicOffice(
      'RESIDENCE_CERTIFICATE',
      'Residence Certificate',
      'Residence certificate',
      _anagrafeFields(),
      _comuneAttachments(),
      shortDescription:
          'Request or evaluate a certificato di residenza with ANPR-first guidance.',
    ),
    _publicOffice(
      'SELF_CERTIFICATION_AUTOCERTIFICAZIONE',
      'Self-Certification / Autocertificazione',
      'Autocertificazione',
      _anagrafeFields(),
      _genericAttachments(),
      shortDescription:
          'Show when self-certification is a valid alternative to an official anagrafe certificate.',
    ),
    _publicOffice(
      'BOOK_ANAGRAFE_APPOINTMENT',
      'Book Anagrafe Appointment',
      'Appointment',
      _appointmentFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare the right appointment request and the right document bundle for Anagrafe support.',
    ),
    _publicOffice(
      'PEC_FORMAL_REQUEST_COMUNE',
      'PEC / Formal Request to Comune',
      'Formal PEC',
      _rejectedFields(),
      _genericAttachments(),
      shortDescription:
          'Draft a formal Comune or Anagrafe follow-up, integration, or protocol-level request.',
    ),
    _publicOffice(
      'ONLINE_COMUNE_SERVICE_PROBLEM',
      'Online Comune Service Problem',
      'Online issue',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Report Comune or Anagrafe portal problems with screenshots and a clear technical description.',
    ),
    _publicOffice(
      'GENERAL_COMUNE_INFORMATION_REQUEST',
      'General Comune Information Request',
      'General information',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Ask Comune or Anagrafe for the correct procedure and document list when the case is still unclear.',
    ),
    _work(
      'UNDERSTAND_JOB_LOSS_BENEFIT_SITUATION',
      'Understand Job-Loss / Benefit Situation',
      'Job-loss orientation',
      _naspiFields(),
      _naspiAttachments(),
      shortDescription:
          'Clarify whether the right path is NASpI, DID/CPI, employer document recovery, union support, or CAF.',
    ),
    _work(
      'NASPI_PREPARATION',
      'NASpI Preparation',
      'NASpI',
      _naspiFields(),
      _naspiAttachments(),
    ),
    _work(
      'PATRONATO_APPOINTMENT_REQUEST',
      'Patronato Appointment Request',
      'Patronato appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _work(
      'NASPI_APPLICATION_FOLLOWUP',
      'NASpI Application Follow-up',
      'NASpI follow-up',
      _naspiFields(),
      _naspiAttachments(),
      shortDescription:
          'Check pending NASpI practices, missing documents, payment delays, and patronato follow-up.',
    ),
    _work(
      'DID_AND_CENTRO_IMPIEGO',
      'DID / Centro per l’Impiego',
      'DID and CPI',
      _appointmentFields(),
      _genericAttachments(),
      shortDescription:
          'Handle DID, patto di servizio, CPI competence, and employment-service obligations linked to unemployment.',
    ),
    _work(
      'INPS_APPOINTMENT_CONTACT_REQUEST',
      'INPS Appointment / Contact Request',
      'INPS contact',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare an INPS contact or appointment request without skipping protocol details and supporting evidence.',
    ),
    _work(
      'REPLY_REJECTED_INPS_REQUEST',
      'Reply to Rejected INPS Request',
      'Rejected INPS request',
      _rejectedFields(),
      _genericAttachments(),
      shortDescription:
          'Respond to rejected or suspended INPS practices with the right escalation and document integration path.',
    ),
    _work(
      'MISSING_DOCUMENTS_INTEGRATION',
      'Missing Documents Integration',
      'INPS integration',
      _rejectedFields(),
      _genericAttachments(),
      shortDescription:
          'Send the missing documents requested by INPS or by the patronato handling the practice.',
    ),
    _work(
      'EMPLOYER_TERMINATION_CONTRACT_END_DOCUMENTS',
      'Employer Contract-End Documents',
      'Employer documents',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Ask the employer for end-of-contract documents needed for checks, patronato, or INPS.',
    ),
    _work(
      'PAYSLIP_TFR_FINAL_PAYMENT_PROBLEM',
      'Payslip / TFR / Final Payment Problem',
      'Salary and TFR dispute',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Organize evidence and first requests when salary, TFR, ferie, or final settlement are missing or wrong.',
    ),
    _work(
      'SICK_LEAVE_MALATTIA_INPS_BASICS',
      'Sick Leave / Malattia INPS Basics',
      'Sick leave',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Explain the core sick-leave steps, certificate protocol handling, and employer communication.',
    ),
    _work(
      'MATERNITY_FAMILY_BENEFIT_HELP',
      'Maternity / Family Benefit Help',
      'Family benefits',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Route users to patronato, INPS, or CAF for maternity, child, and family-related benefit support.',
    ),
    _work(
      'ISEE_CAF_CONNECTION',
      'ISEE / CAF Connection',
      'ISEE / CAF',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Clarify when the user needs CAF for ISEE rather than patronato for INPS applications.',
    ),
    _work(
      'UNION_LEGAL_WORK_DISPUTE_SUPPORT',
      'Union / Work Dispute Support',
      'Work dispute',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Route unpaid salary, dismissal, TFR, and contract-abuse cases toward union or vertenza support.',
    ),
    _work(
      'GENERAL_INPS_FORMAL_REQUEST_PEC',
      'General INPS Formal Request / PEC',
      'Formal INPS PEC',
      _rejectedFields(),
      _genericAttachments(),
      shortDescription:
          'Draft a formal INPS follow-up, clarification request, or payment delay communication with protocol evidence.',
    ),
    _university(
      'UNIVERSITY_OFFICE_REQUEST',
      'University Office Request',
      'University office',
      _universityFields(),
      _universityAttachments(),
    ),
    _university(
      'PERMESSO_DOCUMENT_CHECKLIST',
      'Permesso Document Checklist',
      'Permesso support',
      _permessoFields(),
      _permessoAttachments(),
    ),
    _university(
      'UNDERSTAND_STUDENT_ADMINISTRATIVE_PROBLEM',
      'Understand Student Administrative Problem',
      'Student office routing',
      _universityFields(),
      _universityAttachments(),
      shortDescription:
          'Classify whether the student case belongs to university, EDISU, Questura, CAF, ASL, Comune, or Housing before drafting anything.',
    ),
    _university(
      'EDISU_SCHOLARSHIP_APPLICATION',
      'EDISU Scholarship Application',
      'EDISU scholarship',
      _universityFields(),
      _universityAttachments(),
      shortDescription:
          'Prepare the scholarship or student-benefit application with the right economic, student, and immigration documents.',
    ),
    _university(
      'EDISU_REJECTED_MISSING_DOCUMENTS',
      'EDISU Rejected Request / Missing Documents',
      'EDISU rejected or missing docs',
      _rejectedFields(),
      _universityAttachments(),
      shortDescription:
          'Reply when EDISU asks for integration, blocks a benefit, or rejects scholarship or housing documents.',
    ),
    _university(
      'STUDENT_HOUSING_EDISU_RESIDENCE',
      'Student Housing / EDISU Residence',
      'Student housing',
      _universityFields(),
      _universityAttachments(),
      shortDescription:
          'Handle EDISU housing and residence support without mixing it up with private rent or Comune procedures.',
    ),
    _university(
      'ISEE_ISEE_PARIFICATO_STUDENTS',
      'ISEE / ISEE Parificato for Students',
      'Student ISEE',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Work out whether the student needs ISEE Universitario or ISEE Parificato and when CAF support is the right first step.',
    ),
    _university(
      'TUITION_FEES_FEE_REDUCTION_DOCUMENTS',
      'Tuition Fees / Fee Reduction Documents',
      'Tuition fees',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare or correct fee-reduction documents and separate university fee issues from EDISU and CAF issues.',
    ),
    _university(
      'PERMESSO_FIRST_REQUEST',
      'Permesso di Soggiorno First Request',
      'First permesso',
      _permessoFields(),
      _permessoAttachments(),
      shortDescription:
          'Use official Questura and university guidance to prepare the first student permesso without inventing document rules.',
    ),
    _university(
      'PERMESSO_RENEWAL',
      'Permesso di Soggiorno Renewal',
      'Permesso renewal',
      _permessoFields(),
      _permessoAttachments(),
      shortDescription:
          'Prepare a student permit renewal with timing, enrollment, accommodation, health, and financial proof checks.',
    ),
    _university(
      'PERMESSO_QUESTURA_FOLLOWUP',
      'Permesso Appointment / Questura Follow-up',
      'Questura follow-up',
      _permessoFields(),
      _permessoAttachments(),
      shortDescription:
          'Follow up on a stuck postal-kit or Questura appointment situation using receipt and status evidence.',
    ),
    _university(
      'STUDENT_HEALTHCARE_TESSERA_DOCTOR',
      'Student Healthcare / Tessera Sanitaria / Doctor',
      'Student healthcare',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Route student healthcare cases into the dedicated Health / ASL flow instead of treating them as generic university issues.',
    ),
    _university(
      'RESIDENZA_DOMICILE_STUDENTS',
      'Residenza or Domicile for Students',
      'Student residenza',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Separate student residenza and domicilio issues from housing proof, healthcare, and scholarship questions.',
    ),
    _university(
      'RENTAL_CONTRACT_PROOF_STUDENTS',
      'Rental Contract Proof for Students',
      'Student rental proof',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Handle accommodation-proof requests for EDISU, ASL, permesso, or Comune without guessing landlord documents.',
    ),
    _university(
      'UNIVERSITY_CERTIFICATE_REQUEST',
      'University Certificate Request',
      'University certificate',
      _universityFields(),
      _universityAttachments(),
      shortDescription:
          'Request the correct university certificate for enrollment, exams, scholarships, foreign authorities, or permit needs.',
    ),
    _university(
      'FORMAL_EMAIL_UNIVERSITY_EDISU_OFFICE',
      'Formal Email to University / EDISU / Office',
      'Formal student email',
      _universityFields(),
      _universityAttachments(),
      shortDescription:
          'Generate a structured formal student message for university, EDISU, Questura-support, or CAF follow-up contexts.',
    ),
    _general(
      'REJECTED_REQUEST_REPLY',
      'Reply to Rejected Public Office Request',
      'Rejected request',
      _rejectedFields(),
      _rejectedAttachments(),
    ),
    _general(
      'REPLY_REJECTED_PUBLIC_OFFICE_REQUEST',
      'Reply to Rejected Public Office Request',
      'Rejected request',
      _rejectedFields(),
      _rejectedAttachments(),
      shortDescription:
          'Reply to a blocked or rejected office practice with a clearer formal review or integration request.',
    ),
    _general(
      'REFUND_OR_COMPLAINT_REQUEST',
      'Refund or Complaint Request',
      'Refund / complaint',
      _refundFields(),
      _refundAttachments(),
    ),
    _general(
      'APPOINTMENT_REQUEST',
      'Formal Appointment Request',
      'Appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _general(
      'FORMAL_APPOINTMENT_REQUEST',
      'Formal Appointment Request',
      'Appointment',
      _appointmentFields(),
      _genericAttachments(),
      shortDescription:
          'Request an appointment with a clearer written explanation of the case and documents already available.',
    ),
    _general(
      'GENERIC_FORMAL_REQUEST',
      'Generic Formal Request',
      'Generic formal',
      _genericFields(),
      _genericAttachments(),
    ),
    _general(
      'UNDERSTAND_WHICH_OFFICE_TO_CONTACT',
      'Understand Which Office to Contact',
      'Which office?',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Route the user to the right office or specialized category before writing the wrong message.',
    ),
    _general(
      'MISSING_DOCUMENTS_INTEGRATION_GENERAL',
      'Missing Documents Integration',
      'Missing documents',
      _rejectedFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare a clean integration email or PEC after a request was already submitted.',
    ),
    _general(
      'REFUND_REQUEST',
      'Refund Request',
      'Refund',
      _refundFields(),
      _refundAttachments(),
      shortDescription:
          'Request money back with payment proof, reason, and the right written follow-up path.',
    ),
    _general(
      'COMPLAINT_REQUEST',
      'Complaint Request',
      'Complaint',
      _refundFields(),
      _refundAttachments(),
      shortDescription:
          'Write a complaint with timeline, evidence, and a clear requested solution.',
    ),
    _general(
      'FOLLOWUP_UNANSWERED_REQUEST',
      'Follow-up on Unanswered Request',
      'Follow-up',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Send a reminder when the office or provider has not answered the original request.',
    ),
    _general(
      'STATUS_UPDATE_WITH_PROTOCOL',
      'Status Update with Protocol Number',
      'Status update',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Ask for an update on a pending practice when you already have a protocol or ticket number.',
    ),
    _general(
      'ASK_DOCUMENT_CLARIFICATION',
      'Ask Document Clarification',
      'Document clarification',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Clarify which documents are required before submitting a request or booking an office visit.',
    ),
    _general(
      'SEND_PEC_WITH_ATTACHMENTS',
      'Send PEC with Attachments',
      'PEC with attachments',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare a PEC with the correct subject, attachments, and proof-of-sending checklist.',
    ),
    _general(
      'WRITE_SHORT_POLITE_EMAIL',
      'Write Short Polite Email',
      'Short polite email',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Generate a short, polite, human email when a stronger formal request is not needed.',
    ),
    _general(
      'WRITE_STRONG_FORMAL_COMPLAINT',
      'Write Strong Formal Complaint',
      'Strong formal complaint',
      _refundFields(),
      _refundAttachments(),
      shortDescription:
          'Turn an unresolved problem into a stronger documented complaint without becoming aggressive.',
    ),
    _general(
      'PREPARE_DOCUMENTS_BEFORE_OFFICE',
      'Prepare Documents Before Office Visit',
      'Office visit preparation',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Prepare originals, copies, questions, and proof before going to a desk or appointment.',
    ),
    _general(
      'CONVERT_INFORMAL_TO_FORMAL_ITALIAN',
      'Convert Informal Message to Formal Italian',
      'Formal Italian rewrite',
      _genericFields(),
      _genericAttachments(),
      shortDescription:
          'Rewrite rough notes, English, or WhatsApp-style text into clear formal Italian.',
    ),
  ];
}

const Set<String> kPremiumProcedureIds = {
  'ENERGY_SUPPLIER_COMPARISON',
  'HIGH_BILL_COMPLAINT',
  'CHECK_SUPPLIER_VS_DISTRIBUTOR',
  'NEW_ACTIVATION_PRIMA_ATTIVAZIONE',
  'CONTRACT_NOT_REQUESTED_SCAM_ACTIVATION',
  'GAS_OR_ELECTRICITY_EMERGENCY_FAULT',
  'ARERA_COMPLAINT_AND_CONCILIATION',
  'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
  'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
  'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
  'UNDERSTAND_IF_MUST_PAY_CANONE_RAI',
  'DIPLOMATIC_MILITARY_EXEMPTION',
  'WRONG_ELECTRICITY_BILL_CHARGE',
  'NEW_HOME_CHANGED_ELECTRICITY_CONTRACT',
  'HELP_FILLING_AGENZIA_ENTRATE_FORM',
  'INTERNET_PHONE_CANCELLATION',
  'TELECOM_WRONG_BILL_COMPLAINT',
  'SERVICE_NOT_WORKING_COMPLAINT',
  'MODEM_RETURN_OR_CHARGE_DISPUTE',
  'UNDERSTAND_TELECOM_PROBLEM',
  'MOBILE_SIM_CANCELLATION',
  'PROVIDER_SWITCHING_NUMBER_PORTABILITY',
  'INTERNET_SPEED_TOO_LOW',
  'ACTIVATION_DELAY_NO_LINE',
  'CONTRACT_NOT_REQUESTED_PHONE_SCAM',
  'REFUND_OR_COMPENSATION_REQUEST',
  'PAYMENT_PLAN_UNPAID_BILLS',
  'ROAMING_INTERNATIONAL_CHARGE_DISPUTE',
  'PEC_FORMAL_COMPLAINT_OPERATOR',
  'AGCOM_CORECOM_CONCILIAWEB_ESCALATION',
};

bool isPremiumProcedureId(String procedureId) =>
    kPremiumProcedureIds.contains(procedureId);

AdminProcedure _build({
  required String id,
  required String title,
  required ProcedureCategory category,
  required String subcategory,
  required List<ProcedureField> fields,
  required List<AttachmentSuggestion> attachments,
  required List<String> tags,
  required String shortDescription,
}) {
  return AdminProcedure(
    id: id,
    title: title,
    category: category,
    subcategory: subcategory,
    shortDescription: shortDescription,
    longDescription:
        '$title helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.',
    authorityType: category.label,
    difficulty: _difficultyFor(category),
    estimatedMinutes: _minutesFor(category),
    targetRecipientExamples: _recipientsFor(category),
    fields: fields,
    attachmentSuggestions: attachments,
    tags: tags,
    isPremium: isPremiumProcedureId(id),
    disclaimer: '$kItalianDisclaimer\n\n$kEnglishDisclaimer',
  );
}

AdminProcedure _health(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Health and ASL support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.health,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['medico', 'ASL', 'tessera sanitaria', 'health'],
  shortDescription: shortDescription,
);

AdminProcedure _housing(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Housing and rent administration workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.housing,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['affitto', 'landlord', 'subentro', 'deposit', 'housing'],
  shortDescription: shortDescription,
);

AdminProcedure _utility(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Electricity and gas workflow or checklist.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.utilities,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['bolletta', 'luce', 'gas', 'fornitore', 'voltura', 'disdetta'],
  shortDescription: shortDescription,
);

AdminProcedure _canone(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Canone RAI checklist and support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.canoneRai,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['canone rai', 'tv', 'refund', 'exemption'],
  shortDescription: shortDescription,
);

AdminProcedure _telecom(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Internet and phone complaint workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.telecom,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['internet', 'telefono', 'modem', 'disdetta', 'telecom'],
  shortDescription: shortDescription,
);

AdminProcedure _publicOffice(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Comune and document support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.publicOffice,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['residenza', 'comune', 'anagrafe', 'documents'],
  shortDescription: shortDescription,
);

AdminProcedure _work(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'Work and patronato support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.work,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['NASpI', 'patronato', 'INPS', 'lavoro'],
  shortDescription: shortDescription,
);

AdminProcedure _university(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'University administration support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.university,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['università', 'ISEE', 'borsa', 'tuition'],
  shortDescription: shortDescription,
);

AdminProcedure _general(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments, {
  String shortDescription = 'General formal support workflow.',
}) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.general,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['generic', 'formal', 'appointment', 'refund', 'complaint'],
  shortDescription: shortDescription,
);

ProcedureDifficulty _difficultyFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.health:
    case ProcedureCategory.publicOffice:
    case ProcedureCategory.work:
      return ProcedureDifficulty.medium;
    case ProcedureCategory.housing:
    case ProcedureCategory.utilities:
    case ProcedureCategory.canoneRai:
      return ProcedureDifficulty.high;
    case ProcedureCategory.telecom:
    case ProcedureCategory.university:
    case ProcedureCategory.general:
    case ProcedureCategory.immigration:
    case ProcedureCategory.complaint:
      return ProcedureDifficulty.medium;
  }
}

int _minutesFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.utilities:
      return 10;
    case ProcedureCategory.canoneRai:
      return 8;
    case ProcedureCategory.housing:
      return 9;
    default:
      return 7;
  }
}

List<String> _recipientsFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.health:
      return const ['ASL', 'Health office'];
    case ProcedureCategory.housing:
      return const ['Landlord', 'Agency', 'Agenzia Entrate'];
    case ProcedureCategory.utilities:
      return const ['Energy provider', 'Customer support'];
    case ProcedureCategory.canoneRai:
      return const ['Agenzia Entrate', 'Energy provider'];
    case ProcedureCategory.telecom:
      return const ['Telecom provider'];
    case ProcedureCategory.publicOffice:
      return const ['Comune', 'Anagrafe'];
    case ProcedureCategory.work:
      return const ['Patronato', 'CAF', 'Employer'];
    case ProcedureCategory.university:
      return const ['University office'];
    case ProcedureCategory.complaint:
      return const ['Company', 'Support office'];
    case ProcedureCategory.general:
    case ProcedureCategory.immigration:
      return const ['Office', 'Company'];
  }
}

ProcedureField _field(
  String id,
  String label,
  ProcedureFieldType type, {
  bool required = true,
  String? section,
  List<FieldOption> options = const [],
  FieldCondition? showWhen,
  FieldValidation? validation,
}) {
  return ProcedureField(
    id: id,
    label: label,
    type: type,
    required: required,
    section: section,
    options: options,
    showWhen: showWhen,
    validation: validation,
  );
}

AttachmentSuggestion _attachment(
  String id,
  String name,
  AttachmentCategory category, {
  bool required = false,
}) {
  return AttachmentSuggestion(
    id: id,
    name: name,
    description: name,
    required: required,
    category: category,
  );
}

List<ProcedureField> _identityFields() => [
  _field('fullName', 'Full name', ProcedureFieldType.text, section: 'Personal'),
  _field(
    'codiceFiscale',
    'Codice fiscale',
    ProcedureFieldType.text,
    required: false,
    section: 'Personal',
  ),
  _field(
    'phone',
    'Phone',
    ProcedureFieldType.phone,
    required: false,
    section: 'Personal',
  ),
  _field(
    'email',
    'Email',
    ProcedureFieldType.email,
    required: false,
    section: 'Personal',
  ),
  _field(
    'city',
    'City',
    ProcedureFieldType.text,
    required: false,
    section: 'Personal',
  ),
];

List<ProcedureField> _changeDoctorFields() => [
  ..._identityFields(),
  _field(
    'addressOrDomicile',
    'Address',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'aslOrOfficeName',
    'ASL or office',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'requestedDoctor',
    'Requested doctor',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'reason',
    'Reason',
    ProcedureFieldType.textarea,
    section: 'Case',
    validation: const FieldValidation(minLength: 12),
  ),
  _field(
    'cannotGoInPerson',
    'Cannot go in person',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
];

List<ProcedureField> _tesseraFields() => [
  ..._identityFields(),
  _field(
    'cardExpiryDate',
    'Card expiry date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'cityOrAsl',
    'City or ASL',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
  _field(
    'canGoInPerson',
    'Can go in person',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
  _field(
    'urgencyReason',
    'Urgency reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _rejectedFields() => [
  _field(
    'officeName',
    'Office name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'originalRequestTopic',
    'Original request topic',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'originalRequestDate',
    'Original request date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'rejectionDate',
    'Rejection date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'rejectionReason',
    'Rejection reason',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'missingDocumentNowAttached',
    'Missing document now attached',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
  _field(
    'desiredOutcome',
    'Desired outcome',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _appointmentFields() => [
  ..._identityFields(),
  _field(
    'recipient',
    'Recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
  _field(
    'preferredDatesOrTimes',
    'Preferred dates or times',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
  _field(
    'urgency',
    'Urgency',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _rentalFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'requestType',
    'Request type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'effectiveDate',
    'Effective date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'allPartiesAgree',
    'All parties agree',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
];

List<ProcedureField> _landlordFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('issueType', 'Issue type', ProcedureFieldType.text, section: 'Case'),
  _field(
    'description',
    'Description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'dateDiscovered',
    'Date discovered',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'desiredAction',
    'Desired action',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _depositFields() => [
  ..._landlordFields(),
  _field(
    'depositAmount',
    'Deposit amount',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'moveOutDate',
    'Move-out date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _terminationFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'terminationDate',
    'Termination date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'noticeReason',
    'Notice reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _genericHousingSupportFields() => [
  _field('fullName', 'Full name', ProcedureFieldType.text, section: 'Personal'),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field('issueType', 'Issue type', ProcedureFieldType.text, section: 'Case'),
  _field(
    'description',
    'Description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _energyBillFields() => [
  _field(
    'providerName',
    'Provider name',
    ProcedureFieldType.text,
    section: 'Bill',
  ),
  _field('billPeriod', 'Bill period', ProcedureFieldType.text, section: 'Bill'),
  _field('amount', 'Amount', ProcedureFieldType.number, section: 'Bill'),
  _field(
    'billType',
    'Bill type',
    ProcedureFieldType.select,
    section: 'Bill',
    options: const [
      FieldOption(value: 'electricity', label: 'Electricity'),
      FieldOption(value: 'gas', label: 'Gas'),
      FieldOption(value: 'water', label: 'Water'),
      FieldOption(value: 'internet', label: 'Internet'),
    ],
  ),
  _field(
    'readingType',
    'Reading type',
    ProcedureFieldType.text,
    required: false,
    section: 'Bill',
  ),
  _field(
    'consumption',
    'Consumption',
    ProcedureFieldType.number,
    required: false,
    section: 'Bill',
  ),
  _field(
    'hasConguaglio',
    'Conguaglio present',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'hasCanoneRai',
    'Canone RAI present',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'amountSeemsAbnormal',
    'Amount seems abnormal',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'previousBillAmount',
    'Previous bill amount',
    ProcedureFieldType.number,
    required: false,
    section: 'Bill',
  ),
];

List<ProcedureField> _energyComparisonFields() => [
  _field(
    'currentProvider',
    'Current provider',
    ProcedureFieldType.text,
    section: 'Current contract',
  ),
  _field(
    'currentAnnualCost',
    'Current annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentMonthlyCost',
    'Current monthly cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentConsumptionKwh',
    'Current kWh consumption',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentGasSmc',
    'Current gas Smc',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'residentDomestic',
    'Resident domestic',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'hasCanoneRaiCharge',
    'Canone RAI charge',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'offerAProvider',
    'Offer A provider',
    ProcedureFieldType.text,
    section: 'Offer A',
  ),
  _field(
    'offerAName',
    'Offer A name',
    ProcedureFieldType.text,
    section: 'Offer A',
  ),
  _field(
    'offerAEstimatedAnnualCost',
    'Offer A estimated annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Offer A',
  ),
  _field(
    'offerBProvider',
    'Offer B provider',
    ProcedureFieldType.text,
    section: 'Offer B',
  ),
  _field(
    'offerBName',
    'Offer B name',
    ProcedureFieldType.text,
    section: 'Offer B',
  ),
  _field(
    'offerBEstimatedAnnualCost',
    'Offer B estimated annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Offer B',
  ),
];

List<ProcedureField> _utilitySwitchFields() => [
  _field(
    'fullName',
    'Contract holder',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field('provider', 'Provider', ProcedureFieldType.text, section: 'Recipient'),
  _field(
    'supplyAddress',
    'Supply address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'podOrPdr',
    'POD / PDR',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
];

List<ProcedureField> _utilityCancellationFields() => [
  ..._utilitySwitchFields(),
  _field(
    'contractNumber',
    'Contract number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'cancellationDate',
    'Cancellation date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _highBillFields() => [
  ..._energyBillFields(),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _meterCorrectionFields() => [
  ..._utilitySwitchFields(),
  _field(
    'meterReadingValue',
    'Correct meter reading',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'invoiceNumber',
    'Invoice number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _paymentPlanFields() => [
  ..._energyBillFields(),
  _field(
    'urgencyReason',
    'Reason for payment plan',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _wrongChargeFields() => [
  ..._energyBillFields(),
  _field(
    'wrongChargeDescription',
    'Wrong charge description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _contractChangeComplaintFields() => [
  ..._energyBillFields(),
  _field(
    'changeNoticeDate',
    'Change notice date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
  _field(
    'issueDescription',
    'Issue description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _canoneFields() => [
  _field(
    'billHolderName',
    'Bill holder name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'codiceFiscale',
    'Codice fiscale',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'hasTV',
    'Has TV',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'householdMemberAlreadyPaying',
    'Another household member already paying',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'yearOfExemption',
    'Year or period',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'billProvider',
    'Bill provider',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _canoneRefundFields() => [
  ..._canoneFields(),
  _field(
    'chargeAlreadyPaid',
    'Charge already paid',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'wantsRefund',
    'Wants refund',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _telecomCancellationFields() => [
  _field('provider', 'Provider', ProcedureFieldType.text, section: 'Recipient'),
  _field(
    'contractHolder',
    'Contract holder',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'customerCode',
    'Customer code',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'contractNumber',
    'Contract number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'serviceAddress',
    'Service address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _telecomComplaintFields() => [
  ..._telecomCancellationFields(),
  _field('issueType', 'Issue type', ProcedureFieldType.text, section: 'Case'),
  _field(
    'invoiceNumber',
    'Invoice number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'amountDisputed',
    'Amount disputed',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'previousContacts',
    'Previous contacts',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _comuneFields() => [
  ..._identityFields(),
  _field(
    'cityOrComune',
    'City or Comune',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('address', 'Address', ProcedureFieldType.text, section: 'Case'),
  _field(
    'requestType',
    'Request type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'issueDescription',
    'Issue description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _anagrafeFields() => [
  ..._identityFields(),
  _field(
    'cityOrComune',
    'City or Comune',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'certificateType',
    'Certificate type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'useReason',
    'Use reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _naspiFields() => [
  ..._identityFields(),
  _field(
    'contractType',
    'Contract type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('employer', 'Employer', ProcedureFieldType.text, section: 'Case'),
  _field(
    'contractEndDate',
    'Contract end date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'terminationReason',
    'Termination reason',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _universityFields() => [
  _field(
    'universityName',
    'University name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'officeName',
    'Office name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'studentName',
    'Student name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'studentId',
    'Student ID',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field('topic', 'Topic', ProcedureFieldType.text, section: 'Case'),
  _field(
    'situation',
    'Situation',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field('request', 'Request', ProcedureFieldType.textarea, section: 'Case'),
];

List<ProcedureField> _permessoFields() => [
  ..._identityFields(),
  _field(
    'permessoType',
    'Permesso type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('expiryDate', 'Expiry date', ProcedureFieldType.date, section: 'Case'),
  _field(
    'officeOrRecipient',
    'Office or recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'missingDocument',
    'Missing document',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _refundFields() => [
  ..._identityFields(),
  _field(
    'companyOrOffice',
    'Company or office',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'serviceOrProduct',
    'Service or product',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'problemDescription',
    'Problem description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _genericFields() => [
  _field(
    'senderName',
    'Sender name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'recipientNameOrOffice',
    'Recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('topic', 'Topic', ProcedureFieldType.text, section: 'Case'),
  _field(
    'situation',
    'Situation',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field('request', 'Request', ProcedureFieldType.textarea, section: 'Case'),
];

List<AttachmentSuggestion> _healthAttachments() => [
  _attachment(
    'id_doc',
    'Documento d’identità',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'cf_doc',
    'Codice fiscale / tessera sanitaria',
    AttachmentCategory.health,
    required: true,
  ),
];

List<AttachmentSuggestion> _tesseraAttachments() => [
  _attachment(
    'id_doc',
    'Documento d’identità',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment('health_card', 'Tessera sanitaria', AttachmentCategory.health),
];

List<AttachmentSuggestion> _rejectedAttachments() => [
  _attachment(
    'notice',
    'Notice or rejection letter',
    AttachmentCategory.administrative,
    required: true,
  ),
  _attachment(
    'supporting_doc',
    'Supporting document',
    AttachmentCategory.administrative,
    required: true,
  ),
];

List<AttachmentSuggestion> _rentalAttachments() => [
  _attachment(
    'lease_copy',
    'Lease copy',
    AttachmentCategory.housing,
    required: true,
  ),
  _attachment(
    'id_docs',
    'ID documents',
    AttachmentCategory.identity,
    required: true,
  ),
];

List<AttachmentSuggestion> _landlordAttachments() => [
  _attachment(
    'photos',
    'Photos or evidence',
    AttachmentCategory.evidence,
    required: true,
  ),
  _attachment('lease_copy', 'Lease copy', AttachmentCategory.housing),
];

List<AttachmentSuggestion> _depositAttachments() => [
  _attachment(
    'lease_copy',
    'Lease copy',
    AttachmentCategory.housing,
    required: true,
  ),
  _attachment('moveout_proof', 'Move-out proof', AttachmentCategory.evidence),
];

List<AttachmentSuggestion> _billAttachments() => [
  _attachment(
    'bill_copy',
    'Bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'screenshots',
    'Screenshots or prior communication',
    AttachmentCategory.evidence,
  ),
];

List<AttachmentSuggestion> _utilityAttachments() => [
  _attachment(
    'contract_copy',
    'Contract or bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
];

List<AttachmentSuggestion> _canoneAttachments() => [
  _attachment(
    'bill_copy',
    'Electricity bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Any supporting declaration or prior payment proof',
    AttachmentCategory.administrative,
  ),
];

List<AttachmentSuggestion> _telecomAttachments() => [
  _attachment(
    'invoice_copy',
    'Invoice or bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'contact_proof',
    'Previous contact proof',
    AttachmentCategory.evidence,
  ),
];

List<AttachmentSuggestion> _comuneAttachments() => [
  _attachment(
    'id_doc',
    'Identity document',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Supporting documents',
    AttachmentCategory.administrative,
  ),
];

List<AttachmentSuggestion> _naspiAttachments() => [
  _attachment(
    'termination_docs',
    'Termination documents',
    AttachmentCategory.employment,
    required: true,
  ),
  _attachment('payslips', 'Recent payslips', AttachmentCategory.employment),
];

List<AttachmentSuggestion> _universityAttachments() => [
  _attachment(
    'student_id',
    'Student ID or card',
    AttachmentCategory.academic,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Supporting documents',
    AttachmentCategory.academic,
  ),
];

List<AttachmentSuggestion> _permessoAttachments() => [
  _attachment(
    'passport',
    'Passport copy',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'permesso_copy',
    'Current permit copy',
    AttachmentCategory.administrative,
    required: true,
  ),
];

List<AttachmentSuggestion> _refundAttachments() => [
  _attachment(
    'receipt',
    'Receipt or invoice',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment('evidence', 'Supporting evidence', AttachmentCategory.evidence),
];

List<AttachmentSuggestion> _genericAttachments() => [
  _attachment(
    'supporting_docs',
    'Supporting documents',
    AttachmentCategory.other,
  ),
];
