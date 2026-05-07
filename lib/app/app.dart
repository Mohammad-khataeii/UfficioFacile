import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'app_routes.dart';
import 'app_scope.dart';
import 'app_startup.dart';
import 'app_startup_widgets.dart';
import 'app_theme.dart';
import '../features/italy_admin_copilot/application/italy_admin_copilot_controller.dart';
import '../features/italy_admin_copilot/domain/life_admin_mode.dart';
import '../features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart';
import '../features/italy_admin_copilot/presentation/screens/life_admin_screens.dart';
import '../features/italy_admin_copilot/presentation/screens/life_admin_phase5_screens.dart';

class LifeAdminApp extends StatefulWidget {
  const LifeAdminApp({super.key});

  @override
  State<LifeAdminApp> createState() => _LifeAdminAppState();
}

class _LifeAdminAppState extends State<LifeAdminApp> {
  bool _startupRequested = false;
  bool _deferredLoadsTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startupRequested) return;
    _startupRequested = true;
    final scope = AppScope.of(context);
    unawaited(_initializeStartup(scope));
  }

  Future<void> _initializeStartup(AppScope scope) async {
    await scope.appController.initialize();
    if (!mounted || !scope.appController.startupState.isReady) {
      return;
    }
    _triggerDeferredLoads(scope);
  }

  void _triggerDeferredLoads(AppScope scope) {
    if (_deferredLoadsTriggered) return;
    _deferredLoadsTriggered = true;
    _runDeferredLoad('profile', scope.profileController.load);
    _runDeferredLoad('requests', scope.requestController.load);
    _runDeferredLoad('admin', scope.adminController.load);
  }

  void _runDeferredLoad(String label, Future<void> Function() action) {
    unawaited(() async {
      try {
        await action().timeout(const Duration(seconds: 3));
      } catch (error) {
        assert(() {
          debugPrint('[Startup] Deferred load skipped for $label: $error');
          return true;
        }());
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.appController,
      builder: (context, _) {
        if (scope.appController.startupState.isReady &&
            !_deferredLoadsTriggered) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _triggerDeferredLoads(scope);
            }
          });
        }
        final localizations = AppLocalizations(
          scope.appController.languageCode,
        );
        return AppLocalizationsScope(
          localizations: localizations,
          child: Directionality(
            textDirection: localizations.isRtl
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: MaterialApp(
              title: scope.config.appName,
              debugShowCheckedModeBanner: false,
              locale: Locale(scope.appController.languageCode),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              home: _EntryRouter(controller: scope.appController),
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case AppRoutes.home:
                    return MaterialPageRoute(
                      builder: (_) => const LifeAdminHomeScreen(),
                    );
                  case AppRoutes.onboarding:
                    return MaterialPageRoute(
                      builder: (_) => const OnboardingScreen(),
                    );
                  case AppRoutes.start:
                    return MaterialPageRoute(
                      builder: (_) => const ProblemIntakeScreen(),
                    );
                  case AppRoutes.scan:
                    return MaterialPageRoute(
                      builder: (_) => const ScanMySituationScreen(),
                    );
                  case AppRoutes.cityPacks:
                    return MaterialPageRoute(
                      builder: (_) => const CityPacksScreen(),
                    );
                  case AppRoutes.studentMode:
                    return MaterialPageRoute(
                      builder: (_) =>
                          const ModeScreen(mode: LifeAdminMode.student),
                    );
                  case AppRoutes.tenantMode:
                    return MaterialPageRoute(
                      builder: (_) =>
                          const ModeScreen(mode: LifeAdminMode.tenant),
                    );
                  case AppRoutes.checklist:
                    return MaterialPageRoute(
                      builder: (_) => const ItalyLifeChecklistScreen(),
                    );
                  case AppRoutes.attachmentsHelper:
                    return MaterialPageRoute(
                      builder: (_) => const AttachmentHelperScreen(),
                    );
                  case AppRoutes.household:
                    return MaterialPageRoute(
                      builder: (_) => const HouseholdScreen(),
                    );
                  case AppRoutes.consultant:
                    return MaterialPageRoute(
                      builder: (_) => const ConsultantModePreviewScreen(),
                    );
                  case AppRoutes.deadlines:
                    return MaterialPageRoute(
                      builder: (_) => const DeadlineWatchScreen(),
                    );
                  case AppRoutes.templates:
                    return MaterialPageRoute(
                      builder: (_) => const TemplateLibraryScreen(),
                    );
                  case AppRoutes.proofFolder:
                    return MaterialPageRoute(
                      builder: (_) => const ProofFolderScreen(),
                    );
                  case AppRoutes.costs:
                    return MaterialPageRoute(
                      builder: (_) => const CostSavingDashboardScreen(),
                    );
                  case AppRoutes.officialLinks:
                    return MaterialPageRoute(
                      builder: (_) => const OfficialLinksDirectoryScreen(),
                    );
                  case AppRoutes.documentVault:
                    return MaterialPageRoute(
                      builder: (_) => const DocumentVaultScreen(),
                    );
                  case AppRoutes.contacts:
                    return MaterialPageRoute(
                      builder: (_) => const ContactsDirectoryScreen(),
                    );
                  case AppRoutes.calendar:
                    return MaterialPageRoute(
                      builder: (_) => const LifeAdminCalendarScreen(),
                    );
                  case AppRoutes.procedures:
                    return MaterialPageRoute(
                      builder: (_) => const ProcedureSelectionScreen(),
                    );
                  case AppRoutes.procedureDetail:
                    final args = settings.arguments! as ProcedureRouteArgs;
                    return MaterialPageRoute(
                      builder: (_) =>
                          ProcedureDetailScreen(procedure: args.procedure),
                    );
                  case AppRoutes.procedureStart:
                    final args = settings.arguments! as ProcedureRouteArgs;
                    return MaterialPageRoute(
                      builder: (_) =>
                          GuidedFormScreen(procedure: args.procedure),
                    );
                  case AppRoutes.generated:
                    final args = settings.arguments! as GeneratedRouteArgs;
                    return MaterialPageRoute(
                      builder: (_) => GeneratedPackScreen(
                        procedure: args.procedure,
                        inputData: args.inputData,
                        pack: args.pack,
                      ),
                    );
                  case AppRoutes.requests:
                    return MaterialPageRoute(
                      builder: (_) => const SavedRequestsScreen(),
                    );
                  case AppRoutes.requestDetail:
                    final args = settings.arguments! as RequestRouteArgs;
                    return MaterialPageRoute(
                      builder: (_) =>
                          RequestDetailScreen(request: args.request),
                    );
                  case AppRoutes.plan:
                    return MaterialPageRoute(
                      builder: (_) => const PlanScreen(),
                    );
                  case AppRoutes.terms:
                    final args = settings.arguments! as TermRouteArgs;
                    return MaterialPageRoute(
                      builder: (_) =>
                          TermExplanationScreen(termId: args.termId),
                    );
                  case AppRoutes.profile:
                    return MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    );
                  case AppRoutes.privacy:
                    return MaterialPageRoute(
                      builder: (_) => const PrivacyCenterScreen(),
                    );
                  case AppRoutes.sync:
                    return MaterialPageRoute(
                      builder: (_) => const SyncSettingsScreen(),
                    );
                  case AppRoutes.help:
                    return MaterialPageRoute(
                      builder: (_) => const HelpScreen(),
                    );
                  case AppRoutes.utilities:
                    return MaterialPageRoute(
                      builder: (_) => const UtilityHubScreen(),
                    );
                  case AppRoutes.utilityCompare:
                    return MaterialPageRoute(
                      builder: (_) => const UtilityComparisonScreen(),
                    );
                  case AppRoutes.billAnalyzer:
                    return MaterialPageRoute(
                      builder: (_) => const BillAnalyzerChecklistScreen(),
                    );
                  case AppRoutes.canoneRai:
                    return MaterialPageRoute(
                      builder: (_) => const CanoneRaiHubScreen(),
                    );
                  case AppRoutes.canoneRaiGuide:
                    return MaterialPageRoute(
                      builder: (_) => const CanoneRaiDecisionFlowScreen(),
                    );
                  case AppRoutes.telecom:
                    return MaterialPageRoute(
                      builder: (_) => const TelecomHubScreen(),
                    );
                  case AppRoutes.publicOffice:
                    return MaterialPageRoute(
                      builder: (_) => const PublicOfficeComuneHubScreen(),
                    );
                  case AppRoutes.workInpsPatronato:
                    return MaterialPageRoute(
                      builder: (_) => const WorkInpsPatronatoHubScreen(),
                    );
                  case AppRoutes.universityStudent:
                    return MaterialPageRoute(
                      builder: (_) => const UniversityStudentHubScreen(),
                    );
                  case AppRoutes.general:
                    return MaterialPageRoute(
                      builder: (_) => const GeneralHubScreen(),
                    );
                  case AppRoutes.admin:
                    return MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen(),
                    );
                  case AppRoutes.adminPremium:
                    return MaterialPageRoute(
                      builder: (_) => const AdminPremiumScreen(),
                    );
                  default:
                    return MaterialPageRoute(
                      builder: (_) => const LifeAdminHomeScreen(),
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _EntryRouter extends StatelessWidget {
  const _EntryRouter({required this.controller});

  final ItalyAdminCopilotController controller;

  @override
  Widget build(BuildContext context) {
    switch (decideStartupDestination(controller.startupState)) {
      case StartupDestination.loading:
        return StartupLoadingScreen(controller: controller);
      case StartupDestination.error:
        return StartupErrorScreen(controller: controller);
      case StartupDestination.home:
        return const LifeAdminHomeScreen();
      case StartupDestination.onboarding:
        return const OnboardingScreen();
    }
  }
}
