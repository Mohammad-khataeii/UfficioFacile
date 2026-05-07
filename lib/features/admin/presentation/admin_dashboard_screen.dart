import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_scope.dart';
import 'admin_catalog_screen.dart';
import 'admin_config_screen.dart';
import 'admin_consultancy_requests_screen.dart';
import 'admin_entitlements_screen.dart';
import 'admin_problem_requests_screen.dart';
import 'admin_users_screen.dart';
import '../../admin_cms/presentation/admin_content_dashboard_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppScope.of(context).adminPanelController.load();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.t('admin_panel')),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: context.l10n.t('admin_overview')),
              Tab(text: context.l10n.t('admin_users')),
              Tab(text: context.l10n.t('admin_premium')),
              Tab(text: context.l10n.t('admin_catalog')),
              Tab(text: context.l10n.t('admin_problem_requests')),
              Tab(text: context.l10n.t('admin_consultancy')),
              Tab(text: context.l10n.t('admin_content_manager')),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: scope.adminPanelController,
          builder: (context, _) {
            final controller = scope.adminPanelController;
            final stats = controller.stats;
            return TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (controller.errorMessage != null)
                      Text(controller.errorMessage!),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatCard('Admins', '${stats?.adminCount ?? 0}'),
                        _StatCard(
                          'Premium users',
                          '${stats?.premiumCount ?? 0}',
                        ),
                        _StatCard(
                          'Open problem requests',
                          '${stats?.openProblemRequests ?? 0}',
                        ),
                        _StatCard(
                          'Open consultancy requests',
                          '${stats?.openConsultancyRequests ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.t('admin_security_checklist')),
                            const SizedBox(height: 8),
                            Text(
                              '${context.l10n.t('admin_supabase_configured')}: ${scope.config.isSupabaseEnabled}',
                            ),
                            Text(
                              '${context.l10n.t('admin_authenticated')}: ${scope.authController.isAuthenticated}',
                            ),
                            Text(context.l10n.t('admin_rls_enabled')),
                            Text(context.l10n.t('admin_anon_only')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AdminConfigScreen(),
                  ],
                ),
                const AdminUsersScreen(),
                const AdminEntitlementsScreen(),
                const AdminCatalogScreen(),
                const AdminProblemRequestsScreen(),
                const AdminConsultancyRequestsScreen(),
                const AdminContentDashboardScreen(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
