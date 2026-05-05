import '../domain/red_flag.dart';

class RedFlagService {
  List<RedFlag> evaluate({
    required String procedureId,
    required Map<String, dynamic> inputData,
  }) {
    final flags = <RedFlag>[];
    final text = inputData.values
        .map((item) => '$item')
        .join(' ')
        .toLowerCase();
    if (text.contains('sfratto') || text.contains('eviction')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.eviction,
          message:
              'This may involve eviction or housing enforcement and could require professional support.',
          severity: 3,
        ),
      );
    }
    if (text.contains('emergency') || text.contains('emergenza medica')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.medicalEmergency,
          message:
              'Medical emergencies should be handled urgently through the competent healthcare channels.',
          severity: 3,
        ),
      );
    }
    if (text.contains('court') || text.contains('tribunale')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.courtNotice,
          message: 'A court or legal notice may require professional advice.',
          severity: 3,
        ),
      );
    }
    if (procedureId == 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST' &&
        inputData['hasTv'] == true) {
      flags.add(
        const RedFlag(
          type: RedFlagType.falseDeclarationRisk,
          message:
              'Warning: the no-TV declaration should only be submitted if truthful. Review official eligibility before proceeding.',
          severity: 3,
        ),
      );
    }
    if (text.contains('fake document') ||
        text.contains('forge') ||
        text.contains('falso documento') ||
        text.contains('documento falso')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.falseDeclarationRisk,
          message:
              'I can’t help with fake documents or false statements. I can help with a truthful correction or clarification request instead.',
          severity: 3,
        ),
      );
    }
    if (text.contains('insult') ||
        text.contains('idiot') ||
        text.contains('stupido')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.aggressiveWording,
          message:
              'Aggressive wording detected. Consider using factual and polite language.',
          severity: 1,
        ),
      );
    }
    if (text.contains('salary') && text.contains('unpaid')) {
      flags.add(
        const RedFlag(
          type: RedFlagType.unpaidLargeDebt,
          message:
              'Unpaid salary or debt language detected. Professional advice may be useful.',
          severity: 2,
        ),
      );
    }
    if ((inputData['recipientName'] ??
            inputData['recipient'] ??
            inputData['officeName']) ==
        null) {
      flags.add(
        const RedFlag(
          type: RedFlagType.missingRecipient,
          message: 'Verify the official recipient before sending.',
          severity: 1,
        ),
      );
    }
    return flags;
  }

  bool hasBlockingRisk({
    required String procedureId,
    required Map<String, dynamic> inputData,
  }) {
    return evaluate(procedureId: procedureId, inputData: inputData).any(
      (flag) =>
          flag.type == RedFlagType.falseDeclarationRisk && flag.severity >= 3,
    );
  }
}
