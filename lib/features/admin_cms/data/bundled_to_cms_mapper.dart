class BundledToCmsMapper {
  const BundledToCmsMapper(this._bundle);

  final Map<String, dynamic> _bundle;

  List<Map<String, dynamic>> exportCategories() {
    return (_bundle['cmsCategories'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> exportProcedures() {
    return (_bundle['cmsProcedures'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
