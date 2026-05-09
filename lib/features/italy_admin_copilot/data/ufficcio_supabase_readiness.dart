import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_config.dart';
import '../../../app/supabase_bootstrap.dart';
import '../domain/admin_copilot_profile.dart';
import '../domain/admin_request.dart';
import '../domain/generated_pack.dart';
import '../domain/life_admin_contact.dart';
import '../domain/life_admin_document.dart';
import '../domain/premium_config.dart';
import '../domain/reminder.dart';
import '../domain/request_status.dart';
import '../domain/sync_models.dart';
import '../domain/ufficcio_entitlement.dart';
import '../domain/ufficcio_feedback.dart';
import '../domain/ufficcio_user_settings.dart';
import '../domain/usage_event.dart';
import 'analytics_service.dart';
import 'local_storage_list_repository.dart';
import 'profile_repository.dart';
import 'request_repository.dart';

String _statusToDb(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    )
    .toLowerCase();

String _statusFromDb(String value) {
  if (!value.contains('_')) return value;
  final parts = value.split('_');
  if (parts.isEmpty) return value;
  return parts.first +
      parts
          .skip(1)
          .map((item) => item[0].toUpperCase() + item.substring(1))
          .join();
}

UfficioPlan _planFromDatabase(String? raw, {required bool premiumAccess}) {
  switch (raw) {
    case 'plus_monthly':
      return UfficioPlan.plusMonthly;
    case 'plus_yearly':
      return UfficioPlan.plusYearly;
    case 'premium_monthly':
      return UfficioPlan.premiumMonthly;
    case 'premium_yearly':
      return UfficioPlan.premiumYearly;
    case 'consultancy_one_shot':
      return UfficioPlan.consultancyOneShot;
    case 'admin_grant':
    case 'admin':
      return UfficioPlan.adminGrant;
    case 'lifetime':
      return UfficioPlan.lifetime;
    case 'trial':
      return UfficioPlan.trial;
    case 'premium':
      return premiumAccess ? UfficioPlan.premiumMonthly : UfficioPlan.pro;
    case 'pro':
      return UfficioPlan.pro;
    case 'consultant':
      return UfficioPlan.consultant;
    default:
      return UfficioPlan.free;
  }
}

String _planToDatabase(UfficioPlan plan) {
  switch (plan) {
    case UfficioPlan.free:
      return 'free';
    case UfficioPlan.plusMonthly:
      return 'plus_monthly';
    case UfficioPlan.plusYearly:
      return 'plus_yearly';
    case UfficioPlan.pro:
      return 'pro';
    case UfficioPlan.consultant:
      return 'consultant';
    case UfficioPlan.premiumMonthly:
      return 'premium_monthly';
    case UfficioPlan.premiumYearly:
      return 'premium_yearly';
    case UfficioPlan.consultancyOneShot:
      return 'consultancy_one_shot';
    case UfficioPlan.adminGrant:
      return 'admin_grant';
    case UfficioPlan.lifetime:
      return 'lifetime';
    case UfficioPlan.trial:
      return 'trial';
  }
}

extension AdminCopilotProfileSupabaseMapper on AdminCopilotProfile {
  Map<String, dynamic> toSupabaseJson({required String userId}) => {
    'user_id': userId,
    'full_name': fullName,
    'codice_fiscale': codiceFiscale,
    'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
    'nationality': nationality,
    'phone': phone,
    'email': email,
    'city': city,
    'address': address,
    'preferred_language': preferredLanguage,
    'has_spid': hasSpid,
    'has_cie': hasCie,
    'has_pec': hasPec,
    'student_status': studentStatus,
    'university_name': universityName,
    'matricola': matricola,
    'work_status': workStatus,
    'employer_name': employerName,
    'contract_type': contractType,
    'house_status': houseStatus,
    'landlord_name': landlordName,
    'electricity_provider': electricityProvider,
    'gas_provider': gasProvider,
    'internet_provider': internetProvider,
    'default_asl': defaultAsl,
    'default_comune': defaultComune,
    'default_patronato': defaultPatronato,
    'notes': notes,
  };

  static AdminCopilotProfile fromSupabaseJson(Map<String, dynamic> json) {
    return AdminCopilotProfile(
      fullName: json['full_name'] as String?,
      codiceFiscale: json['codice_fiscale'] as String?,
      dateOfBirth: DateTime.tryParse(json['date_of_birth'] as String? ?? ''),
      nationality: json['nationality'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      hasSpid: json['has_spid'] as bool? ?? false,
      hasCie: json['has_cie'] as bool? ?? false,
      hasPec: json['has_pec'] as bool? ?? false,
      studentStatus: json['student_status'] as String?,
      universityName: json['university_name'] as String?,
      matricola: json['matricola'] as String?,
      workStatus: json['work_status'] as String?,
      employerName: json['employer_name'] as String?,
      contractType: json['contract_type'] as String?,
      houseStatus: json['house_status'] as String?,
      landlordName: json['landlord_name'] as String?,
      electricityProvider: json['electricity_provider'] as String?,
      gasProvider: json['gas_provider'] as String?,
      internetProvider: json['internet_provider'] as String?,
      defaultAsl: json['default_asl'] as String?,
      defaultComune: json['default_comune'] as String?,
      defaultPatronato: json['default_patronato'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

extension ReminderSupabaseMapper on Reminder {
  Map<String, dynamic> toSupabaseJson({required String userId}) => {
    'id': id,
    'user_id': userId,
    'request_id': requestId,
    'local_id': id,
    'title': title,
    'reminder_date': reminderDate.toIso8601String().split('T').first,
    'reminder_type': _statusToDb(type.name),
    'priority': 'normal',
    'is_done': isDone,
    'created_at': createdAt.toIso8601String(),
    'updated_at': createdAt.toIso8601String(),
  };

  static Reminder fromSupabaseJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String? ?? '',
      requestId: json['request_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      reminderDate:
          DateTime.tryParse(json['reminder_date'] as String? ?? '') ??
          DateTime.now(),
      type: reminderTypeFromJson(
        _statusFromDb(json['reminder_type'] as String? ?? 'follow_up'),
      ),
      isDone: json['is_done'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

extension LifeAdminDocumentSupabaseMapper on LifeAdminDocument {
  Map<String, dynamic> toSupabaseJson({required String userId}) => {
    'id': id,
    'user_id': userId,
    'local_id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'has_document': hasDocument,
    'expiry_date': expiryDate?.toIso8601String().split('T').first,
    'file_name': fileName,
    'storage_path': localFilePath,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static LifeAdminDocument fromSupabaseJson(Map<String, dynamic> json) {
    return LifeAdminDocument(
      id: json['id'] as String? ?? '',
      type: lifeAdminDocumentTypeFromJson(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hasDocument: json['has_document'] as bool? ?? false,
      expiryDate: DateTime.tryParse(json['expiry_date'] as String? ?? ''),
      fileName: json['file_name'] as String?,
      localFilePath: json['storage_path'] as String?,
      notes: json['notes'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

extension LifeAdminContactSupabaseMapper on LifeAdminContact {
  Map<String, dynamic> toSupabaseJson({required String userId}) => {
    'id': id,
    'user_id': userId,
    'local_id': id,
    'type': type.name,
    'name': name,
    'email': email,
    'pec': pec,
    'phone': phone,
    'website': website,
    'address': address,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static LifeAdminContact fromSupabaseJson(Map<String, dynamic> json) {
    return LifeAdminContact(
      id: json['id'] as String? ?? '',
      type: lifeAdminContactTypeFromJson(json['type'] as String?),
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      pec: json['pec'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

extension GeneratedPackSupabaseMapper on GeneratedPack {
  Map<String, dynamic> toSupabaseJson({
    required String userId,
    required String requestId,
  }) => {
    'id': id,
    'user_id': userId,
    'request_id': requestId,
    'local_id': id,
    'version': 1,
    'subject': subject,
    'body_italian': bodyItalian,
    'body_pec_italian': bodyPecItalian,
    'short_message_italian': shortMessageItalian,
    'whatsapp_message_italian': whatsappMessageItalian,
    'whatsapp_follow_up_italian': whatsappFollowUpItalian,
    'follow_up_italian': followUpItalian,
    'strong_follow_up_italian': strongFollowUpItalian,
    'user_explanation': localizedExplanations,
    'attachment_checklist': attachmentChecklist
        .map((item) => item.toJson())
        .toList(),
    'next_steps': nextSteps,
    'warnings': warnings,
    'deadline_suggestions': deadlineSuggestions,
    'full_text': fullText,
    'quality_report': {'generated_at': updatedAt.toIso8601String()},
    'disclaimer_included': fullText.contains('Questo strumento'),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static GeneratedPack fromSupabaseJson(Map<String, dynamic> json) {
    final mapped = {
      'id': json['id'],
      'procedureId': '',
      'procedureTitle': '',
      'category': '',
      'status': 'generated',
      'priority': 'normal',
      'inputData': const <String, dynamic>{},
      'subject': json['subject'],
      'bodyItalian': json['body_italian'],
      'bodyPecItalian': json['body_pec_italian'],
      'shortMessageItalian': json['short_message_italian'],
      'whatsappMessageItalian': json['whatsapp_message_italian'],
      'whatsappFollowUpItalian': json['whatsapp_follow_up_italian'],
      'whatsappStrongFollowUpItalian': json['whatsapp_follow_up_italian'],
      'ultraShortSummaryItalian': json['short_message_italian'],
      'followUpItalian': json['follow_up_italian'],
      'strongFollowUpItalian': json['strong_follow_up_italian'],
      'userExplanationEnglish':
          (json['user_explanation'] as Map?)?['en'] as String? ?? '',
      'localizedExplanations': json['user_explanation'] ?? const {},
      'attachmentChecklist': json['attachment_checklist'] ?? const [],
      'nextSteps': json['next_steps'] ?? const [],
      'warnings': json['warnings'] ?? const [],
      'deadlineSuggestions': json['deadline_suggestions'] ?? const [],
      'fullText': json['full_text'],
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
    };
    return GeneratedPack.fromJson(Map<String, dynamic>.from(mapped));
  }
}

extension AdminRequestSupabaseMapper on AdminCopilotRequest {
  Map<String, dynamic> toSupabaseJson({required String userId}) => {
    'id': id,
    'user_id': userId,
    'local_id': id,
    'procedure_id': procedureId,
    'procedure_title': procedureTitle,
    'category': category,
    'subcategory': null,
    'status': _statusToDb(status.name),
    'priority': priority.name,
    'input_data': inputData,
    'readiness': const {},
    'red_flags': const [],
    'recipient_name': recipientName,
    'recipient_email': recipientEmail,
    'recipient_pec': recipientPec,
    'subject': subject,
    'deadline_date': deadlineDate?.toIso8601String().split('T').first,
    'sent_at': sentAt?.toIso8601String(),
    'replied_at': repliedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static AdminCopilotRequest fromSupabaseJson(
    Map<String, dynamic> json, {
    GeneratedPack? generatedPack,
    List<Reminder> reminders = const [],
  }) {
    return AdminCopilotRequest(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      procedureId: json['procedure_id'] as String? ?? '',
      procedureTitle: json['procedure_title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: requestStatusFromJson(
        _statusFromDb(json['status'] as String? ?? 'generated'),
      ),
      priority: requestPriorityFromJson(json['priority'] as String?),
      inputData: Map<String, dynamic>.from(
        (json['input_data'] as Map?) ?? const <String, dynamic>{},
      ),
      generatedPack:
          generatedPack ??
          GeneratedPack.fromJson({
            'id': 'placeholder',
            'procedureId': json['procedure_id'] ?? '',
            'procedureTitle': json['procedure_title'] ?? '',
            'category': json['category'] ?? '',
            'status': 'generated',
            'priority': json['priority'] ?? 'normal',
            'inputData': const <String, dynamic>{},
            'subject': json['subject'] ?? '',
            'bodyItalian': '',
            'bodyPecItalian': '',
            'shortMessageItalian': '',
            'whatsappMessageItalian': '',
            'whatsappFollowUpItalian': '',
            'whatsappStrongFollowUpItalian': '',
            'ultraShortSummaryItalian': '',
            'followUpItalian': '',
            'strongFollowUpItalian': '',
            'userExplanationEnglish': '',
            'localizedExplanations': const <String, String>{},
            'attachmentChecklist': const [],
            'nextSteps': const [],
            'warnings': const [],
            'deadlineSuggestions': const [],
            'fullText': '',
            'createdAt': json['created_at'] ?? DateTime.now().toIso8601String(),
            'updatedAt': json['updated_at'] ?? DateTime.now().toIso8601String(),
          }),
      recipientName: json['recipient_name'] as String?,
      recipientEmail: json['recipient_email'] as String?,
      recipientPec: json['recipient_pec'] as String?,
      subject: json['subject'] as String? ?? '',
      deadlineDate: DateTime.tryParse(json['deadline_date'] as String? ?? ''),
      sentAt: DateTime.tryParse(json['sent_at'] as String? ?? ''),
      repliedAt: DateTime.tryParse(json['replied_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
      reminders: reminders,
      statusEvents: const [],
    );
  }
}

class UfficcioAnalyticsSanitizer {
  static const _blockedKeys = {
    'fullName',
    'codiceFiscale',
    'phone',
    'email',
    'address',
    'inputData',
    'generatedPack',
    'bodyItalian',
    'bodyPecItalian',
    'fullText',
    'documentName',
    'documentTitle',
    'complaintDetails',
    'contractNumber',
    'providerAccountNumber',
  };

  Map<String, dynamic> sanitize(Map<String, dynamic> metadata) {
    final output = <String, dynamic>{};
    metadata.forEach((key, value) {
      if (_blockedKeys.contains(key)) return;
      if (value is String && value.length > 120) {
        output[key] = value.substring(0, 120);
        return;
      }
      if (value is Map || value is List) return;
      output[key] = value;
    });
    return output;
  }
}

class SanitizedAnalyticsService implements AnalyticsService {
  SanitizedAnalyticsService(
    this._inner, {
    UfficcioAnalyticsSanitizer? sanitizer,
  }) : _sanitizer = sanitizer ?? UfficcioAnalyticsSanitizer();

  final AnalyticsService _inner;
  final UfficcioAnalyticsSanitizer _sanitizer;

  Future<void> trackRaw(
    String eventName, {
    String? procedureId,
    String? category,
    Map<String, dynamic> metadata = const {},
  }) async {
    final localRepo = _inner is LocalUsageEventsRepository ? _inner : null;
    if (localRepo == null) {
      return;
    }
    await localRepo.trackRaw(
      eventName,
      procedureId: procedureId,
      category: category,
      metadata: _sanitizer.sanitize(metadata),
    );
  }

  @override
  Future<void> trackCopilotOpened() => _inner.trackCopilotOpened();
  @override
  Future<void> trackPackCopied(String procedureId, String copyType) =>
      _inner.trackPackCopied(procedureId, copyType);
  @override
  Future<void> trackPackGenerated(String procedureId) =>
      _inner.trackPackGenerated(procedureId);
  @override
  Future<void> trackProcedureSelected(String procedureId) =>
      _inner.trackProcedureSelected(procedureId);
  @override
  Future<void> trackProcedureStarted(String procedureId) =>
      _inner.trackProcedureStarted(procedureId);
  @override
  Future<void> trackRequestSaved(String procedureId) =>
      _inner.trackRequestSaved(procedureId);
  @override
  Future<void> trackStatusUpdated(String status) =>
      _inner.trackStatusUpdated(status);
  @override
  Future<void> trackValidationFailed(String procedureId) =>
      _inner.trackValidationFailed(procedureId);
}

class UfficcioAuthState {
  const UfficcioAuthState({
    required this.isConfigured,
    required this.isAuthenticated,
    this.userId,
    this.email,
  });

  final bool isConfigured;
  final bool isAuthenticated;
  final String? userId;
  final String? email;
}

class UfficcioAuthFacade {
  const UfficcioAuthFacade(this.config);

  final UfficcioFacileConfig config;

  UfficcioAuthState get state {
    final client = SupabaseBootstrap.client;
    if (!config.isSupabaseEnabled || client == null) {
      return const UfficcioAuthState(
        isConfigured: false,
        isAuthenticated: false,
      );
    }
    final user = client.auth.currentUser;
    return UfficcioAuthState(
      isConfigured: true,
      isAuthenticated: user != null,
      userId: user?.id,
      email: user?.email,
    );
  }
}

abstract class UfficcioUserSettingsRepository {
  Future<UfficcioUserSettings> getSettings();
  Future<UfficcioUserSettings> saveSettings(UfficcioUserSettings settings);
}

class LocalUfficcioUserSettingsRepository
    implements UfficcioUserSettingsRepository {
  LocalUfficcioUserSettingsRepository(this._prefs);

  static const storageKey = 'ufficcio_user_settings_v1';
  final SharedPreferences _prefs;

  @override
  Future<UfficcioUserSettings> getSettings() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const UfficcioUserSettings();
    }
    try {
      return UfficcioUserSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const UfficcioUserSettings();
    }
  }

  @override
  Future<UfficcioUserSettings> saveSettings(
    UfficcioUserSettings settings,
  ) async {
    await _prefs.setString(storageKey, jsonEncode(settings.toJson()));
    return settings;
  }
}

class SupabaseUfficcioUserSettingsRepository
    implements UfficcioUserSettingsRepository {
  SupabaseUfficcioUserSettingsRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  @override
  Future<UfficcioUserSettings> getSettings() async {
    final row = await _client
        .from('ufficcio_user_settings')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    if (row == null) {
      return const UfficcioUserSettings();
    }
    return UfficcioUserSettings.fromJson({
      'id': row['id'],
      'userId': row['user_id'],
      'selectedLanguage': row['selected_language'],
      'onboardingCompleted': row['onboarding_completed'],
      'syncEnabled': row['sync_enabled'],
      'analyticsEnabled': row['analytics_enabled'],
      'betaModeEnabled': row['beta_mode_enabled'],
      'adminDebugEnabled': row['admin_debug_enabled'],
      'paywallEnabled': row['paywall_enabled'],
      'themeMode': row['theme_mode'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
    });
  }

  @override
  Future<UfficcioUserSettings> saveSettings(
    UfficcioUserSettings settings,
  ) async {
    final row = await _client
        .from('ufficcio_user_settings')
        .upsert({
          'user_id': _userId,
          'selected_language': settings.selectedLanguage,
          'onboarding_completed': settings.onboardingCompleted,
          'sync_enabled': settings.syncEnabled,
          'analytics_enabled': settings.analyticsEnabled,
          'beta_mode_enabled': settings.betaModeEnabled,
          'admin_debug_enabled': settings.adminDebugEnabled,
          'paywall_enabled': settings.paywallEnabled,
          'theme_mode': settings.themeMode,
        })
        .select()
        .single();
    return UfficcioUserSettings.fromJson({
      'id': row['id'],
      'userId': row['user_id'],
      'selectedLanguage': row['selected_language'],
      'onboardingCompleted': row['onboarding_completed'],
      'syncEnabled': row['sync_enabled'],
      'analyticsEnabled': row['analytics_enabled'],
      'betaModeEnabled': row['beta_mode_enabled'],
      'adminDebugEnabled': row['admin_debug_enabled'],
      'paywallEnabled': row['paywall_enabled'],
      'themeMode': row['theme_mode'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
    });
  }
}

class SupabaseAdminCopilotProfileRepository
    implements AdminCopilotProfileRepository {
  SupabaseAdminCopilotProfileRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  Future<String> _tableName() async {
    try {
      await _client.from('ufficio_profiles').select('user_id').limit(1);
      return 'ufficio_profiles';
    } on PostgrestException {
      return 'ufficcio_profiles';
    }
  }

  @override
  Future<void> clearProfile() async {
    final table = await _tableName();
    await _client.from(table).delete().eq('user_id', _userId);
  }

  @override
  Future<AdminCopilotProfile?> getProfile() async {
    final table = await _tableName();
    final row = await _client
        .from(table)
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    return row == null
        ? null
        : AdminCopilotProfileSupabaseMapper.fromSupabaseJson(row);
  }

  @override
  Future<AdminCopilotProfile> saveProfile(AdminCopilotProfile profile) async {
    final table = await _tableName();
    final row = await _client
        .from(table)
        .upsert(profile.toSupabaseJson(userId: _userId), onConflict: 'user_id')
        .select()
        .single();
    return AdminCopilotProfileSupabaseMapper.fromSupabaseJson(row);
  }
}

class SupabaseAdminCopilotRequestRepository
    implements AdminCopilotRequestRepository {
  SupabaseAdminCopilotRequestRepository(this._client, this._userId);

  final SupabaseClient _client;
  final String _userId;

  @override
  Future<AdminCopilotRequest> createRequest(AdminCopilotRequest request) async {
    await _client
        .from('ufficcio_requests')
        .upsert(request.toSupabaseJson(userId: _userId));
    await _client
        .from('ufficcio_generated_packs')
        .upsert(
          request.generatedPack.toSupabaseJson(
            userId: _userId,
            requestId: request.id,
          ),
        );
    for (final reminder in request.reminders) {
      await _client
          .from('ufficcio_reminders')
          .upsert(reminder.toSupabaseJson(userId: _userId));
    }
    return request;
  }

  @override
  Future<void> deleteRequest(String id) async {
    await _client
        .from('ufficcio_requests')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  @override
  Future<AdminCopilotRequest?> getRequest(String id) async {
    final rows = await _listJoined().then(
      (items) => items.where((item) => item.id == id).toList(),
    );
    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<List<AdminCopilotRequest>> listRequests() => _listJoined();

  Future<List<AdminCopilotRequest>> _listJoined() async {
    final requestRows = await _client
        .from('ufficcio_requests')
        .select()
        .eq('user_id', _userId)
        .isFilter('deleted_at', null);
    final packRows = await _client
        .from('ufficcio_generated_packs')
        .select()
        .eq('user_id', _userId)
        .isFilter('deleted_at', null);
    final reminderRows = await _client
        .from('ufficcio_reminders')
        .select()
        .eq('user_id', _userId)
        .isFilter('deleted_at', null);

    final packByRequest = <String, GeneratedPack>{};
    for (final row in packRows) {
      packByRequest[row['request_id']
          as String] = GeneratedPackSupabaseMapper.fromSupabaseJson(
        Map<String, dynamic>.from(row as Map),
      );
    }
    final remindersByRequest = <String, List<Reminder>>{};
    for (final row in reminderRows) {
      final reminder = ReminderSupabaseMapper.fromSupabaseJson(
        Map<String, dynamic>.from(row as Map),
      );
      remindersByRequest
          .putIfAbsent(reminder.requestId, () => [])
          .add(reminder);
    }
    return requestRows
        .map(
          (row) => AdminRequestSupabaseMapper.fromSupabaseJson(
            Map<String, dynamic>.from(row),
            generatedPack: packByRequest[row['id'] as String],
            reminders: remindersByRequest[row['id'] as String] ?? const [],
          ),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<AdminCopilotRequest> updateRequest(AdminCopilotRequest request) async {
    await createRequest(request);
    return request;
  }

  @override
  Future<AdminCopilotRequest> updateStatus(
    String id,
    RequestStatus status, {
    String? note,
  }) async {
    final request = await getRequest(id);
    if (request == null) {
      throw StateError('Request not found: $id');
    }
    final now = DateTime.now();
    final updated = request.copyWith(
      status: status,
      updatedAt: now,
      notes: note ?? request.notes,
    );
    await _client
        .from('ufficcio_requests')
        .update({
          'status': _statusToDb(status.name),
          'updated_at': now.toIso8601String(),
          'sent_at': status == RequestStatus.sent
              ? now.toIso8601String()
              : request.sentAt?.toIso8601String(),
          'replied_at': status == RequestStatus.replied
              ? now.toIso8601String()
              : request.repliedAt?.toIso8601String(),
          'completed_at': status == RequestStatus.completed
              ? now.toIso8601String()
              : request.completedAt?.toIso8601String(),
          'notes': note ?? request.notes,
        })
        .eq('id', id)
        .eq('user_id', _userId);
    await _client.from('ufficcio_status_events').insert({
      'user_id': _userId,
      'request_id': id,
      'old_status': _statusToDb(request.status.name),
      'new_status': _statusToDb(status.name),
      'event_type': 'status_change',
      'note': note,
      'metadata': const {},
    });
    return updated;
  }
}

class LocalUsageEventsRepository implements AnalyticsService {
  LocalUsageEventsRepository(
    this._repo, {
    UfficcioAnalyticsSanitizer? sanitizer,
  }) : _sanitizer = sanitizer ?? UfficcioAnalyticsSanitizer();

  final LocalStorageListRepository<UsageEvent> _repo;
  final UfficcioAnalyticsSanitizer _sanitizer;

  Future<void> trackRaw(
    String eventName, {
    String? procedureId,
    String? category,
    Map<String, dynamic> metadata = const {},
  }) async {
    final items = _repo.readAll();
    items.insert(
      0,
      UsageEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        eventName: eventName,
        procedureId: procedureId,
        category: category,
        metadata: _sanitizer.sanitize(metadata),
        createdAt: DateTime.now(),
      ),
    );
    await _repo.writeAll(items);
  }

  @override
  Future<void> trackCopilotOpened() => trackRaw('app_opened');
  @override
  Future<void> trackPackCopied(String procedureId, String copyType) => trackRaw(
    'pack_copied',
    procedureId: procedureId,
    metadata: {'copy_type': copyType},
  );
  @override
  Future<void> trackPackGenerated(String procedureId) =>
      trackRaw('pack_generated', procedureId: procedureId);
  @override
  Future<void> trackProcedureSelected(String procedureId) =>
      trackRaw('procedure_opened', procedureId: procedureId);
  @override
  Future<void> trackProcedureStarted(String procedureId) =>
      trackRaw('form_started', procedureId: procedureId);
  @override
  Future<void> trackRequestSaved(String procedureId) =>
      trackRaw('request_saved', procedureId: procedureId);
  @override
  Future<void> trackStatusUpdated(String status) =>
      trackRaw('status_updated', metadata: {'status': status});
  @override
  Future<void> trackValidationFailed(String procedureId) =>
      trackRaw('validation_failed', procedureId: procedureId);
}

class SupabaseUsageEventsRepository {
  SupabaseUsageEventsRepository(
    this._client,
    this._userId, {
    UfficcioAnalyticsSanitizer? sanitizer,
  }) : _sanitizer = sanitizer ?? UfficcioAnalyticsSanitizer();

  final SupabaseClient _client;
  final String _userId;
  final UfficcioAnalyticsSanitizer _sanitizer;

  Future<void> insertEvent(
    String eventName, {
    String? procedureId,
    String? category,
    String? requestId,
    Map<String, dynamic> metadata = const {},
  }) {
    return _client.from('ufficcio_usage_events').insert({
      'user_id': _userId,
      'event_name': eventName,
      'procedure_id': procedureId,
      'request_id': requestId,
      'category': category,
      'metadata': _sanitizer.sanitize(metadata),
    });
  }
}

class LocalFeedbackRepository {
  LocalFeedbackRepository(this._repo);
  final LocalStorageListRepository<UfficcioFeedback> _repo;

  Future<List<UfficcioFeedback>> list() async => _repo.readAll();
  Future<void> save(UfficcioFeedback feedback) async {
    final items = _repo.readAll()
      ..removeWhere((item) => item.id == feedback.id)
      ..add(feedback);
    await _repo.writeAll(items);
  }
}

class SupabaseFeedbackRepository {
  SupabaseFeedbackRepository(this._client, this._userId);
  final SupabaseClient _client;
  final String _userId;

  Future<void> save(UfficcioFeedback feedback) async {
    await _client.from('ufficcio_feedback').upsert({
      'id': feedback.id,
      'user_id': _userId,
      'category': feedback.category,
      'message': feedback.message,
      'rating': feedback.rating,
      'related_procedure_id': feedback.relatedProcedureId,
      'contact_email': feedback.contactEmail,
      'status': feedback.status,
    });
  }
}

abstract class UfficcioEntitlementRepository {
  Future<UfficcioEntitlement> getEntitlement();
  Future<UfficcioEntitlement> saveEntitlement(UfficcioEntitlement entitlement);
}

class LocalUfficcioEntitlementRepository
    implements UfficcioEntitlementRepository {
  LocalUfficcioEntitlementRepository(this._prefs);
  static const storageKey = 'ufficcio_entitlement_v1';
  final SharedPreferences _prefs;

  @override
  Future<UfficcioEntitlement> getEntitlement() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const UfficcioEntitlement();
    }
    try {
      return UfficcioEntitlement.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const UfficcioEntitlement();
    }
  }

  @override
  Future<UfficcioEntitlement> saveEntitlement(
    UfficcioEntitlement entitlement,
  ) async {
    await _prefs.setString(storageKey, jsonEncode(entitlement.toJson()));
    return entitlement;
  }
}

class SupabaseUfficcioEntitlementRepository
    implements UfficcioEntitlementRepository {
  SupabaseUfficcioEntitlementRepository(this._client, this._userId);
  final SupabaseClient _client;
  final String _userId;

  @override
  Future<UfficcioEntitlement> getEntitlement() async {
    final row = await _client
        .from('ufficio_user_entitlements')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    final isAdmin = await _client.rpc('is_ufficio_admin') == true;
    if (row == null) {
      return UfficcioEntitlement(
        userId: _userId,
        plan: isAdmin ? UfficioPlan.adminGrant : UfficioPlan.free,
        premiumAccess: isAdmin,
      );
    }
    final planName = row['plan'] as String? ?? 'free';
    final statusName = row['status'] as String? ?? 'active';
    final premiumAccess =
        row['premium_access'] as bool? ??
        (statusName == 'active' || statusName == 'trialing') &&
            <String>{
              'plus_monthly',
              'plus_yearly',
              'premium_monthly',
              'premium_yearly',
              'admin_grant',
              'lifetime',
              'trial',
              'pro',
              'admin',
            }.contains(planName);
    return UfficcioEntitlement.fromJson({
      'id': row['id'],
      'userId': row['user_id'],
      'plan': _planFromDatabase(
        isAdmin && planName == 'free' ? 'admin_grant' : planName,
        premiumAccess: premiumAccess || isAdmin,
      ).name,
      'status': _statusFromDb(statusName),
      'premiumAccess': premiumAccess || isAdmin,
      'source': row['source'],
      'currentPeriodStart': row['current_period_start'],
      'currentPeriodEnd': row['current_period_end'],
      'trialEnd': row['trial_end'],
      'cancelledAt': row['cancelled_at'],
      'revokedAt': row['revoked_at'],
      'provider': row['provider'] ?? row['source'],
      'providerCustomerId':
          row['provider_customer_id'] ?? row['stripe_customer_id'],
      'providerSubscriptionId':
          row['provider_subscription_id'] ?? row['stripe_subscription_id'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
    });
  }

  @override
  Future<UfficcioEntitlement> saveEntitlement(
    UfficcioEntitlement entitlement,
  ) async {
    try {
      final plan = _planToDatabase(entitlement.plan);
      final row = await _client
          .from('ufficio_user_entitlements')
          .upsert({
            'user_id': _userId,
            'plan': plan,
            'status': entitlement.status.name,
            'source': entitlement.source,
            'premium_access': entitlement.premiumAccess,
            'current_period_start': entitlement.currentPeriodStart
                ?.toIso8601String(),
            'current_period_end': entitlement.currentPeriodEnd
                ?.toIso8601String(),
            'trial_end': entitlement.trialEnd?.toIso8601String(),
            'cancelled_at': entitlement.cancelledAt?.toIso8601String(),
            'revoked_at': entitlement.revokedAt?.toIso8601String(),
            'provider': entitlement.provider,
            'provider_customer_id': entitlement.providerCustomerId,
            'provider_subscription_id': entitlement.providerSubscriptionId,
            'metadata': {
              'generatedPacksUsedThisMonth':
                  entitlement.generatedPacksUsedThisMonth,
            },
          })
          .select()
          .single();
      return UfficcioEntitlement.fromJson({
        'id': row['id'],
        'userId': row['user_id'],
        'plan': _planFromDatabase(
          row['plan'] as String? ?? plan,
          premiumAccess: row['premium_access'] as bool? ?? plan != 'free',
        ).name,
        'status': _statusFromDb(row['status'] as String? ?? 'active'),
        'premiumAccess': row['premium_access'] as bool? ?? plan != 'free',
        'source': row['source'],
        'currentPeriodStart': row['current_period_start'],
        'currentPeriodEnd': row['current_period_end'],
        'trialEnd': row['trial_end'],
        'cancelledAt': row['cancelled_at'],
        'revokedAt': row['revoked_at'],
        'provider': row['provider'] ?? row['source'],
        'providerCustomerId': row['provider_customer_id'],
        'providerSubscriptionId': row['provider_subscription_id'],
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
      });
    } catch (_) {
      return entitlement;
    }
  }
}

class UfficcioEntitlementService {
  UfficcioEntitlementService(this._repository, {required this.betaModeEnabled});

  final UfficcioEntitlementRepository _repository;
  final bool betaModeEnabled;

  Future<UfficcioEntitlement> getEntitlement() => _repository.getEntitlement();

  Future<bool> canGeneratePack() async {
    final entitlement = await _repository.getEntitlement();
    if (betaModeEnabled) return true;
    if (entitlement.premiumAccess || entitlement.plan != UfficioPlan.free) {
      return true;
    }
    return entitlement.freePacksUsed < entitlement.freePackLimit;
  }

  Future<UfficcioEntitlement> recordPackGenerated() async {
    final entitlement = await _repository.getEntitlement();
    final updated = entitlement.copyWith(
      freePacksUsed: entitlement.freePacksUsed + 1,
    );
    return _repository.saveEntitlement(updated);
  }

  Future<bool> canUseProcedure(String procedureId) async {
    final entitlement = await _repository.getEntitlement();
    if (betaModeEnabled) return true;
    return entitlement.premiumAccess || entitlement.plan != UfficioPlan.free
        ? true
        : procedureId.isNotEmpty;
  }

  Future<bool> canUseSync() async {
    final entitlement = await _repository.getEntitlement();
    return betaModeEnabled || entitlement.plan != UfficioPlan.free;
  }

  Future<bool> canUseDocumentVault() async {
    final entitlement = await _repository.getEntitlement();
    return betaModeEnabled || entitlement.plan != UfficioPlan.free;
  }

  Future<bool> canUseConsultantMode() async {
    final entitlement = await _repository.getEntitlement();
    return betaModeEnabled || entitlement.plan == UfficioPlan.consultant;
  }

  Future<String?> getUpgradeReason() async {
    final allowed = await canGeneratePack();
    return allowed ? null : 'Free pack limit reached.';
  }
}

class UfficcioRepositoryFactory {
  UfficcioRepositoryFactory({
    required this.config,
    required this.authFacade,
    required this.localProfileRepository,
    required this.localRequestRepository,
    required this.localSettingsRepository,
    required this.localEntitlementRepository,
    SupabaseClient? client,
  }) : _client = client;

  final UfficcioFacileConfig config;
  final UfficcioAuthFacade authFacade;
  final AdminCopilotProfileRepository localProfileRepository;
  final AdminCopilotRequestRepository localRequestRepository;
  final UfficcioUserSettingsRepository localSettingsRepository;
  final UfficcioEntitlementRepository localEntitlementRepository;
  final SupabaseClient? _client;

  SupabaseClient? get client => _client ?? SupabaseBootstrap.client;

  bool shouldUseSupabase({required bool syncEnabled}) {
    final auth = authFacade.state;
    return config.isSupabaseEnabled && auth.isAuthenticated && client != null;
  }

  AdminCopilotProfileRepository profileRepository({required bool syncEnabled}) {
    final auth = authFacade.state;
    if (!shouldUseSupabase(syncEnabled: syncEnabled) || auth.userId == null) {
      return localProfileRepository;
    }
    return SupabaseAdminCopilotProfileRepository(client!, auth.userId!);
  }

  AdminCopilotRequestRepository requestRepository({required bool syncEnabled}) {
    final auth = authFacade.state;
    if (!shouldUseSupabase(syncEnabled: syncEnabled) || auth.userId == null) {
      return localRequestRepository;
    }
    return SupabaseAdminCopilotRequestRepository(client!, auth.userId!);
  }

  UfficcioUserSettingsRepository settingsRepository({
    required bool syncEnabled,
  }) {
    final auth = authFacade.state;
    if (!shouldUseSupabase(syncEnabled: syncEnabled) || auth.userId == null) {
      return localSettingsRepository;
    }
    return SupabaseUfficcioUserSettingsRepository(client!, auth.userId!);
  }

  UfficcioEntitlementRepository entitlementRepository({
    required bool syncEnabled,
  }) {
    final auth = authFacade.state;
    if (!shouldUseSupabase(syncEnabled: syncEnabled) || auth.userId == null) {
      return localEntitlementRepository;
    }
    return SupabaseUfficcioEntitlementRepository(client!, auth.userId!);
  }
}

class MergedAdminCopilotProfileRepository
    implements AdminCopilotProfileRepository {
  MergedAdminCopilotProfileRepository({
    required this.factory,
    required this.settingsRepository,
    required this.localRepository,
    required this.authFacade,
  });

  final UfficcioRepositoryFactory factory;
  final UfficcioUserSettingsRepository settingsRepository;
  final AdminCopilotProfileRepository localRepository;
  final UfficcioAuthFacade authFacade;

  @override
  Future<void> clearProfile() async {
    await localRepository.clearProfile();
    final settings = await settingsRepository.getSettings();
    final remoteRepository = factory.profileRepository(
      syncEnabled: settings.syncEnabled,
    );
    if (!identical(remoteRepository, localRepository)) {
      try {
        await remoteRepository.clearProfile();
      } catch (_) {}
    }
  }

  @override
  Future<AdminCopilotProfile?> getProfile() async {
    final local = await localRepository.getProfile();
    final settings = await settingsRepository.getSettings();
    final remoteRepository = factory.profileRepository(
      syncEnabled: settings.syncEnabled,
    );
    if (identical(remoteRepository, localRepository)) {
      return local;
    }
    try {
      final remote = await remoteRepository.getProfile();
      if (remote != null) {
        await localRepository.saveProfile(remote);
        return _withAuthDefaults(remote);
      }
    } catch (_) {}
    return _withAuthDefaults(local);
  }

  @override
  Future<AdminCopilotProfile> saveProfile(AdminCopilotProfile profile) async {
    final normalized = _withAuthDefaults(profile);
    final localSaved = await localRepository.saveProfile(normalized);
    final settings = await settingsRepository.getSettings();
    final remoteRepository = factory.profileRepository(
      syncEnabled: settings.syncEnabled,
    );
    if (identical(remoteRepository, localRepository)) {
      return localSaved;
    }
    try {
      final remoteSaved = await remoteRepository.saveProfile(normalized);
      await localRepository.saveProfile(remoteSaved);
      return remoteSaved;
    } catch (_) {
      return localSaved;
    }
  }

  AdminCopilotProfile _withAuthDefaults(AdminCopilotProfile? profile) {
    final auth = authFacade.state;
    final next = profile ?? const AdminCopilotProfile();
    if ((next.email ?? '').trim().isNotEmpty || !auth.isAuthenticated) {
      return next;
    }
    return next.copyWith(email: auth.email);
  }
}

class MergedUfficcioEntitlementRepository
    implements UfficcioEntitlementRepository {
  MergedUfficcioEntitlementRepository({
    required this.factory,
    required this.settingsRepository,
    required this.localRepository,
  });

  final UfficcioRepositoryFactory factory;
  final UfficcioUserSettingsRepository settingsRepository;
  final UfficcioEntitlementRepository localRepository;

  @override
  Future<UfficcioEntitlement> getEntitlement() async {
    final local = await localRepository.getEntitlement();
    final settings = await settingsRepository.getSettings();
    final remoteRepository = factory.entitlementRepository(
      syncEnabled: settings.syncEnabled,
    );
    if (identical(remoteRepository, localRepository)) {
      return local;
    }
    try {
      final remote = await remoteRepository.getEntitlement();
      final merged = local.copyWith(
        plan: remote.plan,
        status: remote.status,
        premiumAccess: remote.premiumAccess,
        source: remote.source,
        provider: remote.provider,
        providerCustomerId: remote.providerCustomerId,
        providerSubscriptionId: remote.providerSubscriptionId,
        currentPeriodStart: remote.currentPeriodStart,
        currentPeriodEnd: remote.currentPeriodEnd,
        trialEnd: remote.trialEnd,
        cancelledAt: remote.cancelledAt,
        revokedAt: remote.revokedAt,
      );
      await localRepository.saveEntitlement(merged);
      return merged;
    } catch (_) {
      return local;
    }
  }

  @override
  Future<UfficcioEntitlement> saveEntitlement(UfficcioEntitlement entitlement) {
    return localRepository.saveEntitlement(entitlement);
  }
}

class UfficcioSyncService {
  UfficcioSyncService({
    required this.factory,
    required this.settingsRepository,
  });

  final UfficcioRepositoryFactory factory;
  final UfficcioUserSettingsRepository settingsRepository;
  SyncLogEntry? _lastLog;

  SyncLogEntry? get lastLog => _lastLog;

  Future<SyncStatus> getStatus() async {
    final settings = await settingsRepository.getSettings();
    final auth = factory.authFacade.state;
    if (!factory.config.isSupabaseEnabled) {
      return const SyncStatus(state: SyncStatusState.localOnly);
    }
    if (!settings.syncEnabled) {
      return const SyncStatus(state: SyncStatusState.disabled);
    }
    if (!auth.isAuthenticated) {
      return const SyncStatus(state: SyncStatusState.unavailable);
    }
    return SyncStatus(
      state: SyncStatusState.synced,
      lastSyncAt: _lastLog?.completedAt,
    );
  }

  Future<SyncStatus> syncAll() async {
    final start = DateTime.now();
    final status = await getStatus();
    if (status.state != SyncStatusState.synced) {
      return status;
    }
    _lastLog = SyncLogEntry(
      syncType: 'manual',
      status: 'completed',
      startedAt: start,
      completedAt: DateTime.now(),
    );
    return SyncStatus(
      state: SyncStatusState.synced,
      lastSyncAt: _lastLog?.completedAt,
    );
  }

  Future<AdminCopilotRequest> resolveConflict({
    required AdminCopilotRequest local,
    required AdminCopilotRequest remote,
  }) async {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      return local;
    }
    if ((local.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).isAfter(
      remote.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    )) {
      return local;
    }
    return remote;
  }

  AdminCopilotRequest resolveDeletedConflict({
    required AdminCopilotRequest local,
    required AdminCopilotRequest remote,
  }) {
    return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
  }

  void logFailure(String code, String message) {
    _lastLog = SyncLogEntry(
      syncType: 'manual',
      status: 'failed',
      startedAt: DateTime.now(),
      completedAt: DateTime.now(),
      errorCode: code,
      errorMessage: message,
    );
  }
}

class LocalPrivacyCenterService {
  LocalPrivacyCenterService(this._prefs);

  final SharedPreferences _prefs;

  static const trackedKeys = [
    'italy_life_admin_profile_v1',
    'ufficcio_user_settings_v1',
    'italy_life_admin_requests_v1',
    'italy_life_admin_drafts_v1',
    'italy_life_admin_documents_v1',
    'italy_life_admin_contacts_v1',
    'italy_life_admin_household_members_v1',
    'italy_life_admin_household_contracts_v1',
    'italy_life_admin_usage_events_v1',
    'italy_life_admin_proof_cases_v1',
    'italy_life_admin_proof_items_v1',
    'italy_life_admin_deadlines_v1',
    'italy_life_admin_templates_v1',
    'italy_life_admin_before_sending_v1',
    'ufficcio_entitlement_v1',
  ];

  Map<String, dynamic> exportData() {
    return {
      'profile': _prefs.getString('italy_life_admin_profile_v1'),
      'settings': _prefs.getString('ufficcio_user_settings_v1'),
      'requests': _prefs.getString('italy_life_admin_requests_v1'),
      'drafts': _prefs.getString('italy_life_admin_drafts_v1'),
      'documents': _prefs.getString('italy_life_admin_documents_v1'),
      'contacts': _prefs.getString('italy_life_admin_contacts_v1'),
      'householdMembers': _prefs.getString(
        'italy_life_admin_household_members_v1',
      ),
      'householdContracts': _prefs.getString(
        'italy_life_admin_household_contracts_v1',
      ),
      'usageEvents': _prefs.getString('italy_life_admin_usage_events_v1'),
      'proofCases': _prefs.getString('italy_life_admin_proof_cases_v1'),
      'proofItems': _prefs.getString('italy_life_admin_proof_items_v1'),
      'deadlines': _prefs.getString('italy_life_admin_deadlines_v1'),
      'templates': _prefs.getString('italy_life_admin_templates_v1'),
      'beforeSending': _prefs.getString('italy_life_admin_before_sending_v1'),
      'entitlement': _prefs.getString('ufficcio_entitlement_v1'),
    };
  }

  Future<void> deleteLocalData() async {
    for (final key in trackedKeys) {
      await _prefs.remove(key);
    }
  }

  Map<String, int> storageCounts() {
    int countList(String key) {
      final raw = _prefs.getString(key);
      if (raw == null || raw.isEmpty) return 0;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded.length;
      } catch (_) {}
      return 0;
    }

    return {
      'requests': countList('italy_life_admin_requests_v1'),
      'documents': countList('italy_life_admin_documents_v1'),
      'contacts': countList('italy_life_admin_contacts_v1'),
      'householdMembers': countList('italy_life_admin_household_members_v1'),
      'contracts': countList('italy_life_admin_household_contracts_v1'),
      'usageEvents': countList('italy_life_admin_usage_events_v1'),
    };
  }
}
