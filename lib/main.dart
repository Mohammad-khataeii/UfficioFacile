import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'app/app_scope.dart';
import 'app/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp(config: UfficcioFacileConfig.fromEnv));
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp({required this.config});

  final UfficcioFacileConfig config;

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  SharedPreferences? _prefs;
  SupabaseBootstrapResult _bootstrapResult = const SupabaseBootstrapResult(
    configured: false,
    initialized: false,
  );
  Object? _fatalError;
  StackTrace? _fatalStackTrace;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _fatalError = null;
      _fatalStackTrace = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      SupabaseBootstrapResult bootstrapResult;
      try {
        bootstrapResult =
            await SupabaseBootstrap.initializeIfNeeded(widget.config).timeout(
              const Duration(seconds: 3),
              onTimeout: () => SupabaseBootstrapResult(
                configured: widget.config.isSupabaseEnabled,
                initialized: false,
                error: TimeoutException('Supabase bootstrap timed out'),
              ),
            );
      } catch (error) {
        bootstrapResult = SupabaseBootstrapResult(
          configured: widget.config.isSupabaseEnabled,
          initialized: false,
          error: error,
        );
      }

      if (widget.config.mustFailLoudOnMissingSupabase &&
          !widget.config.hasSupabaseCredentials) {
        throw StateError(
          'This production build is missing required Supabase configuration.',
        );
      }
      if (widget.config.mustFailLoudOnMissingSupabase &&
          !bootstrapResult.initialized) {
        throw StateError(
          'This production build could not connect to its configured backend.',
        );
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _prefs = prefs;
        _bootstrapResult = bootstrapResult;
        _loading = false;
      });
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fatalError = error;
        _fatalStackTrace = stackTrace;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs != null) {
      return AppScope(
        prefs: _prefs!,
        config: widget.config,
        supabaseBootstrapResult: _bootstrapResult,
        child: const LifeAdminApp(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_loading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Starting UfficioFacile...'),
                    const SizedBox(height: 8),
                    Text('Backend mode: ${widget.config.backendLabel}'),
                  ] else ...[
                    const Icon(Icons.error_outline, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'UfficioFacile could not start safely.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.config.mustFailLoudOnMissingSupabase
                          ? 'This build is not correctly configured for production. Please contact support.'
                          : 'Please retry. If the problem continues, reset browser or app storage.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (kDebugMode && _fatalError != null) ...[
                      const SizedBox(height: 16),
                      ExpansionTile(
                        title: const Text('Debug details'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('$_fatalError\n$_fatalStackTrace'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initialize,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
