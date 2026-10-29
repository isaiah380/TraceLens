import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final int? riskScore;
  final bool showScore;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.riskScore,
    this.showScore = true,
  });

  Color _getColor() {
    switch (riskLevel.toLowerCase()) {
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

  IconData _getIcon() {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_outline_rounded;
      case 'low':
      default:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final levelText = riskLevel.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            showScore && riskScore != null
                ? '$levelText ($riskScore%)'
                : levelText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
