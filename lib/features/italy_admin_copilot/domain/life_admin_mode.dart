enum LifeAdminMode { standard, student, tenant, family, consultant }

LifeAdminMode lifeAdminModeFromJson(String? value) {
  return LifeAdminMode.values.firstWhere(
    (item) => item.name == value,
    orElse: () => LifeAdminMode.standard,
  );
}
