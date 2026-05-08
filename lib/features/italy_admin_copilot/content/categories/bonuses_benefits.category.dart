import '../models/cms_seed_models.dart';

const _bonusLoansSeedPath = 'apps/admin/data/seed/bonus_loans_categories.json';

final bonusesBenefitsCategorySeed = CmsCategorySeed.externalJsonReference(
  slug: 'bonuses-benefits',
  sortOrder: 10,
  sourcePath: _bonusLoansSeedPath,
);
