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
  final TextEditingController _amountController = TextEditingController();
  String selectedCategory = "Food";

  final ExpenseService _expenseService = ExpenseService();

  final List<String> categories = [
    "Food",
    "Travel",
    "Bills",
    "Shopping",
    "Entertainment",
    "Other"
  ];

  void _saveExpense() async {
    if (_amountController.text.isEmpty) return;

    final expense = Expense(
      id: const Uuid().v4(),
      amount: double.parse(_amountController.text),
      category: selectedCategory,
      date: DateTime.now(),
    );

    await _expenseService.addExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense added ✅")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32),
              decoration: const InputDecoration(
                hintText: "Enter Amount",
              ),
            ),

            const SizedBox(height: 20),

            // Category Selector
            Wrap(
              spacing: 10,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = cat;
                    });
                  },
                );
              }).toList(),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: const Text("Save Expense"),
              ),
            )
          ],
        ),
      ),
    );
  }
}