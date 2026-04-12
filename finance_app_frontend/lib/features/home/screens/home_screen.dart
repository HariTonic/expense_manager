import 'package:flutter/material.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/models/expense_model.dart';
import '../../expense/screens/add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();

  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final data = _expenseService.getExpenses();
    setState(() {
      expenses = data;
    });
  }

  double get totalExpense {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  void _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );

    _loadExpenses(); // refresh after returning
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔷 Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Spending",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 🔘 Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: "Expense",
                    color: Colors.red,
                    onTap: _navigateToAdd,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton(
                    title: "Income",
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton(
                    title: "Invest",
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 📋 List
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text("No expenses yet"))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.category,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  e.note ?? "",
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              "₹${e.amount}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _actionButton({
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

}