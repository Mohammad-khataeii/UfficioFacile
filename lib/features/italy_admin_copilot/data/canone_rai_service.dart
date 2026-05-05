import '../domain/canone_rai_models.dart';

class CanoneRaiService {
  CanoneRaiDecisionResult evaluate(CanoneRaiDecisionInput input) {
    final type = input.requestType ?? 'support';
    String suggestedProcedureId = 'CANONE_RAI_REFUND_OR_WRONG_CHARGE';
    String path =
        'Based on your answers, the relevant path may be a support request.';
    if (type.contains('no-tv') ||
        (input.hasTv == false && input.alreadyPaid != true)) {
      suggestedProcedureId = 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST';
      path =
          'Based on your answers, the relevant path may be the no-TV declaration checklist.';
    } else if (type.contains('75')) {
      suggestedProcedureId = 'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST';
      path =
          'Based on your answers, the relevant path may be the over-75 exemption checklist.';
    }
    return CanoneRaiDecisionResult(
      possiblePath: path,
      requiredChecks: const [
        'Verify eligibility on official Agenzia Entrate instructions before submitting.',
        'Check which year or period is involved and whether the charge has already been paid.',
        'Confirm whether another household member is already paying in the same family household.',
      ],
      documentsNeeded: const [
        'Codice fiscale of the bill holder',
        'Bill details and provider name',
        'Reference year or billing period',
        'Any prior payment or communication related to the Canone RAI charge',
      ],
      warnings: const [
        'Submit only truthful declarations. False declarations can have legal consequences.',
        'The app does not submit the official declaration for you.',
      ],
      officialReminder:
          'Use official Agenzia Entrate channels and instructions for any declaration, exemption, or refund submission.',
      suggestedProcedureId: suggestedProcedureId,
    );
  }
}
