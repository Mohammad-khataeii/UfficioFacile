import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../data/catalog_premium_marker.dart';
import '../../domain/premium_config.dart';
import '../../domain/ufficio_catalog.dart';
import 'life_admin_screens.dart'
    show
        GlobalProblemRequestCard,
        PremiumBadge,
        PrivateConsultancyCard,
        showPremiumPaywallSheet;

class CatalogCategoryRouteArgs {
  const CatalogCategoryRouteArgs(this.categoryId);

  final String categoryId;
}

class CatalogSubcategoryRouteArgs {
  const CatalogSubcategoryRouteArgs({
    required this.categoryId,
    required this.subcategoryId,
  });

  final String categoryId;
  final String subcategoryId;
}

class CatalogProcedureRouteArgs {
  const CatalogProcedureRouteArgs({
    required this.categoryId,
    required this.subcategoryId,
    required this.procedureId,
  });

  final String categoryId;
  final String subcategoryId;
  final String procedureId;
}

class CatalogCategoryScreen extends StatefulWidget {
  const CatalogCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CatalogCategoryScreen> createState() => _CatalogCategoryScreenState();
}

class _CatalogCategoryScreenState extends State<CatalogCategoryScreen> {
  Future<UfficioCatalog>? _catalogFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalogFuture ??= AppScope.of(
      context,
    ).ufficioCatalogRepository.loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<UfficioCatalog>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadingState();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(
                    context,
                  ).ufficioCatalogRepository.loadCatalog(),
                ),
              );
            }
            final category = snapshot.data!.findCategory(widget.categoryId);
            if (category == null) {
              return const _CatalogNotFoundState();
            }
            final marker = const CatalogPremiumMarker();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CatalogHeaderCard(
                  title: ufficioLocalizedValue(
                    category.title,
                    context.l10n.languageCode,
                    fallback: category.id,
                  ),
                  description: ufficioLocalizedValue(
                    category.description,
                    context.l10n.languageCode,
                  ),
                  badge: marker.categoryHasPremiumContent(category)
                      ? context.l10n.t('premium_plan_label')
                      : null,
                  icon: _iconForCategory(category.icon, category.id),
                ),
                const SizedBox(height: 12),
                ...category.subcategories.map(
                  (subcategory) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          _iconForCategory(category.icon, category.id),
                        ),
                        title: Text(
                          ufficioLocalizedValue(
                            subcategory.title,
                            context.l10n.languageCode,
                            fallback: subcategory.id,
                          ),
                        ),
                        subtitle: Text(
                          ufficioLocalizedValue(
                            subcategory.description,
                            context.l10n.languageCode,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (marker.subcategoryHasPremiumContent(
                              subcategory,
                            ))
                              PremiumBadge(
                                label: context.l10n.t('premium_plan_label'),
                              ),
                            const SizedBox(width: 8),
                            Text('${subcategory.procedures.length}'),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.subcategory,
                          arguments: CatalogSubcategoryRouteArgs(
                            categoryId: category.id,
                            subcategoryId: subcategory.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GlobalProblemRequestCard(
                  categoryId: category.id,
                  sourcePage: category.id,
                ),
                const SizedBox(height: 12),
                PrivateConsultancyCard(
                  categoryId: category.id,
                  sourcePage: category.id,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CatalogSubcategoryScreen extends StatefulWidget {
  const CatalogSubcategoryScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
  });

  final String categoryId;
  final String subcategoryId;

  @override
  State<CatalogSubcategoryScreen> createState() =>
      _CatalogSubcategoryScreenState();
}

class _CatalogSubcategoryScreenState extends State<CatalogSubcategoryScreen> {
  Future<UfficioCatalog>? _catalogFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalogFuture ??= AppScope.of(
      context,
    ).ufficioCatalogRepository.loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<UfficioCatalog>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadingState();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(
                    context,
                  ).ufficioCatalogRepository.loadCatalog(),
                ),
              );
            }
            final catalog = snapshot.data!;
            final category = catalog.findCategory(widget.categoryId);
            final subcategory = catalog.findSubcategory(
              widget.categoryId,
              widget.subcategoryId,
            );
            if (category == null || subcategory == null) {
              return const _CatalogNotFoundState();
            }
            final marker = const CatalogPremiumMarker();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CatalogHeaderCard(
                  title: ufficioLocalizedValue(
                    subcategory.title,
                    context.l10n.languageCode,
                    fallback: subcategory.id,
                  ),
                  description: ufficioLocalizedValue(
                    subcategory.description,
                    context.l10n.languageCode,
                  ),
                  badge: marker.subcategoryHasPremiumContent(subcategory)
                      ? context.l10n.t('premium_plan_label')
                      : null,
                  icon: _iconForCategory(category.icon, category.id),
                ),
                const SizedBox(height: 12),
                ...subcategory.procedures.map(
                  (procedure) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FutureBuilder(
                      future: AppScope.of(
                        context,
                      ).entitlementService.canAccessCatalogProcedure(procedure),
                      builder: (context, accessSnapshot) {
                        final access = accessSnapshot.data;
                        return Card(
                          child: ListTile(
                            title: Text(
                              ufficioLocalizedValue(
                                procedure.title,
                                context.l10n.languageCode,
                                fallback: procedure.id,
                              ),
                            ),
                            subtitle: Text(
                              ufficioLocalizedValue(
                                procedure.shortDescription,
                                context.l10n.languageCode,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (marker.procedureIsPremium(procedure))
                                  PremiumBadge(
                                    label: access?.alreadyUnlocked == true
                                        ? context.l10n.t('already_unlocked')
                                        : context.l10n.t('premium_plan_label'),
                                  ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.catalogProcedure,
                              arguments: CatalogProcedureRouteArgs(
                                categoryId: widget.categoryId,
                                subcategoryId: widget.subcategoryId,
                                procedureId: procedure.id,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CatalogProcedureScreen extends StatefulWidget {
  const CatalogProcedureScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    required this.procedureId,
  });

  final String categoryId;
  final String subcategoryId;
  final String procedureId;

  @override
  State<CatalogProcedureScreen> createState() => _CatalogProcedureScreenState();
}

class _CatalogProcedureScreenState extends State<CatalogProcedureScreen> {
  Future<UfficioProcedure?>? _procedureFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _procedureFuture ??= AppScope.of(context).ufficioCatalogRepository
        .loadProcedureDetail(
          categoryId: widget.categoryId,
          subcategoryId: widget.subcategoryId,
          procedureId: widget.procedureId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<UfficioProcedure?>(
          future: _procedureFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadingState();
            }
            if (snapshot.hasError) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _procedureFuture = scope.ufficioCatalogRepository
                      .loadProcedureDetail(
                        categoryId: widget.categoryId,
                        subcategoryId: widget.subcategoryId,
                        procedureId: widget.procedureId,
                      ),
                ),
              );
            }
            final procedure = snapshot.data;
            if (procedure == null) {
              return const _CatalogNotFoundState();
            }
            return FutureBuilder(
              future: scope.entitlementService.canAccessCatalogProcedure(
                procedure,
              ),
              builder: (context, accessSnapshot) {
                if (!accessSnapshot.hasData) {
                  return const _CatalogLoadingState();
                }
                final access = accessSnapshot.data!;
                final visibleSections = procedure.sections.where((section) {
                  if (!section.isPremiumOnly) return true;
                  return access.allowed;
                }).toList();
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _CatalogHeaderCard(
                      title: ufficioLocalizedValue(
                        procedure.title,
                        context.l10n.languageCode,
                        fallback: procedure.id,
                      ),
                      description: ufficioLocalizedValue(
                        procedure.shortDescription,
                        context.l10n.languageCode,
                      ),
                      badge: procedure.hasPremiumContent
                          ? context.l10n.t('premium_plan_label')
                          : null,
                    ),
                    if (!access.allowed) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.t('premium_locked_title'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ufficioLocalizedValue(
                                  procedure.premiumTeaser.isNotEmpty
                                      ? procedure.premiumTeaser
                                      : procedure.shortDescription,
                                  context.l10n.languageCode,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(access.message),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.l10n.t(
                                                'payment_not_active_yet',
                                              ),
                                            ),
                                          ),
                                        ),
                                    child: Text(
                                      context.l10n.t('unlock_this_guide_only'),
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.plan,
                                    ),
                                    child: Text(
                                      context.l10n.t('upgrade_to_premium'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => showPremiumPaywallSheet(
                                      context,
                                      decision: EntitlementDecision(
                                        allowed: false,
                                        reason: access.message,
                                        upgradeTitle: context.l10n.t(
                                          'cta_consultancy_title',
                                        ),
                                        upgradeMessage: context.l10n.t(
                                          'cta_consultancy_body',
                                        ),
                                        isPremiumFeature: true,
                                      ),
                                      featureLabel: context.l10n.t(
                                        'cta_consultancy_request',
                                      ),
                                    ),
                                    child: Text(
                                      context.l10n.t('cta_consultancy_request'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ...visibleSections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CatalogSectionCard(
                          title: ufficioLocalizedValue(
                            section.title,
                            context.l10n.languageCode,
                            fallback: section.key,
                          ),
                          child: _CatalogSectionBody(section: section),
                        ),
                      ),
                    ),
                    if (procedure.officialLinks.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CatalogSectionCard(
                          title: context.l10n.t('official_links'),
                          child: Column(
                            children: procedure.officialLinks
                                .where((item) => item.url.trim().isNotEmpty)
                                .map(
                                  (item) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      ufficioLocalizedValue(
                                        item.label,
                                        context.l10n.languageCode,
                                        fallback: item.url,
                                      ),
                                    ),
                                    subtitle: Text(item.url),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                    if (procedure.contacts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CatalogSectionCard(
                          title: context.l10n.t('contacts_directory'),
                          child: Column(
                            children: procedure.contacts
                                .map(
                                  (item) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      ufficioLocalizedValue(
                                        item.label,
                                        context.l10n.languageCode,
                                        fallback: item.value,
                                      ),
                                    ),
                                    subtitle: Text(item.value),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                    GlobalProblemRequestCard(
                      categoryId: procedure.categoryId,
                      subcategoryId: procedure.subcategoryId,
                      sourcePage: procedure.id,
                    ),
                    const SizedBox(height: 12),
                    PrivateConsultancyCard(
                      categoryId: procedure.categoryId,
                      subcategoryId: procedure.subcategoryId,
                      sourcePage: procedure.id,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CatalogHeaderCard extends StatelessWidget {
  const _CatalogHeaderCard({
    required this.title,
    required this.description,
    this.badge,
    this.icon,
  });

  final String title;
  final String description;
  final String? badge;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[Icon(icon), const SizedBox(width: 12)],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (badge != null) PremiumBadge(label: badge!),
              ],
            ),
            if (description.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatalogSectionCard extends StatelessWidget {
  const _CatalogSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _CatalogSectionBody extends StatelessWidget {
  const _CatalogSectionBody({required this.section});

  final UfficioContentSection section;

  @override
  Widget build(BuildContext context) {
    final body = ufficioLocalizedValue(
      section.body,
      context.l10n.languageCode,
    ).trim();
    final items =
        section.items[context.l10n.languageCode] ??
        section.items['en'] ??
        section.items['it'] ??
        const <String>[];
    if (section.type == 'checklist' && items.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (body.isNotEmpty) ...[Text(body), const SizedBox(height: 8)],
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $item'),
            ),
          ),
        ],
      );
    }
    return Text(body);
  }
}

class _CatalogLoadingState extends StatelessWidget {
  const _CatalogLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _CatalogErrorState extends StatelessWidget {
  const _CatalogErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.t('no_procedures_yet_body'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.l10n.t('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogNotFoundState extends StatelessWidget {
  const _CatalogNotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.t('not_found'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              ),
              child: Text(context.l10n.t('back_to_dashboard')),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForCategory(String icon, String slug) {
  switch (icon) {
    case 'health_and_safety':
    case 'local_hospital':
      return Icons.local_hospital_outlined;
    case 'home':
    case 'home_work':
      return Icons.home_work_outlined;
    case 'bolt':
    case 'receipt_long':
      return Icons.receipt_long_outlined;
    case 'tv':
      return Icons.tv_outlined;
    case 'wifi':
      return Icons.wifi_tethering_outlined;
    case 'location_city':
      return Icons.location_city_outlined;
    case 'work':
      return Icons.work_outline;
    case 'school':
      return Icons.school_outlined;
    case 'support_agent':
      return Icons.support_agent_outlined;
    default:
      switch (slug) {
        case 'bonuses-benefits':
          return Icons.card_giftcard_outlined;
        case 'loans-credit':
          return Icons.credit_card_outlined;
        default:
          return Icons.folder_open_outlined;
      }
  }
}
