import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.adminPanelController,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: scope.adminPanelController.auditLogs
            .map(
              (item) => ListTile(
                title: Text(item.action),
                subtitle: Text(
                  '${item.targetTable} • ${item.createdAt.toIso8601String()}',
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
