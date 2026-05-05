import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../data/demo_data_service.dart';
import '../../data/pack_generator.dart';
import '../../data/procedure_validator.dart';
import '../../data/red_flag_service.dart';
import '../../data/life_admin_phase5_services.dart';
import '../../domain/admin_copilot_profile.dart';
import '../../domain/admin_procedure.dart';
import '../../domain/admin_request.dart';
import '../../domain/bill_analysis.dart';
import '../../domain/canone_rai_models.dart';
import '../../domain/city_pack.dart';
import '../../domain/generated_pack.dart';
import '../../domain/household_contract.dart';
import '../../domain/life_admin_mode.dart';
import '../../domain/procedure_field.dart';
import '../../domain/procedure_recommendation.dart';
import '../../domain/reminder.dart';
import '../../domain/request_status.dart';
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

class LifeAdminHomeScreen extends StatelessWidget {
  const LifeAdminHomeScreen({super.key});

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
    final contracts = scope.contractsRepository.list();
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
            FutureBuilder<List<HouseholdContract>>(
              future: contracts,
              builder: (context, snapshot) {
                final contractItems = snapshot.data ?? const [];
                final monthly = scope.costInsightService.monthlyTotal(
                  contractItems,
                );
                return _SectionCard(
                  title: 'Household costs',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Monthly estimate: €${monthly.toStringAsFixed(2)}',
                    ),
                    subtitle: const Text(
                      'Review utilities, internet, rent, and renewals.',
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
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _CategoryTile(
                  'University',
                  Icons.school_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
                ),
                _CategoryTile(
                  'Complaints',
                  Icons.report_problem_outlined,
                  () => Navigator.pushNamed(context, AppRoutes.procedures),
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
                      title: Text(procedure.title),
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
    return Scaffold(
      appBar: AppBar(title: Text(procedure.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: procedure.subcategory,
              child: Text(procedure.longDescription),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'What this generates',
              child: const Text(
                'Formal Italian email, PEC-style version, short message, follow-up, stronger follow-up, checklist, warnings, and next steps.',
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Suggested attachments',
              child: Column(
                children: procedure.attachmentSuggestions
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.required
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        title: Text(item.name),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.procedureStart,
              arguments: ProcedureRouteArgs(procedure),
            ),
            child: const Text('Start guided form'),
          ),
        ),
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();
    values = {
      for (final field in widget.procedure.fields)
        if (field.defaultValue != null) field.id: field.defaultValue,
    };
    _loadDraftAndProfile();
  }

  Future<void> _loadDraftAndProfile() async {
    final scope = AppScope.of(context);
    final draft = await scope.requestController.getDraft(widget.procedure.id);
    final profile = scope.profileController.profile;
    setState(() {
      values.addAll({
        if ((profile.fullName ?? '').isNotEmpty) 'fullName': profile.fullName,
        if ((profile.codiceFiscale ?? '').isNotEmpty)
          'codiceFiscale': profile.codiceFiscale,
        if ((profile.email ?? '').isNotEmpty) 'email': profile.email,
        if ((profile.city ?? '').isNotEmpty) 'city': profile.city,
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
            ..._buildSectionedFields(context),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
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
              final pack = PackGenerator.generate(
                procedure: widget.procedure,
                inputData: values,
              );
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
                Text(localizedExplanation),
                const SizedBox(height: 12),
                Text(pack.fullText),
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
                      final request = await AppScope.of(context)
                          .requestController
                          .savePack(
                            procedureId: procedure.id,
                            procedureTitle: procedure.title,
                            category: procedure.category.label,
                            inputData: inputData,
                            pack: pack,
                          );
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

class UtilityHubScreen extends StatelessWidget {
  const UtilityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('utilities_bills'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CategoryTile(
              context.l10n.t('compare_offers'),
              Icons.compare_arrows,
              () => Navigator.pushNamed(context, AppRoutes.utilityCompare),
            ),
            _CategoryTile(
              context.l10n.t('understand_bill'),
              Icons.receipt_long_outlined,
              () => Navigator.pushNamed(context, AppRoutes.billAnalyzer),
            ),
            _CategoryTile(
              context.l10n.t('canone_rai'),
              Icons.tv_outlined,
              () => Navigator.pushNamed(context, AppRoutes.canoneRai),
            ),
          ],
        ),
      ),
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
              onPressed: () {
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
              onPressed: () {
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('canone_rai'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CategoryTile(
              'No-TV declaration checklist',
              Icons.tv_off_outlined,
              () => Navigator.pushNamed(context, AppRoutes.canoneRaiGuide),
            ),
            _CategoryTile(
              'Over-75 exemption checklist',
              Icons.elderly_outlined,
              () => Navigator.pushNamed(context, AppRoutes.canoneRaiGuide),
            ),
            _CategoryTile(
              'Wrong charge / refund',
              Icons.receipt_long_outlined,
              () => Navigator.pushNamed(context, AppRoutes.canoneRaiGuide),
            ),
          ],
        ),
      ),
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
  bool billInOwnName = true;
  bool hasTv = false;
  bool alreadyPaid = false;
  String requestType = 'no-tv';

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).utilityController;
    final result = controller.canoneDecisionResult;
    return Scaffold(
      appBar: AppBar(title: const Text('Canone RAI guided flow')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              value: billInOwnName,
              onChanged: (value) => setState(() => billInOwnName = value),
              title: const Text('Is the electricity bill in your name?'),
            ),
            SwitchListTile(
              value: hasTv,
              onChanged: (value) => setState(() => hasTv = value),
              title: const Text('Do you or your household have a TV?'),
            ),
            SwitchListTile(
              value: alreadyPaid,
              onChanged: (value) => setState(() => alreadyPaid = value),
              title: const Text('Has the charge already been paid?'),
            ),
            DropdownButtonFormField<String>(
              initialValue: requestType,
              items: const [
                DropdownMenuItem(
                  value: 'no-tv',
                  child: Text('No-TV declaration'),
                ),
                DropdownMenuItem(
                  value: 'over-75',
                  child: Text('Over-75 exemption'),
                ),
                DropdownMenuItem(
                  value: 'refund',
                  child: Text('Refund / wrong charge'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => requestType = value ?? 'no-tv'),
              decoration: const InputDecoration(labelText: 'Relevant path'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                controller.evaluateCanone(
                  CanoneRaiDecisionInput(
                    billInOwnName: billInOwnName,
                    hasTv: hasTv,
                    alreadyPaid: alreadyPaid,
                    requestType: requestType,
                    needsDeadlineReminder: true,
                  ),
                );
              },
              child: const Text('Evaluate path'),
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.orange.withValues(alpha: 0.1),
                child: const ListTile(
                  leading: Icon(Icons.warning_amber_outlined),
                  title: Text(
                    'Never submit a false no-TV declaration. False declarations can have legal consequences.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Decision result',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.possiblePath),
                    const SizedBox(height: 8),
                    ...result.requiredChecks.map((item) => Text('- $item')),
                    const SizedBox(height: 8),
                    ...result.warnings.map((item) => Text('- $item')),
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

class TelecomHubScreen extends StatelessWidget {
  const TelecomHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final telecomProcedures = AppScope.of(context)
        .procedureController
        .procedures
        .where((item) => item.category == ProcedureCategory.telecom)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('telecom'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: telecomProcedures.length,
        itemBuilder: (context, index) {
          final procedure = telecomProcedures[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(procedure.title),
              subtitle: Text(procedure.subcategory),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.procedureDetail,
                arguments: ProcedureRouteArgs(procedure),
              ),
            ),
          );
        },
      ),
    );
  }
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
