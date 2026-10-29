import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _healthInfo;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.baseUrl;
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    setState(() => _isChecking = true);
    final health = await ApiService.checkHealth();
    if (!mounted) return;
    setState(() {
      _healthInfo = health;
      _isChecking = false;
    });
  }

  Future<void> _saveUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      await AppConfig.saveBaseUrl(newUrl);
      _checkBackend();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend URL updated successfully.'),
          backgroundColor: AppTheme.accentTeal,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backend Connection Card
            const Text(
              'Backend API Connection',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'API Base Address',
                        prefixIcon: Icon(Icons.dns_rounded,
                            size: 20, color: AppTheme.accentTeal),
                        helperText:
                            'Android Emulator: http://10.0.2.2:8000\nPhysical Phone: http://<PC_LAN_IP>:8000\nHosted API: https://<service>.onrender.com',
                        helperMaxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveUrl,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: const Text('Save & Reconnect'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _checkBackend,
                          child: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Test Ping'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.surfaceLight),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _healthInfo != null && _healthInfo!['status'] == 'ok'
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: _healthInfo != null &&
                                  _healthInfo!['status'] == 'ok'
                              ? AppTheme.riskLow
                              : AppTheme.riskHigh,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _healthInfo != null &&
                                    _healthInfo!['status'] == 'ok'
                                ? 'Connected: Model: ${_healthInfo!['message_model_status']}'
                                : 'Backend Offline or Unreachable',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Privacy & Storage Philosophy',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Scan Privacy: Do not paste passwords, OTPs, or financial details into a scan. Message previews (up to 60 characters) are saved in local device history.\n'
                      '• Device-Local Account: Email and password sign-in currently stores account data on this device; it is not a production cloud identity system.\n'
                      '• Local History: Scan results are kept in SQLite on this device and are not synced to a cloud account.\n'
                      '• Non-Interactive URL Safety: Suspicious links are structurally analyzed; the server never downloads web files or follows redirects.\n'
                      '• Transparent Heuristics: All rules, signal triggers, and probabilities are exposed directly in the UI.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'System Limitations & Disclaimer',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: const Text(
                'Disclaimer: No automated detection system is 100% accurate. Cyber attackers continuously invent new homoglyphs, linguistic obfuscation tricks, and zero-day redirection paths. Always verify requests independently with your banking institution or service provider through official communication lines.',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
