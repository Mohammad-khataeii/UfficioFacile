import '../models/cms_seed_models.dart';

final housingRentCategorySeed = CmsCategorySeed.externalJsonReference(
  slug: 'housing_rent',
  sortOrder: 2,
  sourcePath: 'assets/catalog/ufficio_catalog.v1.json',
);
