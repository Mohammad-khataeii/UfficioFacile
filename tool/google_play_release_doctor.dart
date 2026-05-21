import 'dart:io';

const _requiredPlayDocs = <String>[
  'docs/play_store/google_play_release_checklist.md',
  'docs/play_store/data_safety_draft.md',
  'docs/play_store/privacy_policy_draft.md',
  'docs/play_store/reviewer_instructions.md',
  'docs/play_store/store_listing_draft.md',
  'docs/play_store/account_deletion.md',
  'docs/play_store/android_permissions.md',
  'docs/play_store/local_signing_step_by_step.md',
  'docs/play_store/play_console_copy.md',
  'docs/play_store/final_submission_checklist.md',
  'docs/privacy/account_deletion_data_map.md',
];

const _requiredTools = <String>[
  'tool/google_play_release_doctor.dart',
  'tool/print_google_play_commands.dart',
  'supabase/functions/delete-account/index.ts',
];

const _activeAndroidFiles = <String>[
  'android/app/build.gradle.kts',
  'android/app/src/main/AndroidManifest.xml',
  'android/app/src/main/kotlin/it/ufficiofacile/app/MainActivity.kt',
];

const _productionDocFiles = <String>[
  'README.md',
  'docs/deployment_production.md',
];

const _requiredPublicFiles = <String>[
  'web/privacy/index.html',
  'web/account-deletion/index.html',
];

const _forbiddenWrongAppFlags = <String>[
  'UFFICIOFACILE_ENABLE_BETA_MODE',
  'UFFICIOFACILE_ENABLE_PAYWALL',
  'UFFICIOFACILE_FLAVOR',
  'UFFICIOFACILE_ALLOW_LOCAL_FALLBACK',
  'UFFICIOFACILE_ENABLE_ANALYTICS',
  'UFFICIOFACILE_ENABLE_SYNC',
  'UFFICIOFACILE_ENABLE_ADMIN_DEBUG',
];

const _exampleChangeMeAllowlist = <String>[
  'android/key.properties.example',
  'docs/play_store/reviewer_instructions.md',
];

void main() {
  final problems = <String>[];
  final warnings = <String>[];

  void expectFile(String path) {
    if (!File(path).existsSync()) {
      problems.add('Missing required file: $path');
    }
  }

  for (final path in [..._requiredPlayDocs, ..._requiredTools]) {
    expectFile(path);
  }

  final gradleFile = File('android/app/build.gradle.kts');
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  final pubspecFile = File('pubspec.yaml');
  final readmeFile = File('README.md');
  final gitignoreFile = File('.gitignore');
  final keyExampleFile = File('android/key.properties.example');
  final privacyDraftFile = File('docs/play_store/privacy_policy_draft.md');
  final accountDeletionDocFile = File('docs/play_store/account_deletion.md');
  final deleteAccountFunctionFile = File(
    'supabase/functions/delete-account/index.ts',
  );
  final supabaseConfigFile = File('supabase/config.toml');
  final privacyPageFile = File('web/privacy/index.html');
  final accountDeletionPageFile = File('web/account-deletion/index.html');
  final readme = readmeFile.existsSync() ? readmeFile.readAsStringSync() : '';
  final gradle = gradleFile.existsSync() ? gradleFile.readAsStringSync() : '';
  final manifest = manifestFile.existsSync()
      ? manifestFile.readAsStringSync()
      : '';
  final pubspec = pubspecFile.existsSync()
      ? pubspecFile.readAsStringSync()
      : '';
  final gitignore = gitignoreFile.existsSync()
      ? gitignoreFile.readAsStringSync()
      : '';

  if (!keyExampleFile.existsSync()) {
    problems.add('Missing android/key.properties.example');
  }

  for (final path in _requiredPublicFiles) {
    expectFile(path);
  }
  for (final redirectPath in const [
    'web/delete-account/index.html',
    'web/ufficcio/privacy/index.html',
    'web/ufficio/privacy/index.html',
    'web/life-admin/privacy/index.html',
  ]) {
    if (!File(redirectPath).existsSync()) {
      warnings.add('Missing optional compatibility redirect: $redirectPath');
    }
  }

  for (final path in _activeAndroidFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      problems.add('Missing active Android file: $path');
      continue;
    }
    if (file.readAsStringSync().contains('com.example.ufficiofacile')) {
      problems.add('Legacy Android package remains in active file: $path');
    }
  }

  if (!gradle.contains('namespace = "it.ufficiofacile.app"')) {
    problems.add('Gradle namespace is not set to it.ufficiofacile.app');
  }
  if (!gradle.contains('applicationId = "it.ufficiofacile.app"')) {
    problems.add('Gradle applicationId is not set to it.ufficiofacile.app');
  }
  if (gradle.contains('signingConfigs.getByName("debug")')) {
    problems.add('Release build is still configured to use debug signing');
  }
  if (!gradle.contains('ANDROID_KEYSTORE_PATH') ||
      !gradle.contains('ANDROID_KEY_ALIAS') ||
      !gradle.contains('ANDROID_KEY_PASSWORD')) {
    problems.add('Release signing env fallback is incomplete in Gradle config');
  }
  if (!gradle.contains('targetSdk = maxOf(flutter.targetSdkVersion, 35)')) {
    problems.add('targetSdk is not explicitly enforced to 35 or higher');
  }
  if (!gradle.contains('compileSdk = maxOf(flutter.compileSdkVersion, 35)')) {
    warnings.add('compileSdk 35 floor could not be statically proven');
  }
  if (!gradle.contains('printAndroidReleaseInfo')) {
    problems.add('Missing printAndroidReleaseInfo Gradle verification task');
  }

  if (!manifest.contains('android:label="UfficioFacile"')) {
    problems.add('Android manifest label is missing or incorrect');
  }
  if (!manifest.contains('android:icon="@mipmap/ic_launcher"')) {
    problems.add('Android manifest icon declaration is missing');
  }
  if (!manifest.contains('android.permission.INTERNET')) {
    problems.add('Android manifest is missing INTERNET permission');
  }
  if (!manifest.contains('android.permission.POST_NOTIFICATIONS')) {
    warnings.add('POST_NOTIFICATIONS permission is absent');
  }
  for (final forbiddenPermission in const [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
  ]) {
    if (manifest.contains(forbiddenPermission)) {
      problems.add(
        'Unexpected sensitive permission present: $forbiddenPermission',
      );
    }
  }
  if (manifest.contains('ca-app-pub-3940256099942544')) {
    problems.add(
      'Production manifest still contains the Google sample AdMob app ID',
    );
  }
  if (!manifest.contains(r'${admobApplicationId}')) {
    problems.add('Android manifest is not using the AdMob placeholder value');
  }
  if (!manifest.contains('ufficiofacile') ||
      !manifest.contains('/confirm-email') ||
      !manifest.contains('/reset-password')) {
    problems.add('Android deep links are missing required auth redirect paths');
  }

  final versionMatch = RegExp(
    r'^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (versionMatch == null) {
    problems.add('pubspec.yaml version must include versionName+versionCode');
  } else {
    final versionCode = int.tryParse(versionMatch.group(4) ?? '') ?? 0;
    if (versionCode <= 1) {
      warnings.add(
        'pubspec versionCode is still $versionCode. Increase it before repeated internal testing uploads.',
      );
    }
  }

  for (final file in _productionDocFiles) {
    final text = File(file).existsSync() ? File(file).readAsStringSync() : '';
    if (!text.contains('flutter build appbundle')) {
      problems.add('Missing Android App Bundle build command in $file');
    }
    if (!text.contains('--dart-define=UFFICCIOFACILE_FLAVOR=production')) {
      problems.add('Missing production flavor dart-define in $file');
    }
  }

  if (!readme.contains('docs/play_store/google_play_release_checklist.md') ||
      !readme.contains('docs/play_store/data_safety_draft.md') ||
      !readme.contains('docs/play_store/privacy_policy_draft.md') ||
      !readme.contains('docs/play_store/local_signing_step_by_step.md') ||
      !readme.contains('docs/privacy/account_deletion_data_map.md') ||
      !readme.contains('docs/play_store/play_console_copy.md') ||
      !readme.contains('docs/play_store/final_submission_checklist.md')) {
    problems.add('README is missing required Play Store documentation links');
  }
  if (!readme.contains('https://ufficio-facile.vercel.app/privacy') ||
      !readme.contains('https://ufficio-facile.vercel.app/account-deletion')) {
    problems.add(
      'README is missing the public privacy or account deletion URL',
    );
  }

  final storeDocsText = _readFiles(_requiredPlayDocs);
  if (!readme.contains('docs/play_store/reviewer_instructions.md') ||
      !readme.contains('docs/play_store/store_listing_draft.md')) {
    warnings.add('README could link more Play Store drafts directly');
  }
  if (!storeDocsText.contains('Request account deletion') &&
      !storeDocsText.contains('Delete my account')) {
    problems.add(
      'Play Store docs do not mention the account deletion request path',
    );
  }
  final privacyDraft = privacyDraftFile.existsSync()
      ? privacyDraftFile.readAsStringSync()
      : '';
  if (!privacyDraft.contains('https://ufficio-facile.vercel.app/privacy')) {
    problems.add(
      'privacy_policy_draft.md must include the public privacy policy URL',
    );
  }
  final accountDeletionDoc = accountDeletionDocFile.existsSync()
      ? accountDeletionDocFile.readAsStringSync()
      : '';
  if (!accountDeletionDoc.contains(
    'https://ufficio-facile.vercel.app/account-deletion',
  )) {
    problems.add(
      'account_deletion.md must include the public account deletion URL',
    );
  }
  if (!accountDeletionDoc.contains('Delete my account') ||
      !accountDeletionDoc.contains('support@ufficiofacile.app')) {
    problems.add(
      'account_deletion.md must mention both self-service deletion and the email fallback',
    );
  }

  final privacyPage = privacyPageFile.existsSync()
      ? privacyPageFile.readAsStringSync()
      : '';
  if (!privacyPage.contains('Delete my account') ||
      !privacyPage.contains('Some payment, invoice') ||
      !privacyPage.contains('support@ufficiofacile.app')) {
    problems.add(
      'web/privacy/index.html must mention in-app deletion, retention, and the support fallback',
    );
  }
  final accountDeletionPage = accountDeletionPageFile.existsSync()
      ? accountDeletionPageFile.readAsStringSync()
      : '';
  if (!accountDeletionPage.contains('Delete my account') ||
      !accountDeletionPage.contains('DELETE') ||
      !accountDeletionPage.contains('support@ufficiofacile.app')) {
    problems.add(
      'web/account-deletion/index.html must mention self-service deletion and the email fallback',
    );
  }

  final supabaseConfig = supabaseConfigFile.existsSync()
      ? supabaseConfigFile.readAsStringSync()
      : '';
  if (!supabaseConfig.contains('[functions.delete-account]') ||
      !supabaseConfig.contains('verify_jwt = true')) {
    problems.add(
      'supabase/config.toml must configure delete-account with verify_jwt = true',
    );
  }
  if (supabaseConfig.contains(
        '[functions.delete-account]\nverify_jwt = false',
      ) ||
      supabaseConfig.contains(
        '[functions.delete-account]\r\nverify_jwt = false',
      )) {
    problems.add('delete-account must not disable verify_jwt');
  }

  for (final ignoredPath in const [
    '/android/key.properties',
    '*.jks',
    '*.keystore',
    'upload-keystore.jks',
  ]) {
    if (!gitignore.contains(ignoredPath)) {
      problems.add('.gitignore is missing $ignoredPath');
    }
  }

  final trackedSigningFiles = _gitLsFiles(const [
    'android/key.properties',
    '*.jks',
    '*.keystore',
    'upload-keystore.jks',
  ]);
  if (trackedSigningFiles.isNotEmpty) {
    problems.add(
      'Tracked signing artifact(s) found: ${trackedSigningFiles.join(', ')}',
    );
  }

  final keyPropertiesExists = File('android/key.properties').existsSync();
  if (keyPropertiesExists) {
    warnings.add(
      'android/key.properties exists locally; verify it stays untracked before sharing',
    );
  }

  final clientDirs = <String>['lib', 'android', 'web'];
  for (final dir in clientDirs) {
    final hits = _scanDir(Directory(dir), const [
      'SUPABASE_SERVICE_ROLE_KEY',
      'sk_live_',
      'rk_live_',
      'BEGIN PRIVATE KEY',
    ]);
    problems.addAll(
      hits.map((hit) => 'Potential secret found in client code: $hit'),
    );
  }

  final allTextHits = _scanDir(Directory.current, const [
    'ca-app-pub-3940256099942544',
    '6300978111',
    '2934735716',
  ]);
  for (final hit in allTextHits) {
    if (hit.contains('ads_service.dart') ||
        hit.contains('android/app/build.gradle.kts') ||
        hit.contains('tool/google_play_release_doctor.dart')) {
      continue;
    }
    problems.add(
      'Google test AdMob ID remains outside guarded allowlist: $hit',
    );
  }

  final adsServiceFile = File(
    'lib/features/italy_admin_copilot/data/ads_service.dart',
  );
  if (!adsServiceFile.existsSync()) {
    problems.add('Missing ads service implementation');
  } else {
    final adsService = adsServiceFile.readAsStringSync();
    if (!adsService.contains('if (!testMode)')) {
      problems.add(
        'Ads service can still fall back to test ad units without explicit test mode',
      );
    }
    if (!adsService.contains(
      'enabled: appConfig.isProduction ? wantsProductionAds : enabled',
    )) {
      problems.add(
        'Ads service does not disable production ads when real IDs are missing',
      );
    }
  }

  final privacyCenterFile = File(
    'lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart',
  );
  final accountScreenFile = File(
    'lib/features/auth/presentation/account_screen.dart',
  );
  final profileScreenFile = File(
    'lib/features/italy_admin_copilot/presentation/screens/connected_product_screens.dart',
  );
  final accountPrivacyPanelFile = File(
    'lib/features/auth/presentation/account_privacy_panel.dart',
  );
  final deleteAccountDialogFile = File(
    'lib/features/auth/presentation/account_deletion_dialog.dart',
  );
  if (!privacyCenterFile.existsSync()) {
    problems.add('Missing privacy center implementation file');
  } else {
    final privacyCenter = privacyCenterFile.readAsStringSync();
    if (!privacyCenter.contains('Delete my account') ||
        !privacyCenter.contains('Request deletion by email')) {
      problems.add(
        'Privacy center does not clearly implement self-service deletion and the support fallback',
      );
    }
  }
  if (!accountScreenFile.existsSync()) {
    problems.add('Missing account screen implementation file');
  } else {
    final accountScreen = accountScreenFile.readAsStringSync();
    if (!accountScreen.contains('AccountAndPrivacyPanelContainer') &&
        !accountScreen.contains('account_delete')) {
      problems.add(
        'Account screen is missing the shared account/privacy controls',
      );
    }
  }
  if (!deleteAccountDialogFile.existsSync()) {
    problems.add('DeleteAccountDialog implementation is missing');
  }
  if (!accountPrivacyPanelFile.existsSync()) {
    problems.add('Missing shared account/privacy panel implementation');
  } else {
    final panel = accountPrivacyPanelFile.readAsStringSync();
    if (!panel.contains('account_privacy_section_title') ||
        !panel.contains('account_delete_my_account')) {
      problems.add(
        'Shared account/privacy panel is missing the account/deletion UI copy',
      );
    }
  }
  if (!profileScreenFile.existsSync()) {
    problems.add('Missing connected profile screen implementation file');
  } else {
    final profileScreen = profileScreenFile.readAsStringSync();
    if (!profileScreen.contains('AccountAndPrivacyPanelContainer')) {
      problems.add(
        'Profile does not visibly include the shared account/privacy panel',
      );
    }
  }

  if (!deleteAccountFunctionFile.existsSync()) {
    problems.add('Missing delete-account Edge Function');
  } else {
    final deleteAccountFunction = deleteAccountFunctionFile.readAsStringSync();
    if (!deleteAccountFunction.contains("auth.admin.deleteUser")) {
      problems.add('delete-account function does not delete the auth user');
    }
    if (!deleteAccountFunction.contains('Authorization')) {
      problems.add('delete-account function does not verify the auth header');
    }
    if (deleteAccountFunction.contains('verify_jwt = false')) {
      problems.add(
        'delete-account function must not document verify_jwt = false',
      );
    }
  }

  final deploymentDoc = File('docs/deployment_production.md').existsSync()
      ? File('docs/deployment_production.md').readAsStringSync()
      : '';
  if (!deploymentDoc.contains('supabase functions deploy delete-account')) {
    problems.add(
      'docs/deployment_production.md must mention deploying delete-account',
    );
  }

  final wrongFlagHits = _scanWrongFlagUsage();
  if (wrongFlagHits.isNotEmpty) {
    problems.addAll(wrongFlagHits);
  }

  final changeMeProblems = _scanChangeMeMisuse();
  problems.addAll(changeMeProblems);
  problems.addAll(_scanDocsForJwtOrLiveAnonKey());

  if (problems.isNotEmpty) {
    stderr.writeln('Google Play release doctor failed:');
    for (final problem in problems) {
      stderr.writeln('- $problem');
    }
    if (warnings.isNotEmpty) {
      stderr.writeln('Warnings:');
      for (final warning in warnings) {
        stderr.writeln('- $warning');
      }
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Google Play release doctor passed.');
  if (warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final warning in warnings) {
      stdout.writeln('- $warning');
    }
  }
}

List<String> _scanWrongFlagUsage() {
  final hits = <String>[];
  for (final entity in Directory.current.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!_isTextLikeFile(path)) continue;
    if (path.contains('/build/') || path.contains('.dart_tool')) continue;
    if (path.endsWith('tool/google_play_release_doctor.dart')) continue;
    final text = entity.readAsStringSync();
    for (final wrongFlag in _forbiddenWrongAppFlags) {
      if (text.contains(wrongFlag)) {
        hits.add(
          'Wrong app-config dart-define prefix found in $path: `$wrongFlag`',
        );
      }
    }
  }
  return hits;
}

List<String> _scanChangeMeMisuse() {
  final hits = <String>[];
  for (final entity in Directory.current.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!_isTextLikeFile(path)) continue;
    if (path.contains('/build/') || path.contains('.dart_tool')) continue;
    final text = entity.readAsStringSync();
    if (!text.contains('CHANGE_ME')) continue;
    final allowed =
        path.contains('/docs/') ||
        _exampleChangeMeAllowlist.any(path.endsWith) ||
        path.endsWith('tool/google_play_release_doctor.dart');
    if (!allowed) {
      hits.add(
        'Unexpected `CHANGE_ME` placeholder outside example/docs allowlist: $path',
      );
    }
  }
  return hits;
}

List<String> _scanDocsForJwtOrLiveAnonKey() {
  final hits = <String>[];
  final jwtPattern = RegExp(
    r'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}',
  );
  for (final entity in Directory('docs').listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!_isTextLikeFile(path)) continue;
    final text = entity.readAsStringSync();
    if (jwtPattern.hasMatch(text)) {
      hits.add('Possible real JWT found in docs: $path');
    }
    final anonAssignments = RegExp(
      r'SUPABASE_ANON_KEY\s*=\s*([^\s`]+)',
    ).allMatches(text);
    for (final match in anonAssignments) {
      final value = match.group(1)?.trim() ?? '';
      if (value.isEmpty ||
          value == '...' ||
          value.contains('<') ||
          value.contains('CHANGE') ||
          value.contains('example') ||
          value.contains('YOUR_')) {
        continue;
      }
      hits.add(
        'SUPABASE_ANON_KEY example does not look like a placeholder in $path',
      );
    }
    final serviceAssignments = RegExp(
      r'SUPABASE_SERVICE_ROLE_KEY\s*=\s*([^\s`]+)',
    ).allMatches(text);
    for (final match in serviceAssignments) {
      final value = match.group(1)?.trim() ?? '';
      if (value.isEmpty ||
          value == '...' ||
          value.contains('<') ||
          value.contains('CHANGE') ||
          value.contains('example') ||
          value.contains('YOUR_')) {
        continue;
      }
      hits.add(
        'SUPABASE_SERVICE_ROLE_KEY example does not look like a placeholder in $path',
      );
    }
  }
  return hits;
}

String _readFiles(List<String> paths) {
  final buffer = StringBuffer();
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    buffer.writeln(file.readAsStringSync());
  }
  return buffer.toString();
}

List<String> _gitLsFiles(List<String> patterns) {
  final result = Process.runSync('git', ['ls-files', ...patterns]);
  if (result.exitCode != 0) {
    return const [];
  }
  final output = (result.stdout as String).trim();
  if (output.isEmpty) {
    return const [];
  }
  return output
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

List<String> _scanDir(Directory directory, List<String> needles) {
  if (!directory.existsSync()) return const [];
  final hits = <String>[];
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (path.contains('/build/') || path.contains('.dart_tool')) continue;
    if (!_isTextLikeFile(path)) continue;
    final text = entity.readAsStringSync();
    for (final needle in needles) {
      if (text.contains(needle)) {
        hits.add('$path contains `$needle`');
      }
    }
  }
  return hits;
}

bool _isTextLikeFile(String path) {
  const allowedExtensions = <String>{
    '.dart',
    '.kts',
    '.kt',
    '.java',
    '.xml',
    '.gradle',
    '.md',
    '.yaml',
    '.yml',
    '.properties',
    '.json',
    '.txt',
    '.toml',
    '.ts',
    '.html',
  };
  return allowedExtensions.any(path.endsWith);
}
