import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminProcedureListScreen extends StatelessWidget {
  const AdminProcedureListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.cmsContentController,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: scope.cmsContentController.procedures
            .map(
              (item) => ListTile(
                title: Text((item.title['en'] ?? item.slug).toString()),
                subtitle: Text(
                  '${item.categorySlug} • ${item.verificationStatus} • ${item.visibility}',
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
