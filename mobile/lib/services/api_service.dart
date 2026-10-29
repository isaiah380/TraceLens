import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/analysis_result.dart';

class ApiService {
  /// Fetches backend health status
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/health'))
          .timeout(AppConfig.timeoutDuration);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'status': 'error', 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'status': 'offline', 'message': e.toString()};
    }
  }

  /// Sends raw message text to /analyze/message
  static Future<AnalysisResult> analyzeMessage(String message) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/analyze/message'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'message': message}),
        )
        .timeout(AppConfig.timeoutDuration);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AnalysisResult.fromMessageJson(data, message);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to analyze message');
    }
  }

  /// Sends URL to /analyze/url
  static Future<AnalysisResult> analyzeUrl(String url) async {
    final response = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/analyze/url'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'url': url}),
        )
        .timeout(AppConfig.timeoutDuration);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AnalysisResult.fromUrlJson(data, url);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to analyze URL');
    }
  }
}
