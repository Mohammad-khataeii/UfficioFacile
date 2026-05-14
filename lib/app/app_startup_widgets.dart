import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_localizations.dart';
import '../features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';

class StartupLoadingScreen extends StatefulWidget {
  const StartupLoadingScreen({super.key, required this.controller});

  final ItalyAdminCopilotController controller;

  @override
  State<StartupLoadingScreen> createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<StartupLoadingScreen> {
  Timer? _timer;
  bool _showRecovery = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showRecovery = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.startupState;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(context.l10n.t('startup_loading')),
                const SizedBox(height: 8),
                Text('Backend mode: ${state.backendMode}'),
                Text('Flavor: ${state.flavor}'),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(context.l10n.t('startup_diagnostics')),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'supabaseConfigured=${state.supabaseConfigured}\n'
                          'supabaseInitialized=${state.supabaseInitialized}\n'
                          'language=${state.languageCode}\n'
                          'remoteCatalogAvailable=${state.remoteCatalogAvailable}\n'
                          'canFallbackToLocalMode=${state.canFallbackToLocalMode}',
                        ),
                      ),
                    ],
                  ),
                ],
                if (_showRecovery) ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: widget.controller.retryStartup,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.controller.resetStartupData,
                    child: Text(context.l10n.t('startup_reset_data')),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.controller});

  final ItalyAdminCopilotController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.startupState;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  context.l10n.t('startup_error_title'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? context.l10n.t('startup_unknown_error'),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode && state.debugDetails != null) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(context.l10n.t('startup_diagnostics')),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'backend=${state.backendMode}\n'
                          'flavor=${state.flavor}\n'
                          'supabaseConfigured=${state.supabaseConfigured}\n'
                          'supabaseInitialized=${state.supabaseInitialized}\n'
                          'language=${state.languageCode}\n'
                          'remoteCatalogAvailable=${state.remoteCatalogAvailable}\n\n'
                          '${state.debugDetails!}',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.retryStartup,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: controller.resetStartupData,
                  child: Text(context.l10n.t('startup_reset_data')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
