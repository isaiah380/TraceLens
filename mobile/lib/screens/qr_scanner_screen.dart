import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/loading_indicator.dart';
import 'result_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isAnalyzing = false;
  bool _hasDetected = false;
  String? _nonUrlContent;

  void _onDetect(BarcodeCapture capture) async {
    if (_hasDetected || _isAnalyzing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawVal = barcodes.first.rawValue;
    if (rawVal == null || rawVal.trim().isEmpty) return;

    setState(() {
      _hasDetected = true;
    });

    final content = rawVal.trim();

    // Check if QR content contains a valid URL
    if (Validators.isValidUrl(content) ||
        content.startsWith('http://') ||
        content.startsWith('https://')) {
      setState(() {
        _isAnalyzing = true;
      });

      try {
        final result = await ApiService.analyzeUrl(content);
        await HistoryService.saveResult(
          scanType: 'qr',
          rawInput: content,
          result: result,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              result: result,
              originalInput: content,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isAnalyzing = false;
          _hasDetected = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL analysis error: ${e.toString()}'),
            backgroundColor: AppTheme.riskHigh,
          ),
        );
      }
    } else {
      // Non-URL plain text QR code
      setState(() {
        _nonUrlContent = content;
        _isAnalyzing = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _hasDetected = false;
      _nonUrlContent = null;
      _isAnalyzing = false;
    });
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
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded,
                          size: 48, color: AppTheme.riskHigh),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Unavailable or Permission Denied',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please grant camera permissions in device settings to scan QR codes.\nDetails: ${error.errorCode}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // QR Targeting Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentTeal, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Analysis Loading Overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.75),
              child: const CustomLoadingIndicator(
                  statusText: 'Decoding & analyzing QR URL...'),
            ),

          // Non-URL plain text card dialog
          if (_nonUrlContent != null)
            Container(
              color: Colors.black.withOpacity(0.85),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppTheme.accentCyan, size: 36),
                        const SizedBox(height: 12),
                        const Text(
                          'Plain Text QR Detected',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This QR code does not contain a web URL. URL security analysis is unavailable for plain text.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            _nonUrlContent!,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _resetScanner,
                          child: const Text('Scan Another Code'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
