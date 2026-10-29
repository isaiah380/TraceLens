import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _google = GoogleSignIn.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await _google.initialize(
      clientId: kIsWeb && AppConfig.googleWebClientId.isNotEmpty
          ? AppConfig.googleWebClientId
          : null,
      serverClientId: !kIsWeb && AppConfig.googleWebClientId.isNotEmpty
          ? AppConfig.googleWebClientId
          : null,
    );
    _initialized = true;
  }

  static Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _google.authenticationEvents;

  static Future<GoogleSignInAccount> signIn() async {
    await initialize();
    if (!_google.supportsAuthenticate()) {
      throw UnsupportedError(
        'Use the Google-provided sign-in button in the browser.',
      );
    }
    return _google.authenticate();
  }

  static Future<void> signOut() async {
    if (!_initialized) return;
    await _google.signOut();
  }
}
