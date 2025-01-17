import 'package:flutter/material.dart';
import 'api_services.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeExchangeRates();
  }

  Future<void> _initializeExchangeRates() async {
    try {
      final rates = await ApiService.fetchExchangeRates();
      setState(() {
        _exchangeRates = rates;
        _filteredCurrencies = rates.keys.toList();
      });
    } catch (e) {
      print(e);
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
                  // "From" Dropdown on the left
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _fromCurrency,
                      hint: const Text("From"),
                      decoration: const InputDecoration(
                        labelText: 'Select From Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _filteredCurrencies.map((currency) {
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
                      onChanged: (value) {
                        setState(() {
                          _fromCurrency = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Spacing between dropdowns

                  // "To" Dropdown on the right
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _toCurrency,
                      hint: const Text("To"),
                      decoration: const InputDecoration(
                        labelText: 'Select From Currency',
                        border: OutlineInputBorder(),
                      ),
                      items: _filteredCurrencies.map((currency) {
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
}
