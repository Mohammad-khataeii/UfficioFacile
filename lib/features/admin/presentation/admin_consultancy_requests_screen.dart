import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminConsultancyRequestsScreen extends StatelessWidget {
  const AdminConsultancyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: scope.adminRepository.listConsultancyRequests(),
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
                    title: Text(item.problemType),
                    subtitle: Text(
                      '${item.userPlan} • ${item.paymentStatus.name} • ${item.status.name}',
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
