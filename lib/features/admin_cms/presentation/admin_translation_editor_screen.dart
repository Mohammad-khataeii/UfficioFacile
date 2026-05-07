import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminTranslationEditorScreen extends StatelessWidget {
  const AdminTranslationEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AppScope.of(context).cmsContentController.categories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Translation completeness'),
        const SizedBox(height: 12),
        ...categories.map(
          (item) => ListTile(
            title: Text(item.slug),
            subtitle: Text(
              'en:${item.title['en'] != null} • it:${item.title['it'] != null} • fa:${item.title['fa'] != null} • fr:${item.title['fr'] != null}',
            ),
          ),
        ),
      ],
    );
  }
}
