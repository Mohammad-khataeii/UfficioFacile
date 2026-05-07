import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../domain/ufficcio_user_settings.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  late Future<UfficcioUserSettings> _settingsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsFuture = AppScope.of(context).userSettingsRepository.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Center')),
      body: SafeArea(
        child: FutureBuilder<UfficcioUserSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            final settings = snapshot.data ?? const UfficcioUserSettings();
            final counts = scope.privacyCenterService.storageCounts();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Mode'),
                  subtitle: Text(
                    scope.config.isSupabaseEnabled
                        ? 'Supabase-capable, local-first'
                        : 'Local-only mode',
                  ),
                ),
                SwitchListTile(
                  value: settings.analyticsEnabled,
                  onChanged: (value) async {
                    await scope.userSettingsRepository.saveSettings(
                      settings.copyWith(analyticsEnabled: value),
                    );
                    if (mounted) {
                      setState(() {
                        _settingsFuture = scope.userSettingsRepository
                            .getSettings();
                      });
                    }
                  },
                  title: const Text('Allow privacy-safe analytics'),
                ),
                const SizedBox(height: 16),
                const Text('Storage counts'),
                ...counts.entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key),
                    trailing: Text('${entry.value}'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final export = jsonEncode(
                      scope.privacyCenterService.exportData(),
                    );
                    await SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Sensitive local export from UfficioFacile:\n$export',
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share_outlined),
                  label: const Text('Export local data'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await scope.privacyCenterService.deleteLocalData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Local data cleared')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete local data'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.sync),
                  icon: const Icon(Icons.sync_outlined),
                  label: const Text('Open sync settings'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  late Future<UfficcioUserSettings> _settingsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsFuture = AppScope.of(context).userSettingsRepository.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sync settings')),
      body: SafeArea(
        child: FutureBuilder<UfficcioUserSettings>(
          future: _settingsFuture,
          builder: (context, snapshot) {
            final settings = snapshot.data ?? const UfficcioUserSettings();
            return FutureBuilder(
              future: scope.syncService.getStatus(),
              builder: (context, statusSnapshot) {
                final syncStatus = statusSnapshot.data;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Backend mode'),
                      subtitle: Text(scope.config.backendLabel),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Supabase configured'),
                      subtitle: Text('${scope.config.hasSupabaseCredentials}'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Authenticated'),
                      subtitle: Text(
                        '${scope.authFacade.state.isAuthenticated}',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sync status'),
                      subtitle: Text(syncStatus?.state.name ?? 'unknown'),
                    ),
                    SwitchListTile(
                      value: settings.syncEnabled,
                      onChanged: (value) async {
                        await scope.userSettingsRepository.saveSettings(
                          settings.copyWith(syncEnabled: value),
                        );
                        if (mounted) {
                          setState(() {
                            _settingsFuture = scope.userSettingsRepository
                                .getSettings();
                          });
                        }
                      },
                      title: const Text('Enable sync when signed in'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await scope.syncService.syncAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sync status: ${result.state.name}',
                              ),
                            ),
                          );
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync now'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to sync UfficioFacile data across devices. You can also continue using the app locally without an account.',
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
