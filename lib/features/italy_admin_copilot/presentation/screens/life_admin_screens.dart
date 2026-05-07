import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../data/demo_data_service.dart';
import '../../data/catalog_repository.dart';
import '../../data/canone_rai_guidance_definitions.dart';
import '../../data/general_guidance_definitions.dart';
import '../../data/health_asl_guidance_definitions.dart';
import '../../data/housing_rent_guidance_definitions.dart';
import '../../data/pack_generator.dart';
import '../../data/public_office_comune_guidance_definitions.dart';
import '../../data/procedure_validator.dart';
import '../../data/red_flag_service.dart';
import '../../data/life_admin_phase5_services.dart';
import '../../data/procedure_definitions.dart';
import '../../data/service_intelligence_definitions.dart';
import '../../data/service_intelligence_quality_service.dart';
import '../../data/service_terms_dictionary.dart';
import '../../data/telecom_guidance_definitions.dart';
import '../../data/ufficio_product_services.dart';
import '../../data/university_student_guidance_definitions.dart';
import '../../data/utilities_electricity_gas_guidance_definitions.dart';
import '../../data/work_inps_patronato_guidance_definitions.dart';
import '../../domain/admin_copilot_profile.dart';
import '../../domain/admin_procedure.dart';
import '../../domain/admin_request.dart';
import '../../domain/bill_analysis.dart';
import '../../domain/catalog_models.dart' as catalog;
import '../../domain/city_pack.dart';
import '../../domain/generated_pack.dart';
import '../../domain/health_asl_guidance.dart';
import '../../domain/housing_rent_guidance.dart';
import '../../domain/household_contract.dart';
import '../../domain/life_admin_mode.dart';
import '../../domain/official_link.dart';
import '../../domain/premium_config.dart';
import '../../domain/procedure_field.dart';
import '../../domain/procedure_recommendation.dart';
import '../../domain/reminder.dart';
import '../../domain/request_status.dart';
import '../../domain/service_intelligence.dart';
import '../../domain/sync_models.dart';
import '../../domain/rich_category_models.dart';
import '../../domain/utility_comparison.dart';
import '../../domain/utility_offer.dart';
import 'life_admin_phase5_screens.dart';

class ProcedureRouteArgs {
  const ProcedureRouteArgs(this.procedure);
  final AdminProcedure procedure;
}

class GeneratedRouteArgs {
  const GeneratedRouteArgs({
    required this.procedure,
    required this.inputData,
    required this.pack,
  });

  final AdminProcedure procedure;
  final Map<String, dynamic> inputData;
  final GeneratedPack pack;
}

class RequestRouteArgs {
  const RequestRouteArgs(this.request);
  final AdminCopilotRequest request;
}

class TermRouteArgs {
  const TermRouteArgs(this.termId);
  final String termId;
}

String _localizedCatalogText(
  BuildContext context,
  Map<String, String> values, {
  String fallback = '',
}) => catalog.localizedValue(
  values,
  context.l10n.languageCode,
  fallback: fallback,
);

String? _providerCategoryForProcedure(AdminProcedure procedure) {
  if (procedure.category == ProcedureCategory.telecom) {
    return 'telecom';
  }
  if (procedure.category == ProcedureCategory.utilities) {
    return 'dualEnergy';
  }
  return null;
}

class LifeAdminHomeScreen extends StatefulWidget {
  const LifeAdminHomeScreen({super.key});

  @override
  State<LifeAdminHomeScreen> createState() => _LifeAdminHomeScreenState();
}

class _LifeAdminHomeScreenState extends State<LifeAdminHomeScreen> {
  Future<List<HouseholdContract>>? _contractsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contractsFuture ??= AppScope.of(context).contractsRepository.list();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final app = scope.appController;
    final requests = scope.requestController.requests;
    final profile = scope.profileController.profile;
    final dueReminders = requests
        .expand((item) => item.reminders.map((reminder) => (item, reminder)))
        .where((tuple) => !tuple.$2.isDone)
        .take(3)
        .toList();
    final checklistItems = scope.checklistService.itemsForMode(
      lifeAdminModeFromJson(profile.activeMode),
    );
    final checklistProgress = scope.checklistService.progress(checklistItems);
    CityPack? cityPack;
    if (profile.selectedCityPackId != null) {
      for (final item in scope.cityPackService.all()) {
        if (item.id == profile.selectedCityPackId) {
          cityPack = item;
          break;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('app_title')),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
            icon: const Icon(Icons.workspace_premium_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
          if (app.config.adminModeEnabled)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder(
              future: scope.entitlementService.getCurrentEntitlement(),
              builder: (context, snapshot) {
                final entitlement = snapshot.data;
                if (entitlement == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: UpgradeBanner(entitlement: entitlement),
                );
              },
            ),
            _HeroCard(
              title: context.l10n.t('hero_title'),
              subtitle: context.l10n.t('hero_subtitle'),
              actions: [
                _PrimaryAction(
                  icon: Icons.radar_outlined,
                  label: context.l10n.t('scan_situation'),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.scan),
                ),
                _PrimaryAction(
                  icon: Icons.auto_awesome,
                  label: context.l10n.t('start_problem'),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.start),
                ),
                _PrimaryAction(
                  icon: Icons.folder_open_outlined,
                  label: context.l10n.t('browse_procedures'),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _PrimaryAction(
                  icon: Icons.bolt_outlined,
                  label: context.l10n.t('utilities_bills'),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.utilities),
                ),
                _PrimaryAction(
                  icon: Icons.inventory_2_outlined,
                  label: context.l10n.t('saved_requests'),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'My Italy Life',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checklist progress: $checklistProgress%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: checklistProgress / 100),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.checklist),
                        icon: const Icon(Icons.checklist_outlined),
                        label: Text(context.l10n.t('life_checklist')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.deadlines),
                        icon: const Icon(Icons.event_note_outlined),
                        label: const Text('Deadlines'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.costs),
                        icon: const Icon(Icons.savings_outlined),
                        label: Text(context.l10n.t('cost_dashboard')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.proofFolder),
                        icon: const Icon(Icons.inventory_outlined),
                        label: Text(context.l10n.t('proof_folder')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (dueReminders.isNotEmpty)
              _SectionCard(
                title: context.l10n.t('upcoming_reminders'),
                child: Column(
                  children: dueReminders
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.notifications_outlined),
                          title: Text(entry.$2.title),
                          subtitle: Text(
                            '${entry.$1.procedureTitle} • ${DateFormat('dd MMM').format(entry.$2.reminderDate)}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            if (cityPack != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SectionCard(
                  title: 'City pack',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(cityPack.cityName),
                    subtitle: Text(cityPack.region),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.cityPacks),
                  ),
                ),
              ),
            FutureBuilder<List<UfficioCostItem>>(
              future: scope.costDashboardService.listCostItems(),
              builder: (context, snapshot) {
                final costItems = snapshot.data ?? const [];
                final summary = scope.costDashboardService.calculateCostSummary(
                  costItems,
                );
                return _SectionCard(
                  title: 'Cost dashboard',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Estimated expenses: €${summary.totalEstimatedExpenses.toStringAsFixed(2)}',
                    ),
                    subtitle: const Text(
                      'Track procedure fees, refunds, installments, and disputed amounts.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.costs),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CategoryTile(
                  'Bureaucracy',
                  Icons.account_balance_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _CategoryTile(
                  'Comune / Anagrafe',
                  Icons.location_city_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.publicOffice),
                ),
                _CategoryTile(
                  'Health / ASL',
                  Icons.local_hospital_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _CategoryTile(
                  'House & Rent',
                  Icons.home_work_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _CategoryTile(
                  'Bills & Utilities',
                  Icons.receipt_long_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.utilities),
                ),
                _CategoryTile(
                  'Canone RAI',
                  Icons.tv_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.canoneRai),
                ),
                _CategoryTile(
                  'Internet & Phone',
                  Icons.wifi_tethering_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.telecom),
                ),
                _CategoryTile(
                  'Work / INPS',
                  Icons.work_outline,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.workInpsPatronato,
                  ),
                ),
                _CategoryTile(
                  'University',
                  Icons.school_outlined,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.universityStudent,
                  ),
                ),
                _CategoryTile(
                  'General',
                  Icons.report_problem_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.general),
                ),
                _CategoryTile(
                  'Documents',
                  Icons.folder_copy_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.documentVault),
                ),
                _CategoryTile(
                  'Contacts',
                  Icons.contacts_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.contacts),
                ),
                _CategoryTile(
                  'Official links',
                  Icons.verified_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.officialLinks),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.t('recent_requests'),
              child: requests.isEmpty
                  ? Text(context.l10n.t('disclaimer_short'))
                  : Column(
                      children: requests.take(3).map((request) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(request.procedureTitle),
                          subtitle: Text(request.status.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.requestDetail,
                            arguments: RequestRouteArgs(request),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Trust',
              child: Text(context.l10n.t('disclaimer_short')),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  final _fullNameController = TextEditingController();
  final _cfController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _cfController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _index = index),
                children: [
                  _OnboardingPage(
                    title: context.l10n.t('onboarding_title'),
                    body: context.l10n.t('onboarding_subtitle'),
                    icon: Icons.assistant_navigation,
                  ),
                  _OnboardingPage(
                    title: 'What can it help with?',
                    body:
                        'Bills & utilities, Canone RAI, ASL & health, rent & housing, telecom complaints, work and university life.',
                    icon: Icons.widgets_outlined,
                  ),
                  _OnboardingPage(
                    title: context.l10n.t('privacy_title'),
                    body:
                        'The app helps organize and draft. You still need to verify official rules, offices, and deadlines. Do not submit false declarations.',
                    icon: Icons.shield_outlined,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ListView(
                      children: [
                        Text(
                          'Optional profile setup',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cfController,
                          decoration: const InputDecoration(
                            labelText: 'Codice fiscale',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                      ],
                    ),
                  ),
                  _OnboardingPage(
                    title: 'Ready',
                    body:
                        'Start from your problem or browse procedures whenever you want. You can reopen onboarding from Help later.',
                    icon: Icons.rocket_launch_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await scope.appController.completeOnboarding();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                    child: Text(context.l10n.t('skip')),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (_index < 4) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                        return;
                      }
                      if (_fullNameController.text.trim().isNotEmpty) {
                        await scope.profileController.save(
                          AdminCopilotProfile(
                            fullName: _fullNameController.text.trim(),
                            codiceFiscale: _cfController.text.trim(),
                            city: _cityController.text.trim(),
                            email: _emailController.text.trim(),
                          ),
                        );
                      }
                      await scope.appController.completeOnboarding();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                    child: Text(
                      _index == 4
                          ? context.l10n.t('done')
                          : context.l10n.t('next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProblemIntakeScreen extends StatefulWidget {
  const ProblemIntakeScreen({super.key});

  @override
  State<ProblemIntakeScreen> createState() => _ProblemIntakeScreenState();
}

class _ProblemIntakeScreenState extends State<ProblemIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ProcedureRecommendation> _recommendations = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final procedures = AppScope.of(context).procedureController;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('start_problem'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.l10n.t('what_help'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Example: remove canone rai, cheap electricity, change doctor...',
              ),
              onChanged: (value) {
                setState(() {
                  _recommendations = procedures.recommend(value);
                });
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'I want to remove Canone RAI from my electricity bill',
                        'My gas bill is too high',
                        'I need to change medico di base',
                        'I want to cancel internet',
                        'My landlord is not fixing the heating',
                        'I need NASpI',
                      ]
                      .map(
                        (item) => ActionChip(
                          label: Text(item),
                          onPressed: () {
                            _controller.text = item;
                            setState(() {
                              _recommendations = procedures.recommend(item);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            if (_recommendations.isEmpty)
              Text(context.l10n.t('no_results'))
            else
              ..._recommendations.map((item) {
                final procedure = procedures.procedures.firstWhere(
                  (element) => element.id == item.procedureId,
                );
                return Card(
                  child: ListTile(
                    title: Text(procedure.title),
                    subtitle: Text('${item.reason}\n${item.category}'),
                    trailing: Text('${(item.confidence * 100).round()}%'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.procedureDetail,
                      arguments: ProcedureRouteArgs(procedure),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class ProcedureSelectionScreen extends StatefulWidget {
  const ProcedureSelectionScreen({super.key});

  @override
  State<ProcedureSelectionScreen> createState() =>
      _ProcedureSelectionScreenState();
}

class _ProcedureSelectionScreenState extends State<ProcedureSelectionScreen> {
  String query = '';
  ProcedureCategory? category;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).procedureController;
    final items = controller.search(query: query, category: category);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('browse_procedures'))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by title, tag, description...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: category == null,
                    onSelected: (_) => setState(() => category = null),
                  ),
                  const SizedBox(width: 8),
                  ...ProcedureCategory.values.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item.label),
                        selected: category == item,
                        onSelected: (_) => setState(() => category = item),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final procedure = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(procedure.title)),
                          if (procedure.isPremium)
                            const PremiumBadge(label: 'Pro'),
                        ],
                      ),
                      subtitle: Text(
                        '${procedure.category.label} • ${procedure.subcategory} • ${procedure.estimatedMinutes} min',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.procedureDetail,
                        arguments: ProcedureRouteArgs(procedure),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcedureDetailScreen extends StatelessWidget {
  const ProcedureDetailScreen({super.key, required this.procedure});

  final AdminProcedure procedure;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final intelligence = ServiceIntelligenceDefinitions.forProcedure(procedure);
    final healthGuidance = HealthAslGuidanceDefinitions.forProcedureId(
      procedure.id,
    );
    final housingGuidance = HousingRentGuidanceDefinitions.forProcedureId(
      procedure.id,
    );
    final utilityGuidance =
        UtilitiesElectricityGasGuidanceDefinitions.forProcedureId(procedure.id);
    final canoneGuidance = CanoneRaiGuidanceDefinitions.forProcedureId(
      procedure.id,
    );
    final telecomGuidance = TelecomGuidanceDefinitions.forProcedureId(
      procedure.id,
    );
    final publicOfficeGuidance =
        PublicOfficeComuneGuidanceDefinitions.forProcedureId(procedure.id);
    final workGuidance =
        WorkInpsPatronatoGuidanceDefinitions.forProcedureId(procedure.id);
    final universityGuidance =
        UniversityStudentGuidanceDefinitions.forProcedureId(procedure.id);
    final generalGuidance = GeneralGuidanceDefinitions.forProcedureId(
      procedure.id,
    );
    final hasRichDetail =
        healthGuidance != null ||
        housingGuidance != null ||
        utilityGuidance != null ||
        canoneGuidance != null ||
        telecomGuidance != null ||
        publicOfficeGuidance != null ||
        workGuidance != null ||
        universityGuidance != null ||
        generalGuidance != null;
    final providerCategory = _providerCategoryForProcedure(procedure);
    return Scaffold(
      appBar: AppBar(title: Text(procedure.title)),
      body: SafeArea(
        child: FutureBuilder(
          future: Future.wait([
            scope.catalogRepository.getProcedureGuidance(procedure.id),
            scope.catalogRepository.listOfficialLinks(),
            scope.catalogRepository.listOfficialContacts(),
            scope.catalogRepository.listSourceReferences(),
            scope.catalogRepository.listSubmissionChannels(),
            if (providerCategory != null)
              scope.catalogRepository.getProvidersByCategory(providerCategory)
            else
              Future.value(<catalog.ServiceProvider>[]),
          ]),
          builder: (context, snapshot) {
            final guidance = snapshot.hasData
                ? snapshot.data![0] as catalog.ProcedureGuidance?
                : null;
            final catalogLinks = snapshot.hasData
                ? snapshot.data![1] as List<catalog.OfficialLink>
                : <catalog.OfficialLink>[];
            final contacts = snapshot.hasData
                ? snapshot.data![2] as List<catalog.OfficialContact>
                : <catalog.OfficialContact>[];
            final references = snapshot.hasData
                ? snapshot.data![3] as List<catalog.SourceReference>
                : <catalog.SourceReference>[];
            final channels = snapshot.hasData
                ? snapshot.data![4] as List<catalog.SubmissionChannel>
                : <catalog.SubmissionChannel>[];
            final providers = snapshot.hasData
                ? snapshot.data![5] as List<catalog.ServiceProvider>
                : <catalog.ServiceProvider>[];
            final officialLinks = catalogLinks
                .where(
                  (item) =>
                      guidance?.officialLinkIds.contains(item.id) == true ||
                      intelligence.officialLinks.contains(item.id),
                )
                .toList();
            final exactContacts = contacts
                .where(
                  (item) =>
                      guidance?.officialContactIds.contains(item.id) == true,
                )
                .toList();
            final sourceRefs = references
                .where(
                  (item) =>
                      guidance?.sourceReferenceIds.contains(item.id) == true,
                )
                .toList();
            final recommendedChannels =
                channels
                    .where(
                      (item) =>
                          guidance?.submissionChannelIds.contains(item.id) ==
                          true,
                    )
                    .toList()
                  ..sort((a, b) => a.priority.compareTo(b.priority));
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: procedure.subcategory,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(procedure.category.label)),
                          Chip(label: Text(procedure.difficulty.label)),
                          Chip(
                            label: Text('${procedure.estimatedMinutes} min'),
                          ),
                          VerificationStatusBadge(
                            status: intelligence.verificationStatus,
                          ),
                          if (procedure.isPremium)
                            const PremiumBadge(label: 'Pro'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasRichDetail
                            ? procedure.shortDescription
                            : guidance != null
                            ? _localizedCatalogText(
                                context,
                                guidance.summary,
                                fallback: procedure.longDescription,
                              )
                            : procedure.longDescription,
                      ),
                      if (procedure.isPremium) ...[
                        const SizedBox(height: 12),
                        FutureBuilder(
                          future: scope.entitlementService.canUseProcedure(
                            procedure.id,
                          ),
                          builder: (context, snapshot) {
                            final decision = snapshot.data;
                            if (decision == null ||
                                (!decision.isPremiumFeature &&
                                    !procedure.isPremium)) {
                              return const SizedBox.shrink();
                            }
                            return Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  decision.blockedByBeta
                                      ? 'Pro feature included during beta.'
                                      : 'This procedure is part of Pro. You can review the guidance and upgrade settings from the plan screen.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!hasRichDetail)
                  _SectionCard(
                    title: 'Best way to handle this',
                    child: Text(
                      guidance != null
                          ? _localizedCatalogText(
                              context,
                              guidance.summary,
                              fallback: intelligence.destinationGuidance,
                            )
                          : intelligence.destinationGuidance,
                    ),
                  ),
                if (healthGuidance != null) ...[
                  const SizedBox(height: 16),
                  _HealthAslPracticalGuidanceCard(guidance: healthGuidance),
                ],
                if (housingGuidance != null) ...[
                  const SizedBox(height: 16),
                  _HousingRentPracticalGuidanceCard(
                    categoryGuidance: HousingRentGuidanceDefinitions.category,
                    subcategoryGuidance: housingGuidance,
                  ),
                ],
                if (utilityGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance:
                        UtilitiesElectricityGasGuidanceDefinitions.category,
                    subcategoryGuidance: utilityGuidance,
                  ),
                ],
                if (canoneGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: CanoneRaiGuidanceDefinitions.category,
                    subcategoryGuidance: canoneGuidance,
                  ),
                ],
                if (telecomGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: TelecomGuidanceDefinitions.category,
                    subcategoryGuidance: telecomGuidance,
                  ),
                ],
                if (publicOfficeGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: PublicOfficeComuneGuidanceDefinitions.category,
                    subcategoryGuidance: publicOfficeGuidance,
                  ),
                ],
                if (workGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: WorkInpsPatronatoGuidanceDefinitions.category,
                    subcategoryGuidance: workGuidance,
                  ),
                ],
                if (universityGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: UniversityStudentGuidanceDefinitions.category,
                    subcategoryGuidance: universityGuidance,
                  ),
                ],
                if (generalGuidance != null) ...[
                  const SizedBox(height: 16),
                  _RichCategoryPracticalGuidanceCard(
                    categoryGuidance: GeneralGuidanceDefinitions.category,
                    subcategoryGuidance: generalGuidance,
                  ),
                ],
                const SizedBox(height: 16),
                if (!hasRichDetail && recommendedChannels.isNotEmpty)
                  _SectionCard(
                    title: 'Choose how you want to send it',
                    child: Column(
                      children: recommendedChannels
                          .map(
                            (channel) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  _localizedCatalogText(context, channel.title),
                                ),
                                subtitle: Text(
                                  '${_localizedCatalogText(context, channel.whenToUse)}\n${_localizedCatalogText(context, channel.description)}',
                                ),
                                trailing: Text(channel.type),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (!hasRichDetail && recommendedChannels.isNotEmpty)
                  const SizedBox(height: 16),
                if (!hasRichDetail)
                  DestinationGuidanceCard(
                    intelligence: intelligence,
                    officialLinks: officialLinks,
                  ),
                if (!hasRichDetail && guidance != null) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Exact contacts found',
                    child: exactContacts.isEmpty
                        ? const Text(
                            'No exact verified email/PEC is stored yet. Use the official source below to verify the correct destination before sending.',
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: exactContacts
                                .map(
                                  (item) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(item.label),
                                    subtitle: Text(
                                      '${item.displayValue}\n${item.sourceUrl ?? item.sourceLabel ?? ''}',
                                    ),
                                    trailing: Text(
                                      item.verificationStatus.name,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
                if (!hasRichDetail && providers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Provider / authority',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select your provider in the guided form. Review the official website or customer area before using any contact channel.',
                        ),
                        const SizedBox(height: 8),
                        ...providers
                            .take(12)
                            .map(
                              (item) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                          ),
                                          Text(item.verificationStatus.name),
                                        ],
                                      ),
                                      if ((item.websiteUrl ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(item.websiteUrl!),
                                      ],
                                      if ((item.customerAreaUrl ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Customer area: ${item.customerAreaUrl}',
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        _localizedCatalogText(
                                          context,
                                          item.cancellationGuidance,
                                        ),
                                      ),
                                      if (item.contactOptions.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        ...item.contactOptions
                                            .take(3)
                                            .map(
                                              (option) => Text(
                                                '- ${option.label}: ${option.value ?? option.url ?? _localizedCatalogText(context, option.description)}',
                                              ),
                                            ),
                                      ],
                                      if (item.forms.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        ...item.forms
                                            .take(2)
                                            .map(
                                              (form) => Text(
                                                '- Form: ${form.title}${form.url != null ? '\n  ${form.url}' : ''}',
                                              ),
                                            ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
                if (!hasRichDetail) const SizedBox(height: 16),
                _SectionCard(
                  title: 'Forms and official pages',
                  child: officialLinks.isEmpty
                      ? const Text(
                          'No exact verified contact stored yet. Use the official provider, city, region, or authority page to verify the correct path before sending.',
                        )
                      : Column(
                          children: officialLinks
                              .map((item) => OfficialLinkCard(link: item))
                              .toList(),
                        ),
                ),
                if (!hasRichDetail) ...[
                  const SizedBox(height: 16),
                  OnlineOptionsCard(intelligence: intelligence),
                  const SizedBox(height: 16),
                  InPersonOptionsCard(intelligence: intelligence),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'What this generates',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ClickableTermText(
                          'Formal Italian email, PEC-style version, short message, follow-up, stronger follow-up, checklist, warnings, and next steps.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailedDocumentsCard(
                    procedure: procedure,
                    intelligence: intelligence,
                  ),
                  if (guidance != null) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Documents and proof',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...guidance.requiredDocuments.map(
                            (item) => Text('- $item'),
                          ),
                          ...guidance.recommendedDocuments.map(
                            (item) => Text('- $item'),
                          ),
                          ...guidance.proofItems.map((item) => Text('- $item')),
                        ],
                      ),
                    ),
                  ],
                ],
                if (sourceRefs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Legal / official references',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...sourceRefs.map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.title),
                            subtitle: Text(
                              '${_localizedCatalogText(context, item.explanation)}\n${item.url ?? ''}',
                            ),
                            trailing: Text(item.verificationStatus.name),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is practical guidance only and not legal advice.',
                        ),
                      ],
                    ),
                  ),
                ],
                if (!hasRichDetail) ...[
                  const SizedBox(height: 16),
                  BeforeSendingGuidanceCard(intelligence: intelligence),
                  if (guidance != null) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Before sending',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: guidance.beforeSendingChecklist
                            .map((item) => Text('- $item'))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FollowUpGuidanceCard(
                    intelligence: intelligence,
                    procedure: procedure,
                  ),
                ],
                const SizedBox(height: 16),
                ServiceWarningsCard(intelligence: intelligence),
                const SizedBox(height: 16),
                GlobalProblemRequestCard(
                  categoryId: procedure.category.name,
                  subcategoryId: procedure.id,
                  sourcePage: procedure.title,
                ),
                const SizedBox(height: 12),
                PrivateConsultancyCard(
                  categoryId: procedure.category.name,
                  subcategoryId: procedure.id,
                  sourcePage: procedure.title,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.procedureStart,
                    arguments: ProcedureRouteArgs(procedure),
                  ),
                  child: const Text('Start guided form'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.contacts),
                  child: const Text('Add/select contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthAslPracticalGuidanceCard extends StatefulWidget {
  const _HealthAslPracticalGuidanceCard({required this.guidance});

  final HealthAslGuidance guidance;

  @override
  State<_HealthAslPracticalGuidanceCard> createState() =>
      _HealthAslPracticalGuidanceCardState();
}

class _HealthAslPracticalGuidanceCardState
    extends State<_HealthAslPracticalGuidanceCard> {
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final guidance = widget.guidance;
    final defaultChannel = _findHealthChannel(
      guidance,
      guidance.topAnswer.defaultRecommendedChannel,
    );
    final matchedFlow = _resolveHealthFlow(guidance, _answers);
    final flowContacts = matchedFlow == null
        ? <HealthAslContact>[]
        : _healthFlowContacts(guidance, matchedFlow);
    final flowOutputs = matchedFlow == null
        ? <HealthAslOutputGenerator>[]
        : _healthFlowOutputs(guidance, matchedFlow);

    return _SectionCard(
      title: guidance.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guidance.titleIt,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(guidance.shortDescription),
                  const SizedBox(height: 12),
                  Text(guidance.topAnswer.body),
                  if (defaultChannel != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Chip(label: Text('Recommended channel')),
                        Chip(label: Text(defaultChannel.label)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select your situation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...guidance.userSituationQuestions
              .where(
                (question) => _shouldShowHealthQuestion(question, _answers),
              )
              .map(
                (question) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _QuestionChoiceGroup(
                    title: question.question,
                    options: question.options
                        .map((item) => (id: item.id, label: item.label))
                        .toList(),
                    selectedId: _answers[question.id],
                    onSelected: (value) {
                      setState(() {
                        _answers[question.id] = value;
                      });
                    },
                  ),
                ),
              ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _showHealthOfficesSheet(context, guidance),
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('View ASL offices in Torino'),
          ),
          const SizedBox(height: 16),
          if (matchedFlow != null)
            _HealthFlowResultCard(
              guidance: guidance,
              flow: matchedFlow,
              contacts: flowContacts,
              outputs: flowOutputs,
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  guidance.mainUserQuestion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HealthFlowResultCard extends StatelessWidget {
  const _HealthFlowResultCard({
    required this.guidance,
    required this.flow,
    required this.contacts,
    required this.outputs,
  });

  final HealthAslGuidance guidance;
  final HealthAslUserFlow flow;
  final List<HealthAslContact> contacts;
  final List<HealthAslOutputGenerator> outputs;

  @override
  Widget build(BuildContext context) {
    final commonDocuments = {
      for (final item in guidance.commonDocuments) item.id: item,
    };
    final channel = _findHealthChannel(guidance, flow.recommendedChannel);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(flow.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(flow.labelIt, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(flow.summary),
            const SizedBox(height: 12),
            if (channel != null)
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(flow.channelExplanation),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: const Text('Where to go'),
              subtitle: Text(flow.whereToGo),
            ),
            _DetailExpansionSection(
              title: 'Documents',
              initiallyExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: flow.documents
                    .map(
                      (id) => _BulletText(
                        '${commonDocuments[id]?.label ?? id}${(commonDocuments[id]?.examples ?? const <String>[]).isNotEmpty ? ' (${commonDocuments[id]!.examples.join(', ')})' : ''}',
                      ),
                    )
                    .toList(),
              ),
            ),
            if (flow.extraDocuments.isNotEmpty)
              _DetailExpansionSection(
                title: 'Extra documents',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: flow.extraDocuments
                      .map((item) => _BulletText(item))
                      .toList(),
                ),
              ),
            if (flow.warnings.isNotEmpty)
              _DetailExpansionSection(
                title: 'Warnings',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: flow.warnings
                      .map((item) => _BulletText(item))
                      .toList(),
                ),
              ),
            if (contacts.isNotEmpty)
              _DetailExpansionSection(
                title: 'Contacts',
                child: Column(
                  children: contacts
                      .map((contact) => _HealthContactCard(contact: contact))
                      .toList(),
                ),
              ),
            if (outputs.isNotEmpty)
              _DetailExpansionSection(
                title: 'Available generated outputs',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: outputs
                      .map(
                        (output) => OutlinedButton(
                          onPressed: () =>
                              _showHealthOutputSheet(context, output),
                          child: Text(output.title),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HousingRentPracticalGuidanceCard extends StatelessWidget {
  const _HousingRentPracticalGuidanceCard({
    required this.categoryGuidance,
    required this.subcategoryGuidance,
  });

  final HousingRentGuidance categoryGuidance;
  final HousingRentSubcategory subcategoryGuidance;

  @override
  Widget build(BuildContext context) {
    final contacts = subcategoryGuidance.recommendedContacts
        .map((id) => categoryGuidance.contacts[id])
        .whereType<HousingRentContact>()
        .toList();
    final channels = subcategoryGuidance.recommendedChannels
        .map((id) => _findHousingChannel(categoryGuidance, id))
        .whereType<HousingRentChannelRule>()
        .toList();
    final outputs = subcategoryGuidance.outputs
        .map((id) => _findHousingOutput(categoryGuidance, id))
        .whereType<HousingRentOutputGenerator>()
        .toList();
    final commonDocuments = {
      for (final item in categoryGuidance.commonDocuments) item.id: item,
    };

    return _SectionCard(
      title: categoryGuidance.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subcategoryGuidance.priority == 'urgent')
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.red.withValues(alpha: 0.08),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'This is time-sensitive. Contact Comune di Torino / tenant union as soon as possible.',
                ),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategoryGuidance.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subcategoryGuidance.titleIt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(subcategoryGuidance.whatIsIt),
                  if (subcategoryGuidance.emergencyWarning != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      subcategoryGuidance.emergencyWarning!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DetailExpansionSection(
            title: 'Why do you need it?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subcategoryGuidance.whyDoYouNeedIt
                  .map((item) => _BulletText(item))
                  .toList(),
            ),
          ),
          if (subcategoryGuidance.userQuestions.isNotEmpty)
            _DetailExpansionSection(
              title: 'Questions to clarify first',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.userQuestions
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'What do you need to do?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: channels
                .map(
                  (channel) => ActionChip(
                    label: Text(channel.label),
                    onPressed: () => _showHousingChannelSheet(context, channel),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _DetailExpansionSection(
            title: 'Documents',
            initiallyExpanded: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subcategoryGuidance.documents
                  .map((id) => _BulletText(commonDocuments[id]?.label ?? id))
                  .toList(),
            ),
          ),
          if (subcategoryGuidance.extraDocuments.isNotEmpty)
            _DetailExpansionSection(
              title: 'Extra documents',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.extraDocuments
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          if (subcategoryGuidance.warnings.isNotEmpty)
            _DetailExpansionSection(
              title: 'Warnings',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.warnings
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          Text('Contacts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...contacts.map((contact) => _HousingContactCard(contact: contact)),
          if (categoryGuidance.contacts.length > contacts.length) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  _showHousingContactsSheet(context, categoryGuidance),
              icon: const Icon(Icons.contacts_outlined),
              label: const Text('Useful contacts in Torino'),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Output generators',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: outputs
                .map(
                  (output) => OutlinedButton(
                    onPressed: () => _showHousingOutputSheet(context, output),
                    child: Text(output.title),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuestionChoiceGroup extends StatelessWidget {
  const _QuestionChoiceGroup({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final String title;
  final List<({String id, String label})> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(option.label),
                  selected: selectedId == option.id,
                  onSelected: (_) => onSelected(option.id),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DetailExpansionSection extends StatelessWidget {
  const _DetailExpansionSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(title),
        children: [child],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('- $text'),
    );
  }
}

class _HealthContactCard extends StatelessWidget {
  const _HealthContactCard({required this.contact});

  final HealthAslContact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.name, style: Theme.of(context).textTheme.titleSmall),
            if ((contact.fullName ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.fullName!),
            ],
            if ((contact.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.address!),
            ],
            if ((contact.phone ?? '').isNotEmpty)
              Text('Phone: ${contact.phone}'),
            if (contact.phones.isNotEmpty)
              Text('Phones: ${contact.phones.join(', ')}'),
            if ((contact.email ?? '').isNotEmpty)
              Text('Email: ${contact.email}'),
            if ((contact.pec ?? '').isNotEmpty) Text('PEC: ${contact.pec}'),
            if ((contact.cupRegionale ?? '').isNotEmpty)
              Text('CUP regionale: ${contact.cupRegionale}'),
            if ((contact.openingHours ?? '').isNotEmpty)
              Text('Hours: ${contact.openingHours}'),
            if ((contact.accessMode ?? '').isNotEmpty)
              Text('Access: ${contact.accessMode}'),
            if (contact.useFor.isNotEmpty)
              _DetailExpansionSection(
                title: 'Use for',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contact.useFor
                      .map((item) => _BulletText(item))
                      .toList(),
                ),
              ),
            if ((contact.warning ?? '').isNotEmpty)
              Text(
                contact.warning!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}

class _HousingContactCard extends StatelessWidget {
  const _HousingContactCard({required this.contact});

  final HousingRentContact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.name, style: Theme.of(context).textTheme.titleSmall),
            if ((contact.address ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.address!),
            ],
            if ((contact.phone ?? '').isNotEmpty)
              Text('Phone: ${contact.phone}'),
            if ((contact.email ?? '').isNotEmpty)
              Text('Email: ${contact.email}'),
            if ((contact.pec ?? '').isNotEmpty) Text('PEC: ${contact.pec}'),
            if ((contact.openingHours ?? '').isNotEmpty)
              Text('Hours: ${contact.openingHours}'),
            if (contact.useFor.isNotEmpty)
              _DetailExpansionSection(
                title: 'Use for',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contact.useFor
                      .map((item) => _BulletText(item))
                      .toList(),
                ),
              ),
            if ((contact.warning ?? '').isNotEmpty)
              Text(
                contact.warning!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}

class _RichCategoryPracticalGuidanceCard extends StatelessWidget {
  const _RichCategoryPracticalGuidanceCard({
    required this.categoryGuidance,
    required this.subcategoryGuidance,
  });

  final RichCategoryGuidance categoryGuidance;
  final RichCategorySubcategory subcategoryGuidance;

  @override
  Widget build(BuildContext context) {
    final contacts = subcategoryGuidance.recommendedContacts
        .map((id) => categoryGuidance.contacts[id])
        .whereType<RichCategoryContact>()
        .toList();
    final channels = subcategoryGuidance.recommendedChannels
        .map((id) => _findRichChannel(categoryGuidance, id))
        .whereType<RichCategoryChannelRule>()
        .toList();
    final outputs = subcategoryGuidance.outputs
        .map((id) => _findRichOutput(categoryGuidance, id))
        .whereType<RichCategoryOutputGenerator>()
        .toList();
    final commonDocuments = {
      for (final item in categoryGuidance.commonDocuments) item.id: item,
    };

    return _SectionCard(
      title: categoryGuidance.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((categoryGuidance.topWarning ?? '').isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.amber.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(categoryGuidance.topWarning!),
              ),
            ),
          if ((subcategoryGuidance.urgentWarning ?? '').isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.red.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  subcategoryGuidance.urgentWarning!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (subcategoryGuidance.priority.isNotEmpty)
                        Chip(label: Text(subcategoryGuidance.priority)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subcategoryGuidance.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subcategoryGuidance.titleIt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(subcategoryGuidance.whatIsIt),
                ],
              ),
            ),
          ),
          if (subcategoryGuidance.whyDoYouNeedIt.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailExpansionSection(
              title: 'Why do you need it?',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.whyDoYouNeedIt
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          ],
          if (subcategoryGuidance.userQuestions.isNotEmpty)
            _DetailExpansionSection(
              title: 'Questions to clarify first',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.userQuestions
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          if (subcategoryGuidance.fieldsToExtractFromBill.isNotEmpty)
            _DetailExpansionSection(
              title: 'Read these details from the bill',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.fieldsToExtractFromBill
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          if (subcategoryGuidance.deadlines.isNotEmpty)
            _DetailExpansionSection(
              title: 'Deadlines',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.deadlines
                    .map((item) => _BulletText('${item.label}: ${item.rule}'))
                    .toList(),
              ),
            ),
          if (subcategoryGuidance.configurableRules.isNotEmpty)
            _DetailExpansionSection(
              title: 'Rules to verify',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.configurableRules.entries.map((
                  entry,
                ) {
                  final rule = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${rule.label}: ${rule.value}${rule.warning != null ? '\n${rule.warning}' : ''}',
                    ),
                  );
                }).toList(),
              ),
            ),
          if (channels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'What do you need to do?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: channels
                  .map(
                    (channel) => ActionChip(
                      label: Text(channel.label),
                      onPressed: () => _showRichChannelSheet(context, channel),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          _DetailExpansionSection(
            title: 'Documents',
            initiallyExpanded: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subcategoryGuidance.documents
                  .map((id) => _BulletText(commonDocuments[id]?.label ?? id))
                  .toList(),
            ),
          ),
          if (subcategoryGuidance.extraDocuments.isNotEmpty)
            _DetailExpansionSection(
              title: 'Extra documents',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.extraDocuments
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          if (subcategoryGuidance.warnings.isNotEmpty)
            _DetailExpansionSection(
              title: 'Warnings',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subcategoryGuidance.warnings
                    .map((item) => _BulletText(item))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final scope = AppScope.of(context);
                  final userKey = _resolveLocalUserKey(context);
                  final created = await scope.documentsService
                      .createDocumentsFromSubcategory(
                        userId: userKey,
                        categoryGuidance: categoryGuidance,
                        subcategory: subcategoryGuidance,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        created.isEmpty
                            ? 'Already added to Documents.'
                            : 'Added ${created.length} required documents to Documents.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_copy_outlined),
                label: const Text('Add required documents to Documents'),
              ),
              if (_buildEstimatedCostItemForRichSubcategory(
                    context,
                    categoryGuidance,
                    subcategoryGuidance,
                  ) !=
                  null)
                OutlinedButton.icon(
                  onPressed: () async {
                    final scope = AppScope.of(context);
                    final prefill = _buildEstimatedCostItemForRichSubcategory(
                      context,
                      categoryGuidance,
                      subcategoryGuidance,
                    );
                    if (prefill == null) return;
                    await scope.costDashboardService.createCostItem(prefill);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Estimated cost added to Cost Dashboard.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.savings_outlined),
                  label: const Text('Add estimated cost to Cost Dashboard'),
                ),
            ],
          ),
          if (contacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Contacts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...contacts.map((contact) => _RichContactCard(contact: contact)),
            if (categoryGuidance.contacts.length > contacts.length)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.contacts,
                  ),
                  icon: const Icon(Icons.contacts_outlined),
                  label: const Text('View all contacts'),
                ),
              ),
          ],
          if (categoryGuidance.officialReferences.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DetailExpansionSection(
              title: 'Official references',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryGuidance.officialReferences.values
                    .map(
                      (reference) => _BulletText(
                        reference.url == null
                            ? reference.label
                            : '${reference.label}: ${reference.url}',
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (outputs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Output generators',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: outputs
                  .map(
                    (output) => OutlinedButton(
                      onPressed: () => _showRichOutputSheet(context, output),
                      child: Text(output.title),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RichContactCard extends StatelessWidget {
  const _RichContactCard({required this.contact});

  final RichCategoryContact contact;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if ((contact.address ?? '').isNotEmpty) contact.address!,
      if ((contact.postalAddress ?? '').isNotEmpty)
        'Postal: ${contact.postalAddress!}',
      if ((contact.physicalOfficeAddress ?? '').isNotEmpty)
        'Office: ${contact.physicalOfficeAddress!}',
      if ((contact.phone ?? '').isNotEmpty) 'Phone: ${contact.phone!}',
      if ((contact.phoneHours ?? '').isNotEmpty)
        'Phone hours: ${contact.phoneHours!}',
      if ((contact.phoneSupportLegacy ?? '').isNotEmpty)
        'Legacy phone: ${contact.phoneSupportLegacy!}',
      if ((contact.phoneFixedLine ?? '').isNotEmpty)
        'Phone: ${contact.phoneFixedLine!}',
      if ((contact.phoneMobileOrAbroad ?? '').isNotEmpty)
        'Mobile/abroad: ${contact.phoneMobileOrAbroad!}',
      if ((contact.conciliationFreeNumber ?? '').isNotEmpty)
        'Free number: ${contact.conciliationFreeNumber!}',
      if ((contact.conciliationFreeNumberHours ?? '').isNotEmpty)
        'Free number hours: ${contact.conciliationFreeNumberHours!}',
      if ((contact.consumerPhone ?? '').isNotEmpty)
        'Consumer phone: ${contact.consumerPhone!}',
      if ((contact.email ?? '').isNotEmpty) 'Email: ${contact.email!}',
      if ((contact.pec ?? '').isNotEmpty) 'PEC: ${contact.pec!}',
      if ((contact.permessoSupportPec ?? '').isNotEmpty)
        'Permesso support PEC: ${contact.permessoSupportPec!}',
      if ((contact.url ?? '').isNotEmpty) 'URL: ${contact.url!}',
      if ((contact.howToFind ?? '').isNotEmpty) contact.howToFind!,
      if ((contact.access ?? '').isNotEmpty) 'Access: ${contact.access!}',
      if ((contact.requiredBeforeUse ?? '').isNotEmpty)
        'Before use: ${contact.requiredBeforeUse!}',
      if ((contact.openingHours ?? '').isNotEmpty)
        'Hours: ${contact.openingHours!}',
      if ((contact.publicHours ?? '').isNotEmpty)
        'Public hours: ${contact.publicHours!}',
    ];
    final crossLinkRoute = _routeForCategoryLink(contact.categoryId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.name, style: Theme.of(context).textTheme.titleSmall),
            if ((contact.nameIt ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.nameIt!),
            ],
            if ((contact.authority ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.authority!),
            ],
            if ((contact.officeCode ?? '').isNotEmpty)
              Text('Office code: ${contact.officeCode!}'),
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(line),
                ),
              ),
            ],
            if (contact.useFor.isNotEmpty)
              _DetailExpansionSection(
                title: 'Use for',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contact.useFor
                      .map((item) => _BulletText(item))
                      .toList(),
                ),
              ),
            if ((contact.warning ?? '').isNotEmpty)
              Text(
                contact.warning!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            if (crossLinkRoute != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, crossLinkRoute),
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: const Text('Open related category'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String? _routeForCategoryLink(String? categoryId) {
  switch (categoryId) {
    case 'health_asl':
    case 'housing_rent':
      return AppRoutes.procedures;
    case 'public_office_comune':
      return AppRoutes.publicOffice;
    case 'work_inps_patronato':
      return AppRoutes.workInpsPatronato;
    case 'university_student':
      return AppRoutes.universityStudent;
    case 'utilities_electricity_gas':
      return AppRoutes.utilities;
    case 'canone_rai':
      return AppRoutes.canoneRai;
    case 'telecom_internet_mobile':
      return AppRoutes.telecom;
    case 'general':
      return AppRoutes.general;
    default:
      return null;
  }
}

bool _shouldShowHealthQuestion(
  HealthAslSituationQuestion question,
  Map<String, String> answers,
) {
  if (question.showWhen.isEmpty) {
    return true;
  }
  for (final entry in question.showWhen.entries) {
    if (answers[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

HealthAslUserFlow? _resolveHealthFlow(
  HealthAslGuidance guidance,
  Map<String, String> answers,
) {
  for (final rule in guidance.routingRules) {
    final matches = rule.conditions.entries.every(
      (entry) => answers[entry.key] == entry.value,
    );
    if (matches) {
      for (final flow in guidance.userFlows) {
        if (flow.id == rule.routeTo) {
          return flow;
        }
      }
    }
  }

  if (answers['main_role'] == 'student' &&
      answers['citizenship_status'] == 'italian' &&
      answers['torino_status'] == 'domiciled') {
    return guidance.userFlows.firstWhere(
      (item) => item.id == 'italian_student_domiciled_torino',
      orElse: () => guidance.userFlows.first,
    );
  }
  if (answers['citizenship_status'] == 'italian' &&
      answers['torino_status'] == 'resident') {
    return guidance.userFlows.firstWhere(
      (item) => item.id == 'italian_resident_torino',
      orElse: () => guidance.userFlows.first,
    );
  }
  return null;
}

HealthAslChannelRule? _findHealthChannel(
  HealthAslGuidance guidance,
  String channelId,
) {
  for (final rule in guidance.channelRules) {
    if (rule.id == channelId) {
      return rule;
    }
  }
  return null;
}

List<HealthAslContact> _healthFlowContacts(
  HealthAslGuidance guidance,
  HealthAslUserFlow flow,
) {
  final ids = <String>{...flow.usefulContacts};
  if (ids.isEmpty &&
      flow.recommendedChannel != 'centro_isi' &&
      flow.recommendedChannel != 'edisu_or_in_person_asl') {
    ids.add('aslTorinoGeneral');
  }
  if (flow.recommendedChannel == 'edisu_or_in_person_asl') {
    ids.addAll(['edisuStudentSupport', 'aslTorinoGeneral']);
  }
  return ids
      .map((id) => guidance.contacts[id])
      .whereType<HealthAslContact>()
      .toList();
}

List<HealthAslOutputGenerator> _healthFlowOutputs(
  HealthAslGuidance guidance,
  HealthAslUserFlow flow,
) {
  final outputMap = {
    for (final item in guidance.outputGenerators) item.id: item,
  };
  return flow.outputs
      .map((id) => outputMap[id])
      .whereType<HealthAslOutputGenerator>()
      .toList();
}

HousingRentChannelRule? _findHousingChannel(
  HousingRentGuidance guidance,
  String channelId,
) {
  for (final rule in guidance.channelRules) {
    if (rule.id == channelId) {
      return rule;
    }
  }
  return null;
}

HousingRentOutputGenerator? _findHousingOutput(
  HousingRentGuidance guidance,
  String outputId,
) {
  for (final output in guidance.outputGenerators) {
    if (output.id == outputId) {
      return output;
    }
  }
  return null;
}

RichCategoryChannelRule? _findRichChannel(
  RichCategoryGuidance guidance,
  String channelId,
) {
  for (final rule in guidance.channelRules) {
    if (rule.id == channelId) {
      return rule;
    }
  }
  return null;
}

RichCategoryOutputGenerator? _findRichOutput(
  RichCategoryGuidance guidance,
  String outputId,
) {
  for (final output in guidance.outputGenerators) {
    if (output.id == outputId) {
      return output;
    }
  }
  return null;
}

Future<void> _showHealthOfficesSheet(
  BuildContext context,
  HealthAslGuidance guidance,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ASL offices in Torino',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(guidance.aslAdministrativeOffices.generalOpeningHours),
          if (guidance.aslAdministrativeOffices.verifyBeforeGoing)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Opening hours can change, verify before going.'),
            ),
          const SizedBox(height: 12),
          ...guidance.aslAdministrativeOffices.offices.map(
            (office) => Card(
              child: ListTile(
                title: Text(office.address),
                subtitle: Text(
                  '${office.district} • Circoscrizione ${office.circoscrizione}\n${office.areas.join(', ')}${office.notes != null ? '\n${office.notes}' : ''}',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showHealthOutputSheet(
  BuildContext context,
  HealthAslOutputGenerator output,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(output.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(output.titleIt),
          if ((output.sendTo ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Send to: ${output.sendTo}'),
          ],
          if (output.fieldsNeeded.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Fields needed',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...output.fieldsNeeded.map((item) => _BulletText(item)),
          ],
          if ((output.templateBehavior ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(output.templateBehavior!),
          ],
          if ((output.templateIt ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(output.templateIt!),
          ],
          if (output.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...output.items.map((item) => _BulletText(item)),
          ],
          if ((output.warning ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(output.warning!),
          ],
        ],
      ),
    ),
  );
}

Future<void> _showHousingChannelSheet(
  BuildContext context,
  HousingRentChannelRule channel,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(channel.label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(channel.labelIt),
          const SizedBox(height: 12),
          Text('Priority: ${channel.priority}'),
          const SizedBox(height: 12),
          ...channel.useWhen.map((item) => _BulletText(item)),
          if ((channel.warning ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(channel.warning!),
          ],
        ],
      ),
    ),
  );
}

Future<void> _showHousingOutputSheet(
  BuildContext context,
  HousingRentOutputGenerator output,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(output.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(output.titleIt),
          if ((output.sendTo ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Send to: ${output.sendTo}'),
          ],
          if (output.sendToOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Send to options'),
            ...output.sendToOptions.map((item) => _BulletText(item)),
          ],
          if ((output.templateIt ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(output.templateIt!),
          ],
        ],
      ),
    ),
  );
}

Future<void> _showHousingContactsSheet(
  BuildContext context,
  HousingRentGuidance guidance,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Useful contacts in Torino',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...guidance.contacts.values.map(
            (contact) => _HousingContactCard(contact: contact),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showRichChannelSheet(
  BuildContext context,
  RichCategoryChannelRule channel,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(channel.label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(channel.labelIt),
          const SizedBox(height: 12),
          Text('Priority: ${channel.priority}'),
          if ((channel.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Address: ${channel.address}'),
          ],
          if ((channel.pec ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('PEC: ${channel.pec}'),
          ],
          if (channel.useWhen.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...channel.useWhen.map((item) => _BulletText(item)),
          ],
          if ((channel.warning ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(channel.warning!),
          ],
        ],
      ),
    ),
  );
}

Future<void> _showRichOutputSheet(
  BuildContext context,
  RichCategoryOutputGenerator output,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(output.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(output.titleIt),
          if ((output.recipient ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Recipient: ${output.recipient}'),
          ],
          if ((output.sendTo ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Send to: ${output.sendTo}'),
          ],
          if ((output.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Address: ${output.address}'),
          ],
          if (output.sendToOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Send to options'),
            ...output.sendToOptions.map((item) => _BulletText(item)),
          ],
          if ((output.templateBehavior ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(output.templateBehavior!),
          ],
          if ((output.behavior ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(output.behavior!),
          ],
          if ((output.contentIt ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(output.contentIt!),
          ],
          if ((output.templateIt ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(output.templateIt!),
          ],
          if (output.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...output.items.map((item) => _BulletText(item)),
          ],
          if ((output.warning ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(output.warning!),
          ],
        ],
      ),
    ),
  );
}

class GuidedFormScreen extends StatefulWidget {
  const GuidedFormScreen({super.key, required this.procedure});

  final AdminProcedure procedure;

  @override
  State<GuidedFormScreen> createState() => _GuidedFormScreenState();
}

class _GuidedFormScreenState extends State<GuidedFormScreen> {
  late Map<String, dynamic> values;
  final redFlagService = RedFlagService();
  Map<String, String> errors = {};
  bool loadedDraft = false;
  bool _draftBootstrapStarted = false;

  @override
  void initState() {
    super.initState();
    values = {
      for (final field in widget.procedure.fields)
        if (field.defaultValue != null) field.id: field.defaultValue,
      'submissionMethod': 'normalEmail',
      'verifiedRecipient': false,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_draftBootstrapStarted) {
      return;
    }
    _draftBootstrapStarted = true;
    _loadDraftAndProfile();
  }

  Future<void> _loadDraftAndProfile() async {
    final scope = AppScope.of(context);
    final draft = await scope.requestController.getDraft(widget.procedure.id);
    final profile = scope.profileController.profile;
    if (!mounted) {
      return;
    }
    setState(() {
      values.addAll({
        if ((profile.fullName ?? '').isNotEmpty) 'fullName': profile.fullName,
        if ((profile.codiceFiscale ?? '').isNotEmpty)
          'codiceFiscale': profile.codiceFiscale,
        if ((profile.email ?? '').isNotEmpty) 'email': profile.email,
        if ((profile.city ?? '').isNotEmpty) 'city': profile.city,
        if ((profile.city ?? '').isNotEmpty) 'recipientCity': profile.city,
      });
      if (draft != null) {
        values.addAll(draft.inputData);
        loadedDraft = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).requestController;
    final entitlementService = AppScope.of(context).entitlementService;
    final intelligence = ServiceIntelligenceDefinitions.forProcedure(
      widget.procedure,
    );
    final providerCategory = _providerCategoryForProcedure(widget.procedure);
    final generatedFlags = redFlagService.evaluate(
      procedureId: widget.procedure.id,
      inputData: values,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.procedure.title),
        actions: [
          TextButton(
            onPressed: () => controller.saveDraft(widget.procedure.id, values),
            child: const Text('Save draft'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (loadedDraft)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const ListTile(
                  leading: Icon(Icons.restore_outlined),
                  title: Text('Draft restored'),
                ),
              ),
            if (generatedFlags.isNotEmpty)
              ...generatedFlags.map(
                (flag) => Card(
                  color: Colors.orange.withValues(alpha: 0.12),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(flag.message),
                  ),
                ),
              ),
            _SectionCard(
              title: 'Destination and submission',
              child: Column(
                children: [
                  Text(
                    intelligence.destinationGuidance,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('recipientNameField'),
                    decoration: const InputDecoration(
                      labelText: 'Recipient name or office',
                    ),
                    initialValue: (values['recipientName'] as String?) ?? '',
                    onChanged: (value) =>
                        setState(() => values['recipientName'] = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('recipientEmailField'),
                    decoration: const InputDecoration(
                      labelText: 'Recipient email',
                    ),
                    initialValue: (values['recipientEmail'] as String?) ?? '',
                    onChanged: (value) =>
                        setState(() => values['recipientEmail'] = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('recipientPecField'),
                    decoration: const InputDecoration(
                      labelText: 'Recipient PEC',
                    ),
                    initialValue: (values['recipientPec'] as String?) ?? '',
                    onChanged: (value) =>
                        setState(() => values['recipientPec'] = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue:
                        (values['submissionMethod'] as String?) ??
                        'normalEmail',
                    items: const [
                      DropdownMenuItem(
                        value: 'normalEmail',
                        child: Text('Normal email'),
                      ),
                      DropdownMenuItem(value: 'pec', child: Text('PEC')),
                      DropdownMenuItem(
                        value: 'onlinePortal',
                        child: Text('Online portal'),
                      ),
                      DropdownMenuItem(
                        value: 'inPerson',
                        child: Text('In person'),
                      ),
                      DropdownMenuItem(
                        value: 'whatsappFirst',
                        child: Text('WhatsApp first'),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => values['submissionMethod'] = value ?? 'normalEmail',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Submission method',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ClickableTermText(
                    'If you select PEC, remember that the message has formal PEC value only when sent from a PEC account when required. Online portals may require SPID or CIE.',
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: (values['verifiedRecipient'] as bool?) ?? false,
                    onChanged: (value) => setState(
                      () => values['verifiedRecipient'] = value ?? false,
                    ),
                    title: const Text(
                      'I verified the contact or portal on an official source',
                    ),
                  ),
                  if (providerCategory != null) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<List<catalog.ServiceProvider>>(
                      future: AppScope.of(context).catalogRepository
                          .getProvidersByCategory(providerCategory),
                      builder: (context, snapshot) {
                        final providers =
                            snapshot.data ?? const <catalog.ServiceProvider>[];
                        if (providers.isEmpty) {
                          return const Text(
                            'Provider catalog is loading or falling back to bundled guidance.',
                          );
                        }
                        final currentProviderId =
                            values['providerId'] as String? ??
                            providers.first.id;
                        values['providerId'] = currentProviderId;
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: currentProviderId,
                              items: providers
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setState(() {
                                values['providerId'] = value;
                                values['provider'] = providers
                                    .firstWhere((item) => item.id == value)
                                    .name;
                              }),
                              decoration: const InputDecoration(
                                labelText: 'Provider',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final selected = providers.firstWhere(
                                  (item) => item.id == currentProviderId,
                                  orElse: () => providers.first,
                                );
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(selected.name),
                                        if ((selected.websiteUrl ?? '')
                                            .isNotEmpty)
                                          Text(selected.websiteUrl!),
                                        if ((selected.customerAreaUrl ?? '')
                                            .isNotEmpty)
                                          Text(
                                            'Customer area: ${selected.customerAreaUrl}',
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _localizedCatalogText(
                                            context,
                                            selected.cancellationGuidance,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _localizedCatalogText(
                                            context,
                                            selected.modemReturnGuidance,
                                          ),
                                        ),
                                        if (selected
                                            .contactOptions
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Official contact options',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          ...selected.contactOptions
                                              .take(4)
                                              .map(
                                                (option) => Text(
                                                  '- ${option.label}: ${option.value ?? option.url ?? _localizedCatalogText(context, option.description)}',
                                                ),
                                              ),
                                        ],
                                        if (selected.forms.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Official forms/pages',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          ...selected.forms
                                              .take(3)
                                              .map(
                                                (form) => Text(
                                                  '- ${form.title}${form.url != null ? '\n  ${form.url}' : ''}',
                                                ),
                                              ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._buildSectionedFields(context),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () async {
              final validation = ProcedureValidator.validate(
                widget.procedure,
                values,
              );
              setState(() => errors = validation.fieldErrors);
              if (!validation.ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fix the highlighted fields.'),
                  ),
                );
                return;
              }
              final procedureDecision = await entitlementService
                  .canUseProcedure(widget.procedure.id);
              final packDecision = await entitlementService.canGeneratePack(
                widget.procedure.id,
              );
              if (!context.mounted) {
                return;
              }
              if (!procedureDecision.allowed) {
                await showPremiumPaywallSheet(
                  context,
                  decision: procedureDecision,
                  featureLabel: widget.procedure.title,
                );
                return;
              }
              if (!packDecision.allowed) {
                await showPremiumPaywallSheet(
                  context,
                  decision: packDecision,
                  featureLabel: 'Generate request pack',
                );
                return;
              }
              if (packDecision.blockedByBeta) {
                final continueInBeta = await showPremiumPaywallSheet(
                  context,
                  decision: packDecision,
                  featureLabel: 'Generate request pack',
                );
                if (continueInBeta != true || !context.mounted) {
                  return;
                }
              }
              final pack = PackGenerator.generate(
                procedure: widget.procedure,
                inputData: values,
              );
              await entitlementService.recordPackGenerated(widget.procedure.id);
              if (!context.mounted) {
                return;
              }
              Navigator.pushNamed(
                context,
                AppRoutes.generated,
                arguments: GeneratedRouteArgs(
                  procedure: widget.procedure,
                  inputData: values,
                  pack: pack,
                ),
              );
            },
            child: Text(context.l10n.t('generate_pack')),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionedFields(BuildContext context) {
    final grouped = <String, List<Widget>>{};
    for (final field in widget.procedure.fields) {
      if (!field.isVisible(values)) continue;
      grouped.putIfAbsent(field.section ?? 'Details', () => []);
      grouped[field.section ?? 'Details']!.add(
        _DynamicField(
          field: field,
          value: values[field.id],
          errorText: errors[field.id],
          onChanged: (value) => setState(() => values[field.id] = value),
        ),
      );
    }
    return grouped.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SectionCard(
              title: entry.key,
              child: Column(
                children: entry.value
                    .map(
                      (widget) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: widget,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        )
        .toList();
  }
}

class GeneratedPackScreen extends StatelessWidget {
  const GeneratedPackScreen({
    super.key,
    required this.procedure,
    required this.inputData,
    required this.pack,
  });

  final AdminProcedure procedure;
  final Map<String, dynamic> inputData;
  final GeneratedPack pack;

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).appController.languageCode;
    final intelligence = ServiceIntelligenceDefinitions.forProcedure(procedure);
    final localizedExplanation =
        pack.localizedExplanations[lang] ??
        pack.localizedExplanations['en'] ??
        pack.userExplanationEnglish;
    final readiness = RequestReadinessService().calculate(
      request: AdminCopilotRequest(
        id: pack.id,
        procedureId: procedure.id,
        procedureTitle: procedure.title,
        category: procedure.category.label,
        status: RequestStatus.generated,
        priority: pack.priority,
        inputData: inputData,
        generatedPack: pack,
        subject: pack.subject,
        createdAt: pack.createdAt,
        updatedAt: pack.updatedAt,
        statusEvents: const [],
        reminders: const [],
      ),
      redFlags: RedFlagService().evaluate(
        procedureId: procedure.id,
        inputData: inputData,
      ),
    );
    final sections = {
      context.l10n.t('short_message'): pack.shortMessageItalian,
      'WhatsApp': pack.whatsappMessageItalian,
      'WhatsApp follow-up': pack.whatsappFollowUpItalian,
      context.l10n.t('email'): pack.bodyItalian,
      context.l10n.t('pec'): pack.bodyPecItalian,
      context.l10n.t('follow_up'): pack.followUpItalian,
      context.l10n.t('strong_follow_up'): pack.strongFollowUpItalian,
    };
    return DefaultTabController(
      length: sections.length + 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(procedure.title),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              ...sections.keys.map((item) => Tab(text: item)),
              Tab(text: context.l10n.t('attachments')),
              Tab(text: context.l10n.t('next_steps')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...sections.entries.map(
              (entry) => _CopyableContent(
                title: entry.key,
                value: entry.value,
                copyLabel: entry.key,
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: pack.attachmentChecklist
                  .map(
                    (item) => CheckboxListTile(
                      value: item.userHasIt,
                      onChanged: null,
                      title: Text(item.name),
                    ),
                  )
                  .toList(),
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'Destination',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pack.destinationGuidance.isNotEmpty)
                        Text(pack.destinationGuidance),
                      const SizedBox(height: 8),
                      if ((pack.selectedContactSnapshot['recipientName'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text(
                          'Recipient: ${pack.selectedContactSnapshot['recipientName']}',
                        ),
                      if ((pack.selectedContactSnapshot['recipientEmail'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text(
                          'Email: ${pack.selectedContactSnapshot['recipientEmail']}',
                        ),
                      if ((pack.selectedContactSnapshot['recipientPec'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text(
                          'PEC: ${pack.selectedContactSnapshot['recipientPec']}',
                        ),
                      const SizedBox(height: 8),
                      Text('Submission method: ${pack.submissionMethod}'),
                      if (pack.recipientVerificationChecklist.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...pack.recipientVerificationChecklist.map(
                          (item) => Text('- $item'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Readiness score',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request readiness: ${readiness.score}%'),
                      const SizedBox(height: 8),
                      Text(readiness.nextBestAction),
                      if (readiness.missingRequiredFields.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Missing: ${readiness.missingRequiredFields.join(', ')}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...pack.nextSteps.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(item),
                  ),
                ),
                const SizedBox(height: 12),
                if (pack.inPersonChecklist.isNotEmpty)
                  _SectionCard(
                    title: 'In-person checklist',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pack.inPersonChecklist
                          .map((item) => Text('- $item'))
                          .toList(),
                    ),
                  ),
                if (pack.onlinePortalChecklist.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Online portal checklist',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pack.onlinePortalChecklist
                          .map((item) => Text('- $item'))
                          .toList(),
                    ),
                  ),
                ],
                if (pack.officialLinksToCheck.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Official links to check',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pack.officialLinksToCheck
                          .map((item) => Text('- $item'))
                          .toList(),
                    ),
                  ),
                ],
                if (pack.serviceIntelligenceWarnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Service warnings',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pack.serviceIntelligenceWarnings
                          .map((item) => Text('- $item'))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(localizedExplanation),
                const SizedBox(height: 12),
                Text(pack.fullText),
                const SizedBox(height: 12),
                Text(
                  intelligence.rejectionGuidance,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final allowShare = await showBeforeSendingSheet(
                        context,
                        requestId: pack.id,
                      );
                      if (!allowShare || !context.mounted) {
                        return;
                      }
                      await SharePlus.instance.share(
                        ShareParams(text: pack.fullText),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final scope = AppScope.of(context);
                      final decision = await scope.entitlementService
                          .canSaveRequest();
                      if (!decision.allowed && context.mounted) {
                        await showPremiumPaywallSheet(
                          context,
                          decision: decision,
                          featureLabel: 'Save request',
                        );
                        return;
                      }
                      final request = await scope.requestController.savePack(
                        procedureId: procedure.id,
                        procedureTitle: procedure.title,
                        category: procedure.category.label,
                        inputData: inputData,
                        pack: pack,
                      );
                      await scope.entitlementService.recordSavedRequest();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.t('request_saved')),
                          ),
                        );
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.requestDetail,
                          arguments: RequestRouteArgs(request),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(context.l10n.t('save_request')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SavedRequestsScreen extends StatelessWidget {
  const SavedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = AppScope.of(context).requestController.requests;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('saved_requests'))),
      body: SafeArea(
        child: requests.isEmpty
            ? const Center(child: Text('No saved requests yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final readyCount = request.generatedPack.attachmentChecklist
                      .where((item) => item.userHasIt)
                      .length;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(request.procedureTitle),
                      subtitle: Text(
                        '${request.status.name} • $readyCount/${request.generatedPack.attachmentChecklist.length} docs ready',
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.requestDetail,
                        arguments: RequestRouteArgs(request),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.request});

  final AdminCopilotRequest request;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.request.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).requestController;
    final request = controller.requests.firstWhere(
      (item) => item.id == widget.request.id,
      orElse: () => widget.request,
    );
    return Scaffold(
      appBar: AppBar(title: Text(request.procedureTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Status',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RequestStatus.values
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status.name),
                        selected: request.status == status,
                        onSelected: (_) =>
                            controller.updateStatus(request.id, status),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Next action',
              child: Text(
                AppScope.of(
                  context,
                ).nextActionService.fromRequest(request).title,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Readiness',
              child: Builder(
                builder: (context) {
                  final readiness = AppScope.of(context).requestReadinessService
                      .calculate(
                        request: request,
                        redFlags: RedFlagService().evaluate(
                          procedureId: request.procedureId,
                          inputData: request.inputData,
                        ),
                      );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Request readiness: ${readiness.score}%'),
                      const SizedBox(height: 8),
                      Text(readiness.nextBestAction),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Attachments',
              child: Column(
                children: request.generatedPack.attachmentChecklist
                    .map(
                      (item) => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: item.userHasIt,
                        onChanged: (value) => controller.toggleAttachment(
                          request.id,
                          item.id,
                          value ?? false,
                        ),
                        title: Text(item.name),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Notes',
              child: Column(
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Add notes'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => controller.saveNotes(
                        request.id,
                        _notesController.text,
                      ),
                      child: const Text('Save notes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Reminders',
              child: Column(
                children: [
                  ...request.reminders.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: item.isDone,
                        onChanged: (_) =>
                            controller.markReminderDone(request.id, item.id),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(item.reminderDate),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [7, 14, 30]
                        .map(
                          (days) => OutlinedButton(
                            onPressed: () => controller.addReminder(
                              request.id,
                              Reminder(
                                id: const Uuid().v4(),
                                requestId: request.id,
                                title: 'Follow up in $days days',
                                reminderDate: DateTime.now().add(
                                  Duration(days: days),
                                ),
                                type: ReminderType.followUp,
                                isDone: false,
                                createdAt: DateTime.now(),
                              ),
                            ),
                            child: Text('$days days'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Timeline',
              child: Column(
                children: request.statusEvents
                    .map(
                      (event) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.timeline),
                        title: Text(event.newStatus.name),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(event.createdAt),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Actions',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final ok = await showBeforeSendingSheet(
                        context,
                        requestId: request.id,
                      );
                      if (!ok) return;
                      await controller.updateStatus(
                        request.id,
                        RequestStatus.sent,
                      );
                    },
                    child: const Text('Mark as sent'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.proofFolder),
                    child: const Text('Open proof folder'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.attachmentsHelper,
                    ),
                    child: const Text('Attachment helper'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _cf = TextEditingController();
  final _city = TextEditingController();
  final _email = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = AppScope.of(context).profileController.profile;
    _name.text = profile.fullName ?? '';
    _cf.text = profile.codiceFiscale ?? '';
    _city.text = profile.city ?? '';
    _email.text = profile.email ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _cf.dispose();
    _city.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('profile'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cf,
              decoration: const InputDecoration(labelText: 'Codice fiscale'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: scope.appController.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'it', child: Text('Italiano')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'fa', child: Text('فارسی')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) scope.appController.setLanguage(value);
              },
              decoration: const InputDecoration(labelText: 'Language'),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Backend mode'),
              subtitle: Text(
                scope.config.isSupabaseEnabled
                    ? 'Supabase-ready'
                    : 'Local-only mode',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await scope.profileController.save(
                  AdminCopilotProfile(
                    fullName: _name.text.trim(),
                    codiceFiscale: _cf.text.trim(),
                    city: _city.text.trim(),
                    email: _email.text.trim(),
                    preferredLanguage: scope.appController.languageCode,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved')),
                  );
                }
              },
              child: const Text('Save profile'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.sync),
              child: const Text('Sync settings'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.privacy),
              child: const Text('Privacy Center'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('help'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'What this app does',
              child: const Text(
                'It organizes information, drafts formal Italian requests, prepares checklists, and helps track follow-up actions.',
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'What it does not do',
              child: const Text(
                'It does not replace legal, tax, medical, financial, or professional advice. It does not submit official declarations or guarantee eligibility or savings.',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.onboarding),
              child: const Text('Open onboarding again'),
            ),
          ],
        ),
      ),
    );
  }
}

const Map<String, String> _utilityProcedureMap = {
  'understand_electricity_or_gas_bill': 'ENERGY_BILL_ANALYZER_CHECKLIST',
  'compare_offers_safely': 'ENERGY_SUPPLIER_COMPARISON',
  'provider_switching': 'ELECTRICITY_GAS_SWITCH_REQUEST',
  'voltura': 'VOLTURA_REQUEST',
  'subentro': 'SUBENTRO_REQUEST',
  'utility_cancellation_disdetta': 'UTILITY_CANCELLATION_DISDETTA',
  'high_bill_complaint': 'HIGH_BILL_COMPLAINT',
  'meter_reading_correction': 'METER_READING_CORRECTION',
  'payment_plan_request': 'PAYMENT_PLAN_REQUEST',
  'wrong_charge_refund': 'WRONG_CHARGE_REFUND_REQUEST',
  'unilateral_contract_change_complaint':
      'UNILATERAL_CONTRACT_CHANGE_COMPLAINT',
  'check_supplier_vs_distributor': 'CHECK_SUPPLIER_VS_DISTRIBUTOR',
  'new_activation_prima_attivazione': 'NEW_ACTIVATION_PRIMA_ATTIVAZIONE',
  'contract_not_requested_scam_activation':
      'CONTRACT_NOT_REQUESTED_SCAM_ACTIVATION',
  'gas_or_electricity_emergency_fault': 'GAS_OR_ELECTRICITY_EMERGENCY_FAULT',
  'arera_complaint_and_conciliation': 'ARERA_COMPLAINT_AND_CONCILIATION',
};

const Map<String, String> _canoneProcedureMap = {
  'no_tv_declaration': 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
  'over_75_exemption': 'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
  'refund_wrong_charge': 'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
  'understand_if_must_pay_canone_rai': 'UNDERSTAND_IF_MUST_PAY_CANONE_RAI',
  'diplomatic_military_exemption': 'DIPLOMATIC_MILITARY_EXEMPTION',
  'wrong_electricity_bill_charge': 'WRONG_ELECTRICITY_BILL_CHARGE',
  'new_home_changed_electricity_contract':
      'NEW_HOME_CHANGED_ELECTRICITY_CONTRACT',
  'help_filling_agenzia_entrate_form': 'HELP_FILLING_AGENZIA_ENTRATE_FORM',
};

const Map<String, String> _telecomProcedureMap = {
  'internet_phone_cancellation': 'INTERNET_PHONE_CANCELLATION',
  'wrong_bill_complaint': 'TELECOM_WRONG_BILL_COMPLAINT',
  'service_not_working_complaint': 'SERVICE_NOT_WORKING_COMPLAINT',
  'modem_return_or_charge_dispute': 'MODEM_RETURN_OR_CHARGE_DISPUTE',
  'understand_telecom_problem': 'UNDERSTAND_TELECOM_PROBLEM',
  'mobile_sim_cancellation': 'MOBILE_SIM_CANCELLATION',
  'provider_switching_number_portability':
      'PROVIDER_SWITCHING_NUMBER_PORTABILITY',
  'internet_speed_too_low': 'INTERNET_SPEED_TOO_LOW',
  'activation_delay_no_line': 'ACTIVATION_DELAY_NO_LINE',
  'contract_not_requested_phone_scam': 'CONTRACT_NOT_REQUESTED_PHONE_SCAM',
  'refund_or_compensation_request': 'REFUND_OR_COMPENSATION_REQUEST',
  'payment_plan_unpaid_bills': 'PAYMENT_PLAN_UNPAID_BILLS',
  'roaming_international_charge_dispute':
      'ROAMING_INTERNATIONAL_CHARGE_DISPUTE',
  'pec_formal_complaint_operator': 'PEC_FORMAL_COMPLAINT_OPERATOR',
  'agcom_corecom_conciliaweb_escalation':
      'AGCOM_CORECOM_CONCILIAWEB_ESCALATION',
};

const Map<String, String> _publicOfficeProcedureMap = {
  'understand_residenza_domicilio_temporary':
      'UNDERSTAND_RESIDENZA_DOMICILIO_TEMPORARY',
  'change_residence_from_another_comune_or_abroad':
      'CHANGE_RESIDENCE_FROM_ANOTHER_COMUNE_OR_ABROAD',
  'change_address_inside_torino': 'CHANGE_ADDRESS_INSIDE_TORINO',
  'temporary_residence_popolazione_temporanea':
      'TEMPORARY_RESIDENCE_POPOLAZIONE_TEMPORANEA',
  'doorbell_mailbox_address_proof': 'DOORBELL_MAILBOX_ADDRESS_PROOF',
  'rejected_residenza_request_reply': 'REJECTED_RESIDENZA_REQUEST_REPLY',
  'anagrafe_certificate_request': 'ANAGRAFE_CERTIFICATE_REQUEST',
  'family_status_certificate': 'FAMILY_STATUS_CERTIFICATE',
  'residence_certificate': 'RESIDENCE_CERTIFICATE',
  'self_certification_autocertificazione':
      'SELF_CERTIFICATION_AUTOCERTIFICAZIONE',
  'book_anagrafe_appointment': 'BOOK_ANAGRAFE_APPOINTMENT',
  'pec_formal_request_comune': 'PEC_FORMAL_REQUEST_COMUNE',
  'online_comune_service_problem': 'ONLINE_COMUNE_SERVICE_PROBLEM',
  'general_comune_information_request':
      'GENERAL_COMUNE_INFORMATION_REQUEST',
};

const Map<String, String> _workInpsProcedureMap = {
  'understand_job_loss_benefit_situation':
      'UNDERSTAND_JOB_LOSS_BENEFIT_SITUATION',
  'naspi_preparation': 'NASPI_PREPARATION',
  'naspi_application_followup': 'NASPI_APPLICATION_FOLLOWUP',
  'did_and_centro_impiego': 'DID_AND_CENTRO_IMPIEGO',
  'patronato_appointment_request': 'PATRONATO_APPOINTMENT_REQUEST',
  'inps_appointment_contact_request': 'INPS_APPOINTMENT_CONTACT_REQUEST',
  'reply_rejected_inps_request': 'REPLY_REJECTED_INPS_REQUEST',
  'missing_documents_integration': 'MISSING_DOCUMENTS_INTEGRATION',
  'employer_termination_contract_end_documents':
      'EMPLOYER_TERMINATION_CONTRACT_END_DOCUMENTS',
  'payslip_tfr_final_payment_problem':
      'PAYSLIP_TFR_FINAL_PAYMENT_PROBLEM',
  'sick_leave_malattia_inps_basics': 'SICK_LEAVE_MALATTIA_INPS_BASICS',
  'maternity_family_benefit_help': 'MATERNITY_FAMILY_BENEFIT_HELP',
  'isee_caf_connection': 'ISEE_CAF_CONNECTION',
  'union_legal_work_dispute_support': 'UNION_LEGAL_WORK_DISPUTE_SUPPORT',
  'general_inps_formal_request_pec': 'GENERAL_INPS_FORMAL_REQUEST_PEC',
};

const Map<String, String> _universityProcedureMap = {
  'understand_student_administrative_problem':
      'UNDERSTAND_STUDENT_ADMINISTRATIVE_PROBLEM',
  'university_office_request': 'UNIVERSITY_OFFICE_REQUEST',
  'edisu_scholarship_application': 'EDISU_SCHOLARSHIP_APPLICATION',
  'edisu_rejected_missing_documents': 'EDISU_REJECTED_MISSING_DOCUMENTS',
  'student_housing_edisu_residence': 'STUDENT_HOUSING_EDISU_RESIDENCE',
  'isee_isee_parificato_students': 'ISEE_ISEE_PARIFICATO_STUDENTS',
  'tuition_fees_fee_reduction_documents':
      'TUITION_FEES_FEE_REDUCTION_DOCUMENTS',
  'permesso_first_request': 'PERMESSO_FIRST_REQUEST',
  'permesso_renewal': 'PERMESSO_RENEWAL',
  'permesso_questura_followup': 'PERMESSO_QUESTURA_FOLLOWUP',
  'student_healthcare_tessera_doctor': 'STUDENT_HEALTHCARE_TESSERA_DOCTOR',
  'residenza_domicile_students': 'RESIDENZA_DOMICILE_STUDENTS',
  'rental_contract_proof_students': 'RENTAL_CONTRACT_PROOF_STUDENTS',
  'university_certificate_request': 'UNIVERSITY_CERTIFICATE_REQUEST',
  'formal_email_university_edisu_office':
      'FORMAL_EMAIL_UNIVERSITY_EDISU_OFFICE',
};

const Map<String, String> _generalProcedureMap = {
  'understand_which_office_to_contact': 'UNDERSTAND_WHICH_OFFICE_TO_CONTACT',
  'generic_formal_request': 'GENERIC_FORMAL_REQUEST',
  'formal_appointment_request': 'FORMAL_APPOINTMENT_REQUEST',
  'reply_rejected_public_office_request':
      'REPLY_REJECTED_PUBLIC_OFFICE_REQUEST',
  'missing_documents_integration': 'MISSING_DOCUMENTS_INTEGRATION_GENERAL',
  'refund_request': 'REFUND_REQUEST',
  'complaint_request': 'COMPLAINT_REQUEST',
  'followup_unanswered_request': 'FOLLOWUP_UNANSWERED_REQUEST',
  'status_update_with_protocol': 'STATUS_UPDATE_WITH_PROTOCOL',
  'ask_document_clarification': 'ASK_DOCUMENT_CLARIFICATION',
  'send_pec_with_attachments': 'SEND_PEC_WITH_ATTACHMENTS',
  'write_short_polite_email': 'WRITE_SHORT_POLITE_EMAIL',
  'write_strong_formal_complaint': 'WRITE_STRONG_FORMAL_COMPLAINT',
  'prepare_documents_before_office': 'PREPARE_DOCUMENTS_BEFORE_OFFICE',
  'convert_informal_to_formal_italian':
      'CONVERT_INFORMAL_TO_FORMAL_ITALIAN',
};

class UtilityHubScreen extends StatelessWidget {
  const UtilityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: context.l10n.t('utilities_bills'),
      categoryGuidance: UtilitiesElectricityGasGuidanceDefinitions.category,
      procedureMap: _utilityProcedureMap,
    );
  }
}

class UtilityComparisonScreen extends StatefulWidget {
  const UtilityComparisonScreen({super.key});

  @override
  State<UtilityComparisonScreen> createState() =>
      _UtilityComparisonScreenState();
}

class _UtilityComparisonScreenState extends State<UtilityComparisonScreen> {
  final _currentAnnualCost = TextEditingController(text: '1200');
  final _currentMonthlyCost = TextEditingController(text: '100');
  final _offerA = TextEditingController(text: '900');
  final _offerB = TextEditingController(text: '1100');

  @override
  void dispose() {
    _currentAnnualCost.dispose();
    _currentMonthlyCost.dispose();
    _offerA.dispose();
    _offerB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).utilityController;
    final result = controller.comparisonResult;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('compare_offers'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Current bill',
              child: Column(
                children: [
                  TextField(
                    controller: _currentAnnualCost,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current annual cost',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _currentMonthlyCost,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current monthly cost',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Offers',
              child: Column(
                children: [
                  TextField(
                    controller: _offerA,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Offer A annual cost',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _offerB,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Offer B annual cost',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final decision = await AppScope.of(
                  context,
                ).entitlementService.canRunUtilityComparison();
                if (!context.mounted) {
                  return;
                }
                if (!decision.allowed) {
                  await showPremiumPaywallSheet(
                    context,
                    decision: decision,
                    featureLabel: 'Utility comparison',
                  );
                  return;
                }
                if (decision.blockedByBeta) {
                  final proceed = await showPremiumPaywallSheet(
                    context,
                    decision: decision,
                    featureLabel: 'Utility comparison',
                  );
                  if (proceed != true || !context.mounted) {
                    return;
                  }
                }
                controller.compare(
                  UtilityComparisonInput(
                    utilityType: UtilityType.electricity,
                    currentProvider: 'Current provider',
                    currentAnnualCost: double.tryParse(_currentAnnualCost.text),
                    currentMonthlyCost: double.tryParse(
                      _currentMonthlyCost.text,
                    ),
                    residentDomestic: true,
                    hasCanoneRaiCharge: true,
                    currentPriceType: UtilityPriceType.variable,
                    offers: [
                      UtilityOffer(
                        providerName: 'Offer A Provider',
                        offerName: 'Offer A',
                        utilityType: UtilityType.electricity,
                        priceType: UtilityPriceType.fixed,
                        estimatedAnnualCost: double.tryParse(_offerA.text),
                        fixedMonthlyFee: 10,
                      ),
                      UtilityOffer(
                        providerName: 'Offer B Provider',
                        offerName: 'Offer B',
                        utilityType: UtilityType.electricity,
                        priceType: UtilityPriceType.fixed,
                        estimatedAnnualCost: double.tryParse(_offerB.text),
                        fixedMonthlyFee: 10,
                      ),
                    ],
                  ),
                );
                await AppScope.of(
                  context,
                ).entitlementService.recordUtilityComparison();
              },
              child: const Text('Compare now'),
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Result',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Best estimated offer: ${result.bestOfferName}'),
                    Text(
                      'Annual savings: ${result.estimatedAnnualSavings.toStringAsFixed(0)}',
                    ),
                    Text(
                      'Monthly savings: ${result.estimatedMonthlySavings.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    Text(result.explanation),
                    const SizedBox(height: 8),
                    ...result.riskFlags.map((flag) => Text('- ${flag.name}')),
                    const SizedBox(height: 8),
                    ...result.checklistBeforeSwitching.map(
                      (item) => Text('- $item'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BillAnalyzerChecklistScreen extends StatefulWidget {
  const BillAnalyzerChecklistScreen({super.key});

  @override
  State<BillAnalyzerChecklistScreen> createState() =>
      _BillAnalyzerChecklistScreenState();
}

class _BillAnalyzerChecklistScreenState
    extends State<BillAnalyzerChecklistScreen> {
  final _amount = TextEditingController(text: '240');
  final _previous = TextEditingController(text: '110');

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).utilityController;
    final result = controller.billAnalysisResult;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('understand_bill'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Canone RAI present'),
            ),
            TextField(
              controller: _amount,
              decoration: const InputDecoration(
                labelText: 'Current bill amount',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _previous,
              decoration: const InputDecoration(
                labelText: 'Previous bill amount',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final decision = await AppScope.of(
                  context,
                ).entitlementService.canRunBillAnalysis();
                if (!context.mounted) {
                  return;
                }
                if (!decision.allowed) {
                  await showPremiumPaywallSheet(
                    context,
                    decision: decision,
                    featureLabel: 'Bill analysis',
                  );
                  return;
                }
                if (decision.blockedByBeta) {
                  final proceed = await showPremiumPaywallSheet(
                    context,
                    decision: decision,
                    featureLabel: 'Bill analysis',
                  );
                  if (proceed != true || !context.mounted) {
                    return;
                  }
                }
                controller.analyzeBill(
                  BillAnalysisInput(
                    billType: 'electricity',
                    providerName: 'Demo provider',
                    amount: double.tryParse(_amount.text),
                    previousBillAmount: double.tryParse(_previous.text),
                    readingType: 'estimated',
                    hasConguaglio: true,
                    hasCanoneRai: true,
                    contractChangeNotice: true,
                  ),
                );
                await AppScope.of(
                  context,
                ).entitlementService.recordBillAnalysis();
              },
              child: const Text('Analyze bill'),
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Analysis',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...result.redFlags.map((item) => Text('- $item')),
                    const SizedBox(height: 8),
                    ...result.likelyReasons.map((item) => Text('- $item')),
                    const SizedBox(height: 8),
                    ...result.nextSteps.map((item) => Text('- $item')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CanoneRaiHubScreen extends StatelessWidget {
  const CanoneRaiHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: context.l10n.t('canone_rai'),
      categoryGuidance: CanoneRaiGuidanceDefinitions.category,
      procedureMap: _canoneProcedureMap,
    );
  }
}

class CanoneRaiDecisionFlowScreen extends StatefulWidget {
  const CanoneRaiDecisionFlowScreen({super.key});

  @override
  State<CanoneRaiDecisionFlowScreen> createState() =>
      _CanoneRaiDecisionFlowScreenState();
}

class _CanoneRaiDecisionFlowScreenState
    extends State<CanoneRaiDecisionFlowScreen> {
  @override
  Widget build(BuildContext context) {
    return const CanoneRaiHubScreen();
  }
}

class TelecomHubScreen extends StatelessWidget {
  const TelecomHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: context.l10n.t('telecom'),
      categoryGuidance: TelecomGuidanceDefinitions.category,
      procedureMap: _telecomProcedureMap,
    );
  }
}

class PublicOfficeComuneHubScreen extends StatelessWidget {
  const PublicOfficeComuneHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: 'Public Office / Comune',
      categoryGuidance: PublicOfficeComuneGuidanceDefinitions.category,
      procedureMap: _publicOfficeProcedureMap,
    );
  }
}

class WorkInpsPatronatoHubScreen extends StatelessWidget {
  const WorkInpsPatronatoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: 'Work / INPS / Patronato',
      categoryGuidance: WorkInpsPatronatoGuidanceDefinitions.category,
      procedureMap: _workInpsProcedureMap,
    );
  }
}

class UniversityStudentHubScreen extends StatelessWidget {
  const UniversityStudentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: 'University / Student',
      categoryGuidance: UniversityStudentGuidanceDefinitions.category,
      procedureMap: _universityProcedureMap,
    );
  }
}

class GeneralHubScreen extends StatelessWidget {
  const GeneralHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RichCategoryHubScreen(
      appBarTitle: 'General',
      categoryGuidance: GeneralGuidanceDefinitions.category,
      procedureMap: _generalProcedureMap,
    );
  }
}

class _RichCategoryHubScreen extends StatefulWidget {
  const _RichCategoryHubScreen({
    required this.appBarTitle,
    required this.categoryGuidance,
    required this.procedureMap,
  });

  final String appBarTitle;
  final RichCategoryGuidance categoryGuidance;
  final Map<String, String> procedureMap;

  @override
  State<_RichCategoryHubScreen> createState() => _RichCategoryHubScreenState();
}

class _RichCategoryHubScreenState extends State<_RichCategoryHubScreen> {
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final match = _resolveRichRoute(widget.categoryGuidance, _answers);
    RichCategorySubcategory? routedSubcategory;
    if (match != null) {
      for (final item in widget.categoryGuidance.subcategories) {
        if (item.id == match.routeTo) {
          routedSubcategory = item;
          break;
        }
      }
    }
    final visibleSubcategories = routedSubcategory != null
        ? [routedSubcategory]
        : widget.categoryGuidance.subcategories;

    return Scaffold(
      appBar: AppBar(title: Text(widget.appBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: widget.categoryGuidance.title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.categoryGuidance.shortDescription),
                  const SizedBox(height: 12),
                  Text(
                    widget.categoryGuidance.mainUserQuestion,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Guided selector',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.categoryGuidance.firstScreenQuestions
                      .where(
                        (question) =>
                            _shouldShowRichQuestion(question, _answers),
                      )
                      .map(
                        (question) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RichQuestionField(
                            question: question,
                            value: _answers[question.id],
                            onChanged: (value) =>
                                setState(() => _answers[question.id] = value),
                          ),
                        ),
                      ),
                if (match != null && match.priority == 'urgent')
                    Card(
                      color: Colors.red.withValues(alpha: 0.08),
                      child: const ListTile(
                        leading: Icon(Icons.warning_amber_outlined),
                        title: Text(
                          'For danger, gas smell, suspected leak, sparks, burning smell, or technical emergency, call the distributor/pronto intervento number printed on the bill. Do not wait for email.',
                        ),
                      ),
                    ),
                  if (match?.note != null) ...[
                    const SizedBox(height: 8),
                    Text(match!.note!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...visibleSubcategories.whereType<RichCategorySubcategory>().map(
              (subcategory) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RichSubcategoryCard(
                  subcategory: subcategory,
                  procedureId: widget.procedureMap[subcategory.id],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GlobalProblemRequestCard(
              categoryId: widget.categoryGuidance.id,
              sourcePage: widget.appBarTitle,
            ),
            const SizedBox(height: 12),
            PrivateConsultancyCard(
              categoryId: widget.categoryGuidance.id,
              sourcePage: widget.appBarTitle,
            ),
          ],
        ),
      ),
    );
  }
}

bool _shouldShowRichQuestion(
  RichCategoryQuestion question,
  Map<String, String> answers,
) {
  if (question.showWhen.isEmpty) return true;
  for (final entry in question.showWhen.entries) {
    if (answers[entry.key] != entry.value) return false;
  }
  return true;
}

RichCategoryRoutingRule? _resolveRichRoute(
  RichCategoryGuidance guidance,
  Map<String, String> answers,
) {
  for (final rule in guidance.routingRules) {
    var matches = true;
    for (final entry in rule.conditions.entries) {
      if (answers[entry.key] != entry.value) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return rule;
    }
  }
  return null;
}

class _RichQuestionField extends StatelessWidget {
  const _RichQuestionField({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final RichCategoryQuestion question;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (question.type == 'text') {
      return TextFormField(
        initialValue: value ?? '',
        decoration: InputDecoration(
          labelText: question.question,
          hintText: question.placeholder,
        ),
        onChanged: onChanged,
      );
    }

    return _QuestionChoiceGroup(
      title: question.question,
      options: question.options
          .map((item) => (id: item.id, label: item.label))
          .toList(),
      selectedId: value,
      onSelected: onChanged,
    );
  }
}

class _RichSubcategoryCard extends StatelessWidget {
  const _RichSubcategoryCard({
    required this.subcategory,
    required this.procedureId,
  });

  final RichCategorySubcategory subcategory;
  final String? procedureId;

  @override
  Widget build(BuildContext context) {
    final procedure = procedureId == null
        ? null
        : ItalyAdminProcedureDefinitions.byId(procedureId!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subcategory.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (subcategory.priority.isNotEmpty)
                  Chip(label: Text(subcategory.priority)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subcategory.titleIt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(subcategory.whatIsIt),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: procedure == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.procedureDetail,
                        arguments: ProcedureRouteArgs(procedure),
                      ),
                child: const Text('Open'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalProblemRequestCard extends StatelessWidget {
  const GlobalProblemRequestCard({
    super.key,
    required this.categoryId,
    required this.sourcePage,
    this.subcategoryId,
  });

  final String categoryId;
  final String sourcePage;
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: scope.productEntitlementsService.getUserEntitlements(),
      builder: (context, snapshot) {
        final entitlements = snapshot.data;
        return _SectionCard(
          title: 'Can’t find your problem?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Non trovi il tuo problema?'),
              const SizedBox(height: 8),
              const Text(
                'Ask us and we’ll add your problem as fast as possible.\n\nScrivici e aggiungeremo il tuo problema il prima possibile.',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: entitlements == null
                    ? null
                    : () async {
                        if (entitlements.canRequestProblem) {
                          final request = await _showProblemRequestSheet(
                            context,
                            categoryId: categoryId,
                            subcategoryId: subcategoryId,
                            sourcePage: sourcePage,
                            isPremiumUser: entitlements.isPremium,
                          );
                          if (request == null) return;
                          await scope.problemRequestsService.submitProblemRequest(
                            request,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Thanks. We received your request and will review it as soon as possible.\nGrazie. Abbiamo ricevuto la tua richiesta e la controlleremo il prima possibile.',
                              ),
                            ),
                          );
                          return;
                        }
                        final result = await scope.productEntitlementsService
                            .requirePremiumOrPayment(purpose: 'problem_request');
                        if (!context.mounted) return;
                        if (result.decision != null) {
                          await showPremiumPaywallSheet(
                            context,
                            decision: result.decision!,
                            featureLabel:
                                'This request feature is available for Premium users. Upgrade to Premium to request new problems and get priority support.\n\nQuesta funzione è disponibile per gli utenti Premium. Passa a Premium per richiedere nuovi problemi e ricevere supporto prioritario.',
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        }
                      },
                child: const Text('Request a new problem'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PrivateConsultancyCard extends StatelessWidget {
  const PrivateConsultancyCard({
    super.key,
    required this.categoryId,
    required this.sourcePage,
    this.subcategoryId,
  });

  final String categoryId;
  final String sourcePage;
  final String? subcategoryId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: scope.productEntitlementsService.getUserEntitlements(),
      builder: (context, snapshot) {
        final entitlements = snapshot.data;
        return _SectionCard(
          title: 'Need private help with your case?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hai bisogno di aiuto privato per il tuo caso?'),
              const SizedBox(height: 8),
              const Text(
                'Send us your case by email and we’ll help you understand what to do, which documents you need, and which office/contact to use.\n\nMandaci il tuo caso via email e ti aiutiamo a capire cosa fare, quali documenti servono e quale ufficio/contatto usare.',
              ),
              const SizedBox(height: 12),
              Text(
                'We help you understand procedures, documents, offices, and possible next steps. We do not replace a lawyer, accountant, CAF, patronato, public office, or emergency service.\n\nTi aiutiamo a capire procedure, documenti, uffici e possibili prossimi passi. Non sostituiamo avvocato, commercialista, CAF, patronato, ufficio pubblico o servizio di emergenza.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: entitlements == null
                        ? null
                        : () async {
                            if (entitlements.canUsePrivateConsultancyForFree) {
                              final request = await _showConsultancyRequestSheet(
                                context,
                                categoryId: categoryId,
                                subcategoryId: subcategoryId,
                                sourcePage: sourcePage,
                                userPlan: entitlements.isPremium
                                    ? UfficioPlan.pro.name
                                    : UfficioPlan.free.name,
                              );
                              if (request == null) return;
                              await scope.consultancyService
                                  .submitConsultancyRequest(request);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Consultancy request saved. Notification email is not configured yet.',
                                  ),
                                ),
                              );
                              return;
                            }
                            final result = await scope.productEntitlementsService
                                .requirePremiumOrPayment(
                                  purpose: 'consultancy',
                                );
                            if (!context.mounted) return;
                            if (result.decision != null) {
                              await showPremiumPaywallSheet(
                                context,
                                decision: result.decision!,
                                featureLabel:
                                    'Private consultancy is free for Premium users. Free users need an extra payment or upgrade.\n\nLa consulenza privata è gratuita per gli utenti Premium. Gli utenti free devono pagare o passare a Premium.',
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.message)),
                              );
                            }
                          },
                    child: Text(
                      entitlements?.canUsePrivateConsultancyForFree == true
                          ? 'Request private consultancy'
                          : 'Unlock private consultancy',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
                    child: Text(
                      entitlements?.canUsePrivateConsultancyForFree == true
                          ? 'Send case by email'
                          : 'Upgrade to Premium',
                    ),
                  ),
                ],
              ),
              if (entitlements?.canUsePrivateConsultancyForFree != true) ...[
                const SizedBox(height: 8),
                const Text('Payment is not configured yet.'),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _resolveLocalUserKey(BuildContext context) {
  final scope = AppScope.of(context);
  final auth = scope.authFacade.state;
  final profile = scope.profileController.profile;
  return auth.userId ??
      profile.email ??
      profile.codiceFiscale ??
      'local-user';
}

UfficioCostItem? _buildEstimatedCostItemForRichSubcategory(
  BuildContext context,
  RichCategoryGuidance guidance,
  RichCategorySubcategory subcategory,
) {
  final amountBySubcategory = <String, double>{
    'new_home_changed_electricity_contract': 16,
    'help_filling_agenzia_entrate_form': 0,
    'anagrafe_certificate_request': 16,
    'family_status_certificate': 16,
    'residence_certificate': 16,
    'internet_phone_cancellation': 30,
    'modem_return_or_charge_dispute': 30,
    'payment_plan_request': 0,
    'provider_switching': 0,
    'subentro': 35,
    'voltura': 28,
  };
  final amount = amountBySubcategory[subcategory.id];
  if (amount == null) return null;
  return UfficioCostItem(
    id: const Uuid().v4(),
    userId: _resolveLocalUserKey(context),
    categoryId: guidance.id,
    subcategoryId: subcategory.id,
    title: '${subcategory.title} estimated cost',
    description: 'Prefilled from ${guidance.title}',
    amount: amount,
    type: UfficioCostItemType.estimate,
    status: UfficioCostItemStatus.estimated,
    source: UfficioCostItemSource.generatedFromCategory,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Future<ProblemRequestRecord?> _showProblemRequestSheet(
  BuildContext context, {
  required String categoryId,
  required String sourcePage,
  required bool isPremiumUser,
  String? subcategoryId,
}) {
  final scope = AppScope.of(context);
  final profile = scope.profileController.profile;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final cityController = TextEditingController(
    text: (profile.city ?? '').isEmpty ? 'Torino' : profile.city!,
  );
  final regionController = TextEditingController(text: 'Piemonte');
  final emailController = TextEditingController(text: profile.email ?? '');
  var urgency = 'normal';
  var language = 'English';

  return showModalBottomSheet<ProblemRequestRecord>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request a new problem',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Problem title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: categoryId)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: categoryId.length),
                    ),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: 'Region'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: urgency,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('low')),
                    DropdownMenuItem(value: 'normal', child: Text('normal')),
                    DropdownMenuItem(value: 'urgent', child: Text('urgent')),
                  ],
                  onChanged: (value) =>
                      setState(() => urgency = value ?? 'normal'),
                  decoration: const InputDecoration(labelText: 'Urgency'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: language,
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Italian', child: Text('Italian')),
                    DropdownMenuItem(value: 'Persian', child: Text('Persian')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => language = value ?? 'English'),
                  decoration: const InputDecoration(
                    labelText: 'Preferred language',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Optional email'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Attachments will appear here once a real upload integration is configured.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        categoryId.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Title, description, and category are required.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      ProblemRequestRecord(
                        id: const Uuid().v4(),
                        userId: scope.authFacade.state.userId,
                        userEmail: emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim(),
                        categoryId: categoryId,
                        subcategoryId: subcategoryId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        city: cityController.text.trim().isEmpty
                            ? 'Torino'
                            : cityController.text.trim(),
                        region: regionController.text.trim().isEmpty
                            ? 'Piemonte'
                            : regionController.text.trim(),
                        urgency: urgency,
                        language: language,
                        status: ProblemRequestStatus.newRequest,
                        isPremiumUser: isPremiumUser,
                        sourcePage: sourcePage,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<ConsultancyRequestRecord?> _showConsultancyRequestSheet(
  BuildContext context, {
  required String categoryId,
  required String sourcePage,
  required String userPlan,
  String? subcategoryId,
}) {
  final scope = AppScope.of(context);
  final profile = scope.profileController.profile;
  final nameController = TextEditingController(text: profile.fullName ?? '');
  final emailController = TextEditingController(text: profile.email ?? '');
  final problemTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final resultController = TextEditingController();
  final cityController = TextEditingController(
    text: (profile.city ?? '').isEmpty ? 'Torino' : profile.city!,
  );
  final regionController = TextEditingController(text: 'Piemonte');
  final documentsController = TextEditingController();
  var consent = false;

  return showModalBottomSheet<ConsultancyRequestRecord>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request private consultancy',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: categoryId)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: categoryId.length),
                    ),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: problemTypeController,
                  decoration: const InputDecoration(labelText: 'Problem type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description of the case',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: resultController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'What result do you want?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: regionController,
                  decoration: const InputDecoration(labelText: 'Region'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: documentsController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Documents already available',
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: consent,
                  onChanged: (value) =>
                      setState(() => consent = value ?? false),
                  title: const Text(
                    'I understand this is administrative guidance, not legal representation.\nCapisco che si tratta di orientamento amministrativo, non di rappresentanza legale.',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Attachments will appear here once a real upload integration is configured.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (emailController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        !consent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Email, description, and consent are required.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      ConsultancyRequestRecord(
                        id: const Uuid().v4(),
                        userId: scope.authFacade.state.userId,
                        userEmail: emailController.text.trim(),
                        fullName: nameController.text.trim(),
                        categoryId: categoryId,
                        subcategoryId: subcategoryId,
                        problemType: problemTypeController.text.trim(),
                        description: descriptionController.text.trim(),
                        desiredResult: resultController.text.trim(),
                        city: cityController.text.trim().isEmpty
                            ? 'Torino'
                            : cityController.text.trim(),
                        region: regionController.text.trim().isEmpty
                            ? 'Piemonte'
                            : regionController.text.trim(),
                        documentsAvailable: documentsController.text.trim(),
                        userPlan: userPlan,
                        paymentStatus:
                            ConsultancyPaymentStatus.freeForPremium,
                        status: ConsultancyRequestStatus.newRequest,
                        sourcePage: sourcePage,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final admin = scope.adminController;
    final procedures = scope.procedureController.procedures;
    final requests = scope.requestController.requests;
    final events = admin.events;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('admin_panel'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Dashboard',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Procedures', value: '${procedures.length}'),
                  _StatChip(label: 'Requests', value: '${requests.length}'),
                  _StatChip(label: 'Events', value: '${events.length}'),
                  _StatChip(
                    label: 'Reminders',
                    value:
                        '${requests.expand((item) => item.reminders).length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Backend health',
              child: FutureBuilder(
                future: Future.wait([
                  scope.syncService.getStatus(),
                  scope.catalogRepository.getHealthSnapshot(),
                  scope.catalogRepository.getAppPublicConfig(),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final syncStatus = snapshot.data![0] as SyncStatus;
                  final catalogHealth =
                      snapshot.data![1] as CatalogHealthSnapshot;
                  final appConfig = snapshot.data![2] as Map<String, dynamic>;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product: ${scope.config.appName}'),
                      Text('Backend mode: ${scope.config.backendLabel}'),
                      Text(
                        'Supabase configured: ${scope.config.hasSupabaseCredentials}',
                      ),
                      Text(
                        'Supabase initialized: ${scope.supabaseBootstrapResult.initialized}',
                      ),
                      const Text('User auth: not required for public catalog'),
                      Text(
                        'Authenticated: ${scope.authFacade.state.isAuthenticated}',
                      ),
                      Text('Sync status: ${syncStatus.state.name}'),
                      Text(
                        'Public catalog remote: ${catalogHealth.remoteAvailable ? 'available' : 'fallback'}',
                      ),
                      Text(
                        'Catalog fallback active: ${catalogHealth.usingFallback}',
                      ),
                      Text(
                        'Last catalog fetch: ${catalogHealth.lastFetchAt?.toIso8601String() ?? 'not yet fetched'}',
                      ),
                      Text(
                        'Catalog counts: ${catalogHealth.itemCounts.entries.map((item) => '${item.key}=${item.value}').join(', ')}',
                      ),
                      Text(
                        'Public config says auth required: ${appConfig['userAuthRequired'] ?? false}',
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Catalog status',
              child: FutureBuilder(
                future: Future.wait([
                  scope.catalogRepository.listOfficialLinks(),
                  scope.catalogRepository.listOfficialContacts(),
                  scope.catalogRepository.listServiceProviders(),
                  scope.catalogRepository.listProcedureGuidance(),
                ]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final links = snapshot.data![0] as List<catalog.OfficialLink>;
                  final contacts =
                      snapshot.data![1] as List<catalog.OfficialContact>;
                  final providers =
                      snapshot.data![2] as List<catalog.ServiceProvider>;
                  final guidance =
                      snapshot.data![3] as List<catalog.ProcedureGuidance>;
                  final verifiedLinks = links
                      .where((item) => item.isVerified)
                      .length;
                  final needsReviewContacts = contacts
                      .where(
                        (item) =>
                            item.verificationStatus ==
                            catalog.CatalogVerificationStatus.needsReview,
                      )
                      .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Official links: ${links.length} ($verifiedLinks verified)',
                      ),
                      Text(
                        'Official contacts: ${contacts.length} ($needsReviewContacts need review)',
                      ),
                      Text('Providers: ${providers.length}'),
                      Text('Procedure guidance records: ${guidance.length}'),
                      const SizedBox(height: 8),
                      const Text('Remote editing not enabled in this build.'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Feature flags',
              child: Column(
                children: [
                  SwitchListTile(
                    value: scope.appController.config.adminModeEnabled,
                    onChanged: (value) => scope.appController.updateConfig(
                      scope.appController.config.copyWith(
                        adminModeEnabled: value,
                      ),
                    ),
                    title: const Text('Admin mode'),
                  ),
                  SwitchListTile(
                    value:
                        scope.appController.config.featureFlags.enableUtilities,
                    onChanged: (value) => scope.appController.updateConfig(
                      scope.appController.config.copyWith(
                        featureFlags: scope.appController.config.featureFlags
                            .copyWith(enableUtilities: value),
                      ),
                    ),
                    title: const Text('Enable utilities'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Service intelligence quality',
              child: Builder(
                builder: (context) {
                  final results = ServiceIntelligenceQualityService().runAll();
                  final warningCount = results.fold<int>(
                    0,
                    (sum, item) => sum + item.warnings.length,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Procedure intelligence records: ${results.length}'),
                      Text('Quality warnings: $warningCount'),
                      const SizedBox(height: 8),
                      ...results
                          .take(6)
                          .map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.procedureId),
                              subtitle: Text(
                                item.warnings.isEmpty
                                    ? 'No warnings'
                                    : item.warnings.join(' • '),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Premium config',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Pro is for testing only. Real payments must be verified server-side later.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.adminPremium),
                    child: const Text('Open premium admin'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Pack preview lab',
              child: Column(
                children: procedures.take(6).map((procedure) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(procedure.title),
                    trailing: const Icon(Icons.visibility_outlined),
                    onTap: () {
                      final sample = {
                        'fullName': 'Mario Rossi',
                        'senderName': 'Mario Rossi',
                        'provider': 'Demo Provider',
                        'officeName': 'Demo Office',
                        'reason': 'sample preview',
                        'topic': 'sample topic',
                        'request': 'sample request',
                      };
                      final pack = PackGenerator.generate(
                        procedure: procedure,
                        inputData: sample,
                      );
                      admin.checkPack(pack);
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(procedure.title),
                          content: SingleChildScrollView(
                            child: Text(
                              '${pack.subject}\n\n${admin.qualityResult?.warnings.join('\n') ?? 'No warnings'}',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Recommender tester',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Try phrases like “cancel internet”, “cheap electricity”, or “remove canone rai” from the Start from my problem screen.',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.scan),
                        child: const Text('Situation scanner'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.cityPacks),
                        child: const Text('City packs'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.checklist),
                        child: const Text('Checklist'),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.officialLinks,
                        ),
                        child: const Text('Official links'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Phase 5 tools',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.documentVault),
                    child: const Text('Documents'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.contacts),
                    child: const Text('Contacts'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.household),
                    child: const Text('Household'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.deadlines),
                    child: const Text('Deadlines'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.costs),
                    child: const Text('Costs'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.templates),
                    child: const Text('Templates'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: context.l10n.t('demo_data'),
              child: ElevatedButton(
                onPressed: () async {
                  await admin.seedDemoData();
                  final demo = DemoDataService().build();
                  for (final item in demo.documents) {
                    await scope.documentsRepository.save(item);
                  }
                  for (final item in demo.contacts) {
                    await scope.contactsRepository.save(item);
                  }
                  for (final item in demo.contracts) {
                    await scope.contractsRepository.save(item);
                  }
                  for (final item in demo.householdMembers) {
                    await scope.householdRepository.save(item);
                  }
                  for (final item in demo.clients) {
                    await scope.clientsRepository.save(item);
                  }
                  for (final item in demo.proofCases) {
                    await scope.proofFolderRepository.saveCase(item);
                  }
                  for (final item in demo.templates) {
                    await scope.templatesRepository.save(item);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo data seeded')),
                    );
                  }
                },
                child: const Text('Seed demo requests'),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Local analytics',
              child: Column(
                children: events.take(10).map((event) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(event.eventName),
                    subtitle: Text(
                      DateFormat('dd/MM HH:mm').format(event.createdAt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicField extends StatelessWidget {
  const _DynamicField({
    required this.field,
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  final ProcedureField field;
  final dynamic value;
  final String? errorText;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case ProcedureFieldType.boolean:
        return SwitchListTile(
          value: value as bool? ?? false,
          onChanged: onChanged,
          title: Text(field.label),
        );
      case ProcedureFieldType.date:
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          subtitle: Text(
            value is DateTime
                ? DateFormat('dd/MM/yyyy').format(value)
                : 'Tap to select',
          ),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (picked != null) onChanged(picked);
          },
        );
      case ProcedureFieldType.select:
        return DropdownButtonFormField<String>(
          initialValue: value as String?,
          items: field.options
              .map(
                (item) => DropdownMenuItem(
                  value: item.value,
                  child: Text(item.label),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: field.label,
            errorText: errorText,
          ),
        );
      case ProcedureFieldType.textarea:
        return TextField(
          controller: TextEditingController(text: value?.toString() ?? '')
            ..selection = TextSelection.collapsed(
              offset: (value?.toString() ?? '').length,
            ),
          maxLines: 4,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: field.label,
            errorText: errorText,
          ),
        );
      case ProcedureFieldType.number:
      case ProcedureFieldType.email:
      case ProcedureFieldType.phone:
      case ProcedureFieldType.text:
      case ProcedureFieldType.multiselect:
        return TextField(
          controller: TextEditingController(text: value?.toString() ?? '')
            ..selection = TextSelection.collapsed(
              offset: (value?.toString() ?? '').length,
            ),
          keyboardType: field.type == ProcedureFieldType.number
              ? TextInputType.number
              : field.type == ProcedureFieldType.email
              ? TextInputType.emailAddress
              : field.type == ProcedureFieldType.phone
              ? TextInputType.phone
              : TextInputType.text,
          onChanged: (text) => onChanged(
            field.type == ProcedureFieldType.number
                ? double.tryParse(text)
                : text,
          ),
          decoration: InputDecoration(
            labelText: field.label,
            errorText: errorText,
          ),
        );
    }
  }
}

class _CopyableContent extends StatelessWidget {
  const _CopyableContent({
    required this.title,
    required this.value,
    required this.copyLabel,
  });

  final String title;
  final String value;
  final String copyLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$copyLabel ${context.l10n.t('copied').toLowerCase()}',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SelectableText(value),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: actions),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({super.key, required this.entitlement});

  final dynamic entitlement;

  @override
  Widget build(BuildContext context) {
    final title = entitlement.betaModeEnabled
        ? 'Beta access active: Pro tools are temporarily unlocked while UfficioFacile is being tested.'
        : entitlement.plan == UfficioPlan.free
        ? 'Free plan: ${entitlement.generatedPacksUsedThisMonth} of ${entitlement.freePackLimit} packs used this month.'
        : 'Current plan: ${entitlement.plan.name}.';
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.workspace_premium_outlined),
        title: Text(title),
        subtitle: const Text('Choose how far UfficioFacile can help you.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, AppRoutes.plan),
      ),
    );
  }
}

class UsageLimitCard extends StatelessWidget {
  const UsageLimitCard({super.key, required this.item});

  final UsageSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final ratio = item.limit == 0
        ? 0.0
        : (item.used / item.limit).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text('${item.used} / ${item.limit}'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: ratio),
          ],
        ),
      ),
    );
  }
}

class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({super.key, required this.status});

  final ServiceVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ServiceVerificationStatus.verified => ('Verified', Colors.green),
      ServiceVerificationStatus.needsReview => ('Needs review', Colors.orange),
      ServiceVerificationStatus.unverified => ('Unverified', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label),
    );
  }
}

class ServiceTermLink extends StatelessWidget {
  const ServiceTermLink({super.key, required this.label, required this.termId});

  final String label;
  final String termId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.terms,
        arguments: TermRouteArgs(termId),
      ),
      child: Text(
        label,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TermChip extends StatelessWidget {
  const TermChip({super.key, required this.termId, required this.label});

  final String termId;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () => Navigator.pushNamed(
        context,
        AppRoutes.terms,
        arguments: TermRouteArgs(termId),
      ),
    );
  }
}

class ClickableTermText extends StatelessWidget {
  const ClickableTermText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var remaining = text;
    while (remaining.isNotEmpty) {
      _MatchResult? best;
      for (final pattern in ServiceTermsDictionary.patterns) {
        final index = remaining.toLowerCase().indexOf(
          pattern.label.toLowerCase(),
        );
        if (index == -1) continue;
        if (best == null || index < best.index) {
          best = _MatchResult(index, pattern.label, pattern.id);
        }
      }
      if (best == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }
      if (best.index > 0) {
        spans.add(TextSpan(text: remaining.substring(0, best.index)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: ServiceTermLink(label: best.label, termId: best.termId),
        ),
      );
      remaining = remaining.substring(best.index + best.label.length);
    }
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}

class _MatchResult {
  const _MatchResult(this.index, this.label, this.termId);

  final int index;
  final String label;
  final String termId;
}

class DestinationGuidanceCard extends StatelessWidget {
  const DestinationGuidanceCard({
    super.key,
    required this.intelligence,
    required this.officialLinks,
  });

  final ServiceIntelligence intelligence;
  final List<dynamic> officialLinks;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Where to send / destination',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(intelligence.destinationGuidance),
          const SizedBox(height: 8),
          Text(
            'Usually responsible authority: ${intelligence.responsibleAuthorityType}',
          ),
          const SizedBox(height: 8),
          ...intelligence.recipientRules.map((item) => Text('- $item')),
          if (intelligence.officialContactOptions.isEmpty) ...[
            const SizedBox(height: 8),
            const ContactMissingWarningCard(),
          ],
          if (officialLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...officialLinks.map((item) => OfficialLinkCard(link: item)),
          ],
        ],
      ),
    );
  }
}

class OfficialLinkCard extends StatelessWidget {
  const OfficialLinkCard({super.key, required this.link});

  final dynamic link;

  @override
  Widget build(BuildContext context) {
    final warning =
        (link.warningLocalized?['en'] as String?) ??
        'Verify that this is the correct official page before submitting personal data.';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(link.title as String),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text((link.url as String?) ?? ''),
            const SizedBox(height: 4),
            Text(warning),
          ],
        ),
        trailing: VerificationStatusBadge(
          status: switch (link.verificationStatus) {
            OfficialLinkVerificationStatus.verified =>
              ServiceVerificationStatus.verified,
            OfficialLinkVerificationStatus.needsReview =>
              ServiceVerificationStatus.needsReview,
            OfficialLinkVerificationStatus.unverified =>
              ServiceVerificationStatus.unverified,
            _ => ServiceVerificationStatus.unverified,
          },
        ),
      ),
    );
  }
}

class OnlineOptionsCard extends StatelessWidget {
  const OnlineOptionsCard({super.key, required this.intelligence});

  final ServiceIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Online options',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intelligence.onlineOptions.isEmpty)
            const Text(
              'No exact portal is stored yet. Verify the official city, region, office, or provider website before submitting anything online.',
            ),
          ...intelligence.onlineOptions.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description),
                    if ((item.url ?? '').isNotEmpty) Text(item.url!),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.requiresSpid)
                          const TermChip(termId: 'spid', label: 'SPID'),
                        if (item.requiresCie)
                          const TermChip(termId: 'cie', label: 'CIE'),
                        if (item.requiresPec)
                          const TermChip(termId: 'pec', label: 'PEC'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.warning),
                  ],
                ),
                trailing: VerificationStatusBadge(
                  status: item.verificationStatus,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InPersonOptionsCard extends StatelessWidget {
  const InPersonOptionsCard({super.key, required this.intelligence});

  final ServiceIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'In-person options',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intelligence.inPersonOptions.isEmpty)
            const Text(
              'No exact office address is stored yet. Use the official office finder or city-specific guidance before visiting.',
            ),
          ...intelligence.inPersonOptions.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description),
                    if ((item.address ?? '').isNotEmpty)
                      Text('Address: ${item.address}'),
                    if ((item.officeFinderLink ?? '').isNotEmpty)
                      Text('Office finder: ${item.officeFinderLink}'),
                    const SizedBox(height: 4),
                    ...item.documentsToBring.map((doc) => Text('- $doc')),
                    const SizedBox(height: 4),
                    Text(item.warning),
                  ],
                ),
                trailing: VerificationStatusBadge(
                  status: item.verificationStatus,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailedDocumentsCard extends StatelessWidget {
  const DetailedDocumentsCard({
    super.key,
    required this.procedure,
    required this.intelligence,
  });

  final AdminProcedure procedure;
  final ServiceIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Required / recommended documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...intelligence.requiredDocumentsDetailed.map(
            (item) => DocumentRequirementTile(item: item),
          ),
          ...intelligence.recommendedDocumentsDetailed.map(
            (item) => DocumentRequirementTile(item: item),
          ),
          ...intelligence.situationSpecificDocuments.map(
            (item) => DocumentRequirementTile(item: item),
          ),
          const SizedBox(height: 8),
          ...procedure.attachmentSuggestions.map(
            (item) => Text(
              '- ${item.name}${item.required ? ' (suggested as required)' : ''}',
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentRequirementTile extends StatelessWidget {
  const DocumentRequirementTile({super.key, required this.item});

  final DocumentRequirementDetailed item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(switch (item.requiredLevel) {
        DocumentRequiredLevel.required => Icons.check_circle,
        DocumentRequiredLevel.recommended => Icons.info_outline,
        DocumentRequiredLevel.conditional => Icons.rule_folder_outlined,
        DocumentRequiredLevel.optional => Icons.circle_outlined,
      }),
      title: Text(item.name),
      subtitle: Text('${item.description}\n${item.whenNeeded}'),
    );
  }
}

class BeforeSendingGuidanceCard extends StatelessWidget {
  const BeforeSendingGuidanceCard({super.key, required this.intelligence});

  final ServiceIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Before sending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: intelligence.beforeSendingChecklist
            .map((item) => Text('- $item'))
            .toList(),
      ),
    );
  }
}

class FollowUpGuidanceCard extends StatelessWidget {
  const FollowUpGuidanceCard({
    super.key,
    required this.intelligence,
    required this.procedure,
  });

  final ServiceIntelligence intelligence;
  final AdminProcedure procedure;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Follow-up and rejection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(intelligence.followUpGuidance),
          const SizedBox(height: 8),
          Text(intelligence.rejectionGuidance),
          const SizedBox(height: 8),
          Text(intelligence.escalationGuidance),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.procedureDetail,
                  arguments: ProcedureRouteArgs(
                    ItalyAdminProcedureDefinitions.byId(
                          procedure.category == ProcedureCategory.health
                              ? 'ASL_REJECTED_REQUEST_REPLY'
                              : 'REJECTED_REQUEST_REPLY',
                        ) ??
                        procedure,
                  ),
                ),
                child: const Text('Open rejected request reply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceWarningsCard extends StatelessWidget {
  const ServiceWarningsCard({super.key, required this.intelligence});

  final ServiceIntelligence intelligence;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Warnings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: intelligence.warnings.map((item) => Text('- $item')).toList(),
      ),
    );
  }
}

class ContactMissingWarningCard extends StatelessWidget {
  const ContactMissingWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Exact email/PEC not stored yet. Add the office or provider contact after verifying it on the official website.',
        ),
      ),
    );
  }
}

Future<bool?> showPremiumPaywallSheet(
  BuildContext context, {
  required EntitlementDecision decision,
  required String featureLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            decision.upgradeTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(featureLabel),
          const SizedBox(height: 8),
          Text(decision.upgradeMessage),
          if (decision.limit != null && decision.used != null) ...[
            const SizedBox(height: 8),
            Text('Usage: ${decision.used} / ${decision.limit}'),
          ],
          const SizedBox(height: 8),
          Text(decision.reason),
          const SizedBox(height: 16),
          if (decision.blockedByBeta)
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue in beta'),
            ),
          if (!decision.blockedByBeta) ...[
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
              child: const Text('Open plan screen'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Payments are not connected yet. You can review the plan and local beta configuration.',
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Maybe later'),
          ),
        ],
      ),
    ),
  );
}

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entitlementService = AppScope.of(context).entitlementService;
    return Scaffold(
      appBar: AppBar(title: const Text('UfficioFacile plan')),
      body: FutureBuilder(
        future: Future.wait([
          entitlementService.getCurrentEntitlement(),
          entitlementService.getUsageSummary(),
          entitlementService.getConfig(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final values = snapshot.data!;
          final entitlement = values[0] as dynamic;
          final usage = values[1] as List<UsageSummaryItem>;
          final config = values[2] as PremiumConfig;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose how far UfficioFacile can help you.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text('Current plan: ${entitlement.plan.name}'),
              if (config.betaModeEnabled) ...[
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Beta access active: Pro tools are temporarily unlocked while UfficioFacile is being tested.',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: usage
                    .map(
                      (item) => SizedBox(
                        width: 180,
                        child: UsageLimitCard(item: item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Free',
                child: const Text(
                  'Good for occasional requests and basic bureaucracy help.',
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Pro',
                child: const Text(
                  'For people who want full support with bills, documents, reminders, utilities, Canone RAI, and advanced request packs.',
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Consultant',
                child: const Text(
                  'For helpers, CAF-style consultants, relocation support, and people managing multiple clients. Coming soon.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payments are not connected yet. Real payments must be added later through a secure server-side flow.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminPremiumScreen extends StatefulWidget {
  const AdminPremiumScreen({super.key});

  @override
  State<AdminPremiumScreen> createState() => _AdminPremiumScreenState();
}

class _AdminPremiumScreenState extends State<AdminPremiumScreen> {
  @override
  Widget build(BuildContext context) {
    final service = AppScope.of(context).entitlementService;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium admin')),
      body: FutureBuilder(
        future: Future.wait([
          service.getConfig(),
          service.getCurrentEntitlement(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final config = snapshot.data![0] as PremiumConfig;
          final entitlement = snapshot.data![1] as dynamic;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                value: config.betaModeEnabled,
                onChanged: (value) async {
                  await service.saveConfig(
                    config.copyWith(betaModeEnabled: value),
                  );
                  if (mounted) setState(() {});
                },
                title: const Text('Beta mode enabled'),
              ),
              SwitchListTile(
                value: config.paywallEnabled,
                onChanged: (value) async {
                  await service.saveConfig(
                    config.copyWith(paywallEnabled: value),
                  );
                  if (mounted) setState(() {});
                },
                title: const Text('Paywall enabled'),
              ),
              SwitchListTile(
                value: config.showPremiumBadges,
                onChanged: (value) async {
                  await service.saveConfig(
                    config.copyWith(showPremiumBadges: value),
                  );
                  if (mounted) setState(() {});
                },
                title: const Text('Show premium badges'),
              ),
              const SizedBox(height: 12),
              Text('Current plan: ${entitlement.plan.name}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await service.resetUsageCounters();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Reset usage counters'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await service.activateLocalProForDebug();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Activate local Pro'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await service.deactivateLocalProForDebug();
                      if (mounted) setState(() {});
                    },
                    child: const Text('Deactivate local Pro'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Local Pro is for testing only. Real payments must be verified server-side.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class TermExplanationScreen extends StatelessWidget {
  const TermExplanationScreen({super.key, required this.termId});

  final String termId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Term explanation')),
      body: FutureBuilder(
        future: AppScope.of(context).catalogRepository.getTerm(termId),
        builder: (context, snapshot) {
          final catalogTerm = snapshot.data;
          final fallbackTerm = ServiceTermsDictionary.byId(termId);
          if (catalogTerm == null && fallbackTerm == null) {
            return const Center(child: Text('Term explanation not found.'));
          }
          final title = catalogTerm?.term ?? fallbackTerm!.term;
          final shortDefinition = catalogTerm != null
              ? _localizedCatalogText(context, catalogTerm.shortDefinition)
              : fallbackTerm!.shortDefinition;
          final longExplanation = catalogTerm != null
              ? _localizedCatalogText(context, catalogTerm.longExplanation)
              : fallbackTerm!.longExplanation;
          final providerExamples =
              catalogTerm?.providerExamples ?? fallbackTerm!.providers;
          final relatedLinks =
              catalogTerm?.relatedLinks ?? fallbackTerm!.relatedLinks;
          final warnings = catalogTerm != null
              ? [
                  _localizedCatalogText(
                    context,
                    catalogTerm.warnings,
                    fallback:
                        'Verify on the official website before sending sensitive data.',
                  ),
                ]
              : fallbackTerm!.warnings;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                shortDefinition,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(longExplanation),
              if (providerExamples.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Provider examples',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...providerExamples.map((item) => Text('- $item')),
                      const SizedBox(height: 8),
                      const Text(
                        'Verify current price and terms on the provider website. UfficioFacile does not endorse one provider as the best option.',
                      ),
                    ],
                  ),
                ),
              ],
              if (relatedLinks.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Official or reference links',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: relatedLinks
                        .map((item) => Text('- $item'))
                        .toList(),
                  ),
                ),
              ],
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Warnings',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: warnings.map((item) => Text('- $item')).toList(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
