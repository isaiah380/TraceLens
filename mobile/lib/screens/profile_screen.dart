import 'package:flutter/material.dart';
import '../models/scan_history_item.dart';
import '../services/account_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_badge.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSignOut;
  const ProfileScreen({super.key, this.onOpenSettings, this.onSignOut});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ScanHistoryItem> _scans = [];
  String _name = '';
  String _email = '';
  String _provider = 'Email';
  String? _photo;
  String? _createdAt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final values = await Future.wait([
      AccountService.name,
      AccountService.email,
      AccountService.provider,
      AccountService.photoUrl,
      AccountService.createdAt,
      HistoryService.getHistory(),
    ]);
    if (!mounted) return;
    setState(() {
      _name = values[0] as String? ?? 'TraceLens user';
      _email = values[1] as String? ?? '';
      _provider = values[2] as String;
      _photo = values[3] as String?;
      _createdAt = values[4] as String?;
      _scans = values[5] as List<ScanHistoryItem>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final highRisk = _scans.where((scan) => ['high', 'critical'].contains(scan.riskLevel.toLowerCase())).length;
    final average = _scans.isEmpty ? 0 : (_scans.fold<int>(0, (sum, item) => sum + item.riskScore) / _scans.length).round();
    final joined = DateTime.tryParse(_createdAt ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          if (widget.onOpenSettings != null)
            IconButton(
              tooltip: 'Settings',
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          if (widget.onSignOut != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE7F1EE),
                          foregroundImage: _photo != null ? NetworkImage(_photo!) : null,
                          child: _photo == null ? const Icon(Icons.person_outline, size: 38, color: AppTheme.accentTeal) : null,
                        ),
                        const SizedBox(height: 12),
                        Text('Hi, $_name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        const SizedBox(height: 5),
                        Text(_email, style: const TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Column(children: [
                      _detail(Icons.verified_user_outlined, 'Sign-in method', _provider),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _detail(Icons.calendar_today_outlined, 'Member since', joined == null ? 'Date unavailable' : '${joined.day.toString().padLeft(2, '0')}/${joined.month.toString().padLeft(2, '0')}/${joined.year}'),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _detail(Icons.storage_outlined, 'History storage', 'This device only'),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  const Text('Your activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth > 520 ? 3 : 1;
                    final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
                    return Wrap(spacing: 12, runSpacing: 12, children: [
                      _stat(width, 'Total checks', '${_scans.length}', Icons.manage_search_outlined),
                      _stat(width, 'Higher risk', '$highRisk', Icons.warning_amber_outlined),
                      _stat(width, 'Average score', '$average / 100', Icons.analytics_outlined),
                    ]);
                  }),
                  const SizedBox(height: 22),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Recent checks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    if (_scans.isNotEmpty) TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())), child: const Text('View all')),
                  ]),
                  const SizedBox(height: 8),
                  if (_scans.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Your scan history will appear here after your first check.', style: TextStyle(color: AppTheme.textSecondary))))
                  else
                    ..._scans.take(5).map((scan) => Card(
                          margin: const EdgeInsets.only(bottom: 9),
                          child: ListTile(
                            leading: Icon(_iconForType(scan.scanType), color: AppTheme.accentTeal),
                            title: Text(scan.previewText, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('${scan.scanType.toUpperCase()} · ${scan.timestamp}\n${scan.briefExplanation}', maxLines: 2, overflow: TextOverflow.ellipsis),
                            isThreeLine: true,
                            trailing: RiskBadge(riskLevel: scan.riskLevel, showScore: false),
                          ),
                        )),
                  const SizedBox(height: 10),
                  const Text('Scan history is saved locally on this device and is not synced to a cloud account.', style: TextStyle(fontSize: 12, height: 1.45, color: AppTheme.textMuted)),
                ],
              ),
            ),
    );
  }

  Widget _detail(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      );

  Widget _stat(double width, String label, String value, IconData icon) => SizedBox(
        width: width,
        child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppTheme.accentTeal), const SizedBox(height: 14), Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))]))),
      );

  IconData _iconForType(String type) => switch (type.toLowerCase()) {
        'url' => Icons.link_outlined,
        'qr' => Icons.qr_code_2_outlined,
        _ => Icons.mark_email_unread_outlined,
      };
}
