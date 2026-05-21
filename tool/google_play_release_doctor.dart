import 'dart:io';

const _requiredPlayDocs = <String>[
  'docs/play_store/google_play_release_checklist.md',
  'docs/play_store/data_safety_draft.md',
  'docs/play_store/privacy_policy_draft.md',
  'docs/play_store/reviewer_instructions.md',
  'docs/play_store/store_listing_draft.md',
  'docs/play_store/account_deletion.md',
  'docs/play_store/android_permissions.md',
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

void main() {
  final problems = <String>[];
  final warnings = <String>[];

  void expectFile(String path) {
    if (!File(path).existsSync()) {
      problems.add('Missing required file: $path');
    }
  }

  for (final path in _requiredPlayDocs) {
    expectFile(path);
  }

  final gradleFile = File('android/app/build.gradle.kts');
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  final pubspecFile = File('pubspec.yaml');
  final readmeFile = File('README.md');
  final gitignoreFile = File('.gitignore');

  if (!gradleFile.existsSync()) {
    problems.add('Missing android/app/build.gradle.kts');
  }
  if (!manifestFile.existsSync()) {
    problems.add('Missing android/app/src/main/AndroidManifest.xml');
  }
  if (!pubspecFile.existsSync()) {
    problems.add('Missing pubspec.yaml');
  }

  final gradle = gradleFile.existsSync() ? gradleFile.readAsStringSync() : '';
  final manifest = manifestFile.existsSync()
      ? manifestFile.readAsStringSync()
      : '';
  final pubspec = pubspecFile.existsSync()
      ? pubspecFile.readAsStringSync()
      : '';
  final readme = readmeFile.existsSync() ? readmeFile.readAsStringSync() : '';
  final gitignore = gitignoreFile.existsSync()
      ? gitignoreFile.readAsStringSync()
      : '';

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
    r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+\+[0-9]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (versionMatch == null) {
    problems.add('pubspec.yaml version must include versionName+versionCode');
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
      !readme.contains('docs/play_store/privacy_policy_draft.md')) {
    problems.add('README is missing required Play Store documentation links');
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

  if (File('android/key.properties').existsSync()) {
    warnings.add(
      'android/key.properties exists locally; verify it is untracked before sharing',
    );
  }

  final clientDirs = <String>['lib', 'android'];
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

  final testIdHits = _scanDir(Directory('lib'), const [
    'ca-app-pub-3940256099942544',
    '6300978111',
    '2934735716',
  ]).where((hit) => !hit.contains('ads_service.dart')).toList();
  for (final hit in testIdHits) {
    problems.add(
      'Google test AdMob ID remains outside guarded ads service logic: $hit',
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
  };
  return allowedExtensions.any(path.endsWith);
}
