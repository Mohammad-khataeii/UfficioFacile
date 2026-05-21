import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/features/auth/data/account_deletion_service.dart';
import 'package:ufficiofacile/features/auth/presentation/account_deletion_dialog.dart';

void main() {
  testWidgets('delete button stays disabled until DELETE is typed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeleteAccountDialog(
            onDeleteNow: () async => const AccountDeletionResult.success(),
            onEmailFallback: () async {},
          ),
        ),
      ),
    );

    final deleteButton = find.widgetWithText(FilledButton, 'Delete my account');
    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();

    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNotNull);
  });

  testWidgets('failed deletion shows email fallback', (tester) async {
    var deleteCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeleteAccountDialog(
            onDeleteNow: () async {
              deleteCalls += 1;
              return const AccountDeletionResult.failure(
                'Deletion is temporarily unavailable.',
              );
            },
            onEmailFallback: () async {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete my account'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 1);
    expect(find.text('Deletion is temporarily unavailable.'), findsOneWidget);
    expect(find.text('Email support instead'), findsOneWidget);
  });
}
