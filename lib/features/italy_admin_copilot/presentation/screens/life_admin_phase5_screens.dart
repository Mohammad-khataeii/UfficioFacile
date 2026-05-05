import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../domain/before_sending_checklist.dart';
import '../../domain/city_pack.dart';
import '../../domain/community_template.dart';
import '../../domain/deadline_watch.dart';
import '../../domain/household_contract.dart';
import '../../domain/household_member.dart';
import '../../domain/life_admin_client.dart';
import '../../domain/life_admin_contact.dart';
import '../../domain/life_admin_document.dart';
import '../../domain/life_admin_mode.dart';
import '../../domain/life_checklist_item.dart';
import '../../domain/proof_folder.dart';

class ScanMySituationScreen extends StatefulWidget {
  const ScanMySituationScreen({super.key});

  @override
  State<ScanMySituationScreen> createState() => _ScanMySituationScreenState();
}

class _ScanMySituationScreenState extends State<ScanMySituationScreen> {
  final TextEditingController _controller = TextEditingController();
  dynamic result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanner = AppScope.of(context).situationScannerService;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('scan_situation'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Example: My electricity bill is too high and I also see Canone RAI.',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'My landlord wants 300 euro to add my friend to the rent contract.',
                        'My electricity bill is too high and I also see Canone RAI.',
                        'I need to renew tessera sanitaria but I cannot go there.',
                      ]
                      .map(
                        (item) => ActionChip(
                          label: Text(item),
                          onPressed: () =>
                              setState(() => _controller.text = item),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  result = scanner.scan(
                    _controller.text,
                    languageCode: AppScope.of(
                      context,
                    ).appController.languageCode,
                  );
                });
              },
              child: const Text('Scan'),
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confidence ${(result.confidence * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(result.explanationLocalized),
                      if (result.safetyWarning != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          result.safetyWarning!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ...result.detectedCategories.map<Widget>(
                (item) => ListTile(
                  title: Text(item.localizedName),
                  subtitle: Text('Category: ${item.id}'),
                ),
              ),
              ...result.recommendedProcedures.map<Widget>(
                (procedureId) => Card(
                  child: ListTile(
                    title: Text(procedureId),
                    subtitle: const Text('Recommended workflow'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.procedures),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CityPacksScreen extends StatelessWidget {
  const CityPacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context).cityPackService.all();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('city_packs'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final pack = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(pack.cityName),
              subtitle: Text(pack.region),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CityPackDetailScreen(pack: pack),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CityPackDetailScreen extends StatelessWidget {
  const CityPackDetailScreen({super.key, required this.pack});

  final CityPack pack;

  @override
  Widget build(BuildContext context) {
    final lang = AppScope.of(context).appController.languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(pack.cityName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            pack.descriptionLocalized[lang] ??
                pack.descriptionLocalized['en'] ??
                '',
          ),
          const SizedBox(height: 16),
          ...pack.recommendedProcedures.map(
            (item) => ListTile(title: Text(item)),
          ),
          const SizedBox(height: 12),
          Text(pack.warnings.join('\n')),
        ],
      ),
    );
  }
}

class ModeScreen extends StatelessWidget {
  const ModeScreen({super.key, required this.mode});

  final LifeAdminMode mode;

  @override
  Widget build(BuildContext context) {
    final checklist = AppScope.of(context).checklistService.itemsForMode(mode);
    return Scaffold(
      appBar: AppBar(title: Text(mode.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Focused checklist and workflows for ${mode.name}.'),
          const SizedBox(height: 16),
          ...checklist.map(
            (item) => CheckboxListTile(
              value: item.status == LifeChecklistStatus.done,
              onChanged: null,
              title: Text(item.title),
              subtitle: Text(item.category),
            ),
          ),
        ],
      ),
    );
  }
}

class ItalyLifeChecklistScreen extends StatefulWidget {
  const ItalyLifeChecklistScreen({super.key});

  @override
  State<ItalyLifeChecklistScreen> createState() =>
      _ItalyLifeChecklistScreenState();
}

class _ItalyLifeChecklistScreenState extends State<ItalyLifeChecklistScreen> {
  late List<LifeChecklistItem> items;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mode = lifeAdminModeFromJson(
      AppScope.of(context).profileController.profile.activeMode,
    );
    items = AppScope.of(context).checklistService.itemsForMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).checklistService.progress(items);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('life_checklist'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: progress / 100),
          const SizedBox(height: 8),
          Text('Progress $progress%'),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Card(
              child: CheckboxListTile(
                value: item.status == LifeChecklistStatus.done,
                onChanged: (checked) {
                  setState(() {
                    items = items
                        .map(
                          (it) => it.id == item.id
                              ? it.copyWith(
                                  status: checked == true
                                      ? LifeChecklistStatus.done
                                      : LifeChecklistStatus.notStarted,
                                )
                              : it,
                        )
                        .toList();
                  });
                },
                title: Text(item.title),
                subtitle: Text(item.category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentHelperScreen extends StatefulWidget {
  const AttachmentHelperScreen({super.key});

  @override
  State<AttachmentHelperScreen> createState() => _AttachmentHelperScreenState();
}

class _AttachmentHelperScreenState extends State<AttachmentHelperScreen> {
  String procedureId = 'HIGH_BILL_COMPLAINT';
  dynamic plan;

  @override
  Widget build(BuildContext context) {
    final procedures = AppScope.of(context).procedureController.procedures;
    return Scaffold(
      appBar: AppBar(title: const Text('What should I attach?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: procedureId,
            items: procedures
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.title)),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => procedureId = value ?? procedureId),
            decoration: const InputDecoration(labelText: 'Procedure'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                plan = AppScope.of(context).attachmentRequirementEngine.build(
                  procedureId: procedureId,
                  availableDocuments: const [],
                );
              });
            },
            child: const Text('Build attachment plan'),
          ),
          if (plan != null) ...[
            const SizedBox(height: 16),
            Text('Readiness ${plan.readinessScore}%'),
            ...plan.requiredAttachments.map<Widget>(
              (item) => ListTile(title: Text(item.title)),
            ),
            ...plan.proofItems.map<Widget>((item) => Text('- $item')),
          ],
        ],
      ),
    );
  }
}

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  List<LifeAdminDocument> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).documentsRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('document_vault'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).documentsRepository.save(
            LifeAdminDocument(
              id: const Uuid().v4(),
              type: LifeAdminDocumentType.identityCardPassport,
              title: 'Identity card',
              description: 'Document record',
              hasDocument: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.type.name),
                  trailing: Text(item.hasDocument ? 'Ready' : 'Missing'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ContactsDirectoryScreen extends StatefulWidget {
  const ContactsDirectoryScreen({super.key});

  @override
  State<ContactsDirectoryScreen> createState() =>
      _ContactsDirectoryScreenState();
}

class _ContactsDirectoryScreenState extends State<ContactsDirectoryScreen> {
  List<LifeAdminContact> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).contactsRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('contacts_directory'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).contactsRepository.save(
            LifeAdminContact(
              id: const Uuid().v4(),
              type: LifeAdminContactType.landlord,
              name: 'Demo Landlord',
              email: 'demo.landlord@example.invalid',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.type.name),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class HouseholdScreen extends StatefulWidget {
  const HouseholdScreen({super.key});

  @override
  State<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends State<HouseholdScreen> {
  List<HouseholdMember> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).householdRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Household')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).householdRepository.save(
            HouseholdMember(
              id: const Uuid().v4(),
              displayName: 'Roommate Demo',
              relationship: HouseholdRelationship.roommate,
              isPrimary: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.displayName),
                  subtitle: Text(item.relationship.name),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ConsultantModePreviewScreen extends StatefulWidget {
  const ConsultantModePreviewScreen({super.key});

  @override
  State<ConsultantModePreviewScreen> createState() =>
      _ConsultantModePreviewScreenState();
}

class _ConsultantModePreviewScreenState
    extends State<ConsultantModePreviewScreen> {
  List<LifeAdminClient> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).clientsRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultant mode beta')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).clientsRepository.save(
            LifeAdminClient(
              id: const Uuid().v4(),
              displayName: 'Demo Client',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Consultant mode beta: local client management readiness.',
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Card(child: ListTile(title: Text(item.displayName))),
          ),
        ],
      ),
    );
  }
}

class DeadlineWatchScreen extends StatefulWidget {
  const DeadlineWatchScreen({super.key});

  @override
  State<DeadlineWatchScreen> createState() => _DeadlineWatchScreenState();
}

class _DeadlineWatchScreenState extends State<DeadlineWatchScreen> {
  List<UserDeadline> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).deadlinesRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Official deadline watch')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).deadlinesRepository.save(
            UserDeadline(
              id: const Uuid().v4(),
              title: 'Canone RAI reminder',
              date: DateTime.now().add(const Duration(days: 30)),
              category: 'Canone RAI',
              isDone: false,
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add_alert_outlined),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(item.date)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class TemplateLibraryScreen extends StatefulWidget {
  const TemplateLibraryScreen({super.key});

  @override
  State<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends State<TemplateLibraryScreen> {
  List<CommunityTemplate> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).templatesRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template library')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).templatesRepository.save(
            CommunityTemplate(
              id: const Uuid().v4(),
              title: 'Generic landlord follow-up',
              category: 'housing',
              language: 'it',
              officialTextItalian: 'Testo ufficiale locale',
              explanationLocalized: const {'en': 'Local demo template'},
              tags: const ['landlord', 'follow-up'],
              status: CommunityTemplateStatus.local,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.category),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ProofFolderScreen extends StatefulWidget {
  const ProofFolderScreen({super.key});

  @override
  State<ProofFolderScreen> createState() => _ProofFolderScreenState();
}

class _ProofFolderScreenState extends State<ProofFolderScreen> {
  List<ProofCase> cases = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    cases = await AppScope.of(context).proofFolderRepository.listCases();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('proof_folder'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).proofFolderRepository.saveCase(
            ProofCase(
              id: const Uuid().v4(),
              title: 'Landlord heating issue',
              category: 'housing',
              status: ProofCaseStatus.open,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: cases
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.status.name),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class CostSavingDashboardScreen extends StatefulWidget {
  const CostSavingDashboardScreen({super.key});

  @override
  State<CostSavingDashboardScreen> createState() =>
      _CostSavingDashboardScreenState();
}

class _CostSavingDashboardScreenState extends State<CostSavingDashboardScreen> {
  List<HouseholdContract> items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).contractsRepository.list();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = AppScope.of(context).costInsightService;
    final monthly = service.monthlyTotal(items);
    final annual = service.annualTotal(items);
    final insights = service.insights(items);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('cost_dashboard'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).contractsRepository.save(
            HouseholdContract(
              id: const Uuid().v4(),
              type: HouseholdContractType.internet,
              providerName: 'Demo Internet',
              contractName: 'Fiber Max',
              monthlyCost: 65,
              annualCost: 780,
              renewalDate: DateTime.now().add(const Duration(days: 40)),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add_chart),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Monthly total: ${monthly.toStringAsFixed(2)}'),
          Text('Annual total: ${annual.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          ...insights.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OfficialLinksDirectoryScreen extends StatefulWidget {
  const OfficialLinksDirectoryScreen({super.key});

  @override
  State<OfficialLinksDirectoryScreen> createState() =>
      _OfficialLinksDirectoryScreenState();
}

class _OfficialLinksDirectoryScreenState
    extends State<OfficialLinksDirectoryScreen> {
  @override
  Widget build(BuildContext context) {
    final builtIns = AppScope.of(
      context,
    ).officialLinksDirectoryService.builtIns();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('official_links'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: builtIns
            .map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.verificationStatus.name),
                  trailing: Text(item.category),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class LifeAdminCalendarScreen extends StatelessWidget {
  const LifeAdminCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: Future.wait([
        scope.documentsRepository.list(),
        scope.contractsRepository.list(),
        scope.deadlinesRepository.list(),
      ]),
      builder: (context, snapshot) {
        final requestReminders = scope.requestController.requests
            .expand((item) => item.reminders)
            .toList();
        final docs = snapshot.hasData
            ? snapshot.data![0] as List<LifeAdminDocument>
            : <LifeAdminDocument>[];
        final contracts = snapshot.hasData
            ? snapshot.data![1] as List<HouseholdContract>
            : <HouseholdContract>[];
        final deadlines = snapshot.hasData
            ? snapshot.data![2] as List<UserDeadline>
            : <UserDeadline>[];
        final items = scope.calendarService.build(
          reminders: requestReminders,
          documents: docs,
          contracts: contracts,
          deadlines: deadlines,
        );
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.t('calendar'))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(item.date),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

Future<bool> showBeforeSendingSheet(
  BuildContext context, {
  required String requestId,
}) async {
  bool personalDataChecked = false;
  bool recipientVerified = false;
  bool attachmentsReady = false;
  bool placeholdersRemoved = false;
  bool statementTruthful = false;
  bool officialRulesVerified = false;
  bool proofSaved = false;
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ask before sending'),
                    CheckboxListTile(
                      value: personalDataChecked,
                      onChanged: (value) =>
                          setState(() => personalDataChecked = value ?? false),
                      title: const Text('My personal data is correct'),
                    ),
                    CheckboxListTile(
                      value: recipientVerified,
                      onChanged: (value) =>
                          setState(() => recipientVerified = value ?? false),
                      title: const Text(
                        'Recipient verified from official source',
                      ),
                    ),
                    CheckboxListTile(
                      value: attachmentsReady,
                      onChanged: (value) =>
                          setState(() => attachmentsReady = value ?? false),
                      title: const Text('Attachments are ready'),
                    ),
                    CheckboxListTile(
                      value: placeholdersRemoved,
                      onChanged: (value) =>
                          setState(() => placeholdersRemoved = value ?? false),
                      title: const Text('Placeholders checked'),
                    ),
                    CheckboxListTile(
                      value: statementTruthful,
                      onChanged: (value) =>
                          setState(() => statementTruthful = value ?? false),
                      title: const Text('Statements are truthful'),
                    ),
                    CheckboxListTile(
                      value: officialRulesVerified,
                      onChanged: (value) => setState(
                        () => officialRulesVerified = value ?? false,
                      ),
                      title: const Text('Official rules verified'),
                    ),
                    CheckboxListTile(
                      value: proofSaved,
                      onChanged: (value) =>
                          setState(() => proofSaved = value ?? false),
                      title: const Text('Proof of sending saved'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final checklist = BeforeSendingChecklist(
                          requestId: requestId,
                          personalDataChecked: personalDataChecked,
                          recipientVerified: recipientVerified,
                          attachmentsReady: attachmentsReady,
                          placeholdersRemoved: placeholdersRemoved,
                          statementTruthful: statementTruthful,
                          officialRulesVerified: officialRulesVerified,
                          proofSaved: proofSaved,
                          skipFuturePrompt: false,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        await AppScope.of(
                          context,
                        ).beforeSendingRepository.save(checklist);
                        if (context.mounted) {
                          Navigator.pop(context, checklist.canMarkSent);
                        }
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ) ??
      false;
}
