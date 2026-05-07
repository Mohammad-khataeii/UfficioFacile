import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminCatalogScreen extends StatelessWidget {
  const AdminCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return FutureBuilder(
      future: Future.wait([
        scope.adminRepository.listOfficialLinks(),
        scope.adminRepository.listOfficialContacts(),
        scope.adminRepository.listProcedureGuidance(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final links = data[0] as List;
        final contacts = data[1] as List;
        final procedures = data[2] as List;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Official links'),
              trailing: Text('${links.length}'),
            ),
            ListTile(
              title: const Text('Official contacts'),
              trailing: Text('${contacts.length}'),
            ),
            ListTile(
              title: const Text('Procedure guidance rows'),
              trailing: Text('${procedures.length}'),
            ),
            const SizedBox(height: 12),
            const Text('Use the Content Manager tab for full no-code editing.'),
          ],
        );
      },
    );
  }
}
