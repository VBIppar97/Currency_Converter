import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = '0b787beced942186881bb4f2';
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  // Fetch available currencies
  Future<List<String>> getCurrencies(String baseCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['conversion_rates'] as Map<String, dynamic>).keys.toList();
    } else {
      throw Exception("Failed to fetch currencies");
    }
  }

  // Convert currency
  Future<double> convertCurrency(double amount, String fromCurrency, String toCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl/$_apiKey/latest/$fromCurrency'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final exchangeRate = data['conversion_rates'][toCurrency];
      if (exchangeRate == null) {
        throw Exception("Currency not found");
      }
      return amount * exchangeRate;
    } else {
      throw Exception("Failed to convert currency");
    }
  }
}
