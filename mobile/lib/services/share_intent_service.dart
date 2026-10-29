import 'package:flutter/services.dart';

/// Android text shares from messaging and browser apps.
class ShareIntentService {
  static const _methodChannel = MethodChannel('tracelens/share');
  static const _eventChannel = EventChannel('tracelens/share_events');

  static Stream<String> get sharedTexts => _eventChannel
      .receiveBroadcastStream()
      .where((value) => value is String && value.trim().isNotEmpty)
      .map((value) => value as String);

  static Future<String?> initialText() async {
    try {
      final value = await _methodChannel.invokeMethod<String>('getInitialText');
      return value?.trim().isEmpty == true ? null : value;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
