import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_indicator.dart';
import 'result_screen.dart';

class MessageScannerScreen extends StatefulWidget {
  final String? initialText;
  const MessageScannerScreen({super.key, this.initialText});

  @override
  State<MessageScannerScreen> createState() => _MessageScannerScreenState();
}

class _MessageScannerScreenState extends State<MessageScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) _controller.text = widget.initialText!;
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _controller.text = clipboardData.text!;
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

  Future<void> _analyzeMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please paste or enter a message to analyze.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.analyzeMessage(text);
      await HistoryService.saveResult(
        scanType: 'message',
        rawInput: text,
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
            originalInput: text,
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
        title: const Text('Message Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Analyze SMS, WhatsApp, or Emails',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Paste a message to detect fraud, social engineering tricks, urgent threats, and malicious links.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Text Input Box
            TextField(
              controller: _controller,
              maxLines: 8,
              minLines: 5,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Paste suspicious message content here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Paste and Clear Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded,
                        size: 16, color: AppTheme.accentTeal),
                    label: const Text('Paste',
                        style: TextStyle(color: AppTheme.accentTeal)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.surfaceLight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearInput,
                    icon: const Icon(Icons.clear_rounded,
                        size: 16, color: AppTheme.textSecondary),
                    label: const Text('Clear',
                        style: TextStyle(color: AppTheme.textSecondary)),
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

            // Primary Analyze Button or Loading Indicator
            _isLoading
                ? const CustomLoadingIndicator(
                    statusText: 'Running NLP & heuristic analysis...')
                : ElevatedButton.icon(
                    onPressed: _analyzeMessage,
                    icon: const Icon(Icons.security_rounded, size: 20),
                    label: const Text('Analyze Message'),
                  ),
            const SizedBox(height: 20),

            // Privacy reminder
            Center(
              child: Text(
                'TraceLens processes text on the backend API without storing raw message content.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textMuted.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
