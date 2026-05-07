import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminProblemRequestsScreen extends StatelessWidget {
  const AdminProblemRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: scope.adminRepository.listProblemRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: requests
              .map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.categoryId ?? 'general'} • ${item.status.name}',
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
