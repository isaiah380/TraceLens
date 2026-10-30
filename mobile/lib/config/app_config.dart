import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized configuration for TraceLens Mobile
class AppConfig {
  static const String _savedBaseUrlKey = 'api_base_url';
  /// Default backend URL:
  /// - Web / Desktop / Localhost: 'http://127.0.0.1:8000'
  /// - Android Emulator loopback: 'http://10.0.2.2:8000'
  /// - Physical Android device: replace with development PC's Wi-Fi LAN IP (e.g. 'http://192.168.1.15:8000')
  static String baseUrl = kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  static Future<void> loadSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_savedBaseUrlKey);
    if (saved != null && saved.isNotEmpty) baseUrl = saved;
  }

  static Future<void> saveBaseUrl(String url) async {
    final normalized = url.trim().replaceFirst(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedBaseUrlKey, normalized);
    baseUrl = normalized;
  }

  static const String appName = 'TraceLens';
  static const String tagline = 'Spot the scam before it gets you.';

  /// Set this to the Web OAuth client ID from Google Cloud Console.
  /// The same Web client ID can be passed as serverClientId on Android.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    // Keep Android APK builds working when the optional dart-define is omitted.
    // This must match the Web OAuth client configured for this app.
    defaultValue:
        '316031895940-2d9mkitnrg6pl3lrbgrnt3s8kup3vgt3.apps.googleusercontent.com',
  );

  // Request timeout duration
  static const Duration timeoutDuration = Duration(seconds: 12);
}
