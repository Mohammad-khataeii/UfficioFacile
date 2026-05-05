import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'app_routes.dart';
import 'app_scope.dart';
import 'app_theme.dart';
import '../features/italy_admin_copilot/domain/life_admin_mode.dart';
import '../features/italy_admin_copilot/presentation/screens/life_admin_screens.dart';
import '../features/italy_admin_copilot/presentation/screens/life_admin_phase5_screens.dart';

class LifeAdminApp extends StatefulWidget {
  const LifeAdminApp({super.key});

  @override
  State<LifeAdminApp> createState() => _LifeAdminAppState();
}

class _LifeAdminAppState extends State<LifeAdminApp> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final scope = AppScope.of(context);
    scope.appController.initialize();
    scope.profileController.load();
    scope.requestController.load();
    scope.adminController.load();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.appController,
      builder: (context, _) {
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
              title: localizations.t('app_title'),
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
              home: const _EntryRouter(),
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
                  case AppRoutes.profile:
                    return MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
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
                  case AppRoutes.admin:
                    return MaterialPageRoute(
                      builder: (_) => const AdminPanelScreen(),
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
  const _EntryRouter();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context).appController;
    if (!app.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return app.onboardingState.completed
        ? const LifeAdminHomeScreen()
        : const OnboardingScreen();
  }
}
