import 'package:flutter/material.dart';

import '../../../../app/external_actions.dart';
import '../../../../app/app_localizations.dart';
import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';
import '../../data/ufficio_city_registry.dart';
import '../../domain/ufficio_city.dart';
import '../../domain/premium_config.dart';
import '../../domain/ufficio_catalog.dart';
import '../../data/ufficio_catalog_repository.dart';
import 'life_admin_screens.dart'
    show
        GlobalProblemRequestCard,
        PremiumBadge,
        PremiumBadgeTone,
        PrivateConsultancyCard,
        showCityCatalogRequestSheet,
        showPremiumPaywallSheet;

PremiumBadge _subcategoryAccessBadge(
  BuildContext context,
  UfficioSubcategory subcategory,
) {
  final isPremium = subcategory.isPremiumOnly;
  return PremiumBadge(
    label: context.l10n.t(isPremium ? 'premium_plan_label' : 'free_plan_label'),
    tone: isPremium ? PremiumBadgeTone.premium : PremiumBadgeTone.free,
  );
}

Future<bool> _isPremiumHierarchyLocked(
  BuildContext context, {
  required String categoryId,
  required String subcategoryId,
  required UfficioProcedure procedure,
}) async {
  final scope = AppScope.of(context);
  final config = await scope.entitlementService.getConfig();
  if (!config.paywallEnabled) {
    return false;
  }
  final citySlug = UfficioCityRegistry.normalizeSlug(
    scope.profileController.profile.selectedCityPackId,
  );
  final result = await scope.ufficioCatalogRepository.loadCatalogResult(
    citySlug: citySlug,
  );
  final catalog = result.catalog;
  final category = catalog?.findCategory(categoryId);
  final subcategory = catalog?.findSubcategory(categoryId, subcategoryId);
  final hasPremiumPath =
      procedure.isPremiumOnly ||
      (subcategory?.isPremiumOnly ?? false) ||
      (category?.isPremiumOnly ?? false);
  if (!hasPremiumPath) {
    return false;
  }
  final entitlement = await scope.entitlementService.getCurrentEntitlement();
  return !entitlement.isProLike;
}

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
  Future<UfficioCatalogLoadResult>? _catalogFuture;
  String? _resolvedCitySlug;
  ChangeNotifier? _profileListenable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextListenable = AppScope.of(context).profileController;
    if (!identical(_profileListenable, nextListenable)) {
      _profileListenable?.removeListener(_handleProfileChanged);
      _profileListenable = nextListenable;
      _profileListenable?.addListener(_handleProfileChanged);
    }
    _refreshCatalogFutureIfNeeded();
  }

  void _handleProfileChanged() {
    if (!mounted) return;
    setState(_refreshCatalogFutureIfNeeded);
  }

  @override
  void dispose() {
    _profileListenable?.removeListener(_handleProfileChanged);
    super.dispose();
  }

  void _refreshCatalogFutureIfNeeded() {
    final scope = AppScope.of(context);
    final nextCitySlug = UfficioCityRegistry.normalizeSlug(
      scope.profileController.profile.selectedCityPackId,
    );
    if (_catalogFuture != null && _resolvedCitySlug == nextCitySlug) {
      return;
    }
    _resolvedCitySlug = nextCitySlug;
    _catalogFuture = scope.ufficioCatalogRepository.loadCatalogResult(
      citySlug: nextCitySlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<UfficioCatalogLoadResult>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadingState();
            }
            final result = snapshot.data;
            if (snapshot.hasError || result == null) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(context)
                      .ufficioCatalogRepository
                      .loadCatalogResult(citySlug: _resolvedCitySlug),
                ),
              );
            }
            if (result.isUnavailable) {
              return _CatalogUnavailableState(city: result.city);
            }
            if (result.catalog == null) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(context)
                      .ufficioCatalogRepository
                      .loadCatalogResult(citySlug: _resolvedCitySlug),
                ),
              );
            }
            final category = result.catalog!.findCategory(widget.categoryId);
            if (category == null) {
              return const _CatalogNotFoundState();
            }
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
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _subcategoryAccessBadge(context, subcategory),
                            const SizedBox(width: 8),
                            Text('${subcategory.procedures.length}'),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          final featureLabel = ufficioLocalizedValue(
                            subcategory.title,
                            context.l10n.languageCode,
                            fallback: subcategory.id,
                          );

                          final subcategoryAccess = await AppScope.of(context)
                              .entitlementService
                              .canAccessSubcategory(subcategory);

                          if (!context.mounted) return;

                          final mustLock =
                              subcategory.isPremiumOnly &&
                              !subcategoryAccess.allowed;

                          if (mustLock) {
                            await showPremiumPaywallSheet(
                              context,
                              decision: const EntitlementDecision(
                                allowed: false,
                                isPremiumFeature: true,
                                reason:
                                    'This guide is part of UfficioFacile Premium.',
                                upgradeTitle: 'Premium feature',
                                upgradeMessage:
                                    'This guide is part of UfficioFacile Premium. You can still browse free guides, or choose a plan to unlock deeper checklists, templates, and private support.',
                                recommendedPlan: UfficioPlan.premiumMonthly,
                              ),
                              featureLabel: featureLabel,
                            );
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            AppRoutes.subcategory,
                            arguments: CatalogSubcategoryRouteArgs(
                              categoryId: category.id,
                              subcategoryId: subcategory.id,
                            ),
                          );
                        },
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
  Future<UfficioCatalogLoadResult>? _catalogFuture;
  String? _resolvedCitySlug;
  ChangeNotifier? _profileListenable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextListenable = AppScope.of(context).profileController;
    if (!identical(_profileListenable, nextListenable)) {
      _profileListenable?.removeListener(_handleProfileChanged);
      _profileListenable = nextListenable;
      _profileListenable?.addListener(_handleProfileChanged);
    }
    _refreshCatalogFutureIfNeeded();
  }

  void _handleProfileChanged() {
    if (!mounted) return;
    setState(_refreshCatalogFutureIfNeeded);
  }

  @override
  void dispose() {
    _profileListenable?.removeListener(_handleProfileChanged);
    super.dispose();
  }

  void _refreshCatalogFutureIfNeeded() {
    final scope = AppScope.of(context);
    final nextCitySlug = UfficioCityRegistry.normalizeSlug(
      scope.profileController.profile.selectedCityPackId,
    );
    if (_catalogFuture != null && _resolvedCitySlug == nextCitySlug) {
      return;
    }
    _resolvedCitySlug = nextCitySlug;
    _catalogFuture = scope.ufficioCatalogRepository.loadCatalogResult(
      citySlug: nextCitySlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<UfficioCatalogLoadResult>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadingState();
            }
            final result = snapshot.data;
            if (snapshot.hasError || result == null) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(context)
                      .ufficioCatalogRepository
                      .loadCatalogResult(citySlug: _resolvedCitySlug),
                ),
              );
            }
            if (result.isUnavailable) {
              return _CatalogUnavailableState(city: result.city);
            }
            if (result.catalog == null) {
              return _CatalogErrorState(
                onRetry: () => setState(
                  () => _catalogFuture = AppScope.of(context)
                      .ufficioCatalogRepository
                      .loadCatalogResult(citySlug: _resolvedCitySlug),
                ),
              );
            }
            final catalog = result.catalog!;
            final category = catalog.findCategory(widget.categoryId);
            final subcategory = catalog.findSubcategory(
              widget.categoryId,
              widget.subcategoryId,
            );
            if (category == null || subcategory == null) {
              return const _CatalogNotFoundState();
            }
            return FutureBuilder(
              future: AppScope.of(
                context,
              ).entitlementService.canAccessSubcategory(subcategory),
              builder: (context, accessSnapshot) {
                if (!accessSnapshot.hasData) {
                  return const _CatalogLoadingState();
                }
                final subcategoryAccess = accessSnapshot.data!;
                if (!subcategoryAccess.allowed) {
                  return _CatalogLockedState(
                    decision: subcategoryAccess,
                    description: ufficioLocalizedValue(
                      subcategory.description,
                      context.l10n.languageCode,
                    ),
                  );
                }
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
                      badge: context.l10n.t(
                        subcategory.isPremiumOnly
                            ? 'premium_plan_label'
                            : 'free_plan_label',
                      ),
                      icon: _iconForCategory(category.icon, category.id),
                    ),
                    const SizedBox(height: 12),
                    ...subcategory.procedures.map(
                      (procedure) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FutureBuilder(
                          future: AppScope.of(context).entitlementService
                              .canAccessCatalogProcedure(procedure),
                          builder: (context, accessSnapshot) {
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
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [const Icon(Icons.chevron_right)],
                                ),
                                onTap: () async {
                                  final featureLabel = ufficioLocalizedValue(
                                    procedure.title,
                                    context.l10n.languageCode,
                                    fallback: procedure.id,
                                  );

                                  final procedureAccess =
                                      await AppScope.of(context)
                                          .entitlementService
                                          .canAccessProcedure(procedure);

                                  if (!context.mounted) return;
                                  final languageCode =
                                      context.l10n.languageCode;
                                  final teaserText = ufficioLocalizedValue(
                                    procedure.premiumTeaser.isNotEmpty
                                        ? procedure.premiumTeaser
                                        : procedure.shortDescription,
                                    languageCode,
                                  );

                                  final mustLock =
                                      !procedureAccess.allowed ||
                                      await _isPremiumHierarchyLocked(
                                        context,
                                        categoryId: widget.categoryId,
                                        subcategoryId: widget.subcategoryId,
                                        procedure: procedure,
                                      );

                                  if (!context.mounted) return;

                                  if (mustLock) {
                                    await showPremiumPaywallSheet(
                                      context,
                                      decision: const EntitlementDecision(
                                        allowed: false,
                                        isPremiumFeature: true,
                                        reason:
                                            'This guide is part of UfficioFacile Premium.',
                                        upgradeTitle: 'Premium feature',
                                        upgradeMessage:
                                            'This guide is part of UfficioFacile Premium. You can still browse free guides, or choose a plan to unlock deeper checklists, templates, and private support.',
                                        recommendedPlan:
                                            UfficioPlan.premiumMonthly,
                                      ),
                                      featureLabel: featureLabel,
                                      teaser: teaserText,
                                    );
                                    return;
                                  }

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.catalogProcedure,
                                    arguments: CatalogProcedureRouteArgs(
                                      categoryId: widget.categoryId,
                                      subcategoryId: widget.subcategoryId,
                                      procedureId: procedure.id,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
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
  String? _resolvedCitySlug;
  ChangeNotifier? _profileListenable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextListenable = AppScope.of(context).profileController;
    if (!identical(_profileListenable, nextListenable)) {
      _profileListenable?.removeListener(_handleProfileChanged);
      _profileListenable = nextListenable;
      _profileListenable?.addListener(_handleProfileChanged);
    }
    _refreshProcedureFutureIfNeeded();
  }

  void _handleProfileChanged() {
    if (!mounted) return;
    setState(_refreshProcedureFutureIfNeeded);
  }

  void _refreshProcedureFutureIfNeeded() {
    final scope = AppScope.of(context);
    final nextCitySlug = UfficioCityRegistry.normalizeSlug(
      scope.profileController.profile.selectedCityPackId,
    );
    if (_procedureFuture != null && _resolvedCitySlug == nextCitySlug) {
      return;
    }
    _resolvedCitySlug = nextCitySlug;
    _procedureFuture = scope.ufficioCatalogRepository.loadProcedureDetail(
      categoryId: widget.categoryId,
      subcategoryId: widget.subcategoryId,
      procedureId: widget.procedureId,
    );
  }

  @override
  void dispose() {
    _profileListenable?.removeListener(_handleProfileChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    _refreshProcedureFutureIfNeeded();
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
              final error = snapshot.error;
              if (error is UfficioCatalogUnavailableException) {
                return _CatalogUnavailableState(city: error.city);
              }
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
              future: scope.entitlementService.canAccessProcedure(procedure),
              builder: (context, accessSnapshot) {
                if (!accessSnapshot.hasData) {
                  return const _CatalogLoadingState();
                }
                final access = accessSnapshot.data!;
                return FutureBuilder<bool>(
                  future: _isPremiumHierarchyLocked(
                    context,
                    categoryId: widget.categoryId,
                    subcategoryId: widget.subcategoryId,
                    procedure: procedure,
                  ),
                  builder: (context, premiumSnapshot) {
                    if (!premiumSnapshot.hasData) {
                      return const _CatalogLoadingState();
                    }
                    final showLockedPremiumShell =
                        !access.allowed || premiumSnapshot.data == true;
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
                        ),
                        if (showLockedPremiumShell) ...[
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.t('premium_locked_title'),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
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
                                  Text(access.reason),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
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
                                        onPressed: () =>
                                            showPremiumPaywallSheet(
                                              context,
                                              decision: EntitlementDecision(
                                                allowed: false,
                                                reason: access.reason,
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
                                          context.l10n.t(
                                            'cta_consultancy_request',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (!showLockedPremiumShell) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                ...procedure.sections.map(
                                  (section) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child:
                                        section.isPremiumOnly && !access.allowed
                                        ? _CatalogLockedSectionCard(
                                            title: ufficioLocalizedValue(
                                              section.title,
                                              context.l10n.languageCode,
                                              fallback: section.key,
                                            ),
                                          )
                                        : _CatalogSectionCard(
                                            title: ufficioLocalizedValue(
                                              section.title,
                                              context.l10n.languageCode,
                                              fallback: section.key,
                                            ),
                                            child: _CatalogSectionBody(
                                              section: section,
                                            ),
                                          ),
                                  ),
                                ),
                                if (procedure.officialLinks.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CatalogSectionCard(
                                      title: context.l10n.t('official_links'),
                                      child: Column(
                                        children: procedure.officialLinks
                                            .where(
                                              (item) =>
                                                  item.url.trim().isNotEmpty,
                                            )
                                            .map(
                                              (item) => ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                onTap: () =>
                                                    ExternalActionService.open(
                                                      context,
                                                      item.url,
                                                      ExternalValueKind.website,
                                                    ),
                                                title: Text(
                                                  ufficioLocalizedValue(
                                                    item.label,
                                                    context.l10n.languageCode,
                                                    fallback: item.url,
                                                  ),
                                                ),
                                                subtitle: ExternalValueText(
                                                  item.url,
                                                  kind:
                                                      ExternalValueKind.website,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (!showLockedPremiumShell &&
                            procedure.contacts.isNotEmpty) ...[
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
                                        subtitle: ExternalValueText(
                                          item.value,
                                          kind: ExternalValueKind.auto,
                                        ),
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

class _CatalogLockedState extends StatelessWidget {
  const _CatalogLockedState({
    required this.decision,
    required this.description,
  });

  final EntitlementDecision decision;
  final String description;

  @override
  Widget build(BuildContext context) {
    const genericLockedReason = 'This guide is part of UfficioFacile Premium.';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CatalogHeaderCard(
          title: context.l10n.t('premium_feature'),
          description: description,
          badge: context.l10n.t('premium_plan_label'),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.t('paywall_premium_body')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
                  child: Text(context.l10n.t('paywall_open_plan')),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.t('paywall_maybe_later')),
                ),
                if (decision.reason.trim().isNotEmpty &&
                    decision.reason.trim() != genericLockedReason) ...[
                  const SizedBox(height: 8),
                  Text(decision.reason),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CatalogLockedSectionCard extends StatelessWidget {
  const _CatalogLockedSectionCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _CatalogSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.t('paywall_section_locked_body')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
            child: Text(context.l10n.t('paywall_open_plan')),
          ),
        ],
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
              context.l10n.t('catalog_load_error'),
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

class _CatalogUnavailableState extends StatelessWidget {
  const _CatalogUnavailableState({required this.city});

  final UfficioCity city;

  @override
  Widget build(BuildContext context) {
    final isComingSoon = !city.isAvailable;
    final suffix = isComingSoon
        ? context.l10n.t('city_catalog_status_coming_soon')
        : context.l10n.t('city_catalog_status_available');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.t('city_catalog_unavailable_title'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n
                  .t('city_catalog_unavailable_body')
                  .replaceAll('{city}', city.label),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${context.l10n.t('city_catalog_label')}: ${city.label} — $suffix',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => showCityCatalogRequestSheet(context, city: city),
              child: Text(context.l10n.t('city_catalog_request_cta')),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Text(context.l10n.t('city_catalog_change_city')),
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
