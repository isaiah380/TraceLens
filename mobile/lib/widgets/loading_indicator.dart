import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final String statusText;

  const CustomLoadingIndicator({
    super.key,
    this.statusText = 'Analyzing signals...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 38,
            width: 38,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
