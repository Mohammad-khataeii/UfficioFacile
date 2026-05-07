import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';

class StartupLoadingScreen extends StatefulWidget {
  const StartupLoadingScreen({super.key, required this.controller});

  final ItalyAdminCopilotController controller;

  @override
  State<StartupLoadingScreen> createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<StartupLoadingScreen> {
  Timer? _timer;
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showFallback = true);
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
                const Text('Starting UfficioFacile...'),
                const SizedBox(height: 8),
                Text('Backend mode: ${state.backendMode}'),
                if (state.usedFallbackLocalMode) ...[
                  const SizedBox(height: 8),
                  const Text('Continuing in local mode.'),
                ],
                if (_showFallback) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.controller.continueWithFallbackLocalMode,
                    child: const Text('Continue in local mode'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.controller.retryStartup,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: widget.controller.resetStartupData,
                    child: const Text('Reset startup data'),
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
                const Text(
                  'UfficioFacile could not finish startup.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unknown startup error.',
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode && state.debugDetails != null) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Debug details'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(state.debugDetails!),
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
                  onPressed: controller.continueWithFallbackLocalMode,
                  child: const Text('Continue local-only'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: controller.resetStartupData,
                  child: const Text('Reset startup data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
