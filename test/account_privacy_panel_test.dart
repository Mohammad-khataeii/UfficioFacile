import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/app/app_localizations.dart';
import 'package:ufficiofacile/features/auth/data/account_deletion_service.dart';
import 'package:ufficiofacile/features/auth/presentation/account_privacy_panel.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return AppLocalizationsScope(
      localizations: AppLocalizations('en'),
      child: MaterialApp(
        home: Scaffold(
          body: ListView(padding: const EdgeInsets.all(16), children: [child]),
        ),
      ),
    );
  }

  testWidgets('panel shows account and privacy controls', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        AccountAndPrivacyPanel(
          email: 'user@example.com',
          isSignedIn: true,
          planLabel: 'Premium',
          onSignInOrCreate: () async {},
          onSignOut: () async {},
          onChangePassword: () async {},
          onOpenPrivacyCenter: () async {},
          onDeleteLocalData: () async {},
          onDeleteMyAccount: () async => const AccountDeletionResult.success(),
          onRequestDeletionByEmail: () async {},
          onDeletionCompleted: () async {},
        ),
      ),
    );

    expect(find.text('Account and privacy'), findsOneWidget);
    expect(find.text('Delete my account'), findsOneWidget);
    expect(find.text('Privacy center'), findsOneWidget);
    expect(find.text('Request deletion by email'), findsOneWidget);
  });

  testWidgets('delete action is gated when signed out', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        AccountAndPrivacyPanel(
          email: null,
          isSignedIn: false,
          planLabel: 'Free',
          onSignInOrCreate: () async {},
          onSignOut: () async {},
          onChangePassword: () async {},
          onOpenPrivacyCenter: () async {},
          onDeleteLocalData: () async {},
          onDeleteMyAccount: () async => const AccountDeletionResult.success(),
          onRequestDeletionByEmail: () async {},
          onDeletionCompleted: () async {},
        ),
      ),
    );

    final deleteButton = find.widgetWithText(FilledButton, 'Delete my account');
    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);
    expect(find.text('Sign in to delete your account.'), findsOneWidget);
  });

  testWidgets('delete button opens the existing delete dialog', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        AccountAndPrivacyPanel(
          email: 'user@example.com',
          isSignedIn: true,
          planLabel: 'Premium',
          onSignInOrCreate: () async {},
          onSignOut: () async {},
          onChangePassword: () async {},
          onOpenPrivacyCenter: () async {},
          onDeleteLocalData: () async {},
          onDeleteMyAccount: () async => const AccountDeletionResult.success(),
          onRequestDeletionByEmail: () async {},
          onDeletionCompleted: () async {},
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Delete my account'));
    await tester.pumpAndSettle();

    expect(find.text('Type DELETE to confirm'), findsOneWidget);
  });
}
