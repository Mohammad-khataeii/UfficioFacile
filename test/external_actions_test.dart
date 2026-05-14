import 'package:flutter_test/flutter_test.dart';
import 'package:ufficiofacile/app/external_actions.dart';

void main() {
  group('ExternalActionService', () {
    test('builds https url for bare websites', () {
      final uri = ExternalActionService.uriFor(
        'www.comune.torino.it',
        ExternalValueKind.website,
      );
      expect(uri?.toString(), 'https://www.comune.torino.it');
    });

    test('builds google maps search url for addresses', () {
      final uri = ExternalActionService.uriFor(
        'Via Roma 1, Torino',
        ExternalValueKind.address,
      );
      expect(
        uri?.toString(),
        contains('https://www.google.com/maps/search/?api=1&query='),
      );
      expect(uri?.toString(), contains('Via%20Roma%201%2C%20Torino'));
    });

    test('builds mailto uri for email and pec', () {
      expect(
        ExternalActionService.uriFor(
          'info@example.com',
          ExternalValueKind.email,
        )?.toString(),
        'mailto:info@example.com',
      );
      expect(
        ExternalActionService.uriFor(
          'protocollo@pec.example.it',
          ExternalValueKind.pec,
        )?.toString(),
        'mailto:protocollo@pec.example.it',
      );
    });

    test('builds tel uri for phones', () {
      final uri = ExternalActionService.uriFor(
        '+39 011 123 4567',
        ExternalValueKind.phone,
      );
      expect(uri?.toString(), 'tel:+390111234567');
    });

    test('auto mode detects web and email text', () {
      expect(
        ExternalActionService.uriFor(
          'Official page: https://www.aslcittaditorino.it/',
          ExternalValueKind.auto,
        )?.toString(),
        'https://www.aslcittaditorino.it/',
      );
      expect(
        ExternalActionService.uriFor(
          'Write to support@example.com for help',
          ExternalValueKind.auto,
        )?.toString(),
        'mailto:support@example.com',
      );
    });
  });
}
