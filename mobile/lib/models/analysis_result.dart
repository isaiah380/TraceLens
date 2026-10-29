class SignalItem {
  final String code;
  final String description;
  final String severity;

  SignalItem({
    required this.code,
    required this.description,
    required this.severity,
  });

  factory SignalItem.fromJson(Map<String, dynamic> json) {
    return SignalItem(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'low',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'description': description,
    'severity': severity,
  };
}

class AnalysisResult {
  final String scanType; // 'message' or 'url'
  final String modelUsed;
  final String classification;
  final String riskLevel; // 'low', 'medium', 'high', 'critical'
  final int riskScore; // 0-100
  final List<SignalItem> signals;
  final List<String> urlsFound;
  final Map<String, double>? modelScores;
  final List<String> recommendations;
  final String disclaimer;
  final String? originalInput;
  final String? normalizedUrl;
  final String? threatIntelResult;

  AnalysisResult({
    required this.scanType,
    required this.modelUsed,
    required this.classification,
    required this.riskLevel,
    required this.riskScore,
    required this.signals,
    this.urlsFound = const [],
    this.modelScores,
    required this.recommendations,
    required this.disclaimer,
    this.originalInput,
    this.normalizedUrl,
    this.threatIntelResult,
  });

  factory AnalysisResult.fromMessageJson(Map<String, dynamic> json, String originalText) {
    Map<String, double>? scores;
    if (json['model_scores'] != null) {
      scores = (json['model_scores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return AnalysisResult(
      scanType: json['scan_type'] ?? 'message',
      modelUsed: json['model_used'] ?? 'rule_based',
      classification: json['classification'] ?? 'unknown',
      riskLevel: json['risk_level'] ?? 'medium',
      riskScore: json['risk_score'] ?? 50,
      signals: (json['signals'] as List<dynamic>? ?? [])
          .map((s) => SignalItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      urlsFound: (json['urls_found'] as List<dynamic>? ?? [])
          .map((u) => u.toString())
          .toList(),
      modelScores: scores,
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((r) => r.toString())
          .toList(),
      disclaimer: json['disclaimer'] ?? '',
      originalInput: originalText,
    );
  }

  factory AnalysisResult.fromUrlJson(Map<String, dynamic> json, String rawUrl) {
    return AnalysisResult(
      scanType: json['scan_type'] ?? 'url',
      modelUsed: json['ml_prediction'] != null ? 'url_random_forest' : 'structural_heuristics',
      classification: json['risk_level'] == 'low' ? 'benign' : 'phishing_threat',
      riskLevel: json['risk_level'] ?? 'medium',
      riskScore: json['risk_score'] ?? 50,
      signals: (json['signals'] as List<dynamic>? ?? [])
          .map((s) => SignalItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((r) => r.toString())
          .toList(),
      disclaimer: json['disclaimer'] ?? '',
      originalInput: rawUrl,
      normalizedUrl: json['normalized_url'],
      threatIntelResult: json['threat_intel_result'],
    );
  }
}
