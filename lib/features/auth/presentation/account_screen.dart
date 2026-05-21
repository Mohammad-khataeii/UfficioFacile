import 'package:flutter/material.dart';

import '../../../../app/app_localizations.dart';
import '../../italy_admin_copilot/presentation/screens/notification_and_monetization_screens.dart';
import 'account_privacy_panel.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('account_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AccountAndPrivacyPanelContainer(),
            const SizedBox(height: 16),
            const Card(child: AppMonetizationEntryTile()),
          ],
        ),
      ),
    );
  }
}
