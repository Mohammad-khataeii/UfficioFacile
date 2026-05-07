import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  bool _loading = true;
  final _values = <String, dynamic>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final values = await scope.adminRepository.getPublicConfig();
    if (!mounted) return;
    setState(() {
      _values
        ..clear()
        ..addAll(values);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    final freePackLimit = (_values['freePackLimit'] ?? 5).toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Public config'),
            SwitchListTile(
              value: _values['userAuthRequired'] == true,
              onChanged: (value) =>
                  setState(() => _values['userAuthRequired'] = value),
              title: const Text('Require auth for private workspace'),
            ),
            SwitchListTile(
              value: _values['publicCatalogMode'] != false,
              onChanged: (value) =>
                  setState(() => _values['publicCatalogMode'] = value),
              title: const Text('Public catalog mode'),
            ),
            SwitchListTile(
              value: _values['betaModeEnabled'] != false,
              onChanged: (value) =>
                  setState(() => _values['betaModeEnabled'] = value),
              title: const Text('Beta mode'),
            ),
            SwitchListTile(
              value: _values['paywallEnabled'] == true,
              onChanged: (value) =>
                  setState(() => _values['paywallEnabled'] = value),
              title: const Text('Paywall enabled'),
            ),
            SwitchListTile(
              value: _values['showPremiumBadges'] != false,
              onChanged: (value) =>
                  setState(() => _values['showPremiumBadges'] = value),
              title: const Text('Show premium badges'),
            ),
            TextFormField(
              initialValue: freePackLimit,
              decoration: const InputDecoration(labelText: 'Free pack limit'),
              onChanged: (value) =>
                  _values['freePackLimit'] = int.tryParse(value) ?? 5,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await scope.adminRepository.savePublicConfig(_values);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Config saved')));
              },
              child: const Text('Save config'),
            ),
          ],
        ),
      ),
    );
  }
}
