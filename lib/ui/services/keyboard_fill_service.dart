import 'dart:io';

import 'package:flutter/services.dart';

class KeyboardFillService {
  static const _channel = MethodChannel('com.example.keepassux/keyboard');

  bool get _supported => Platform.isAndroid;

  Future<void> setEntry({
    required String label,
    required String username,
    required String password,
  }) async {
    if (!_supported) return;
    await _channel.invokeMethod('setKeyboardEntry', {
      'label': label,
      'username': username,
      'password': password,
    });
  }

  Future<void> clear() async {
    if (!_supported) return;
    await _channel.invokeMethod('clearKeyboardEntry');
  }

  Future<bool> isEnabled() async {
    if (!_supported) return false;
    final result = await _channel.invokeMethod<bool>('isKeyboardEnabled');
    return result ?? false;
  }

  Future<void> openSettings() async {
    if (!_supported) return;
    await _channel.invokeMethod('openKeyboardSettings');
  }

  Future<void> showPicker() async {
    if (!_supported) return;
    await _channel.invokeMethod('showKeyboardPicker');
  }
}
