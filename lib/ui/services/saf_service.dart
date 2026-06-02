import 'package:flutter/services.dart';

class SafService {
  static const _channel = MethodChannel('com.example.keepassux/saf');

  Future<void> takePersistablePermission(String uri) async {
    try {
      await _channel.invokeMethod('takePersistableUriPermission', {'uri': uri});
    } catch (_) {}
  }
}
