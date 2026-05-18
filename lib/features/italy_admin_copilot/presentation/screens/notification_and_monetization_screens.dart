import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/app_scope.dart';

String _planLabelForUi(dynamic plan) {
  switch (plan?.toString()) {
    case 'UfficioPlan.premiumMonthly':
    case 'UfficioPlan.premiumYearly':
    case 'UfficioPlan.plusMonthly':
    case 'UfficioPlan.plusYearly':
    case 'UfficioPlan.pro':
    case 'UfficioPlan.trial':
    case 'UfficioPlan.lifetime':
    case 'UfficioPlan.adminGrant':
    case 'UfficioPlan.consultant':
      return 'Premium';
    case 'UfficioPlan.consultancyOneShot':
      return 'One-time support';
    case 'UfficioPlan.free':
    default:
      return 'Free';
  }
}

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: FutureBuilder(
          future: Future.wait<dynamic>([
            scope.notificationService.getPreferences(),
            scope.notificationService.buildInbox(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? const <dynamic>[];
            final preferences = data.isNotEmpty ? data[0] : null;
            final items = data.length > 1 ? data[1] as List<dynamic> : const [];
            if (preferences == null) {
              return const Center(child: Text('Could not load notifications.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Allow reminders'),
                        subtitle: const Text(
                          'Deadlines, checklist dates, and payments.',
                        ),
                        value: preferences.enabled,
                        onChanged: _saving
                            ? null
                            : (value) => _savePreferences(
                                context,
                                preferences.copyWith(enabled: value),
                              ),
                      ),
                      SwitchListTile(
                        title: const Text('Deadlines'),
                        value: preferences.deadlines,
                        onChanged: preferences.enabled && !_saving
                            ? (value) => _savePreferences(
                                context,
                                preferences.copyWith(deadlines: value),
                              )
                            : null,
                      ),
                      SwitchListTile(
                        title: const Text('Checklist items'),
                        value: preferences.checklist,
                        onChanged: preferences.enabled && !_saving
                            ? (value) => _savePreferences(
                                context,
                                preferences.copyWith(checklist: value),
                              )
                            : null,
                      ),
                      SwitchListTile(
                        title: const Text('Costs and bills'),
                        value: preferences.costs,
                        onChanged: preferences.enabled && !_saving
                            ? (value) => _savePreferences(
                                context,
                                preferences.copyWith(costs: value),
                              )
                            : null,
                      ),
                      SwitchListTile(
                        title: const Text('Premium expiry'),
                        value: preferences.premium,
                        onChanged: preferences.enabled && !_saving
                            ? (value) => _savePreferences(
                                context,
                                preferences.copyWith(premium: value),
                              )
                            : null,
                      ),
                      ListTile(
                        title: const Text('Permission'),
                        subtitle: const Text(
                          'Turn this on if your phone blocked reminders.',
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final granted = await scope.notificationService
                                .requestPermissionIfNeeded();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  granted
                                      ? 'Permission updated.'
                                      : 'Permission is still blocked.',
                                ),
                              ),
                            );
                          },
                          child: const Text('Check'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What needs attention',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          const Text('Nothing urgent right now.')
                        else
                          ...items.map((item) {
                            final entry = item as dynamic;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.notifications_active),
                              title: Text(entry.title as String),
                              subtitle: Text(entry.body as String),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                final route = entry.targetRoute as String?;
                                if (route == null || route.isEmpty) return;
                                Navigator.pushNamed(context, route);
                              },
                            );
                          }),
                      ],
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

  Future<void> _savePreferences(
    BuildContext context,
    dynamic preferences,
  ) async {
    setState(() => _saving = true);
    try {
      await AppScope.of(
        context,
      ).notificationService.savePreferences(preferences);
      if (!context.mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notifications updated.')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  int _refreshTick = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Promo codes')),
      body: SafeArea(
        child: FutureBuilder(
          key: ValueKey(_refreshTick),
          future: Future.wait<dynamic>([
            scope.promoCodeService.listHistory(),
            scope.entitlementService.getCurrentEntitlement(),
            scope.promoCodeService.getAccountStatus(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? const <dynamic>[];
            final history = data.isNotEmpty
                ? (data[0] as List<dynamic>)
                : const <dynamic>[];
            final entitlement = data.length > 1 ? data[1] : null;
            final accountStatus = data.length > 2 ? data[2] : null;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apply a code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entitlement == null
                              ? 'Sign in to redeem a code.'
                              : 'Current plan: ${_planLabelForUi(entitlement.plan)}',
                        ),
                        if (accountStatus != null &&
                            accountStatus.hasActiveCheckoutDiscount) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${accountStatus.activeCheckoutDiscountPercent}% off saved for ${accountStatus.activeCheckoutTargetPlanKeys.join(' and ')}. It will be used on your next Premium checkout.',
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Promo code',
                            hintText: 'ENTER CODE',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _redeem(context),
                          icon: const Icon(Icons.redeem_outlined),
                          label: Text(
                            _submitting ? 'Applying...' : 'Apply code',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const FreeUserBannerAdCard(screen: 'promo_codes'),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (history.isEmpty)
                          const Text('No promo code used yet.')
                        else
                          ...history.map((item) {
                            final entry = item as dynamic;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.local_offer_outlined),
                              title: Text(entry.code as String),
                              subtitle: Text(
                                [
                                  entry.message as String,
                                  if (entry.promoKind == 'percent_discount' &&
                                      entry.discountPercent != null)
                                    '${entry.discountPercent}% off',
                                ].join('\n'),
                              ),
                              isThreeLine:
                                  entry.promoKind == 'percent_discount' &&
                                  entry.discountPercent != null,
                              trailing: Text(
                                DateFormat(
                                  'dd MMM',
                                ).format(entry.createdAt as DateTime),
                              ),
                            );
                          }),
                      ],
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

  Future<void> _redeem(BuildContext context) async {
    setState(() => _submitting = true);
    try {
      final result = await AppScope.of(
        context,
      ).promoCodeService.redeem(_controller.text);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      if (result.ok) {
        if (result.promoKind == 'grant_entitlement') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.expiresAt == null
                    ? 'Premium started successfully.'
                    : 'Premium started successfully and is active until ${DateFormat('dd MMM').format(result.expiresAt!)}.',
              ),
            ),
          );
        }
        _controller.clear();
        unawaited(
          AppScope.of(context).notificationService.syncScheduledNotifications(),
        );
        setState(() => _refreshTick += 1);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class FreeUserBannerAdCard extends StatefulWidget {
  const FreeUserBannerAdCard({super.key, required this.screen});

  final String screen;

  @override
  State<FreeUserBannerAdCard> createState() => _FreeUserBannerAdCardState();
}

class _FreeUserBannerAdCardState extends State<FreeUserBannerAdCard> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _hidden = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_hidden) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _hidden || _bannerAd == null || !_loaded) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sponsored',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final shouldShow = await scope.adsService.shouldShowAds(widget.screen);
    if (!shouldShow || !mounted) {
      setState(() => _hidden = true);
      return;
    }
    final config = await scope.adsService.loadConfig();
    await scope.adsService.initialize();
    if (!mounted) return;
    final platform = Theme.of(context).platform;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: config.bannerUnitId(platform),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _hidden = true);
        },
      ),
    );
    _bannerAd = ad;
    await ad.load();
  }
}

class AppMonetizationEntryTile extends StatelessWidget {
  const AppMonetizationEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          subtitle: const Text('Deadlines, checklist, and payment reminders.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        ListTile(
          leading: const Icon(Icons.local_offer_outlined),
          title: const Text('Promo codes'),
          subtitle: const Text('Apply a code and check recent redemptions.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.promoCodes),
        ),
      ],
    );
  }
}
