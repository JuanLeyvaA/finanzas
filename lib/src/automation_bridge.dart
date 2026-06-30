import 'package:flutter/services.dart';

class AutomationBridge {
  AutomationBridge._();

  static const MethodChannel _channel = MethodChannel('misfin/automation');

  static Future<String?> initialize(
    Future<void> Function(String text) onIncomingText,
  ) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'incomingText') {
        return;
      }

      final text = call.arguments as String?;
      if (text != null && text.trim().isNotEmpty) {
        await onIncomingText(text.trim());
      }
    });

    return consumePendingText();
  }

  static Future<String?> consumePendingText() async {
    try {
      final text = await _channel.invokeMethod<String>('consumePendingText');
      return text?.trim();
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
