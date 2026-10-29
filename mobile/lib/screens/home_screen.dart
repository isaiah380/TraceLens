import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/scan_history_item.dart';
import '../services/account_service.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';
import '../services/history_service.dart';
import '../services/share_intent_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import 'history_screen.dart';
import 'message_scanner_screen.dart';
import 'portal_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'url_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = 'there';
  List<ScanHistoryItem> _history = [];
  bool _backendOnline = false;
  StreamSubscription<String>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _refresh();
    _shareSubscription = ShareIntentService.sharedTexts.listen(_handleSharedText);
    ShareIntentService.initialText().then((text) {
      if (text != null) _handleSharedText(text);
    });
    AccountService.name.then((name) {
      if (mounted && name != null && name.trim().isNotEmpty) {
        setState(() => _userName = name.trim().split(' ').first);
      }
    });
  }

  void _handleSharedText(String text) {
    if (!mounted || text.trim().isEmpty) return;
    final shared = text.trim();
    final Widget scanner = Validators.isValidUrl(shared) ||
            shared.startsWith('http://') || shared.startsWith('https://')
        ? UrlScannerScreen(initialUrl: shared)
        : MessageScannerScreen(initialText: shared);
    _openScanner(scanner);
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final values = await Future.wait([
      HistoryService.getHistory(),
      ApiService.checkHealth(),
    ]);
    if (!mounted) return;
    final health = values[1] as Map<String, dynamic>;
    setState(() {
      _history = values[0] as List<ScanHistoryItem>;
      _backendOnline = health['status'] == 'ok';
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()));
    _refresh();
  }

  Future<void> _signOut() async {
    await GoogleAuthService.signOut();
    await AccountService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PortalScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = <Widget>[
      _OverviewTab(
        name: _userName,
        history: _history,
        backendOnline: _backendOnline,
        onRefresh: _refresh,
        onNavigate: (index) => setState(() => _selectedIndex = index),
        onScanMessage: () => _openScanner(const MessageScannerScreen()),
        onScanUrl: () => _openScanner(const UrlScannerScreen()),
        onScanQr: () => _openScanner(const QrScannerScreen()),
      ),
      _ScanTab(
        onScanMessage: () => _openScanner(const MessageScannerScreen()),
        onScanUrl: () => _openScanner(const UrlScannerScreen()),
        onScanQr: () => _openScanner(const QrScannerScreen()),
      ),
      HistoryScreen(key: ValueKey('history-${_history.length}')),
      const SafetyCenterScreen(),
      ProfileScreen(onOpenSettings: _openSettings, onSignOut: _signOut),
    ];

    final shell = Scaffold(
      appBar: _selectedIndex <= 1
          ? AppBar(
              title: Row(children: [
                const Icon(Icons.shield_outlined,
                    color: AppTheme.accentTeal, size: 22),
                const SizedBox(width: 9),
                Text(AppConfig.appName),
              ]),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Account options',
                  onSelected: (value) {
                    if (value == 'profile') setState(() => _selectedIndex = 4);
                    if (value == 'signout') _signOut();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'profile', child: Text('My profile')),
                    PopupMenuItem(value: 'signout', child: Text('Sign out')),
                  ],
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                if (index == 2) _refresh();
              },
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.manage_search_outlined),
                    selectedIcon: Icon(Icons.manage_search),
                    label: 'Check'),
                NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: 'Activity'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Learn'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile'),
              ],
            ),
    );

    if (!wide) return shell;
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
            if (index == 2) _refresh();
          },
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Icon(Icons.shield_outlined,
                color: AppTheme.accentTeal, size: 26),
          ),
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.home_outlined), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.manage_search_outlined), label: Text('Check')),
            NavigationRailDestination(
                icon: Icon(Icons.history_outlined), label: Text('Activity')),
            NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined), label: Text('Learn')),
            NavigationRailDestination(
                icon: Icon(Icons.person_outline), label: Text('Profile')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: shell),
      ]),
    );
  }

  Future<void> _openScanner(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _refresh();
  }
}

class _OverviewTab extends StatelessWidget {
  final String name;
  final List<ScanHistoryItem> history;
  final bool backendOnline;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onNavigate;
  final VoidCallback onScanMessage;
  final VoidCallback onScanUrl;
  final VoidCallback onScanQr;

  const _OverviewTab({
    required this.name,
    required this.history,
    required this.backendOnline,
    required this.onRefresh,
    required this.onNavigate,
    required this.onScanMessage,
    required this.onScanUrl,
    required this.onScanQr,
  });

  @override
  Widget build(BuildContext context) {
    final recent = history.take(3).toList();
    final elevated = history.where((item) =>
        ['high', 'critical'].contains(item.riskLevel.toLowerCase())).length;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Good to see you, $name',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('A calmer way to check suspicious messages and links.',
            style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                const Expanded(child: Text('Your protection activity',
                    style: TextStyle(fontWeight: FontWeight.w700))),
                Icon(backendOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                    size: 19, color: backendOnline ? AppTheme.riskLow : AppTheme.textMuted),
                const SizedBox(width: 5),
                Text(backendOnline ? 'Connected' : 'Offline',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _metric('Checks', '${history.length}'),
                const SizedBox(width: 26),
                _metric('High risk', '$elevated'),
                const SizedBox(width: 26),
                _metric('Saved on', 'This device'),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Start a safety check', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          TextButton(onPressed: () => onNavigate(1), child: const Text('All checks')),
        ]),
        _ActionTile(icon: Icons.message_outlined, title: 'Check a message',
            subtitle: 'SMS, chat messages or email', onTap: onScanMessage),
        const SizedBox(height: 9),
        _ActionTile(icon: Icons.link_outlined, title: 'Check a link',
            subtitle: 'Inspect the address before opening it', onTap: onScanUrl),
        const SizedBox(height: 9),
        _ActionTile(icon: Icons.qr_code_2_outlined, title: 'Check a QR code',
            subtitle: 'Scan a code and review its destination', onTap: onScanQr),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Recent activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          if (history.isNotEmpty)
            TextButton(onPressed: () => onNavigate(2), child: const Text('View all')),
        ]),
        if (recent.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(18),
              child: Text('Your checks will appear here. Start with a message, link or QR code.',
                  style: TextStyle(color: AppTheme.textSecondary))))
        else
          ...recent.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(item.scanType == 'url' ? Icons.link_outlined :
                      item.scanType == 'qr' ? Icons.qr_code_2_outlined : Icons.message_outlined,
                      color: AppTheme.accentTeal),
                  title: Text(item.previewText, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${item.scanType.toUpperCase()} · ${item.timestamp}'),
                  trailing: Text('${item.riskScore}/100', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              )),
        const SizedBox(height: 18),
        const Text('A result is a helpful signal, not a guarantee. Confirm important requests directly with the organization using contact details you already trust.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.45)),
      ]),
    );
  }

  Widget _metric(String label, String value) => Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]));
}

class _ScanTab extends StatelessWidget {
  final VoidCallback onScanMessage;
  final VoidCallback onScanUrl;
  final VoidCallback onScanQr;

  const _ScanTab({required this.onScanMessage, required this.onScanUrl, required this.onScanQr});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Text('What would you like to check?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Choose a check. TraceLens explains the signals it finds and suggests safer next steps.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4)),
        const SizedBox(height: 20),
        _ActionTile(icon: Icons.message_outlined, title: 'Message or email',
            subtitle: 'Check for impersonation, pressure and requests for sensitive information.', onTap: onScanMessage),
        const SizedBox(height: 12),
        _ActionTile(icon: Icons.link_outlined, title: 'Web link',
            subtitle: 'Review suspicious domains and link structure without visiting the site.', onTap: onScanUrl),
        const SizedBox(height: 12),
        _ActionTile(icon: Icons.qr_code_2_outlined, title: 'QR code',
            subtitle: 'Read the destination first, then assess its link.', onTap: onScanQr),
        const SizedBox(height: 22),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text(
          'TraceLens does not open suspicious links. Avoid sharing passwords, one-time codes or payment details in the scanner.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
        ))),
      ]);
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFFEAF2EF), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppTheme.accentTeal),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.35))),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ),
      );
}

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Safety guide')),
        body: ListView(padding: const EdgeInsets.all(20), children: const [
          Text('Common scam patterns', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('A practical guide to warning signs. This is educational content, not a live threat feed.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4)),
          SizedBox(height: 18),
          _GuideCard(icon: Icons.timer_outlined, title: 'Urgency and pressure',
              body: 'A caller or message insists you must act immediately, keep the conversation secret, or risk losing access or money.'),
          SizedBox(height: 10),
          _GuideCard(icon: Icons.password_outlined, title: 'Requests for codes or credentials',
              body: 'Never share a one-time code, password, recovery phrase or remote-access permission with someone who contacts you.'),
          SizedBox(height: 10),
          _GuideCard(icon: Icons.account_balance_outlined, title: 'Unexpected payments',
              body: 'Pause when asked to pay by gift card, cryptocurrency, wire transfer, or a new bank account to resolve a surprise problem.'),
          SizedBox(height: 10),
          _GuideCard(icon: Icons.link_outlined, title: 'Lookalike links',
              body: 'Read the actual domain carefully. Do not trust a familiar logo or display name by itself, and do not sign in from an unsolicited link.'),
          SizedBox(height: 10),
          _GuideCard(icon: Icons.support_agent_outlined, title: 'If you already responded',
              body: 'Stop contact. Call your bank or service using a number from its official app or card, change exposed passwords, and report through your local official cybercrime or carrier channel.'),
          SizedBox(height: 18),
          Card(child: Padding(padding: EdgeInsets.all(16), child: Text(
            'Safer habit: pause, verify through a contact method you found independently, and ask someone you trust before sending money or sharing access.',
            style: TextStyle(fontWeight: FontWeight.w600, height: 1.45),
          ))),
        ]),
      );
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _GuideCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppTheme.accentTeal, size: 21),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: AppTheme.textSecondary, height: 1.4, fontSize: 13)),
          ])),
        ]),
      ));
}
