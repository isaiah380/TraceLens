import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_badge.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final String originalInput;

  const ResultScreen({
    super.key,
    required this.result,
    required this.originalInput,
  });

  Color _getRiskColor() {
    switch (result.riskLevel.toLowerCase()) {
      case 'critical':
        return AppTheme.riskCritical;
      case 'high':
        return AppTheme.riskHigh;
      case 'medium':
        return AppTheme.riskMedium;
      case 'low':
      default:
        return AppTheme.riskLow;
    }
  }

  Future<void> _copyAssessment(BuildContext context) async {
    final lines = <String>[
      'TraceLens security assessment',
      'Risk: ${result.riskLevel} (${result.riskScore}/100)',
      'Category: ${result.classification}',
      'Assessment method: ${result.modelUsed}',
      if (result.signals.isNotEmpty) ...[
        '',
        'Signals:',
        ...result.signals.map((signal) => '- ${signal.description}'),
      ],
      if (result.recommendations.isNotEmpty) ...[
        '',
        'Suggested next steps:',
        ...result.recommendations.map((recommendation) => '- $recommendation'),
      ],
      '',
      'This automated assessment can be wrong. Verify important requests independently.',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assessment summary copied. Original message or link was not included.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Risk Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: riskColor.withOpacity(0.35), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RISK LEVEL: ${result.riskLevel.toUpperCase()}',
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      RiskBadge(
                        riskLevel: result.riskLevel,
                        riskScore: result.riskScore,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: result.riskScore / 100.0,
                    backgroundColor: AppTheme.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category: ${result.classification.toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Method: ${result.modelUsed}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Pretrained Model Class Probability Scores (if available)
            if (result.modelScores != null &&
                result.modelScores!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Pretrained Model Output Scores',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Column(
                  children: result.modelScores!.entries.map((entry) {
                    final percent = (entry.value * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(
                                color: AppTheme.accentTeal,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Signals / Explanations
            const SizedBox(height: 24),
            const Text(
              'Detected Signals & Reasons',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            if (result.signals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                    'No anomalous patterns or suspicious markers detected.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              )
            else
              ...result.signals.map((signal) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          signal.severity == 'critical'
                              ? Icons.error_outline_rounded
                              : (signal.severity == 'high'
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline_rounded),
                          size: 20,
                          color: signal.severity == 'critical'
                              ? AppTheme.riskCritical
                              : (signal.severity == 'high'
                                  ? AppTheme.riskHigh
                                  : AppTheme.accentCyan),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                signal.code.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                signal.description,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

            // Extracted URLs
            if (result.urlsFound.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Extracted Embedded Links',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              ...result.urlsFound.map((u) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded,
                            color: AppTheme.accentTeal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            u,
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // Threat intelligence status (if URL scan)
            if (result.threatIntelResult != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Threat Intelligence Status',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceLight),
                ),
                child: Text(
                  result.threatIntelResult!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            ],

            // Actionable Recommendations
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('If this looks suspicious',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                      'Do not reply, open the link, send money or share a code. Contact the organization using its official app, website or a number you already trust. If you shared payment details, contact your bank promptly.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.45),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _copyAssessment(context),
                      icon: const Icon(Icons.copy_outlined, size: 17),
                      label: const Text('Copy assessment summary'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Security Recommendations',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            ...result.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppTheme.accentTeal, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )),

            // Automated Assessment Disclaimer
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded,
                      color: AppTheme.textMuted, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.disclaimer,
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
