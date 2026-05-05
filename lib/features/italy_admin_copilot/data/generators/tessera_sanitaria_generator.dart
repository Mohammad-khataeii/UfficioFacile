import '../../domain/admin_procedure.dart';
import '../../domain/generated_pack.dart';
import '../generators/shared_generator_helpers.dart';

class TesseraSanitariaGenerator {
  static GeneratedPack generate(
    AdminProcedure procedure,
    Map<String, dynamic> inputData,
  ) {
    final reason = valueOrPlaceholder(
      inputData,
      'reason',
      'gestire il problema relativo alla tessera sanitaria',
    );
    return buildStandardPack(
      procedure: procedure,
      inputData: inputData,
      subject: 'Richiesta supporto tessera sanitaria',
      recipientLabel: 'cityOrAsl',
      requestSummary:
          'ricevere assistenza per la tessera sanitaria in relazione al seguente problema: $reason',
      englishExplanation:
          'This pack asks the health office for support with a health card issue such as expiry, missing delivery, loss, or incorrect data.',
      warnings: [
        if (inputData['canGoInPerson'] == false)
          'State clearly why an in-person visit is not feasible and ask whether remote handling is allowed.',
      ],
    );
  }
}
