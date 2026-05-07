import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../domain/admin_models.dart';

class AdminEntitlementsScreen extends StatelessWidget {
  const AdminEntitlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.adminPanelController,
      builder: (context, _) {
        final entitlements = scope.adminPanelController.entitlements;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: entitlements
              .map(
                (record) => Card(
                  child: ListTile(
                    title: Text(record.userId),
                    subtitle: Text('${record.plan} • ${record.status}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () =>
                              scope.adminPanelController.saveEntitlement(
                                AdminEntitlementRecord(
                                  id: record.id,
                                  userId: record.userId,
                                  plan: 'premium',
                                  status: 'active',
                                  source: 'manual',
                                  currentPeriodEnd: record.currentPeriodEnd,
                                  premiumSince:
                                      record.premiumSince ?? DateTime.now(),
                                  metadata: record.metadata,
                                ),
                              ),
                          child: const Text('Grant premium'),
                        ),
                        TextButton(
                          onPressed: () =>
                              scope.adminPanelController.saveEntitlement(
                                AdminEntitlementRecord(
                                  id: record.id,
                                  userId: record.userId,
                                  plan: 'free',
                                  status: 'active',
                                  source: 'manual',
                                  currentPeriodEnd: null,
                                  premiumSince: null,
                                  metadata: record.metadata,
                                ),
                              ),
                          child: const Text('Revoke'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
