import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      "https://v6.exchangerate-api.com/v6/0b787beced942186881bb4f2/latest/USD";

  static Future<Map<String, dynamic>> fetchExchangeRates() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body)['conversion_rates'];
    } else {
      throw Exception("Failed to load exchange rates");
    }
  }
}
