import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/income_model.dart';
import '../../../data/services/income_service.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String selectedSource = 'Salary';
  String selectedCurrency = '₹';

  final IncomeService _incomeService = IncomeService();

  final List<String> sources = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  final List<String> currencies = ['₹', '\$', '€', '£', '¥'];

  @override
  void initState() {
    super.initState();
    _updateDateField();
  }

  void _updateDateField() {
    _dateController.text = _formatDate(_selectedDate);
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

  double? _parseCurrencyAmount(String value) {
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

  String get _displayAmount {
    if (_amountController.text.isEmpty) {
      return '${selectedCurrency}0.00';
    }
    final parsed = _parseCurrencyAmount(_amountController.text);
    return parsed == null ? _amountController.text : '$selectedCurrency${parsed.toStringAsFixed(2)}';
  }

  void _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseCurrencyAmount(_amountController.text);
    if (amount == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid numeric amount')),
      );
      return;
    }

    final income = Income(
      id: const Uuid().v4(),
      source: selectedSource,
      amount: amount,
      note: _noteController.text.isEmpty ? null : _noteController.text.trim(),
      date: _selectedDate,
    );

    await _incomeService.addIncome(income);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income added ✅')),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Income', style: TextStyle(color: Colors.white)),
        centerTitle: false,
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
                      _buildAmountPreview(),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Income Source', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: sources.map((source) {
                                final isSelected = selectedSource == source;
                                return ChoiceChip(
                                  label: Text(source),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF4D5BFF),
                                  backgroundColor: const Color(0xFF202637),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onSelected: (_) {
                                    setState(() {
                                      selectedSource = source;
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
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Date', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_dateController.text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
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
                                _updateDateField();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Add Note', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noteController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Description of this income...',
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                              ),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Amount', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                hintText: '${selectedCurrency}0.00',
                                hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                                filled: true,
                                fillColor: const Color(0xFF181E2F),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter amount';
                                }
                                if (_parseCurrencyAmount(value) == null) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                          ],
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

  Widget _buildAmountPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF151B35),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL AMOUNT', style: TextStyle(color: Colors.white38, letterSpacing: 1.3, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
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
                child: TextFormField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 36, fontWeight: FontWeight.w700),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {});
                  },
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
      padding: const EdgeInsets.all(20),
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
              color: const Color(0xFF1F2A45),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.trending_up, color: Color(0xFF8EE593), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Wealth Projection', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('This entry increases your monthly forecast by 12%.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
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
      height: 60,
      child: ElevatedButton(
        onPressed: _saveIncome,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F83FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Save Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151B35))),
      ),
    );
  }
}
