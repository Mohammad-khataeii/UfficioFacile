import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final userIdController = TextEditingController();
    final emailController = TextEditingController();
    var role = 'admin';
    var isActive = true;

    return AnimatedBuilder(
      animation: scope.adminPanelController,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add or update admin'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: userIdController,
                        decoration: const InputDecoration(labelText: 'User ID'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        items: const [
                          DropdownMenuItem(
                            value: 'owner',
                            child: Text('owner'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('admin'),
                          ),
                          DropdownMenuItem(
                            value: 'editor',
                            child: Text('editor'),
                          ),
                          DropdownMenuItem(
                            value: 'support',
                            child: Text('support'),
                          ),
                          DropdownMenuItem(
                            value: 'viewer',
                            child: Text('viewer'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => role = value ?? role),
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                        title: const Text('Active'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await scope.adminPanelController.saveAdminUser(
                            userId: userIdController.text.trim(),
                            email: emailController.text.trim(),
                            role: role,
                            isActive: isActive,
                          );
                        },
                        child: const Text('Save admin user'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...scope.adminPanelController.adminUsers.map(
              (item) => ListTile(
                title: Text(item.email ?? item.userId),
                subtitle: Text(
                  '${item.role} • ${item.isActive ? 'active' : 'inactive'}',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
