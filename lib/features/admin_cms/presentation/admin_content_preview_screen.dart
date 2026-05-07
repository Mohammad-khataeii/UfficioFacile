import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminContentPreviewScreen extends StatelessWidget {
  const AdminContentPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AppScope.of(context).cmsContentController.categories;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: categories
          .take(10)
          .map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((item.title['en'] ?? item.slug).toString()),
                    const SizedBox(height: 8),
                    Text((item.shortDescription['en'] ?? '').toString()),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
