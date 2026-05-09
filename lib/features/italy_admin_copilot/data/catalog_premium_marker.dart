import '../domain/ufficio_catalog.dart';

class CatalogPremiumMarker {
  const CatalogPremiumMarker();

  bool categoryHasPremiumContent(UfficioCategory category) {
    return category.isPremiumOnly ||
        category.hasPremiumContent ||
        category.subcategories.any(subcategoryHasPremiumContent);
  }

  bool subcategoryHasPremiumContent(UfficioSubcategory subcategory) {
    return subcategory.isPremiumOnly ||
        subcategory.hasPremiumContent ||
        subcategory.procedures.any(procedureIsPremium);
  }

  bool procedureIsPremium(UfficioProcedure procedure) {
    return procedure.isPremiumOnly || procedure.hasPremiumContent;
  }
}
