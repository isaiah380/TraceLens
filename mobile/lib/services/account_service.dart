import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight, device-local account for the current standalone app.
/// Production deployments should replace this with a server-side identity provider.
class AccountService {
  static const _nameKey = 'account_name';
  static const _emailKey = 'account_email';
  static const _passwordKey = 'account_password';
  static const _sessionKey = 'account_signed_in';
  static const _providerKey = 'account_provider';
  static const _photoKey = 'account_photo';
  static const _createdKey = 'account_created';

  static Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_emailKey);
  }

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  static Future<String?> get name async => (await SharedPreferences.getInstance()).getString(_nameKey);
  static Future<String?> get email async => (await SharedPreferences.getInstance()).getString(_emailKey);
  static Future<String?> get photoUrl async => (await SharedPreferences.getInstance()).getString(_photoKey);
  static Future<String> get provider async => (await SharedPreferences.getInstance()).getString(_providerKey) ?? 'Email';
  static Future<String?> get createdAt async => (await SharedPreferences.getInstance()).getString(_createdKey);

  static Future<void> register({required String name, required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim());
    await prefs.setString(_emailKey, email.trim().toLowerCase());
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_providerKey, 'Email');
    await prefs.setString(_createdKey, DateTime.now().toIso8601String());
    await prefs.setBool(_sessionKey, true);
  }

  static Future<void> signInWithGoogle({required String name, required String email, String? photoUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email.toLowerCase());
    if (photoUrl != null) await prefs.setString(_photoKey, photoUrl);
    await prefs.setString(_providerKey, 'Google');
    if (!prefs.containsKey(_createdKey)) await prefs.setString(_createdKey, DateTime.now().toIso8601String());
    await prefs.setBool(_sessionKey, true);
  }

  static Future<bool> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final identifier = email.trim().toLowerCase();
    final savedEmail = prefs.getString(_emailKey)?.trim().toLowerCase();
    final savedName = prefs.getString(_nameKey)?.trim().toLowerCase();
    final identifierMatches = identifier == savedEmail || identifier == savedName;
    final valid = identifierMatches && prefs.getString(_passwordKey) == password;
    if (valid) await prefs.setBool(_sessionKey, true);
    return valid;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
  }
}
