import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/app_scope.dart';
import 'admin_content_revision_history_screen.dart';

class AdminContentImportExportScreen extends StatelessWidget {
  const AdminContentImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton(
          onPressed: () async {
            final payload = {
              'categories': scope.cmsContentController.categories
                  .map((item) => item.slug)
                  .toList(),
              'procedures': scope.cmsContentController.procedures
                  .map((item) => item.slug)
                  .toList(),
            };
            await SharePlus.instance.share(
              ShareParams(text: jsonEncode(payload)),
            );
          },
          child: const Text('Export CMS summary'),
        ),
        const SizedBox(height: 12),
        const AdminContentRevisionHistoryScreen(),
      ],
    );
  }
}
