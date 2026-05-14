class UfficioCity {
  const UfficioCity({
    required this.slug,
    required this.label,
    required this.region,
    required this.isAvailable,
    this.bundledCatalogAsset,
  });

  final String slug;
  final String label;
  final String region;
  final bool isAvailable;
  final String? bundledCatalogAsset;

  UfficioCity copyWith({
    String? slug,
    String? label,
    String? region,
    bool? isAvailable,
    String? bundledCatalogAsset,
  }) {
    return UfficioCity(
      slug: slug ?? this.slug,
      label: label ?? this.label,
      region: region ?? this.region,
      isAvailable: isAvailable ?? this.isAvailable,
      bundledCatalogAsset: bundledCatalogAsset ?? this.bundledCatalogAsset,
    );
  }
}
