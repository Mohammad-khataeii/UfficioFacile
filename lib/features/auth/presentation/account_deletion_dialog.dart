import 'package:flutter/material.dart';

import '../../../../app/external_actions.dart';
import '../../../../app/app_config.dart';
import '../data/account_deletion_service.dart';

typedef DeleteAccountNow = Future<AccountDeletionResult> Function();
typedef EmailFallback = Future<void> Function();

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({
    super.key,
    required this.onDeleteNow,
    required this.onEmailFallback,
  });

  final DeleteAccountNow onDeleteNow;
  final EmailFallback onEmailFallback;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isDeleting = false;
  String? _errorMessage;

  bool get _canDelete =>
      !_isDeleting && _confirmationController.text.trim() == 'DELETE';

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteNow() async {
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });
    final result = await widget.onDeleteNow();
    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isDeleting = false;
      _errorMessage =
          result.errorMessage ?? 'We could not delete your account right now.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destructiveColor = theme.colorScheme.error;
    return AlertDialog(
      title: const Text('Delete my account'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your account and app data where legally possible.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Some payment, invoice, fraud-prevention, security, or legal records may be retained.',
            ),
            const SizedBox(height: 8),
            const Text(
              'UfficioFacile is not a public authority, and deleting your account does not change official deadlines or obligations with any office.',
            ),
            const SizedBox(height: 8),
            const Text(
              'You will be signed out and local app data will be cleared after deletion.',
            ),
            const SizedBox(height: 16),
            const Text('Type DELETE to confirm'),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              autofocus: true,
              enabled: !_isDeleting,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: destructiveColor)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isDeleting ? null : widget.onEmailFallback,
                icon: const Icon(Icons.email_outlined),
                label: const Text('Email support instead'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructiveColor,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _canDelete ? _deleteNow : null,
          child: Text(_isDeleting ? 'Deleting...' : 'Delete my account'),
        ),
      ],
    );
  }
}

String buildAccountDeletionSupportMailto(String userEmail) {
  final subject = Uri.encodeComponent('UfficioFacile account deletion request');
  final body = Uri.encodeComponent(
    'Account email: ${userEmail.isEmpty ? '<add your account email>' : userEmail}\n'
    'Full name: <add your full name>\n'
    'Request: Please delete my UfficioFacile account and associated app data where legally possible.\n',
  );
  return 'mailto:${UfficcioFacileConfig.supportEmail}?subject=$subject&body=$body';
}

Future<void> openAccountDeletionSupportMail(
  BuildContext context,
  String userEmail,
) {
  return ExternalActionService.open(
    context,
    buildAccountDeletionSupportMailto(userEmail),
    ExternalValueKind.email,
    failureMessage: 'Could not open your email app for the deletion request.',
  );
}
