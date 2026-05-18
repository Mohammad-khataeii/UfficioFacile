import 'package:supabase_flutter/supabase_flutter.dart';

import 'premium_service.dart';

class PromoRedemptionResult {
  const PromoRedemptionResult({
    required this.ok,
    required this.message,
    this.plan,
    this.expiresAt,
  });

  final bool ok;
  final String message;
  final String? plan;
  final DateTime? expiresAt;
}

class PromoRedemptionRecord {
  const PromoRedemptionRecord({
    required this.id,
    required this.code,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String status;
  final String message;
  final DateTime createdAt;
}

class UfficioPromoCodeService {
  UfficioPromoCodeService({
    required SupabaseClient? client,
    required UfficioPremiumEntitlementService entitlementService,
  }) : _client = client,
       _entitlementService = entitlementService;

  final SupabaseClient? _client;
  final UfficioPremiumEntitlementService _entitlementService;

  bool get _isAuthenticated => _client?.auth.currentUser != null;

  Future<PromoRedemptionResult> redeem(String code) async {
    final client = _client;
    if (client == null || !_isAuthenticated) {
      return const PromoRedemptionResult(
        ok: false,
        message: 'Log in to redeem a code.',
      );
    }
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return const PromoRedemptionResult(
        ok: false,
        message: 'Enter a promo code first.',
      );
    }
    try {
      final result = await client.rpc(
        'redeem_ufficio_promo_code',
        params: {'input_code': trimmed},
      );
      final map = Map<String, dynamic>.from((result as Map?) ?? const {});
      await _entitlementService.getCurrentEntitlement();
      return PromoRedemptionResult(
        ok: map['ok'] == true,
        message:
            map['message'] as String? ??
            (map['ok'] == true ? 'Code applied.' : 'Code was not applied.'),
        plan: map['plan'] as String?,
        expiresAt: DateTime.tryParse(map['expires_at'] as String? ?? ''),
      );
    } catch (error) {
      return PromoRedemptionResult(
        ok: false,
        message: 'Could not redeem this code right now.',
      );
    }
  }

  Future<List<PromoRedemptionRecord>> listHistory() async {
    final client = _client;
    if (client == null || !_isAuthenticated) {
      return const <PromoRedemptionRecord>[];
    }
    try {
      final rows = await client
          .from('ufficio_promo_redemptions')
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return rows
          .map(
            (item) => PromoRedemptionRecord(
              id: item['id'] as String? ?? '',
              code: item['code'] as String? ?? '',
              status: item['status'] as String? ?? 'unknown',
              message:
                  item['message'] as String? ?? item['reason'] as String? ?? '',
              createdAt:
                  DateTime.tryParse(item['created_at'] as String? ?? '') ??
                  DateTime.now(),
            ),
          )
          .toList();
    } catch (_) {
      return const <PromoRedemptionRecord>[];
    }
  }
}
