import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/investment_model.dart';
import '../../../data/services/investment_service.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _investmentNameController = TextEditingController();
  final TextEditingController _stockPriceController = TextEditingController();
  final TextEditingController _numberOfStocksController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String selectedType = 'Stocks';
  String selectedCurrency = '\$';

  final InvestmentService _investmentService = InvestmentService();

  final List<String> types = [
    'Stocks',
    'Gold',
    'Bonds',
    'Bitcoin',
  ];

  final List<String> currencies = ['₹', '\$', '€', '£', '¥'];

  double? _parseAmount(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^0-9\.,-]'), '');
    if (cleaned.isEmpty) return null;

    var normalized = cleaned;
    if (normalized.contains(',') && normalized.contains('.')) {
      if (normalized.indexOf(',') < normalized.indexOf('.')) {
        normalized = normalized.replaceAll(',', '');
      } else {
        normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
      }
    } else {
      normalized = normalized.replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  int? _parseNumber(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  double get _totalInvestment {
    final price = _parseAmount(_stockPriceController.text) ?? 0.0;
    final number = _parseNumber(_numberOfStocksController.text) ?? 0;
    return price * number;
  }

  String get _displayTotal {
    return '$selectedCurrency${_totalInvestment.toStringAsFixed(2)}';
  }

  String get _investmentNameLabel => selectedType == 'Stocks' ? 'Investment Name' : selectedType;

  String get _investmentNameHint {
    if (selectedType == 'Stocks') {
      return 'e.g. Apple Inc.';
    }
    return selectedType;
  }

  bool get _isInvestmentNameEditable => selectedType == 'Stocks';

  String get _priceLabel {
    switch (selectedType) {
      case 'Gold':
        return 'Gold Price per Gram';
      case 'Bonds':
        return 'Bond Price';
      case 'Bitcoin':
        return 'Bitcoin Price';
      default:
        return 'Stock Price';
    }
  }

  String get _priceHint {
    switch (selectedType) {
      case 'Gold':
        return 'e.g. 5600.00';
      case 'Bonds':
        return 'e.g. 1000.00';
      case 'Bitcoin':
        return 'e.g. 42000.00';
      default:
        return 'e.g. 150.00';
    }
  }

  String get _quantityLabel {
    switch (selectedType) {
      case 'Gold':
        return 'Grams';
      case 'Bonds':
        return 'Units';
      case 'Bitcoin':
        return 'Quantity';
      default:
        return 'Number of Shares';
    }
  }

  String get _quantityHint {
    switch (selectedType) {
      case 'Gold':
        return 'e.g. 10';
      case 'Bonds':
        return '1';
      case 'Bitcoin':
        return 'e.g. 1';
      default:
        return 'e.g. 10';
    }
  }

  bool get _isQuantityEditable => selectedType != 'Bonds';

  void _updateTypeDefaults() {
    if (selectedType == 'Bonds') {
      _investmentNameController.text = 'Bonds';
      _numberOfStocksController.text = '1';
    } else if (selectedType == 'Gold' || selectedType == 'Bitcoin') {
      _investmentNameController.text = selectedType;
      if (_numberOfStocksController.text == '1') {
        _numberOfStocksController.clear();
      }
    } else {
      _investmentNameController.clear();
      if (_numberOfStocksController.text == '1') {
        _numberOfStocksController.clear();
      }
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveInvestment() async {
    if (!_formKey.currentState!.validate()) return;

    final stockPrice = _parseAmount(_stockPriceController.text);
    final numberOfStocks = _parseNumber(_numberOfStocksController.text);

    if (stockPrice == null || numberOfStocks == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid stock price and number of stocks')),
      );
      return;
    }

    final totalInvestment = stockPrice * numberOfStocks;

    final note = _noteController.text.isEmpty
        ? null
        : _noteController.text.trim();

    final investment = Investment(
      id: const Uuid().v4(),
      investmentName: _investmentNameController.text.trim(),
      stockPrice: stockPrice,
      numberOfStocks: numberOfStocks,
      totalInvestment: totalInvestment,
      type: selectedType,
      currency: selectedCurrency,
      note: note,
      date: _selectedDate,
    );

    await _investmentService.addInvestment(investment);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Investment added ✅')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Investment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Spend Vault', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('INVESTMENT DETAILS', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      const Text('Track your investments', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
                      const SizedBox(height: 24),
                      _buildTotalPreview(),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_investmentNameLabel, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _investmentNameController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: _investmentNameHint,
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              readOnly: !_isInvestmentNameEditable,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter investment name';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Investment Type', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: types.map((type) {
                                final isSelected = selectedType == type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF4D5BFF),
                                  backgroundColor: const Color(0xFF202637),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  onSelected: (_) {
                                    setState(() {
                                      selectedType = type;
                                      _updateTypeDefaults();
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_priceLabel, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _stockPriceController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: _priceHint,
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter ${_priceLabel.toLowerCase()}';
                                }
                                if (_parseAmount(value) == null) {
                                  return 'Enter a valid price';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_quantityLabel, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _numberOfStocksController,
                              readOnly: !_isQuantityEditable,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: _quantityHint,
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter ${_quantityLabel.toLowerCase()}';
                                }
                                if (_parseNumber(value) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Note (Optional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _noteController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Additional notes',
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Investment Date', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_formatDate(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF202637),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.calendar_today, color: Color(0xFF7F83FF), size: 22),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF4D5BFF),
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF121826),
                                      onSurface: Colors.white,
                                    ),
                                    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0A0E1F)),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151B35),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL INVESTMENT', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4D5BFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Text(
                  selectedCurrency,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  _displayTotal,
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: currencies.map((currency) {
              final isSelected = selectedCurrency == currency;
              return ChoiceChip(
                label: Text(currency, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                selected: isSelected,
                selectedColor: const Color(0xFF4D5BFF),
                backgroundColor: const Color(0xFF202637),
                onSelected: (_) {
                  setState(() {
                    selectedCurrency = currency;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151B35),
        borderRadius: BorderRadius.circular(26),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151B35),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C1B14),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.lightbulb, color: Color(0xFF69D16B), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('PRO TIP', style: TextStyle(color: Color(0xFF69D16B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                SizedBox(height: 6),
                Text('Track your portfolio growth with accurate investment entries.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _saveInvestment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F83FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text('Save Investment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151B35))),
      ),
    );
  }
}