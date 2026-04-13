import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String selectedCategory = 'Food';
  String selectedCurrency = '₹';

  final ExpenseService _expenseService = ExpenseService();

  final List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Other',
  ];

  final List<String> currencies = ['₹', '\$', '€', '£', '¥'];

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
  @override
  void initState() {
    super.initState();
  }

  String get _displayAmount {
    if (_amountController.text.isEmpty) {
      return '${selectedCurrency}0.00';
    }
    final parsed = _parseCurrencyAmount(_amountController.text);
    return parsed == null ? _amountController.text : '$selectedCurrency${parsed.toStringAsFixed(2)}';
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

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseCurrencyAmount(_amountController.text);
    if (amount == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final note = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text.trim();
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: selectedCategory,
      note: note,
      date: _selectedDate,
    );

    await _expenseService.addExpense(expense);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added ✅')),
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
        title: const Text('New Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      const Text('ENTRY DETAILS', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                    const Text('Track your spending', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
                    const SizedBox(height: 24),
                    _buildAmountPreview(),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expense Type', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: categories.map((category) {
                              final isSelected = selectedCategory == category;
                              return ChoiceChip(
                                label: Text(category),
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
                                    selectedCategory = category;
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
                          const Text('Expense Name', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descriptionController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'e.g. Grocery shopping',
                              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                              filled: true,
                              fillColor: const Color(0xFF181E2F),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Acquisition Date', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
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

  Widget _buildAmountPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151B35),
        borderRadius: BorderRadius.circular(26),
      ),
      child: InkWell(
        onTap: _showAmountInputDialog,
        borderRadius: BorderRadius.circular(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTAL AMOUNT', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1.5)),
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
                    _displayAmount,
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Tap to enter amount', style: TextStyle(color: Colors.white54, fontSize: 14)),
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
      ),
    );
  }

  Future<void> _showAmountInputDialog() async {
    final dialogController = TextEditingController(text: _amountController.text);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E1F),
          title: const Text('Enter amount', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: dialogController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF151B35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _amountController.text = dialogController.text.trim();
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFF7F83FF))),
            ),
          ],
        );
      },
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
                Text('Accurate amount entries keep your budget insights precise.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
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
        onPressed: _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F83FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text('Save Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151B35))),
      ),
    );
  }
}
