import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminContentRevisionHistoryScreen extends StatelessWidget {
  const AdminContentRevisionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = AppScope.of(context).adminPanelController.auditLogs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: logs
          .take(20)
          .map(
            (item) => ListTile(
              title: Text(item.action),
              subtitle: Text(
                '${item.targetTable} • ${item.createdAt.toIso8601String()}',
              ),
            ),
          )
          .toList(),
    );
  }
}
