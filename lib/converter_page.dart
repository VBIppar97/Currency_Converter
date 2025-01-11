import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String? _fromCurrency;
  String? _toCurrency;
  double? _conversionResult;
  Map<String, dynamic>? _exchangeRates;
  List<String> _filteredCurrencies = [];
  String _searchQuery = '';

  Future<void> fetchExchangeRates() async {
    final url =
        "https://v6.exchangerate-api.com/v6/fcdf87381720a471b4127745/latest/USD"; // Using USD as base currency
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _exchangeRates = json.decode(response.body)['conversion_rates'];
        _filteredCurrencies =
            _exchangeRates!.keys.toList(); // Initialize filtered list
      });
    } else {
      throw Exception("Failed to load exchange rates");
    }
  }

  void _convertCurrency() {
    if (_exchangeRates == null || _fromCurrency == null || _toCurrency == null)
      return;

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double rate =
        _exchangeRates![_toCurrency]! / _exchangeRates![_fromCurrency]!;

    setState(() {
      _conversionResult = amount * rate;
    });
  }

  void _filterCurrencies(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCurrencies = _exchangeRates!.keys
          .where((currency) =>
              currency.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  String _getFlagUrl(String currencyCode) {
    return "https://flagcdn.com/w40/${currencyCode.substring(0, 2).toLowerCase()}.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.5, 1.0],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Currency Converter",
          style:
              TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSearchableDropdown(
                      hint: 'From',
                      selectedValue: _fromCurrency,
                      onChanged: (value) {
                        setState(() {
                          _fromCurrency = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSearchableDropdown(
                      hint: 'To',
                      selectedValue: _toCurrency,
                      onChanged: (value) {
                        setState(() {
                          _toCurrency = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _convertCurrency,
                child: const Text('Convert'),
              ),
              const SizedBox(height: 16),
              if (_conversionResult != null)
                Text(
                  'Converted Amount: $_conversionResult $_toCurrency',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String hint,
    String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: _filterCurrencies,
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            hint: Text("Select $hint"),
            items: _filteredCurrencies.map((String currency) {
              return DropdownMenuItem(
                value: currency,
                child: Row(
                  children: [
                    Image.network(
                      _getFlagUrl(currency),
                      width: 30,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag),
                    ),
                    const SizedBox(width: 10),
                    Text(currency),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
