import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/account_service.dart';
import '../services/google_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/google_sign_in_button.dart';
import 'home_screen.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  int _section = 0;

  void _openAuth({bool register = false}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AuthScreen(register: register)))
        .then((signedIn) {
      if (signedIn == true && mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _Brand(),
        actions: [
          if (MediaQuery.sizeOf(context).width > 650) ...[
            _NavAction(
                label: 'Overview',
                selected: _section == 0,
                onTap: () => setState(() => _section = 0)),
            _NavAction(
                label: 'How it works',
                selected: _section == 1,
                onTap: () => setState(() => _section = 1)),
            const SizedBox(width: 12),
          ],
          TextButton(
              onPressed: () => _openAuth(), child: const Text('Sign in')),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
                onPressed: () => _openAuth(register: true),
                child: const Text('Create account')),
          ),
        ],
      ),
      body: _section == 0 ? _overview() : _howItWorks(),
      bottomNavigationBar: MediaQuery.sizeOf(context).width <= 650
          ? NavigationBar(
              selectedIndex: _section,
              onDestinationSelected: (index) =>
                  setState(() => _section = index),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.shield_outlined), label: 'Overview'),
                NavigationDestination(
                    icon: Icon(Icons.fact_check_outlined),
                    label: 'How it works'),
              ],
            )
          : null,
    );
  }

  Widget _overview() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _hero(),
              const SizedBox(height: 48),
              const Text('A clearer way to check what feels off',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                  'Review messages, links and QR destinations before you respond or open them.',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width > 780 ? 3 : (width > 500 ? 2 : 1);
                return Wrap(spacing: 14, runSpacing: 14, children: [
                  _featureCard(
                      width: (width - (columns - 1) * 14) / columns,
                      icon: Icons.mark_email_unread_outlined,
                      title: 'Message checks',
                      description:
                          'Look for pressure tactics, credential requests and common phishing language.'),
                  _featureCard(
                      width: (width - (columns - 1) * 14) / columns,
                      icon: Icons.link_outlined,
                      title: 'Link checks',
                      description:
                          'Inspect suspicious domains without opening the destination.'),
                  _featureCard(
                      width: (width - (columns - 1) * 14) / columns,
                      icon: Icons.qr_code_2_outlined,
                      title: 'QR safety',
                      description:
                          'Read the destination behind a QR code before you visit it.'),
                ]);
              }),
              const SizedBox(height: 28),
              const Card(
                  child: Padding(
                      padding: EdgeInsets.all(22),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 22, color: AppTheme.accentTeal),
                            SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('Privacy comes first',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                                  SizedBox(height: 5),
                                  Text(
                                      'Scans are assessed for risk and explained in plain language. TraceLens does not follow suspicious links or ask for banking details, passwords or one-time codes.',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          height: 1.5))
                                ])),
                          ]))),
              const SizedBox(height: 26),
              Center(
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 14,
                      runSpacing: 10,
                      children: [
                    const Text('Ready to take a closer look?',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    ElevatedButton(
                        onPressed: () => _openAuth(register: true),
                        child: const Text('Get started')),
                  ])),
            ]),
          ),
        ),
      );

  Widget _hero() => LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 700;
        final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE7F1EE),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('PERSONAL DIGITAL SAFETY',
                      style: TextStyle(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.8))),
              const SizedBox(height: 18),
              const Text('Pause. Check.\nThen decide.',
                  style: TextStyle(
                      fontSize: 42,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.4,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 14),
              const Text(
                  'A practical safety portal for checking suspicious messages, links and QR codes before they catch you off guard.',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.55)),
              const SizedBox(height: 22),
              Wrap(spacing: 12, runSpacing: 10, children: [
                ElevatedButton(
                    onPressed: () => _openAuth(register: true),
                    child: const Text('Create your free account')),
                OutlinedButton(
                    onPressed: () => _openAuth(),
                    child: const Text('I already have an account'))
              ]),
              const SizedBox(height: 14),
              const Text('Understand the signals. Make your own call.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]);
        final visual = _heroIllustration();
        return Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 330),
            padding: EdgeInsets.all(narrow ? 22 : 36),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF3F2),
                borderRadius: BorderRadius.circular(20)),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        copy,
                        const SizedBox(height: 26),
                        SizedBox(height: 210, child: visual)
                      ])
                : Row(children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: 25),
                    Expanded(
                        flex: 5, child: SizedBox(height: 260, child: visual))
                  ]));
      });

  Widget _heroIllustration() => Stack(alignment: Alignment.center, children: [
        Container(
            decoration: BoxDecoration(
                color: const Color(0xFFDDE9E5),
                borderRadius: BorderRadius.circular(17))),
        Positioned(
            right: 28,
            top: 24,
            child: _signalCard(
                Icons.link_outlined, 'Link checked', 'No site opened')),
        Positioned(
            left: 25,
            bottom: 25,
            child: _signalCard(Icons.fact_check_outlined, 'Risk signals',
                'Explained clearly')),
        Container(
            width: 126,
            height: 142,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A243F38),
                      blurRadius: 24,
                      offset: Offset(0, 9))
                ]),
            child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined,
                      size: 57, color: AppTheme.accentTeal),
                  SizedBox(height: 8),
                  Text('TraceLens',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary))
                ])),
      ]);

  Widget _signalCard(IconData icon, String title, String subtitle) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x10243F38), blurRadius: 12, offset: Offset(0, 4))
          ]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: AppTheme.accentTeal),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.textSecondary))
        ])
      ]));

  Widget _featureCard(
          {required double width,
          required IconData icon,
          required String title,
          required String description}) =>
      SizedBox(
          width: width,
          child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: AppTheme.accentTeal, size: 22),
                        const SizedBox(height: 14),
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.45,
                                fontSize: 13))
                      ]))));

  Widget _howItWorks() => Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How TraceLens works',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    const Text(
                        'A little context can make a suspicious moment easier to handle.',
                        style: TextStyle(
                            fontSize: 15, color: AppTheme.textSecondary)),
                    const SizedBox(height: 22),
                    _step(
                        '01',
                        'Choose what to check',
                        'Paste a message or web address, or scan a QR code.',
                        Icons.input_outlined),
                    _step(
                        '02',
                        'Review the signals',
                        'TraceLens checks for common warning signs and shows why they may matter.',
                        Icons.manage_search_outlined),
                    _step(
                        '03',
                        'Make an informed choice',
                        'Use the risk assessment as a guide. When in doubt, contact the organisation through a known official channel.',
                        Icons.fact_check_outlined),
                    const SizedBox(height: 20),
                    const Card(
                        child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                                'No automated system can identify every new scam. A low risk result is not a guarantee that a message or site is safe.',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    height: 1.5)))),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () => _openAuth(register: true),
                        child: const Text('Create your account')),
                  ]))));

  Widget _step(
          String number, String title, String description, IconData icon) =>
      Card(
          margin: const EdgeInsets.only(top: 12),
          child: Padding(
              padding: const EdgeInsets.all(18),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(number,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentTeal)),
                const SizedBox(width: 16),
                Icon(icon, size: 21, color: AppTheme.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(description,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, height: 1.45))
                    ]))
              ])));
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(children: [
        Icon(Icons.shield_outlined, color: AppTheme.accentTeal, size: 23),
        SizedBox(width: 8),
        Text('TraceLens',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppTheme.textPrimary))
      ]);
}

class _NavAction extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavAction(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => TextButton(
      onPressed: onTap,
      child: Text(label,
          style: TextStyle(
              color: selected ? AppTheme.accentTeal : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)));
}

class AuthScreen extends StatefulWidget {
  final bool register;
  const AuthScreen({super.key, required this.register});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _register;
  bool _obscure = true;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleSubscription;
  bool _googleReady = false;
  bool _googleFailed = false;

  @override
  void initState() {
    super.initState();
    _register = widget.register;
    GoogleAuthService.initialize().then((_) {
      if (!mounted) return;
      if (kIsWeb) {
        _googleSubscription = GoogleAuthService.authenticationEvents.listen(
          _handleGoogleEvent,
          onError: (Object error) {
            if (mounted) _showGoogleError(error);
          },
        );
      }
      setState(() => _googleReady = true);
    }).catchError((Object error) {
      if (mounted) {
        setState(() => _googleFailed = true);
        _showGoogleError(error);
      }
    });
  }

  @override
  void dispose() {
    _googleSubscription?.cancel();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;
    await _completeGoogleSignIn(event.user);
  }

  Future<void> _completeGoogleSignIn(GoogleSignInAccount user) async {
    await AccountService.signInWithGoogle(
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email.split('@').first,
      email: user.email,
      photoUrl: user.photoUrl,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _showGoogleError(Object error) {
    if (!mounted) return;
    final message = error.toString().contains('client') ||
            error.toString().contains('Client')
        ? 'Google sign-in is not configured yet. Add your OAuth client ID and authorized app origin.'
        : 'Google sign-in could not be completed. Please try again.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startGoogleSignIn() async {
    try {
      final user = await GoogleAuthService.signIn();
      await _completeGoogleSignIn(user);
    } catch (error) {
      _showGoogleError(error);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_register) {
      await AccountService.register(
          name: _name.text, email: _email.text, password: _password.text);
    } else {
      final success = await AccountService.login(
          email: _email.text, password: _password.text);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Those sign-in details do not match this device’s account.')));
        return;
      }
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 34, color: AppTheme.accentTeal),
                      const SizedBox(height: 14),
                      Text(_register ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 7),
                      Text(
                          _register
                              ? 'Sign in to start checking messages and links.'
                              : 'Sign in to continue to TraceLens.',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 22),
                      if (_register) ...[
                        TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.person_outline)),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter your name'
                                : null),
                        const SizedBox(height: 13),
                      ],
                      TextFormField(
                          controller: _email,
                          keyboardType: _register
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              labelText: _register
                                  ? 'Email address'
                                  : 'Email or username',
                              prefixIcon: Icon(Icons.email_outlined)),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return _register
                                  ? 'Enter your email address'
                                  : 'Enter your email or username';
                            }
                            if (_register &&
                                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                    .hasMatch(v.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          }),
                      const SizedBox(height: 13),
                      TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined))),
                          validator: (v) => (v == null || v.length < 8)
                              ? 'Use at least 8 characters'
                              : null),
                      const SizedBox(height: 18),
                      SizedBox(
                          height: 48,
                          child: ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                  _register ? 'Create account' : 'Sign in'))),
                      const SizedBox(height: 15),
                      const Row(children: [
                        Expanded(child: Divider()),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: TextStyle(
                                    color: AppTheme.textMuted, fontSize: 11))),
                        Expanded(child: Divider())
                      ]),
                      const SizedBox(height: 14),
                      if (_googleFailed)
                        const Text(
                            'Google sign-in needs an OAuth client ID before it can be used.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.riskHigh))
                      else if (!_googleReady)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))))
                      else if (kIsWeb)
                        Center(
                            child: buildGoogleSignInButton(
                                onPressed: _startGoogleSignIn))
                      else
                        OutlinedButton.icon(
                            onPressed: _startGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata, size: 25),
                            label: const Text('Continue with Google')),
                      const SizedBox(height: 12),
                      Text(
                          _register
                              ? 'Your account is stored on this device. For multi-device sign-in, connect a secure authentication provider.'
                              : 'This account is stored on this device.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              height: 1.45)),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: () =>
                              setState(() => _register = !_register),
                          child: Text(_register
                              ? 'Already registered? Sign in'
                              : 'New to TraceLens? Create an account')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
