import '../../../app/app_config.dart';
import '../../../app/supabase_bootstrap.dart';
import '../domain/insurance_finder.dart';

class InsuranceFinderService {
  const InsuranceFinderService({required this.config});

  final UfficcioFacileConfig config;

  Future<InsuranceSearchResult> search(InsuranceSearchInput input) async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (!config.isSupabaseEnabled || client == null) {
      return _unavailable(
        'Live offers are unavailable because the backend is not active in this build.',
      );
    }
    if (user == null) {
      return _unavailable('Sign in to run the live insurance comparison.');
    }
    try {
      final response = await client.functions.invoke(
        'insurance-finder',
        body: input.toJson(),
      );
      final data = response.data;
      if (data is Map) {
        return InsuranceSearchResult.fromJson(Map<String, dynamic>.from(data));
      }
      return _unavailable(
        'Live offers are temporarily unavailable. Check the official sources below and verify policy wording before buying.',
      );
    } catch (_) {
      return _unavailable(
        'Live offers are temporarily unavailable. Verify SSN and private-insurance conditions directly on the official websites before paying.',
      );
    }
  }

  InsuranceSearchResult _unavailable(String reason) => InsuranceSearchResult(
    ok: true,
    liveAvailable: false,
    offers: const <InsuranceOffer>[],
    warnings: const <String>[
      'Private insurance may not replace SSN/ASL registration for every situation.',
      'Verify the policy wording and the requirement of your university, Questura, employer, or ASL before buying.',
    ],
    retrievedAt: DateTime.now().toUtc(),
    unavailableReason: reason,
  );
}
