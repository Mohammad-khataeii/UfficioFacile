import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class ChangeDoctorGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    final reason = valueOrPlaceholder(
      inputData,
      'reason',
      'procedere al cambio del medico di base',
    );
    final requestedDoctor = valueOrPlaceholder(
      inputData,
      'requestedDoctor',
      'il medico richiesto',
    );
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta cambio medico di base',
      recipientLabel: 'aslOrOfficeName',
      requestSummary:
          'richiedere il cambio del medico di base, con preferenza per $requestedDoctor, per il seguente motivo: $reason',
      englishExplanation:
          'This pack asks the local health office for help changing the user’s assigned general practitioner and asks whether the attached documents are sufficient.',
      warnings: [
        if (inputData['cannotGoInPerson'] == true)
          'Explain clearly why an in-person visit is not possible and attach supporting documents if available.',
      ],
      nextSteps: const [
        'If the ASL has an online portal, verify whether a portal ticket or application number should be referenced.',
      ],
    );
  }
}
