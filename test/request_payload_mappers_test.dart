import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/ufficio_product_services.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/premium_config.dart';

void main() {
  group('problem request insert payload', () {
    test('uses only production database columns', () {
      final payload = toProblemRequestInsertPayload(
        ProblemRequestRecord(
          id: 'problem-1',
          userId: 'user-1',
          userEmail: 'mario@example.com',
          categoryId: 'residence',
          subcategoryId: 'change-address',
          title: 'Need help changing address',
          description: 'Comune portal rejected my request.',
          city: 'Torino',
          region: 'Piemonte',
          urgency: 'urgent',
          language: 'Italian',
          attachmentPlaceholder: 'placeholder',
          status: ProblemRequestStatus.reviewing,
          isPremiumUser: true,
          sourcePage: '/life-admin/residence',
          createdAt: DateTime.utc(2026, 5, 13),
          updatedAt: DateTime.utc(2026, 5, 13),
        ),
      );

      expect(payload.keys.toSet(), problemRequestInsertColumns);
      expect(payload['email'], 'mario@example.com');
      expect(payload['category'], 'residence');
      expect(payload['problem_title'], 'Need help changing address');
      expect(
        payload['problem_description'],
        'Comune portal rejected my request.',
      );
      expect(payload['language_code'], 'it');
      expect(payload['status'], 'reviewing');
      expect(payload.containsKey('attachment_placeholder'), isFalse);
      expect(payload.containsKey('city'), isFalse);
      expect(payload.containsKey('source_page'), isFalse);
    });

    test('normalizes unsupported languages to english', () {
      final payload = toProblemRequestInsertPayload(
        ProblemRequestRecord(
          id: 'problem-2',
          userId: null,
          userEmail: null,
          categoryId: null,
          subcategoryId: 'permesso-renewal',
          title: 'Renewal problem',
          description: 'Need help',
          city: 'Torino',
          region: 'Piemonte',
          urgency: 'normal',
          language: 'Arabic',
          attachmentPlaceholder: null,
          status: ProblemRequestStatus.newRequest,
          isPremiumUser: false,
          sourcePage: '/life-admin/permits',
          createdAt: DateTime.utc(2026, 5, 13),
          updatedAt: DateTime.utc(2026, 5, 13),
        ),
      );

      expect(payload['category'], 'permesso-renewal');
      expect(payload['language_code'], 'en');
      expect(payload['status'], 'new');
    });
  });

  group('consultancy request insert payload', () {
    test('uses only production database columns', () {
      final payload = toConsultancyRequestInsertPayload(
        ConsultancyRequestRecord(
          id: 'consultancy-1',
          userId: 'user-2',
          userEmail: 'sara@example.com',
          fullName: 'Sara Rossi',
          categoryId: 'taxes',
          subcategoryId: 'partita-iva',
          problemType: 'Partita IVA setup',
          description: 'I need help choosing the right regime.',
          desiredResult: 'Understand the best option for freelancing.',
          city: 'Milano',
          region: 'Lombardia',
          documentsAvailable: 'Passport and codice fiscale',
          attachmentUrls: const <String>['https://example.com/file.pdf'],
          userPlan: UfficioPlan.premiumMonthly.name,
          paymentStatus: ConsultancyPaymentStatus.freeForPremium,
          status: ConsultancyRequestStatus.newRequest,
          sourcePage: '/life-admin/taxes',
          createdAt: DateTime.utc(2026, 5, 13),
          updatedAt: DateTime.utc(2026, 5, 13),
        ),
      );

      expect(payload.keys.toSet(), consultancyRequestInsertColumns);
      expect(payload['email'], 'sara@example.com');
      expect(payload['category'], 'taxes');
      expect(payload['subject'], 'Partita IVA setup');
      expect(payload['message'], 'I need help choosing the right regime.');
      expect(payload['language_code'], 'en');
      expect(payload['is_premium_snapshot'], isTrue);
      expect(payload['payment_status'], 'not_required');
      expect(payload['status'], 'new');
      expect(payload.containsKey('attachment_urls'), isFalse);
      expect(payload.containsKey('full_name'), isFalse);
      expect(payload.containsKey('source_page'), isFalse);
    });

    test('maps free request payment and waiting state safely', () {
      final payload = toConsultancyRequestInsertPayload(
        ConsultancyRequestRecord(
          id: 'consultancy-2',
          userId: null,
          userEmail: 'free@example.com',
          fullName: 'Free User',
          categoryId: null,
          subcategoryId: 'contracts',
          problemType: '',
          description: '',
          desiredResult: 'Need a one-shot consultation',
          city: 'Torino',
          region: 'Piemonte',
          documentsAvailable: '',
          userPlan: UfficioPlan.free.name,
          paymentStatus: ConsultancyPaymentStatus.waitingPayment,
          status: ConsultancyRequestStatus.waitingPayment,
          sourcePage: '/life-admin/contracts',
          createdAt: DateTime.utc(2026, 5, 13),
          updatedAt: DateTime.utc(2026, 5, 13),
        ),
      );

      expect(payload['category'], 'contracts');
      expect(payload['subject'], 'Need a one-shot consultation');
      expect(payload['message'], 'Need a one-shot consultation');
      expect(payload['is_premium_snapshot'], isFalse);
      expect(payload['payment_status'], 'pending');
      expect(payload['status'], 'waiting_user');
    });
  });

  group('frontend Supabase key usage', () {
    test('flutter client bootstrap uses anon key and not service role', () {
      final appConfig = File('lib/app/app_config.dart').readAsStringSync();
      final bootstrap = File(
        'lib/app/supabase_bootstrap.dart',
      ).readAsStringSync();

      expect(appConfig, contains('SUPABASE_ANON_KEY'));
      expect(appConfig, isNot(contains('SUPABASE_SERVICE_ROLE_KEY')));
      expect(bootstrap, contains('anonKey: config.supabaseAnonKey'));
      expect(bootstrap, isNot(contains('service_role')));
      expect(bootstrap, isNot(contains('SUPABASE_SERVICE_ROLE_KEY')));
    });
  });
}
