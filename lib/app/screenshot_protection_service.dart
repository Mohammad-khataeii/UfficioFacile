import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenshotProtectionService {
  static const MethodChannel _channel = MethodChannel(
    'ufficiofacile/screen_protection',
  );

  bool? _lastEnabled;

  Future<void> setFreeAccountProtectionEnabled(bool enabled) async {
    if (kIsWeb || _lastEnabled == enabled) {
      _lastEnabled = enabled;
      return;
    }
    _lastEnabled = enabled;
    try {
      await _channel.invokeMethod<void>('setSecureScreen', <String, dynamic>{
        'enabled': enabled,
      });
    } catch (_) {}
  }
}
