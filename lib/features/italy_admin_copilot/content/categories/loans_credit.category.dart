import '../models/cms_seed_models.dart';

const _bonusLoansSeedPath = 'apps/admin/data/seed/bonus_loans_categories.json';

final loansCreditCategorySeed = CmsCategorySeed.externalJsonReference(
  slug: 'loans-credit',
  sortOrder: 11,
  sourcePath: _bonusLoansSeedPath,
);
