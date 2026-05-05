import '../domain/admin_config.dart';

abstract class AdminConfigRepository {
  Future<AdminConfig> getConfig();
  Future<AdminConfig> saveConfig(AdminConfig config);
}
