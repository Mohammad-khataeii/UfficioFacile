import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/external_actions.dart';
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
import '../../domain/life_admin_document.dart';
import '../../domain/life_admin_mode.dart';
import '../../domain/life_checklist_item.dart';
import '../../domain/premium_config.dart';
import '../../domain/proof_folder.dart';
import '../../data/ufficio_product_services.dart';

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
  List<UfficioDocumentEntry> items = const [];
  String _search = '';
  String? _categoryFilter;
  UfficioDocumentStatus? _statusFilter;
  UfficioDocumentType? _typeFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).documentsService.listDocuments();
    if (mounted) setState(() {});
  }

  List<UfficioDocumentEntry> get _filteredItems {
    return items.where((item) {
      final matchesSearch =
          _search.isEmpty ||
          item.title.toLowerCase().contains(_search.toLowerCase()) ||
          (item.description ?? '').toLowerCase().contains(
            _search.toLowerCase(),
          );
      final matchesCategory =
          _categoryFilter == null || item.categoryId == _categoryFilter;
      final matchesStatus =
          _statusFilter == null || item.status == _statusFilter;
      final matchesType =
          _typeFilter == null || item.documentType == _typeFilter;
      return matchesSearch && matchesCategory && matchesStatus && matchesType;
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final summary = scope.documentsService.calculateDocumentSummary(items);
    final categoryOptions =
        items
            .map((item) => item.categoryId)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('document_vault'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final decision = await scope.entitlementService.canAddDocument();
          if (!context.mounted) return;
          if (!decision.allowed) {
            await _showFeatureBlockedDialog(
              context,
              title: 'Document vault is included in paid plans',
              message: decision.upgradeMessage,
            );
            return;
          }
          final created = await _showDocumentFormSheet(context);
          if (created == null) return;
          await scope.documentsService.createDocument(created);
          await scope.entitlementService.recordDocumentAdded();
          await _load();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Document saved')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryWrap(
            cards: [
              _SummaryCardData('Needed', '${summary.needed}'),
              _SummaryCardData('Collected', '${summary.collected}'),
              _SummaryCardData('Uploaded', '${summary.uploaded}'),
              _SummaryCardData('Sent', '${summary.sent}'),
              _SummaryCardData(
                'Rejected/expired',
                '${summary.rejectedOrExpired}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search documents',
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DropdownButton<String?>(
                value: _categoryFilter,
                hint: const Text('Category'),
                onChanged: (value) => setState(() => _categoryFilter = value),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...categoryOptions.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item,
                      child: Text(item),
                    ),
                  ),
                ],
              ),
              DropdownButton<UfficioDocumentStatus?>(
                value: _statusFilter,
                hint: const Text('Status'),
                onChanged: (value) => setState(() => _statusFilter = value),
                items: [
                  const DropdownMenuItem<UfficioDocumentStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...UfficioDocumentStatus.values.map(
                    (item) => DropdownMenuItem<UfficioDocumentStatus?>(
                      value: item,
                      child: Text(item.name),
                    ),
                  ),
                ],
              ),
              DropdownButton<UfficioDocumentType?>(
                value: _typeFilter,
                hint: const Text('Type'),
                onChanged: (value) => setState(() => _typeFilter = value),
                items: [
                  const DropdownMenuItem<UfficioDocumentType?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  ...UfficioDocumentType.values.map(
                    (item) => DropdownMenuItem<UfficioDocumentType?>(
                      value: item,
                      child: Text(item.name),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._filteredItems.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.documentType.name} • ${item.status.name}${item.categoryId != null ? ' • ${item.categoryId}' : ''}',
                    ),
                    if ((item.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(item.description!),
                    ],
                    if ((item.fileName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('File: ${item.fileName}'),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await scope.documentsService.markCollected(item);
                            await _load();
                          },
                          child: const Text('Mark collected'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await scope.documentsService.markSent(item);
                            await _load();
                          },
                          child: const Text('Mark sent'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final updated = await _showDocumentFormSheet(
                              context,
                              existing: item,
                            );
                            if (updated == null) return;
                            await scope.documentsService.updateDocument(
                              updated,
                            );
                            await _load();
                          },
                          child: const Text('Edit'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              title: 'Delete document?',
                            );
                            if (confirmed != true) return;
                            await scope.documentsService.deleteDocument(
                              item.id,
                            );
                            await _load();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uploads are shown only when a real storage integration is configured.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
  List<UfficioContactEntry> items = const [];
  String _search = '';
  String? _categoryFilter;
  UfficioContactType? _typeFilter;
  bool _hasPec = false;
  bool _hasEmail = false;
  bool _hasPhone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).contactsDirectoryService.listContacts();
    if (mounted) setState(() {});
  }

  List<UfficioContactEntry> get _filteredItems {
    return items.where((item) {
      final haystack =
          '${item.name} ${item.description ?? ''} ${item.city ?? ''} ${item.region ?? ''}'
              .toLowerCase();
      final matchesSearch =
          _search.isEmpty || haystack.contains(_search.toLowerCase());
      final matchesCategory =
          _categoryFilter == null || item.categoryId == _categoryFilter;
      final matchesType =
          _typeFilter == null || item.contactType == _typeFilter;
      final matchesPec = !_hasPec || (item.pec ?? '').isNotEmpty;
      final matchesEmail = !_hasEmail || (item.email ?? '').isNotEmpty;
      final matchesPhone = !_hasPhone || (item.phone ?? '').isNotEmpty;
      return matchesSearch &&
          matchesCategory &&
          matchesType &&
          matchesPec &&
          matchesEmail &&
          matchesPhone;
    }).toList()..sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final categories =
        items
            .map((item) => item.categoryId)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('contacts_directory'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final decision = await scope.entitlementService.canAddContact();
          if (!context.mounted) return;
          if (!decision.allowed) {
            await _showFeatureBlockedDialog(
              context,
              title: 'Contacts limit reached',
              message: decision.upgradeMessage,
            );
            return;
          }
          final created = await _showContactFormSheet(context);
          if (created == null) return;
          await scope.contactsDirectoryService.createCustomContact(created);
          await scope.entitlementService.recordContactAdded();
          await _load();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Contact saved')));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search contacts',
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DropdownButton<String?>(
                value: _categoryFilter,
                hint: const Text('Category'),
                onChanged: (value) => setState(() => _categoryFilter = value),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...categories.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item,
                      child: Text(item),
                    ),
                  ),
                ],
              ),
              DropdownButton<UfficioContactType?>(
                value: _typeFilter,
                hint: const Text('Contact type'),
                onChanged: (value) => setState(() => _typeFilter = value),
                items: [
                  const DropdownMenuItem<UfficioContactType?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  ...UfficioContactType.values.map(
                    (item) => DropdownMenuItem<UfficioContactType?>(
                      value: item,
                      child: Text(item.name),
                    ),
                  ),
                ],
              ),
              FilterChip(
                label: const Text('Has PEC'),
                selected: _hasPec,
                onSelected: (value) => setState(() => _hasPec = value),
              ),
              FilterChip(
                label: const Text('Has email'),
                selected: _hasEmail,
                onSelected: (value) => setState(() => _hasEmail = value),
              ),
              FilterChip(
                label: const Text('Has phone'),
                selected: _hasPhone,
                onSelected: (value) => setState(() => _hasPhone = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._filteredItems.map(
            (item) => _ContactDirectoryCard(
              contact: item,
              onEdit: item.isOfficial
                  ? null
                  : () async {
                      final updated = await _showContactFormSheet(
                        context,
                        existing: item,
                      );
                      if (updated == null) return;
                      await scope.contactsDirectoryService.updateCustomContact(
                        updated,
                      );
                      await _load();
                    },
              onDelete: item.isOfficial
                  ? null
                  : () async {
                      final confirmed = await _confirmDelete(
                        context,
                        title: 'Delete contact?',
                      );
                      if (confirmed != true) return;
                      await scope.contactsDirectoryService.deleteCustomContact(
                        item.id,
                      );
                      await _load();
                    },
            ),
          ),
        ],
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
          final scope = AppScope.of(context);
          final decision = await scope.entitlementService
              .canAddHouseholdMember();
          if (!context.mounted) return;
          if (!decision.allowed) {
            await _showFeatureBlockedDialog(
              context,
              title: 'Household members are included in paid plans',
              message: decision.upgradeMessage,
            );
            return;
          }
          await scope.householdRepository.save(
            HouseholdMember(
              id: const Uuid().v4(),
              displayName: 'New household member',
              relationship: HouseholdRelationship.roommate,
              isPrimary: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await scope.entitlementService.recordHouseholdMemberAdded();
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
      appBar: AppBar(title: const Text('Client workspace')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AppScope.of(context).clientsRepository.save(
            LifeAdminClient(
              id: const Uuid().v4(),
              displayName: 'Client',
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
          const Text('Manage private client workspaces from one place.'),
          const SizedBox(height: 8),
          const Text('Use this area for multi-client support work.'),
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
          final scope = AppScope.of(context);
          final decision = await scope.entitlementService.canCreateProofCase();
          if (!context.mounted) return;
          if (!decision.allowed) {
            await _showFeatureBlockedDialog(
              context,
              title: 'Proof folder is included in paid plans',
              message: decision.upgradeMessage,
            );
            return;
          }
          await scope.proofFolderRepository.saveCase(
            ProofCase(
              id: const Uuid().v4(),
              title: 'Housing issue',
              category: 'housing',
              status: ProofCaseStatus.open,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await scope.entitlementService.recordProofCaseCreated();
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
  List<UfficioCostItem> items = const [];
  String? _categoryFilter;
  UfficioCostItemType? _typeFilter;
  UfficioCostItemStatus? _statusFilter;
  DateTimeRange? _dateRange;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    items = await AppScope.of(context).costDashboardService.listCostItems();
    if (mounted) setState(() {});
  }

  List<UfficioCostItem> get _filteredItems {
    return items.where((item) {
      final matchesCategory =
          _categoryFilter == null || item.categoryId == _categoryFilter;
      final matchesType = _typeFilter == null || item.type == _typeFilter;
      final matchesStatus =
          _statusFilter == null || item.status == _statusFilter;
      if (_dateRange == null) {
        return matchesCategory && matchesType && matchesStatus;
      }
      final itemDate = item.dueDate ?? item.paidDate ?? item.createdAt;
      final matchesRange =
          !itemDate.isBefore(_dateRange!.start) &&
          !itemDate.isAfter(_dateRange!.end);
      return matchesCategory && matchesType && matchesStatus && matchesRange;
    }).toList()..sort((a, b) {
      final aDate = a.dueDate ?? a.updatedAt;
      final bDate = b.dueDate ?? b.updatedAt;
      return aDate.compareTo(bDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final summary = scope.costDashboardService.calculateCostSummary(items);
    final categories =
        items
            .map((item) => item.categoryId)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('cost_dashboard'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final decision = await scope.entitlementService.canUseFeature(
            FeatureKey.costDashboard,
          );
          if (!context.mounted) return;
          if (!decision.allowed) {
            await _showFeatureBlockedDialog(
              context,
              title: 'Cost dashboard is included in paid plans',
              message: decision.upgradeMessage,
            );
            return;
          }
          final created = await _showCostItemFormSheet(context);
          if (created == null) return;
          await scope.costDashboardService.createCostItem(created);
          await scope.entitlementService.recordCostItemAdded();
          await _load();
        },
        child: const Icon(Icons.add_chart),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryWrap(
            cards: [
              _SummaryCardData(
                'Estimated expenses',
                '€${summary.totalEstimatedExpenses.toStringAsFixed(2)}',
              ),
              _SummaryCardData(
                'Paid',
                '€${summary.totalPaid.toStringAsFixed(2)}',
              ),
              _SummaryCardData(
                'Expected refunds',
                '€${summary.totalExpectedRefunds.toStringAsFixed(2)}',
              ),
              _SummaryCardData(
                'Disputed',
                '€${summary.totalDisputed.toStringAsFixed(2)}',
              ),
              _SummaryCardData(
                'Upcoming due',
                '${summary.upcomingDuePayments}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DropdownButton<String?>(
                value: _categoryFilter,
                hint: const Text('Category'),
                onChanged: (value) => setState(() => _categoryFilter = value),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...categories.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item,
                      child: Text(item),
                    ),
                  ),
                ],
              ),
              DropdownButton<UfficioCostItemType?>(
                value: _typeFilter,
                hint: const Text('Type'),
                onChanged: (value) => setState(() => _typeFilter = value),
                items: [
                  const DropdownMenuItem<UfficioCostItemType?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  ...UfficioCostItemType.values.map(
                    (item) => DropdownMenuItem<UfficioCostItemType?>(
                      value: item,
                      child: Text(item.name),
                    ),
                  ),
                ],
              ),
              DropdownButton<UfficioCostItemStatus?>(
                value: _statusFilter,
                hint: const Text('Status'),
                onChanged: (value) => setState(() => _statusFilter = value),
                items: [
                  const DropdownMenuItem<UfficioCostItemStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...UfficioCostItemStatus.values.map(
                    (item) => DropdownMenuItem<UfficioCostItemStatus?>(
                      value: item,
                      child: Text(item.name),
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDateRange: _dateRange,
                  );
                  if (range == null) return;
                  setState(() => _dateRange = range);
                },
                icon: const Icon(Icons.date_range_outlined),
                label: Text(
                  _dateRange == null
                      ? 'Date range'
                      : '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
                ),
              ),
              if (_dateRange != null)
                TextButton(
                  onPressed: () => setState(() => _dateRange = null),
                  child: const Text('Clear dates'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ..._filteredItems.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${item.amount.toStringAsFixed(2)} • ${item.type.name} • ${item.status.name}',
                    ),
                    if ((item.categoryId ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.categoryId} • ${item.subcategoryId ?? 'General'}',
                      ),
                    ],
                    if (item.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Due: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                      ),
                    ],
                    if ((item.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(item.description!),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            final updated = await _showCostItemFormSheet(
                              context,
                              existing: item,
                            );
                            if (updated == null) return;
                            await scope.costDashboardService.updateCostItem(
                              updated,
                            );
                            await _load();
                          },
                          child: const Text('Edit'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await scope.costDashboardService.markCostItemPaid(
                              item,
                            );
                            await _load();
                          },
                          child: Text(
                            item.type == UfficioCostItemType.refund
                                ? 'Mark refunded'
                                : 'Mark paid',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              title: 'Delete cost item?',
                            );
                            if (confirmed != true) return;
                            await scope.costDashboardService.deleteCostItem(
                              item.id,
                            );
                            await _load();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
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
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('official_links'))),
      body: FutureBuilder(
        future: AppScope.of(context).catalogRepository.listOfficialLinks(),
        builder: (context, snapshot) {
          final builtIns = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: builtIns.map((item) {
              final targetUrl =
                  item.sourceUrl?.trim().isNotEmpty == true
                  ? item.sourceUrl!
                  : item.url;
              return Card(
                child: ListTile(
                  onTap: targetUrl.trim().isEmpty
                      ? null
                      : () => ExternalActionService.open(
                          context,
                          targetUrl,
                          ExternalValueKind.website,
                        ),
                  title: Text(item.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.verificationStatus.name),
                      if (targetUrl.trim().isNotEmpty)
                        ExternalValueText(
                          targetUrl,
                          kind: ExternalValueKind.website,
                        ),
                    ],
                  ),
                  trailing: Text(item.category),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryWrap extends StatelessWidget {
  const _SummaryWrap({required this.cards});

  final List<_SummaryCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (item) => SizedBox(
              width: 160,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ContactDirectoryCard extends StatelessWidget {
  const _ContactDirectoryCard({
    required this.contact,
    this.onEdit,
    this.onDelete,
  });

  final UfficioContactEntry contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(contact.isOfficial ? 'Official' : 'Custom')),
              ],
            ),
            if ((contact.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.description!),
            ],
            if ((contact.categoryId ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(contact.categoryId!),
            ],
            const SizedBox(height: 8),
            ...[
                  ('Phone', contact.phone),
                  ('Email', contact.email),
                  ('PEC', contact.pec),
                  ('Address', contact.address),
                  ('Website', contact.website),
                  ('Hours', contact.openingHours),
                ]
                .where((entry) => (entry.$2 ?? '').isNotEmpty)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ExternalValueRow(
                      label: entry.$1,
                      value: entry.$2!,
                      kind: switch (entry.$1) {
                        'Phone' => ExternalValueKind.phone,
                        'Email' => ExternalValueKind.email,
                        'PEC' => ExternalValueKind.pec,
                        'Address' => ExternalValueKind.address,
                        'Website' => ExternalValueKind.website,
                        _ => ExternalValueKind.auto,
                      },
                    ),
                  ),
                ),
            if (contact.useFor.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Use for'),
                children: contact.useFor
                    .map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(item),
                      ),
                    )
                    .toList(),
              ),
            if ((contact.warning ?? '').isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Warning'),
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(contact.warning!),
                  ),
                ],
              ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onEdit != null)
                    OutlinedButton(
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  if (onDelete != null)
                    OutlinedButton(
                      onPressed: onDelete,
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context, {required String title}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

Future<UfficioDocumentEntry?> _showDocumentFormSheet(
  BuildContext context, {
  UfficioDocumentEntry? existing,
}) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  final notesController = TextEditingController(text: existing?.notes ?? '');
  String? categoryId = existing?.categoryId;
  String? subcategoryId = existing?.subcategoryId;
  var documentType = existing?.documentType ?? UfficioDocumentType.other;
  var status = existing?.status ?? UfficioDocumentStatus.needed;

  return showModalBottomSheet<UfficioDocumentEntry>(
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
                  existing == null ? 'Add document' : 'Edit document',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UfficioDocumentType>(
                  initialValue: documentType,
                  items: UfficioDocumentType.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => documentType = value ?? UfficioDocumentType.other,
                  ),
                  decoration: const InputDecoration(labelText: 'Document type'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UfficioDocumentStatus>(
                  initialValue: status,
                  items: UfficioDocumentStatus.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => status = value ?? UfficioDocumentStatus.needed,
                  ),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: categoryId ?? '')
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: (categoryId ?? '').length),
                    ),
                  onChanged: (value) =>
                      categoryId = value.trim().isEmpty ? null : value.trim(),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: subcategoryId ?? '')
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: (subcategoryId ?? '').length),
                    ),
                  onChanged: (value) => subcategoryId = value.trim().isEmpty
                      ? null
                      : value.trim(),
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Attachment upload is available only when a real storage integration is configured.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title is required')),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      UfficioDocumentEntry(
                        id: existing?.id ?? const Uuid().v4(),
                        userId: existing?.userId,
                        categoryId: categoryId,
                        subcategoryId: subcategoryId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        documentType: documentType,
                        status: status,
                        source:
                            existing?.source ?? UfficioDocumentSource.manual,
                        fileUrl: existing?.fileUrl,
                        fileName: existing?.fileName,
                        relatedRequestId: existing?.relatedRequestId,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<UfficioContactEntry?> _showContactFormSheet(
  BuildContext context, {
  UfficioContactEntry? existing,
}) {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  final phoneController = TextEditingController(text: existing?.phone ?? '');
  final emailController = TextEditingController(text: existing?.email ?? '');
  final pecController = TextEditingController(text: existing?.pec ?? '');
  final websiteController = TextEditingController(
    text: existing?.website ?? '',
  );
  final addressController = TextEditingController(
    text: existing?.address ?? '',
  );
  final cityController = TextEditingController(
    text: existing?.city ?? 'Torino',
  );
  final regionController = TextEditingController(
    text: existing?.region ?? 'Piemonte',
  );
  final useForController = TextEditingController(
    text: existing?.useFor.join(', ') ?? '',
  );
  final warningController = TextEditingController(
    text: existing?.warning ?? '',
  );
  var contactType = existing?.contactType ?? UfficioContactType.personal;

  return showModalBottomSheet<UfficioContactEntry>(
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
                  existing == null ? 'Add contact' : 'Edit contact',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UfficioContactType>(
                  initialValue: contactType,
                  items: UfficioContactType.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => contactType = value ?? UfficioContactType.personal,
                  ),
                  decoration: const InputDecoration(labelText: 'Contact type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pecController,
                  decoration: const InputDecoration(labelText: 'PEC'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
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
                  controller: useForController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Use for (comma separated)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: warningController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Warning'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name is required')),
                      );
                      return;
                    }
                    final hasRecommendedContactInfo =
                        phoneController.text.trim().isNotEmpty ||
                        emailController.text.trim().isNotEmpty ||
                        pecController.text.trim().isNotEmpty ||
                        addressController.text.trim().isNotEmpty ||
                        websiteController.text.trim().isNotEmpty;
                    if (!hasRecommendedContactInfo) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Add at least one contact detail such as phone, email, PEC, address, or website.',
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      UfficioContactEntry(
                        id: existing?.id ?? const Uuid().v4(),
                        userId: existing?.userId,
                        source:
                            existing?.source ?? UfficioContactSource.userSaved,
                        categoryId: existing?.categoryId,
                        subcategoryId: existing?.subcategoryId,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        address: addressController.text.trim().isEmpty
                            ? null
                            : addressController.text.trim(),
                        phone: phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                        email: emailController.text.trim().isEmpty
                            ? null
                            : emailController.text.trim(),
                        pec: pecController.text.trim().isEmpty
                            ? null
                            : pecController.text.trim(),
                        website: websiteController.text.trim().isEmpty
                            ? null
                            : websiteController.text.trim(),
                        openingHours: existing?.openingHours,
                        useFor: useForController.text
                            .split(',')
                            .map((item) => item.trim())
                            .where((item) => item.isNotEmpty)
                            .toList(),
                        warning: warningController.text.trim().isEmpty
                            ? null
                            : warningController.text.trim(),
                        city: cityController.text.trim().isEmpty
                            ? null
                            : cityController.text.trim(),
                        region: regionController.text.trim().isEmpty
                            ? null
                            : regionController.text.trim(),
                        tags: existing?.tags ?? const [],
                        contactType: contactType,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<UfficioCostItem?> _showCostItemFormSheet(
  BuildContext context, {
  UfficioCostItem? existing,
}) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final amountController = TextEditingController(
    text: existing?.amount.toStringAsFixed(2) ?? '',
  );
  final descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  final notesController = TextEditingController(text: existing?.notes ?? '');
  final categoryController = TextEditingController(
    text: existing?.categoryId ?? '',
  );
  final subcategoryController = TextEditingController(
    text: existing?.subcategoryId ?? '',
  );
  var type = existing?.type ?? UfficioCostItemType.expense;
  var status = existing?.status ?? UfficioCostItemStatus.estimated;
  DateTime? dueDate = existing?.dueDate;
  DateTime? paidDate = existing?.paidDate;

  return showModalBottomSheet<UfficioCostItem>(
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
                  existing == null ? 'Add cost item' : 'Edit cost item',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UfficioCostItemType>(
                  initialValue: type,
                  items: UfficioCostItemType.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => type = value ?? UfficioCostItemType.expense,
                  ),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UfficioCostItemStatus>(
                  initialValue: status,
                  items: UfficioCostItemStatus.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => status = value ?? UfficioCostItemStatus.estimated,
                  ),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subcategoryController,
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDate: dueDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => dueDate = picked);
                        }
                      },
                      child: Text(
                        dueDate == null
                            ? 'Due date'
                            : 'Due: ${DateFormat('dd/MM/yyyy').format(dueDate!)}',
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDate: paidDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => paidDate = picked);
                        }
                      },
                      child: Text(
                        paidDate == null
                            ? 'Paid date'
                            : 'Paid: ${DateFormat('dd/MM/yyyy').format(paidDate!)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title is required')),
                      );
                      return;
                    }
                    if (amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Amount must be numeric')),
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      UfficioCostItem(
                        id: existing?.id ?? const Uuid().v4(),
                        userId: existing?.userId,
                        categoryId: categoryController.text.trim().isEmpty
                            ? null
                            : categoryController.text.trim(),
                        subcategoryId: subcategoryController.text.trim().isEmpty
                            ? null
                            : subcategoryController.text.trim(),
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        amount: amount,
                        type: type,
                        status: status,
                        dueDate: dueDate,
                        paidDate: paidDate,
                        relatedContactId: existing?.relatedContactId,
                        relatedDocumentId: existing?.relatedDocumentId,
                        source:
                            existing?.source ?? UfficioCostItemSource.manual,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showFeatureBlockedDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.plan);
          },
          child: const Text('Open plan'),
        ),
      ],
    ),
  );
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
