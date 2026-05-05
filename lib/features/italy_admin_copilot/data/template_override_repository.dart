import '../domain/procedure_template_override.dart';

abstract class ProcedureTemplateOverrideRepository {
  Future<List<ProcedureTemplateOverride>> listOverrides();
  Future<void> saveOverride(ProcedureTemplateOverride override);
}
