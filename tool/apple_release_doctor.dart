import 'dart:io';

void main() {
  final problems = <String>[];
  final warnings = <String>[];

  void expectFile(String path) {
    if (!File(path).existsSync()) {
      problems.add('Missing required file: $path');
    }
  }

  for (final path in const [
    'ios/Runner/Info.plist',
    'ios/Runner.xcodeproj/project.pbxproj',
    'ios/Flutter/Debug.xcconfig',
    'ios/Flutter/Release.xcconfig',
    'ios/Flutter/ReleaseDefaults.xcconfig',
    'docs/app_store/ios_release_checklist.md',
    'tool/apple_release_doctor.dart',
  ]) {
    expectFile(path);
  }

  final plist = File('ios/Runner/Info.plist').existsSync()
      ? File('ios/Runner/Info.plist').readAsStringSync()
      : '';
  final project = File('ios/Runner.xcodeproj/project.pbxproj').existsSync()
      ? File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync()
      : '';
  final readme = File('README.md').existsSync()
      ? File('README.md').readAsStringSync()
      : '';
  final deploymentDoc = File('docs/deployment_production.md').existsSync()
      ? File('docs/deployment_production.md').readAsStringSync()
      : '';
  final gitignore = File('.gitignore').existsSync()
      ? File('.gitignore').readAsStringSync()
      : '';

  if (project.contains('com.example.ufficiofacile')) {
    problems.add('iOS project still contains legacy com.example.ufficiofacile');
  }
  if (!project.contains('PRODUCT_BUNDLE_IDENTIFIER = it.ufficiofacile.app;')) {
    problems.add(
      'iOS Runner bundle identifier is not set to it.ufficiofacile.app',
    );
  }
  const googleSampleAdmobPrefix =
      'ca-app-pub-'
      '3940256099942544';
  if (plist.contains(googleSampleAdmobPrefix)) {
    problems.add(
      'iOS Info.plist still contains the Google sample AdMob app ID',
    );
  }
  if (!plist.contains(r'<string>$(ADMOB_APPLICATION_ID_IOS)</string>')) {
    problems.add(
      'iOS Info.plist is not using the ADMOB_APPLICATION_ID_IOS placeholder',
    );
  }
  if (!plist.contains('<string>ufficiofacile</string>')) {
    problems.add('iOS custom URL scheme ufficiofacile is missing');
  }
  if (!gitignore.contains('/ios/Flutter/AdMob.local.xcconfig')) {
    problems.add('.gitignore must ignore ios/Flutter/AdMob.local.xcconfig');
  }
  if (!readme.contains('flutter build ipa') ||
      !deploymentDoc.contains('flutter build ipa')) {
    problems.add(
      'README and deployment docs must include the iOS build command',
    );
  }
  if (!readme.contains('docs/app_store/ios_release_checklist.md')) {
    problems.add('README is missing the iOS App Store checklist link');
  }
  if (!deploymentDoc.contains('it.ufficiofacile.app')) {
    problems.add(
      'Deployment docs must mention the final iOS bundle identifier',
    );
  }

  for (final path in const [
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png',
    'web/icons/Icon-512.png',
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
  ]) {
    if (!File(path).existsSync()) {
      problems.add('Missing release icon asset: $path');
    }
  }

  if (File('ios/Flutter/AdMob.local.xcconfig').existsSync()) {
    warnings.add(
      'ios/Flutter/AdMob.local.xcconfig exists locally. Keep it untracked and review it before shipping.',
    );
  }

  if (problems.isEmpty) {
    stdout.writeln('Apple release doctor passed.');
  } else {
    stderr.writeln('Apple release doctor found issues:');
    for (final problem in problems) {
      stderr.writeln('- $problem');
    }
    exitCode = 1;
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final warning in warnings) {
      stdout.writeln('- $warning');
    }
  }
}
