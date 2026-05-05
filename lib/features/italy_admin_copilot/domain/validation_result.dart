class ValidationResult {
  const ValidationResult({
    required this.ok,
    this.fieldErrors = const {},
    this.globalErrors = const [],
  });

  final bool ok;
  final Map<String, String> fieldErrors;
  final List<String> globalErrors;
}
