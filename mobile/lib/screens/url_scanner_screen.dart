import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/loading_indicator.dart';
import 'result_screen.dart';

class UrlScannerScreen extends StatefulWidget {
  final String? initialUrl;
  const UrlScannerScreen({super.key, this.initialUrl});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _controller.text = widget.initialUrl!;
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _controller.text = clipboardData.text!.trim();
        _errorMessage = null;
      });
    }
  }

  void _clearInput() {
    setState(() {
      _controller.clear();
      _errorMessage = null;
    });
  }

  Future<void> _analyzeUrl() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL to inspect.';
      });
      return;
    }

    if (!Validators.isValidUrl(url)) {
      setState(() {
        _errorMessage =
            'Invalid URL format. Example: https://example.com/login';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.analyzeUrl(url);
      await HistoryService.saveResult(
        scanType: 'url',
        rawInput: url,
        result: result,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: result,
            originalInput: url,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Analysis error: ${e.toString().replaceAll('Exception:', '')}';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Inspect Links Before Clicking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'TraceLens evaluates domain structure, Punycode tricks, raw IP hosts, and URL shorteners without navigating to the site.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://example-banking-alert.xyz/verify',
                prefixIcon:
                    const Icon(Icons.link_rounded, color: AppTheme.accentTeal),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: _clearInput,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded,
                        size: 16, color: AppTheme.accentTeal),
                    label: const Text('Paste URL',
                        style: TextStyle(color: AppTheme.accentTeal)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.surfaceLight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.riskHigh.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.riskHigh.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.riskHigh, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: AppTheme.riskHigh, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            _isLoading
                ? const CustomLoadingIndicator(
                    statusText: 'Inspecting URL structure and reputations...')
                : ElevatedButton.icon(
                    onPressed: _analyzeUrl,
                    icon: const Icon(Icons.travel_explore_rounded, size: 20),
                    label: const Text('Analyze URL'),
                  ),
            const SizedBox(height: 20),

            // Explanatory Safety Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded,
                      color: AppTheme.accentTeal, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Zero-Touch Scanning: This application inspects URL strings algebraically and structurally. It will NEVER send HTTP traffic or visit suspicious servers.',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
