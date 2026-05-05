import '../domain/utility_comparison.dart';
import '../domain/utility_offer.dart';
import 'generators/shared_generator_helpers.dart';

class UtilityComparisonService {
  UtilityComparisonResult compare(UtilityComparisonInput input) {
    final riskFlags = <UtilityRiskFlag>[];
    final missingData = <String>[];
    final costs = <String, double>{};
    for (final offer in input.offers.where(
      (item) => item.offerName.trim().isNotEmpty,
    )) {
      final estimated = _estimateAnnualCost(input, offer);
      if (estimated == null) {
        missingData.add(
          'Estimated annual cost missing for ${offer.offerName}.',
        );
        riskFlags.add(UtilityRiskFlag.missingEstimatedAnnualCost);
        continue;
      }
      costs[offer.offerName] = estimated;
      if (offer.priceType == UtilityPriceType.unknown) {
        riskFlags.add(UtilityRiskFlag.unclearPriceType);
      }
      if (offer.fixedMonthlyFee == null) {
        riskFlags.add(UtilityRiskFlag.missingFixedFee);
      }
      if ((offer.contractDuration ?? '').trim().isEmpty) {
        riskFlags.add(UtilityRiskFlag.unclearContractDuration);
      }
      if ((offer.paymentMethod ?? '').trim().isEmpty) {
        riskFlags.add(UtilityRiskFlag.unclearPaymentMethod);
      }
      if (offer.activationCost == null) {
        riskFlags.add(UtilityRiskFlag.unclearActivationCost);
      }
    }

    if (input.currentConsumptionKwh == null &&
        input.currentGasSmc == null &&
        input.currentAnnualCost == null &&
        input.currentMonthlyCost == null) {
      riskFlags.add(UtilityRiskFlag.missingConsumption);
      missingData.add('Current consumption or cost data is missing.');
    }
    if (input.hasCanoneRaiCharge == true) {
      riskFlags.add(UtilityRiskFlag.canoneRaiIncluded);
    }
    if (input.residentDomestic == null) {
      riskFlags.add(UtilityRiskFlag.unclearResidentStatus);
    }
    if (input.noticedUnilateralChange == true) {
      riskFlags.add(UtilityRiskFlag.unilateralChangesSuspected);
    }

    final current =
        input.currentAnnualCost ??
        ((input.currentMonthlyCost ?? 0) > 0
            ? (input.currentMonthlyCost! * 12)
            : null) ??
        0;
    String bestOfferName = 'Not enough data';
    double savings = 0;
    if (costs.isNotEmpty) {
      final sorted = costs.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      bestOfferName = sorted.first.key;
      savings = current > 0 ? current - sorted.first.value : 0;
    }

    return UtilityComparisonResult(
      bestOfferName: bestOfferName,
      estimatedAnnualSavings: savings,
      estimatedMonthlySavings: savings / 12,
      riskFlags: riskFlags.toSet().toList(),
      missingData: missingData,
      checklistBeforeSwitching: const [
        'Verify the official provider documents and summary sheet.',
        'Check whether the price is fixed, variable, or indexed and for how long.',
        'Confirm activation costs, payment method requirements, and contract duration.',
        'Verify conditions on Portale Offerte or the provider’s official pages before switching.',
      ],
      providerQuestions: const [
        'What is the estimated annual cost based on my consumption profile?',
        'Are there activation costs or penalties to consider?',
        'Is the tariff fixed or variable, and what are the update conditions?',
        'Which payment methods are required for bonuses or discounts?',
      ],
      explanation: bestOfferName == 'Not enough data'
          ? 'There is not enough cost information to estimate the cheapest option yet.'
          : 'Based on the data entered, $bestOfferName appears cheaper under your estimated consumption. This is only a manual estimate, not a guaranteed market-wide best offer.',
      disclaimer:
          '$kItalianDisclaimer\n\nAlways verify official provider documents and comparison portals before switching.',
    );
  }

  double? _estimateAnnualCost(
    UtilityComparisonInput input,
    UtilityOffer offer,
  ) {
    if (offer.estimatedAnnualCost != null) {
      return offer.estimatedAnnualCost;
    }
    final fixedPart = (offer.fixedMonthlyFee ?? 0) * 12;
    switch (input.utilityType) {
      case UtilityType.electricity:
        if (input.currentConsumptionKwh != null &&
            offer.energyPriceKwh != null) {
          return fixedPart +
              (input.currentConsumptionKwh! * offer.energyPriceKwh!);
        }
      case UtilityType.gas:
        if (input.currentGasSmc != null && offer.gasPriceSmc != null) {
          return fixedPart + (input.currentGasSmc! * offer.gasPriceSmc!);
        }
      case UtilityType.dual:
        if (input.currentConsumptionKwh != null &&
            offer.energyPriceKwh != null &&
            input.currentGasSmc != null &&
            offer.gasPriceSmc != null) {
          return fixedPart +
              (input.currentConsumptionKwh! * offer.energyPriceKwh!) +
              (input.currentGasSmc! * offer.gasPriceSmc!);
        }
    }
    return null;
  }
}
