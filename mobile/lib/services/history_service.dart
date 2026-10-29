import '../database/local_database.dart';
import '../models/analysis_result.dart';
import '../models/scan_history_item.dart';
import 'package:intl/intl.dart';

class HistoryService {
  static Future<void> saveResult({
    required String scanType,
    required String rawInput,
    required AnalysisResult result,
  }) async {
    // Generate safe short preview (limit length to prevent sensitive storage)
    String preview = rawInput.trim();
    if (preview.length > 60) {
      preview = '${preview.substring(0, 57)}...';
    }

    final briefExplanation = result.signals.isNotEmpty
        ? result.signals.first.description
        : 'Automated scan completed';

    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    final item = ScanHistoryItem(
      scanType: scanType,
      timestamp: nowStr,
      previewText: preview,
      category: result.classification,
      riskLevel: result.riskLevel,
      riskScore: result.riskScore,
      briefExplanation: briefExplanation,
    );

    await LocalDatabase.instance.insertScan(item);
  }

  static Future<List<ScanHistoryItem>> getHistory() async {
    return await LocalDatabase.instance.getAllScans();
  }

  static Future<void> deleteItem(int id) async {
    await LocalDatabase.instance.deleteScan(id);
  }

  static Future<void> clearAll() async {
    await LocalDatabase.instance.clearAllHistory();
  }
}
