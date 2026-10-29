class ScanHistoryItem {
  final int? id;
  final String scanType; // 'message', 'url', 'qr'
  final String timestamp;
  final String previewText; // Redacted or shortened preview
  final String category;
  final String riskLevel;
  final int riskScore;
  final String briefExplanation;

  ScanHistoryItem({
    this.id,
    required this.scanType,
    required this.timestamp,
    required this.previewText,
    required this.category,
    required this.riskLevel,
    required this.riskScore,
    required this.briefExplanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scan_type': scanType,
      'timestamp': timestamp,
      'preview_text': previewText,
      'category': category,
      'risk_level': riskLevel,
      'risk_score': riskScore,
      'brief_explanation': briefExplanation,
    };
  }

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    return ScanHistoryItem(
      id: map['id'],
      scanType: map['scan_type'] ?? 'message',
      timestamp: map['timestamp'] ?? '',
      previewText: map['preview_text'] ?? '',
      category: map['category'] ?? '',
      riskLevel: map['risk_level'] ?? 'medium',
      riskScore: map['risk_score'] ?? 50,
      briefExplanation: map['brief_explanation'] ?? '',
    );
  }
}
