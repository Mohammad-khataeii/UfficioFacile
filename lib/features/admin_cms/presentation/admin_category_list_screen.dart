import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../../../app/app_scope.dart';

class AdminCategoryListScreen extends StatelessWidget {
  const AdminCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope.cmsContentController,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () => scope.cmsContentController.importBundledContent(),
            child: Text(context.l10n.t('import_bundled_content')),
          ),
          const SizedBox(height: 12),
          ...scope.cmsContentController.categories.map(
            (item) => ListTile(
              title: Text((item.title['en'] ?? item.slug).toString()),
              subtitle: Text(
                '${item.slug} • ${item.visibility} • ${item.isActive ? 'active' : 'hidden'}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
