import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/external_actions.dart';
import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../data/connected_product_data.dart';
import '../../data/ufficio_city_registry.dart';
import '../../domain/ufficio_catalog.dart';
import '../screens/catalog_screens.dart';
import 'notification_and_monetization_screens.dart';

String _premiumLabel(UfficioPremiumVisibility visibility) {
  switch (visibility) {
    case UfficioPremiumVisibility.free:
      return 'Free';
    case UfficioPremiumVisibility.premiumPreview:
      return 'Premium preview';
    case UfficioPremiumVisibility.premiumOnly:
      return 'Premium';
    case UfficioPremiumVisibility.hidden:
      return 'Hidden';
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill({required this.visibility});

  final UfficioPremiumVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = switch (visibility) {
      UfficioPremiumVisibility.free => Colors.green.shade100,
      UfficioPremiumVisibility.premiumPreview => colorScheme.secondaryContainer,
      UfficioPremiumVisibility.premiumOnly => colorScheme.primaryContainer,
      UfficioPremiumVisibility.hidden => Colors.grey.shade300,
    };
    final foregroundColor = switch (visibility) {
      UfficioPremiumVisibility.free => Colors.green.shade900,
      UfficioPremiumVisibility.premiumPreview =>
        colorScheme.onSecondaryContainer,
      UfficioPremiumVisibility.premiumOnly => colorScheme.onPrimaryContainer,
      UfficioPremiumVisibility.hidden => Colors.grey.shade800,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _premiumLabel(visibility),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}

Future<bool> _canOpenPremiumContent(
  BuildContext context,
  UfficioPremiumVisibility visibility,
) async {
  if (visibility != UfficioPremiumVisibility.premiumOnly) {
    return true;
  }
  final scope = AppScope.of(context);
  final entitlement = await scope.entitlementService.getCurrentEntitlement();
  return entitlement.isProLike;
}

Future<void> _showPremiumLockedMessage(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('This is part of Premium'),
      content: const Text(
        'Check out Premium: you can open all categories and ask for 2 private help requests per month.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Maybe later'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.pushNamed(context, AppRoutes.plan);
          },
          child: const Text('Check out Premium'),
        ),
      ],
    ),
  );
}

Future<void> _openPremiumAwareRoute({
  required BuildContext context,
  required UfficioPremiumVisibility visibility,
  required String routeName,
  Object? arguments,
}) async {
  final allowed = await _canOpenPremiumContent(context, visibility);
  if (!context.mounted) return;
  if (!allowed) {
    await _showPremiumLockedMessage(context);
    return;
  }
  Navigator.pushNamed(context, routeName, arguments: arguments);
}

UfficioPremiumVisibility _effectivePremiumVisibility(
  List<UfficioPremiumVisibility> values,
) {
  if (values.contains(UfficioPremiumVisibility.premiumOnly)) {
    return UfficioPremiumVisibility.premiumOnly;
  }
  if (values.contains(UfficioPremiumVisibility.premiumPreview)) {
    return UfficioPremiumVisibility.premiumPreview;
  }
  if (values.contains(UfficioPremiumVisibility.hidden)) {
    return UfficioPremiumVisibility.hidden;
  }
  return UfficioPremiumVisibility.free;
}

class _PremiumLockedView extends StatelessWidget {
  const _PremiumLockedView({
    required this.title,
    required this.description,
    this.visibility = UfficioPremiumVisibility.premiumOnly,
  });

  final String title;
  final String description;
  final UfficioPremiumVisibility visibility;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PremiumPill(visibility: visibility),
                  ],
                ),
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(description),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is part of Premium',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check out Premium: you can open all categories and ask for 2 private help requests per month.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
                  child: const Text('Check out Premium'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectedBrowseProceduresScreen extends StatefulWidget {
  const ConnectedBrowseProceduresScreen({super.key});

  @override
  State<ConnectedBrowseProceduresScreen> createState() =>
      _ConnectedBrowseProceduresScreenState();
}

class _ConnectedBrowseProceduresScreenState
    extends State<ConnectedBrowseProceduresScreen> {
  final TextEditingController _queryController = TextEditingController();
  String? _categoryId;
  String? _subcategoryId;
  String? _channel;
  bool _includePremium = true;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final location = _currentLocation(scope);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('browse_procedures'))),
      body: FutureBuilder<List<ConnectedCategoryRecord>>(
        future: scope.connectedCatalogService.loadConnectedCatalog(
          languageCode: context.l10n.languageCode,
          location: location,
        ),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? const <ConnectedCategoryRecord>[];
          final query = _queryController.text.trim();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LocationSummaryCard(location: location),
              const SizedBox(height: 12),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText:
                      'Search a procedure, office, or document. Example: tessera sanitaria',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => setState(() {
                            _queryController.clear();
                          }),
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDropdownChip<String?>(
                    label: 'Category',
                    value: _categoryId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All categories'),
                      ),
                      ...categories.map(
                        (item) => DropdownMenuItem<String?>(
                          value: item.id,
                          child: Text(item.title),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      _categoryId = value;
                      _subcategoryId = null;
                    }),
                  ),
                  _buildDropdownChip<String?>(
                    label: 'Subcategory',
                    value: _subcategoryId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All subcategories'),
                      ),
                      ...categories
                          .where(
                            (item) =>
                                _categoryId == null || item.id == _categoryId,
                          )
                          .expand((item) => item.subcategories)
                          .map(
                            (item) => DropdownMenuItem<String?>(
                              value: item.id,
                              child: Text(item.title),
                            ),
                          ),
                    ],
                    onChanged: (value) =>
                        setState(() => _subcategoryId = value),
                  ),
                  _buildDropdownChip<String?>(
                    label: 'Channel',
                    value: _channel,
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All channels'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'online',
                        child: Text('Online'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'in person',
                        child: Text('In person'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'pec',
                        child: Text('PEC'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'email',
                        child: Text('Email'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'raccomandata',
                        child: Text('Raccomandata'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _channel = value),
                  ),
                  FilterChip(
                    selected: _includePremium,
                    label: const Text('Show premium'),
                    onSelected: (value) =>
                        setState(() => _includePremium = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (query.isEmpty)
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder_open_outlined),
                        title: Text(category.title),
                        subtitle: Text(category.description),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _PremiumPill(
                              visibility: category.premiumVisibility,
                            ),
                            const SizedBox(height: 6),
                            Text('${category.subcategories.length} subcats'),
                          ],
                        ),
                        onTap: () => _openPremiumAwareRoute(
                          context: context,
                          visibility: category.premiumVisibility,
                          routeName: AppRoutes.category,
                          arguments: CatalogCategoryRouteArgs(category.id),
                        ),
                      ),
                    ),
                  ),
                )
              else
                FutureBuilder<List<CatalogSearchResult>>(
                  future: scope.connectedCatalogService.searchCatalog(
                    query: query,
                    languageCode: context.l10n.languageCode,
                    location: location,
                    categoryId: _categoryId,
                    subcategoryId: _subcategoryId,
                    channel: _channel,
                    includePremium: _includePremium,
                  ),
                  builder: (context, searchSnapshot) {
                    final results =
                        searchSnapshot.data ?? const <CatalogSearchResult>[];
                    if (results.isEmpty) {
                      return const _EmptySearchCard();
                    }
                    return Column(
                      children: results
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                child: ListTile(
                                  title: Text(item.procedureTitle),
                                  subtitle: Text(
                                    '${item.categoryTitle} / ${item.subcategoryTitle}\n${item.reason}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _PremiumPill(
                                        visibility: item.premiumVisibility,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(item.locationLabel),
                                    ],
                                  ),
                                  onTap: () => _openPremiumAwareRoute(
                                    context: context,
                                    visibility: item.premiumVisibility,
                                    routeName: AppRoutes.catalogProcedure,
                                    arguments: CatalogProcedureRouteArgs(
                                      categoryId: item.categoryId,
                                      subcategoryId: item.subcategoryId,
                                      procedureId: item.procedureId,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class ConnectedCategoryScreen extends StatelessWidget {
  const ConnectedCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final location = _currentLocation(scope);
    return Scaffold(
      appBar: AppBar(title: const Text('Browse procedures')),
      body: FutureBuilder<List<ConnectedCategoryRecord>>(
        future: scope.connectedCatalogService.loadConnectedCatalog(
          languageCode: context.l10n.languageCode,
          location: location,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load this category.'));
          }
          final category = _findCategory(
            snapshot.data ?? const <ConnectedCategoryRecord>[],
            categoryId,
          );
          if (category == null) {
            return const Center(child: Text('Category not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LocationSummaryCard(location: location),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: Text(category.title),
                  subtitle: Text(category.description),
                  trailing: _PremiumPill(
                    visibility: category.premiumVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...category.subcategories.map((subcategory) {
                final effectiveVisibility = _effectivePremiumVisibility([
                  category.premiumVisibility,
                  subcategory.premiumVisibility,
                ]);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text(subcategory.title),
                      subtitle: Text(subcategory.description),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _PremiumPill(visibility: effectiveVisibility),
                          const SizedBox(height: 6),
                          Text('${subcategory.procedures.length} procedures'),
                        ],
                      ),
                      onTap: () => _openPremiumAwareRoute(
                        context: context,
                        visibility: effectiveVisibility,
                        routeName: AppRoutes.subcategory,
                        arguments: CatalogSubcategoryRouteArgs(
                          categoryId: category.id,
                          subcategoryId: subcategory.id,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class ConnectedSubcategoryScreen extends StatelessWidget {
  const ConnectedSubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
  });

  final String categoryId;
  final String subcategoryId;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final location = _currentLocation(scope);
    return Scaffold(
      appBar: AppBar(title: const Text('Procedures')),
      body: FutureBuilder<List<ConnectedCategoryRecord>>(
        future: scope.connectedCatalogService.loadConnectedCatalog(
          languageCode: context.l10n.languageCode,
          location: location,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load this subcategory.'),
            );
          }
          final category = _findCategory(
            snapshot.data ?? const <ConnectedCategoryRecord>[],
            categoryId,
          );
          final subcategory = category == null
              ? null
              : _findSubcategory(category, subcategoryId);
          if (category == null || subcategory == null) {
            return const Center(child: Text('Subcategory not found.'));
          }
          final effectiveVisibility = _effectivePremiumVisibility([
            category.premiumVisibility,
            subcategory.premiumVisibility,
          ]);
          if (effectiveVisibility == UfficioPremiumVisibility.premiumOnly) {
            return FutureBuilder<bool>(
              future: _canOpenPremiumContent(context, effectiveVisibility),
              builder: (context, accessSnapshot) {
                if (accessSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (accessSnapshot.data != true) {
                  return _PremiumLockedView(
                    title: subcategory.title,
                    description:
                        '${category.title}\n${subcategory.description}',
                    visibility: effectiveVisibility,
                  );
                }
                return _ConnectedSubcategoryBody(
                  location: location,
                  category: category,
                  subcategory: subcategory,
                );
              },
            );
          }
          return _ConnectedSubcategoryBody(
            location: location,
            category: category,
            subcategory: subcategory,
          );
        },
      ),
    );
  }
}

class _ConnectedSubcategoryBody extends StatelessWidget {
  const _ConnectedSubcategoryBody({
    required this.location,
    required this.category,
    required this.subcategory,
  });

  final CatalogLocationSelection location;
  final ConnectedCategoryRecord category;
  final ConnectedSubcategoryRecord subcategory;

  @override
  Widget build(BuildContext context) {
    final effectiveVisibility = _effectivePremiumVisibility([
      category.premiumVisibility,
      subcategory.premiumVisibility,
    ]);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LocationSummaryCard(location: location),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text(subcategory.title),
            subtitle: Text('${category.title}\n${subcategory.description}'),
            isThreeLine: true,
            trailing: _PremiumPill(visibility: effectiveVisibility),
          ),
        ),
        const SizedBox(height: 12),
        ...subcategory.procedures.map((procedure) {
          final effectiveVisibility = _effectivePremiumVisibility([
            category.premiumVisibility,
            subcategory.premiumVisibility,
            procedure.premiumVisibility,
          ]);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openPremiumAwareRoute(
                  context: context,
                  visibility: effectiveVisibility,
                  routeName: AppRoutes.catalogProcedure,
                  arguments: CatalogProcedureRouteArgs(
                    categoryId: category.id,
                    subcategoryId: subcategory.id,
                    procedureId: procedure.slug,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              procedure.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _PremiumPill(visibility: effectiveVisibility),
                      const SizedBox(height: 10),
                      Text(
                        procedure.summary,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class ConnectedProcedureDetailScreen extends StatelessWidget {
  const ConnectedProcedureDetailScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.procedureId,
  });

  final String categoryId;
  final String subcategoryId;
  final String procedureId;

  Future<void> _saveProcedure(
    BuildContext context,
    ConnectedProcedureRecord procedure,
  ) async {
    final repo = AppScope.of(context).connectedUserDataRepository;
    await repo.saveProcedure(
      SavedProcedureRecord(
        id: const Uuid().v4(),
        categorySlug: procedure.categoryId,
        subcategorySlug: procedure.subcategoryId,
        procedureSlug: procedure.slug,
        createdAt: DateTime.now(),
      ),
    );
    for (final item in _buildChecklistItemsForProcedure(procedure)) {
      await repo.saveChecklistItem(item);
    }
    for (final item in _buildDeadlinesForProcedure(procedure)) {
      await repo.saveDeadline(item);
    }
    for (final item in _buildCostItemsForProcedure(procedure)) {
      await repo.saveCostItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final location = _currentLocation(scope);
    return Scaffold(
      appBar: AppBar(title: const Text('Procedure detail')),
      body: FutureBuilder<List<ConnectedCategoryRecord>>(
        future: scope.connectedCatalogService.loadConnectedCatalog(
          languageCode: context.l10n.languageCode,
          location: location,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load this procedure.'));
          }
          final category = _findCategory(
            snapshot.data ?? const <ConnectedCategoryRecord>[],
            categoryId,
          );
          final subcategory = category == null
              ? null
              : _findSubcategory(category, subcategoryId);
          final procedure = subcategory == null
              ? null
              : _findProcedure(subcategory, procedureId);
          if (category == null || subcategory == null || procedure == null) {
            return const Center(child: Text('Procedure not found.'));
          }
          final effectiveVisibility = _effectivePremiumVisibility([
            category.premiumVisibility,
            subcategory.premiumVisibility,
            procedure.premiumVisibility,
          ]);
          if (effectiveVisibility == UfficioPremiumVisibility.premiumOnly) {
            return FutureBuilder<bool>(
              future: _canOpenPremiumContent(context, effectiveVisibility),
              builder: (context, accessSnapshot) {
                if (accessSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (accessSnapshot.data != true) {
                  return _PremiumLockedView(
                    title: procedure.title,
                    description: procedure.summary,
                    visibility: effectiveVisibility,
                  );
                }
                return _ConnectedProcedureDetailBody(
                  location: location,
                  category: category,
                  subcategory: subcategory,
                  procedure: procedure,
                  onSaveProcedure: () => _saveProcedure(context, procedure),
                );
              },
            );
          }
          return _ConnectedProcedureDetailBody(
            location: location,
            category: category,
            subcategory: subcategory,
            procedure: procedure,
            onSaveProcedure: () => _saveProcedure(context, procedure),
          );
        },
      ),
    );
  }
}

class _ConnectedProcedureDetailBody extends StatelessWidget {
  const _ConnectedProcedureDetailBody({
    required this.location,
    required this.category,
    required this.subcategory,
    required this.procedure,
    required this.onSaveProcedure,
  });

  final CatalogLocationSelection location;
  final ConnectedCategoryRecord category;
  final ConnectedSubcategoryRecord subcategory;
  final ConnectedProcedureRecord procedure;
  final Future<void> Function() onSaveProcedure;

  @override
  Widget build(BuildContext context) {
    final effectiveVisibility = _effectivePremiumVisibility([
      category.premiumVisibility,
      subcategory.premiumVisibility,
      procedure.premiumVisibility,
    ]);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LocationSummaryCard(location: location),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  procedure.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                _PremiumPill(visibility: effectiveVisibility),
                const SizedBox(height: 8),
                Text('${category.title} / ${subcategory.title}'),
                const SizedBox(height: 12),
                Text(procedure.summary),
                if (procedure.localVariationNote != null) ...[
                  const SizedBox(height: 12),
                  Text(procedure.localVariationNote!),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await onSaveProcedure();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Procedure saved with checklist, deadlines, and costs.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save this checklist'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.costs),
                      child: const Text('Open cost dashboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ProcedureSectionCard(
          title: 'What it is',
          items: [procedure.description],
          initiallyExpanded: true,
        ),
        _ProcedureSectionCard(
          title: 'When you need it',
          items: procedure.whenYouNeedIt.isEmpty
              ? (procedure.summary.trim().isEmpty
                    ? const [
                        'Check the official office link for the exact cases.',
                      ]
                    : [procedure.summary])
              : procedure.whenYouNeedIt,
        ),
        _ProcedureSectionCard(
          title: 'Before you send',
          items: procedure.preparationChecklist,
        ),
        _ProcedureSectionCard(title: 'Steps', items: procedure.steps),
        _ProcedureSectionCard(
          title: 'Documents',
          items: procedure.documentsRequired,
        ),
        _ProcedureSectionCard(title: 'Cost', items: procedure.costs),
        _ProcedureSectionCard(title: 'Timeline', items: procedure.timelines),
        _ProcedureSectionCard(title: 'Warnings', items: procedure.warnings),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official channels',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...procedure.channels.map((item) => Text('• $item')),
                if (procedure.officialLinks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...procedure.officialLinks.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ExternalValueRow(
                        label: ufficioLocalizedValue(
                          item.label,
                          context.l10n.languageCode,
                          fallback: item.type,
                        ),
                        value: item.url,
                        kind: ExternalValueKind.website,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official contacts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (procedure.officialContacts.isEmpty)
                  const Text(
                    'No local contact saved yet. Check the official office link before sending documents.',
                  )
                else
                  ...procedure.officialContacts.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExternalValueRow(
                        label: ufficioLocalizedValue(
                          item.label,
                          context.l10n.languageCode,
                          fallback: item.type,
                        ),
                        value: item.value,
                        kind: _contactKind(item),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConnectedProblemIntakeScreen extends StatefulWidget {
  const ConnectedProblemIntakeScreen({super.key});

  @override
  State<ConnectedProblemIntakeScreen> createState() =>
      _ConnectedProblemIntakeScreenState();
}

class _ConnectedProblemIntakeScreenState
    extends State<ConnectedProblemIntakeScreen> {
  final TextEditingController _controller = TextEditingController();
  ProblemIntakeResult? _result;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final scope = AppScope.of(context);
    final result = await scope.connectedCatalogService.startFromProblem(
      query: _controller.text,
      languageCode: context.l10n.languageCode,
      location: _currentLocation(scope),
      statusTags: scope.profileController.profile.activeMode == null
          ? const <String>[]
          : <String>[scope.profileController.profile.activeMode!],
    );
    if (!mounted) return;
    setState(() => _result = result);
  }

  Future<void> _saveSnapshotAndPlan() async {
    final result = _result;
    if (result == null) return;
    setState(() => _saving = true);
    final scope = AppScope.of(context);
    final languageCode = context.l10n.languageCode;
    await scope.connectedUserDataRepository.saveScan(result.snapshot);
    final procedures = await scope.connectedCatalogService.proceduresBySlugs(
      languageCode: languageCode,
      procedureSlugs: result.results
          .take(3)
          .map((item) => item.procedureId)
          .toList(),
      location: _currentLocation(scope),
    );
    for (final procedure in procedures) {
      await scope.connectedUserDataRepository.saveProcedure(
        SavedProcedureRecord(
          id: const Uuid().v4(),
          categorySlug: procedure.categoryId,
          subcategorySlug: procedure.subcategoryId,
          procedureSlug: procedure.slug,
          createdAt: DateTime.now(),
        ),
      );
      for (final checklist in _buildChecklistItemsForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveChecklistItem(checklist);
      }
      for (final deadline in _buildDeadlinesForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveDeadline(deadline);
      }
      for (final cost in _buildCostItemsForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveCostItem(cost);
      }
    }
    await scope.notificationService.syncScheduledNotifications();
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Situation saved. Checklist, deadlines, and costs were updated.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examples = const [
      'I need a doctor',
      'My electricity bill is too high',
      'I want to cancel internet',
      'I need NASpI',
      'I need ISEE',
      'My landlord is not returning the deposit',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('start_problem'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'What do you need to do?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use simple words. Example: “I need to change doctor” or “my internet provider charged me wrong”.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Describe the problem'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    onPressed: () {
                      _controller.text = item;
                      _analyze();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _analyze,
            child: const Text('Find the best procedure'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            if (_result!.clarifyingQuestions.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before you send anything',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._result!.clarifyingQuestions.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ..._result!.results
                .take(6)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        title: Text(item.procedureTitle),
                        subtitle: Text(
                          '${item.categoryTitle} / ${item.subcategoryTitle}\n${item.reason}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _PremiumPill(visibility: item.premiumVisibility),
                            const SizedBox(height: 6),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => _openPremiumAwareRoute(
                          context: context,
                          visibility: item.premiumVisibility,
                          routeName: AppRoutes.catalogProcedure,
                          arguments: CatalogProcedureRouteArgs(
                            categoryId: item.categoryId,
                            subcategoryId: item.subcategoryId,
                            procedureId: item.procedureId,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _saveSnapshotAndPlan,
                    child: Text(_saving ? 'Saving...' : 'Save this checklist'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ConnectedSituationScanScreen extends StatefulWidget {
  const ConnectedSituationScanScreen({super.key});

  @override
  State<ConnectedSituationScanScreen> createState() =>
      _ConnectedSituationScanScreenState();
}

class _ConnectedSituationScanScreenState
    extends State<ConnectedSituationScanScreen> {
  final Set<String> _statusTags = <String>{};
  final Set<String> _adminNeeds = <String>{};
  bool _alreadyLate = false;
  bool _receivedRejection = false;
  bool _paymentRisk = false;
  bool _serviceInterruptionRisk = false;
  SituationScanRecord? _scan;

  Future<void> _runScan() async {
    final scope = AppScope.of(context);
    final scan = await scope.connectedCatalogService.scanSituation(
      languageCode: context.l10n.languageCode,
      location: _currentLocation(scope),
      statusTags: _statusTags.toList(),
      adminNeeds: _adminNeeds.toList(),
      urgency: {
        'alreadyLate': _alreadyLate,
        'receivedRejection': _receivedRejection,
        'paymentRisk': _paymentRisk,
        'serviceInterruptionRisk': _serviceInterruptionRisk,
      },
    );
    await scope.connectedUserDataRepository.saveScan(scan);
    if (!mounted) return;
    setState(() => _scan = scan);
  }

  Future<void> _generateFromScan() async {
    final scan = _scan;
    if (scan == null) return;
    final scope = AppScope.of(context);
    final procedures = await scope.connectedCatalogService.proceduresBySlugs(
      languageCode: context.l10n.languageCode,
      procedureSlugs: scan.matchedProcedureIds.take(4).toList(),
      location: _currentLocation(scope),
    );
    for (final procedure in procedures) {
      for (final checklist in _buildChecklistItemsForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveChecklistItem(checklist);
      }
      for (final deadline in _buildDeadlinesForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveDeadline(deadline);
      }
      for (final cost in _buildCostItemsForProcedure(procedure)) {
        await scope.connectedUserDataRepository.saveCostItem(cost);
      }
    }
    await scope.notificationService.syncScheduledNotifications();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Checklist, deadlines, and costs were created from this scan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('scan_situation'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Choose your situation'),
          _ChoiceWrap(
            items: const [
              'student',
              'worker',
              'unemployed',
              'family member',
              'new resident',
              'non-EU citizen',
              'EU citizen',
              'Italian citizen',
              'renter',
              'homeowner',
            ],
            selected: _statusTags,
            onToggle: (value) => setState(() => _toggle(_statusTags, value)),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Admin needs'),
          _ChoiceWrap(
            items: const [
              'health/ASL',
              'housing/rent',
              'utilities/bills',
              'telecom',
              'university/student',
              'work/INPS',
              'public office/comune',
              'documents',
              'canone RAI',
              'general bureaucracy',
            ],
            selected: _adminNeeds,
            onToggle: (value) => setState(() => _toggle(_adminNeeds, value)),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Urgency'),
          SwitchListTile(
            value: _alreadyLate,
            title: const Text('Already late'),
            onChanged: (value) => setState(() => _alreadyLate = value),
          ),
          SwitchListTile(
            value: _receivedRejection,
            title: const Text('Received notice or rejection'),
            onChanged: (value) => setState(() => _receivedRejection = value),
          ),
          SwitchListTile(
            value: _paymentRisk,
            title: const Text('Payment risk'),
            onChanged: (value) => setState(() => _paymentRisk = value),
          ),
          SwitchListTile(
            value: _serviceInterruptionRisk,
            title: const Text('Service interruption risk'),
            onChanged: (value) =>
                setState(() => _serviceInterruptionRisk = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _runScan,
            child: const Text('Scan my situation'),
          ),
          if (_scan != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended procedures',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._scan!.matchedProcedureIds.map(
                      (item) => Text('• $item'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Required documents',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._scan!.recommendedDocuments
                        .take(8)
                        .map((item) => Text('• $item')),
                    const SizedBox(height: 12),
                    Text(
                      'Possible deadlines',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._scan!.recommendedDeadlines
                        .take(6)
                        .map((item) => Text('• $item')),
                    const SizedBox(height: 12),
                    Text(
                      'Estimated costs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._scan!.recommendedCostItems
                        .take(6)
                        .map((item) => Text('• $item')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _generateFromScan,
              child: const Text('Generate checklist'),
            ),
          ],
        ],
      ),
    );
  }

  void _toggle(Set<String> values, String value) {
    if (values.contains(value)) {
      values.remove(value);
    } else {
      values.add(value);
    }
  }
}

class ConnectedChecklistScreen extends StatefulWidget {
  const ConnectedChecklistScreen({super.key});

  @override
  State<ConnectedChecklistScreen> createState() =>
      _ConnectedChecklistScreenState();
}

class _ConnectedChecklistScreenState extends State<ConnectedChecklistScreen> {
  Future<List<ChecklistItemRecord>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(
      context,
    ).connectedUserDataRepository.listChecklistItems();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AppScope.of(
        context,
      ).connectedUserDataRepository.listChecklistItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('life_checklist'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repository = AppScope.of(context).connectedUserDataRepository;
          final created = await _showManualChecklistSheet(context);
          if (created == null) return;
          await repository.saveChecklistItem(created);
          await _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ChecklistItemRecord>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <ChecklistItemRecord>[];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No checklist items yet. Save a procedure or run a situation scan first.',
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        [
                          item.description,
                          if (item.dueDate != null)
                            'Due ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                          if ((item.documentRequired ?? '').isNotEmpty)
                            'Document: ${item.documentRequired}',
                        ].join('\n'),
                      ),
                      isThreeLine: true,
                      leading: Checkbox(
                        value: item.status == ConnectedChecklistStatus.done,
                        onChanged: (checked) async {
                          final scope = AppScope.of(context);
                          await scope.connectedUserDataRepository
                              .saveChecklistItem(
                                item.copyWith(
                                  status: checked == true
                                      ? ConnectedChecklistStatus.done
                                      : ConnectedChecklistStatus.todo,
                                ),
                              );
                          await scope.notificationService
                              .syncScheduledNotifications();
                          await _reload();
                        },
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          final scope = AppScope.of(context);
                          if (value == 'delete') {
                            await scope.connectedUserDataRepository
                                .deleteChecklistItem(item.id);
                          } else {
                            await scope.connectedUserDataRepository
                                .saveChecklistItem(
                                  item.copyWith(
                                    status: ConnectedChecklistStatus.values
                                        .firstWhere(
                                          (status) => status.name == value,
                                        ),
                                  ),
                                );
                          }
                          await scope.notificationService
                              .syncScheduledNotifications();
                          await _reload();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'todo', child: Text('To do')),
                          PopupMenuItem(
                            value: 'inProgress',
                            child: Text('In progress'),
                          ),
                          PopupMenuItem(value: 'done', child: Text('Done')),
                          PopupMenuItem(
                            value: 'skipped',
                            child: Text('Skipped'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class ConnectedDeadlinesScreen extends StatefulWidget {
  const ConnectedDeadlinesScreen({super.key});

  @override
  State<ConnectedDeadlinesScreen> createState() =>
      _ConnectedDeadlinesScreenState();
}

class _ConnectedDeadlinesScreenState extends State<ConnectedDeadlinesScreen> {
  Future<List<DeadlineRecord>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(
      context,
    ).connectedUserDataRepository.listDeadlines();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AppScope.of(
        context,
      ).connectedUserDataRepository.listDeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('deadlines_short'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final scope = AppScope.of(context);
          final repository = scope.connectedUserDataRepository;
          final created = await _showDeadlineSheet(context);
          if (created == null) return;
          await repository.saveDeadline(created);
          await scope.notificationService.syncScheduledNotifications();
          await _reload();
        },
        child: const Icon(Icons.add_alert_outlined),
      ),
      body: FutureBuilder<List<DeadlineRecord>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <DeadlineRecord>[];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No deadlines yet. Add one manually or generate them from a scan or saved procedure.',
                ),
              ),
            );
          }
          final sorted = [...items]
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: sorted
                .map(
                  (item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_note_outlined),
                      title: Text(item.title),
                      subtitle: Text(
                        '${DateFormat('dd/MM/yyyy').format(item.dueDate)} • ${_deadlineStatusLabel(item)}\n${item.description}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          final scope = AppScope.of(context);
                          if (value == 'delete') {
                            await scope.connectedUserDataRepository
                                .deleteDeadline(item.id);
                          } else {
                            await scope.connectedUserDataRepository
                                .saveDeadline(
                                  DeadlineRecord(
                                    id: item.id,
                                    userId: item.userId,
                                    title: item.title,
                                    description: item.description,
                                    dueDate: item.dueDate,
                                    sourceType: item.sourceType,
                                    sourceProcedureId: item.sourceProcedureId,
                                    categorySlug: item.categorySlug,
                                    procedureSlug: item.procedureSlug,
                                    status: ConnectedDeadlineStatus.values
                                        .firstWhere(
                                          (status) => status.name == value,
                                        ),
                                    reminderEnabled: item.reminderEnabled,
                                    reminderOffsetDays: item.reminderOffsetDays,
                                    officialLink: item.officialLink,
                                    createdAt: item.createdAt,
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          }
                          await scope.notificationService
                              .syncScheduledNotifications();
                          await _reload();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'done', child: Text('Done')),
                          PopupMenuItem(
                            value: 'canceled',
                            child: Text('Canceled'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  String _deadlineStatusLabel(DeadlineRecord item) {
    if (item.status == ConnectedDeadlineStatus.done) return 'Done';
    if (item.status == ConnectedDeadlineStatus.canceled) return 'Canceled';
    final today = DateTime.now();
    if (item.dueDate.isBefore(today)) return 'Overdue';
    if (item.dueDate.difference(today).inDays <= 7) return 'Due soon';
    return 'Upcoming';
  }
}

class ConnectedProfileFolderScreen extends StatefulWidget {
  const ConnectedProfileFolderScreen({super.key});

  @override
  State<ConnectedProfileFolderScreen> createState() =>
      _ConnectedProfileFolderScreenState();
}

class _ConnectedProfileFolderScreenState
    extends State<ConnectedProfileFolderScreen> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final profile = scope.profileController.profile;
    final location = _currentLocation(scope);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('profile'))),
      body: FutureBuilder(
        future: Future.wait([
          scope.connectedUserDataRepository.listSavedProcedures(),
          scope.connectedUserDataRepository.listChecklistItems(),
          scope.connectedUserDataRepository.listDeadlines(),
          scope.connectedUserDataRepository.listScans(),
          scope.entitlementService.getCurrentEntitlement(),
        ]),
        builder: (context, snapshot) {
          final values = snapshot.data as List<dynamic>?;
          final saved = values?[0] as List<SavedProcedureRecord>? ?? const [];
          final checklist =
              values?[1] as List<ChecklistItemRecord>? ?? const [];
          final deadlines = values?[2] as List<DeadlineRecord>? ?? const [];
          final scans = values?[3] as List<SituationScanRecord>? ?? const [];
          final entitlement = values?[4];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My situation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'City: ${location.city.isEmpty ? 'Not set' : location.city}',
                      ),
                      Text(
                        'Region: ${location.region.isEmpty ? 'Not set' : location.region}',
                      ),
                      Text('Language: ${profile.preferredLanguage}'),
                      if ((profile.studentStatus ?? '').isNotEmpty)
                        Text('Student: ${profile.studentStatus}'),
                      if ((profile.workStatus ?? '').isNotEmpty)
                        Text('Work: ${profile.workStatus}'),
                      if ((profile.houseStatus ?? '').isNotEmpty)
                        Text('Housing: ${profile.houseStatus}'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: UfficioCityRegistry.knownCities
                            .map(
                              (city) => ChoiceChip(
                                label: Text(city.label),
                                selected:
                                    city.slug ==
                                    UfficioCityRegistry.normalizeSlug(
                                      profile.selectedCityPackId,
                                    ),
                                onSelected: (_) async {
                                  await scope.profileController.save(
                                    profile.copyWith(
                                      selectedCityPackId: city.slug,
                                      city: city.label,
                                      defaultComune: city.label,
                                    ),
                                  );
                                  if (!mounted) return;
                                  setState(() {});
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _DashboardStatCard(
                title: 'Saved procedures',
                value: '${saved.length}',
                subtitle: 'Open the procedures you want to keep.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.procedures),
              ),
              _DashboardStatCard(
                title: 'Documents I may need',
                value: scans.isEmpty
                    ? '0'
                    : '${scans.first.recommendedDocuments.length}',
                subtitle: 'Based on your latest scan.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.scan),
              ),
              _DashboardStatCard(
                title: 'My checklist',
                value: '${checklist.length}',
                subtitle: 'Tasks linked to your procedures.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.checklist),
              ),
              _DashboardStatCard(
                title: 'Deadlines',
                value: '${deadlines.length}',
                subtitle: 'Upcoming, due soon, and overdue dates.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.deadlines),
              ),
              _DashboardStatCard(
                title: 'Requests',
                value: '${scope.requestController.requests.length}',
                subtitle: 'Problem requests and consultancy history.',
                onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
              ),
              _DashboardStatCard(
                title: 'Premium status',
                value: entitlement == null
                    ? '...'
                    : (entitlement.hasActivePremiumEntitlement
                          ? 'Premium'
                          : 'Free'),
                subtitle: 'Public procedures stay available in both plans.',
              ),
              const SizedBox(height: 12),
              const AppMonetizationEntryTile(),
              const SizedBox(height: 12),
              const FreeUserBannerAdCard(screen: 'profile_folder'),
            ],
          );
        },
      ),
    );
  }
}

class ConnectedCostDashboardScreen extends StatefulWidget {
  const ConnectedCostDashboardScreen({super.key});

  @override
  State<ConnectedCostDashboardScreen> createState() =>
      _ConnectedCostDashboardScreenState();
}

class _ConnectedCostDashboardScreenState
    extends State<ConnectedCostDashboardScreen> {
  Future<List<ConnectedCostItemRecord>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(
      context,
    ).connectedUserDataRepository.listCostItems();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AppScope.of(
        context,
      ).connectedUserDataRepository.listCostItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('cost_dashboard'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final scope = AppScope.of(context);
          final repository = scope.connectedUserDataRepository;
          final created = await _showCostItemSheet(context);
          if (created == null) return;
          await repository.saveCostItem(created);
          await scope.notificationService.syncScheduledNotifications();
          await _reload();
        },
        child: const Icon(Icons.add_chart_outlined),
      ),
      body: FutureBuilder<List<ConnectedCostItemRecord>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <ConnectedCostItemRecord>[];
          final oneTime = items
              .where((item) => item.frequency == 'one_time')
              .fold<double>(0, (sum, item) => sum + item.amountMax);
          final monthly = items
              .where((item) => item.frequency == 'monthly')
              .fold<double>(0, (sum, item) => sum + item.amountMax);
          final disputed = items
              .where((item) => item.status == ConnectedCostStatus.disputed)
              .fold<double>(0, (sum, item) => sum + item.amountMax);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryRow(
                items: [
                  _SummaryData('One-time', 'EUR ${oneTime.toStringAsFixed(2)}'),
                  _SummaryData('Monthly', 'EUR ${monthly.toStringAsFixed(2)}'),
                  _SummaryData(
                    'Disputed',
                    'EUR ${disputed.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No cost items yet. Add a real cost or generate one from a saved procedure.',
                    ),
                  ),
                ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        'EUR ${item.amountMin.toStringAsFixed(2)}'
                        '${item.amountMax > item.amountMin ? ' - ${item.amountMax.toStringAsFixed(2)}' : ''}'
                        ' • ${item.frequency} • ${item.status.name}'
                        '${item.notes == null || item.notes!.isEmpty ? '' : '\n${item.notes}'}',
                      ),
                      isThreeLine: item.notes != null && item.notes!.isNotEmpty,
                      trailing: IconButton(
                        onPressed: () async {
                          final scope = AppScope.of(context);
                          await scope.connectedUserDataRepository
                              .deleteCostItem(item.id);
                          await scope.notificationService
                              .syncScheduledNotifications();
                          await _reload();
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ConnectedComparisonScreen extends StatefulWidget {
  const ConnectedComparisonScreen({super.key, required this.mode});

  final String mode;

  @override
  State<ConnectedComparisonScreen> createState() =>
      _ConnectedComparisonScreenState();
}

class _ConnectedComparisonScreenState extends State<ConnectedComparisonScreen> {
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _serviceType = 'home internet';
  String _speedNeed = 'normal';
  String _preference = 'fixed';
  List<OfferSuggestion> _results = const [];

  @override
  void dispose() {
    _providerController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final scope = AppScope.of(context);
    if (widget.mode == 'telecom') {
      _results = await scope.connectedCatalogService.compareTelecom(
        serviceType: _serviceType,
        currentProvider: _providerController.text,
        monthlyBudget: double.tryParse(_budgetController.text) ?? 0,
        speedNeed: _speedNeed,
      );
    } else {
      _results = await scope.connectedCatalogService.compareUtilities(
        serviceType: _serviceType,
        currentMonthlyCost: double.tryParse(_budgetController.text) ?? 0,
        preference: _preference,
      );
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isTelecom = widget.mode == 'telecom';
    return Scaffold(
      appBar: AppBar(
        title: Text(isTelecom ? 'Telecom comparison' : 'Bills comparison'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelecom
                        ? 'We compare the official public tools and provider pages we can verify. Offers change often, so check the provider page before signing.'
                        : 'We compare the official public tools and provider pages we can verify. Prices change often, so check the provider page before signing.',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _serviceType,
                    decoration: const InputDecoration(
                      labelText: 'Service type',
                    ),
                    items:
                        (isTelecom
                                ? const ['home internet', 'mobile', 'both']
                                : const ['electricity', 'gas', 'both'])
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _serviceType = value ?? _serviceType),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _providerController,
                    decoration: InputDecoration(
                      labelText: isTelecom
                          ? 'Current provider'
                          : 'Current provider (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isTelecom
                          ? 'Monthly budget'
                          : 'Current monthly bill',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: isTelecom ? _speedNeed : _preference,
                    decoration: InputDecoration(
                      labelText: isTelecom ? 'Speed need' : 'Preference',
                    ),
                    items:
                        (isTelecom
                                ? const ['basic', 'normal', 'high']
                                : const [
                                    'fixed',
                                    'variable',
                                    'green',
                                    'online only',
                                  ])
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() {
                      if (isTelecom) {
                        _speedNeed = value ?? _speedNeed;
                      } else {
                        _preference = value ?? _preference;
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _run,
                    child: Text(
                      isTelecom
                          ? 'Check official offer'
                          : 'Compare your current bill',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!isTelecom)
            const Card(
              child: ListTile(
                title: Text('Official energy comparison'),
                subtitle: Text(
                  'Use Portale Offerte as the main official source.',
                ),
              ),
            ),
          ..._results
              .take(10)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.providerName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(item.reasons.join('\n')),
                          const SizedBox(height: 12),
                          const Text('Check before you sign'),
                          const SizedBox(height: 8),
                          ...item.requiredUserChecks.map(
                            (check) => Text('• $check'),
                          ),
                          const SizedBox(height: 12),
                          ...item.officialLinks
                              .where((url) => url.isNotEmpty)
                              .map(
                                (url) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ExternalValueRow(
                                    label: 'Official link',
                                    value: url,
                                    kind: ExternalValueKind.website,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

CatalogLocationSelection _currentLocation(AppScope scope) {
  final selectedCity = UfficioCityRegistry.baseCityForSlug(
    scope.profileController.profile.selectedCityPackId,
  );
  return CatalogLocationSelection(
    city: scope.profileController.profile.city ?? selectedCity.label,
    region: selectedCity.region,
  );
}

List<ChecklistItemRecord> _buildChecklistItemsForProcedure(
  ConnectedProcedureRecord procedure,
) {
  final items = <ChecklistItemRecord>[];
  for (final step in procedure.steps.take(6)) {
    items.add(
      ChecklistItemRecord(
        id: const Uuid().v4(),
        title: step,
        description: procedure.title,
        sourceType: 'procedure',
        sourceProcedureId: procedure.slug,
        status: ConnectedChecklistStatus.todo,
        dueDate: null,
        priority: 1,
        categorySlug: procedure.categoryId,
        procedureSlug: procedure.slug,
        documentRequired: procedure.documentsRequired.isEmpty
            ? null
            : procedure.documentsRequired.first,
        officialLink: procedure.officialLinks.isEmpty
            ? null
            : procedure.officialLinks.first.url,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
  if (items.isEmpty) {
    items.add(
      ChecklistItemRecord(
        id: const Uuid().v4(),
        title: 'Review the official steps',
        description: procedure.title,
        sourceType: 'procedure',
        sourceProcedureId: procedure.slug,
        status: ConnectedChecklistStatus.todo,
        priority: 1,
        categorySlug: procedure.categoryId,
        procedureSlug: procedure.slug,
        documentRequired: procedure.documentsRequired.isEmpty
            ? null
            : procedure.documentsRequired.first,
        officialLink: procedure.officialLinks.isEmpty
            ? null
            : procedure.officialLinks.first.url,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
  return items;
}

List<DeadlineRecord> _buildDeadlinesForProcedure(
  ConnectedProcedureRecord procedure,
) {
  if (procedure.timelines.isEmpty) return const <DeadlineRecord>[];
  return procedure.timelines.take(3).map((timeline) {
    return DeadlineRecord(
      id: const Uuid().v4(),
      title: procedure.title,
      description: timeline,
      dueDate: DateTime.now().add(const Duration(days: 14)),
      sourceType: 'procedure',
      sourceProcedureId: procedure.slug,
      categorySlug: procedure.categoryId,
      procedureSlug: procedure.slug,
      status: ConnectedDeadlineStatus.upcoming,
      officialLink: procedure.officialLinks.isEmpty
          ? null
          : procedure.officialLinks.first.url,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }).toList();
}

List<ConnectedCostItemRecord> _buildCostItemsForProcedure(
  ConnectedProcedureRecord procedure,
) {
  if (procedure.costs.isEmpty) return const <ConnectedCostItemRecord>[];
  return procedure.costs.take(3).map((cost) {
    return ConnectedCostItemRecord(
      id: const Uuid().v4(),
      title: procedure.title,
      amountMin: 0,
      amountMax: 0,
      frequency: 'unknown',
      status: ConnectedCostStatus.estimated,
      sourceType: 'procedure',
      sourceProcedureId: procedure.slug,
      categorySlug: procedure.categoryId,
      officialLink: procedure.officialLinks.isEmpty
          ? null
          : procedure.officialLinks.first.url,
      notes: '$cost\nThis price changes often. Verify before signing.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }).toList();
}

DropdownButton<String?> _buildDropdownChip<T>({
  required String label,
  required String? value,
  required List<DropdownMenuItem<String?>> items,
  required void Function(String?) onChanged,
}) {
  return DropdownButton<String?>(
    value: value,
    hint: Text(label),
    onChanged: onChanged,
    items: items,
  );
}

class _LocationSummaryCard extends StatelessWidget {
  const _LocationSummaryCard({required this.location});

  final CatalogLocationSelection location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(location.city.isEmpty ? 'Location not set' : location.city),
        subtitle: Text(
          location.region.isEmpty
              ? 'National fallback will be used where local data is missing.'
              : '${location.region}. National fallback is used when local details are missing.',
        ),
      ),
    );
  }
}

ConnectedCategoryRecord? _findCategory(
  List<ConnectedCategoryRecord> categories,
  String categoryId,
) {
  for (final category in categories) {
    if (category.id == categoryId) return category;
  }
  return null;
}

ConnectedSubcategoryRecord? _findSubcategory(
  ConnectedCategoryRecord category,
  String subcategoryId,
) {
  for (final subcategory in category.subcategories) {
    if (subcategory.id == subcategoryId) return subcategory;
  }
  return null;
}

ConnectedProcedureRecord? _findProcedure(
  ConnectedSubcategoryRecord subcategory,
  String procedureId,
) {
  for (final procedure in subcategory.procedures) {
    if (procedure.slug == procedureId) return procedure;
  }
  return null;
}

class _ProcedureSectionCard extends StatelessWidget {
  const _ProcedureSectionCard({
    required this.title,
    required this.items,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<String> items;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) => item.trim().isNotEmpty).toList();
    if (visibleItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '${visibleItems.length} ${visibleItems.length == 1 ? 'item' : 'items'}',
          ),
          children: [
            ...visibleItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: AutoLinkText(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ExternalValueKind _contactKind(UfficioContact contact) {
  switch (contact.type.toLowerCase()) {
    case 'email':
      return ExternalValueKind.email;
    case 'pec':
      return ExternalValueKind.pec;
    case 'phone':
    case 'telephone':
      return ExternalValueKind.phone;
    case 'address':
    case 'office':
      return ExternalValueKind.address;
    case 'website':
    case 'url':
      return ExternalValueKind.website;
    default:
      final value = contact.value.toLowerCase();
      if (value.contains('@')) return ExternalValueKind.email;
      if (value.startsWith('http') || value.startsWith('www.')) {
        return ExternalValueKind.website;
      }
      if (RegExp(r'^[\d+\s()/.-]+$').hasMatch(contact.value)) {
        return ExternalValueKind.phone;
      }
      return ExternalValueKind.address;
  }
}

class _EmptySearchCard extends StatelessWidget {
  const _EmptySearchCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No exact match. Try describing the problem in simple words, for example: “I need to change doctor” or “my internet provider charged me wrong”.',
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final List<String> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => FilterChip(
              label: Text(item),
              selected: selected.contains(item),
              onSelected: (_) => onToggle(item),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text(value),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData(this.label, this.value);

  final String label;
  final String value;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.items});

  final List<_SummaryData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 160,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label),
                      const SizedBox(height: 6),
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

Future<ChecklistItemRecord?> _showManualChecklistSheet(
  BuildContext context,
) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  return showModalBottomSheet<ChecklistItemRecord>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              ChecklistItemRecord(
                id: const Uuid().v4(),
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                sourceType: 'manual',
                status: ConnectedChecklistStatus.todo,
                priority: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

Future<DeadlineRecord?> _showDeadlineSheet(BuildContext context) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));
  return showModalBottomSheet<DeadlineRecord>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Deadline title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Why it matters'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(DateFormat('dd/MM/yyyy').format(dueDate)),
              trailing: const Icon(Icons.date_range_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2035),
                  initialDate: dueDate,
                );
                if (picked != null) {
                  setModalState(() => dueDate = picked);
                }
              },
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                DeadlineRecord(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  dueDate: dueDate,
                  sourceType: 'manual',
                  status: ConnectedDeadlineStatus.upcoming,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
              child: const Text('Add deadline'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<ConnectedCostItemRecord?> _showCostItemSheet(
  BuildContext context,
) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  String frequency = 'one_time';
  return showModalBottomSheet<ConnectedCostItemRecord>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Cost title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'one_time', child: Text('One-time')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
              ],
              onChanged: (value) =>
                  setModalState(() => frequency = value ?? frequency),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                ConnectedCostItemRecord(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  amountMin: double.tryParse(amountController.text) ?? 0,
                  amountMax: double.tryParse(amountController.text) ?? 0,
                  frequency: frequency,
                  status: ConnectedCostStatus.confirmed,
                  sourceType: 'manual',
                  notes: notesController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
              child: const Text('Add cost'),
            ),
          ],
        ),
      ),
    ),
  );
}
