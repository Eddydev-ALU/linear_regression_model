import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://life-expectancy-predictor-19yh.onrender.com';

  /// Sends a POST request to /predict and returns the predicted value.
  /// Throws an [Exception] with a user-friendly message on failure.
  static Future<double> predict(Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/predict');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['predicted_life_expectancy'] as num).toDouble();
    } else if (response.statusCode == 422) {
      // Pydantic validation error – extract readable message
      final data = jsonDecode(response.body);
      final details = data['detail'] as List<dynamic>?;
      if (details != null && details.isNotEmpty) {
        final messages = details.map((d) {
          final loc = (d['loc'] as List).last;
          final msg = d['msg'];
          return '$loc: $msg';
        }).join('\n');
        throw Exception(messages);
      }
      throw Exception('Validation error – check your inputs.');
    } else {
      throw Exception(
          'Server error (${response.statusCode}). Please try again.');
    }
  }
}