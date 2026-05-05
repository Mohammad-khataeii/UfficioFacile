class CityPack {
  const CityPack({
    required this.id,
    required this.cityName,
    required this.region,
    required this.descriptionLocalized,
    required this.recommendedProcedures,
    required this.commonTopics,
    required this.officialLinks,
    required this.localNotes,
    required this.studentTips,
    required this.tenantTips,
    required this.utilityTips,
    required this.healthTips,
    required this.universityTips,
    required this.warnings,
    required this.isActive,
  });

  final String id;
  final String cityName;
  final String region;
  final Map<String, String> descriptionLocalized;
  final List<String> recommendedProcedures;
  final List<String> commonTopics;
  final List<String> officialLinks;
  final List<String> localNotes;
  final List<String> studentTips;
  final List<String> tenantTips;
  final List<String> utilityTips;
  final List<String> healthTips;
  final List<String> universityTips;
  final List<String> warnings;
  final bool isActive;
}
