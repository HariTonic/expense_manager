import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'data/models/expense_model.dart';
import 'data/services/expense_service.dart';
import 'data/database/hive_init.dart';
// import 'features/expense/screens/add_expense_screen.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInit.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenses = _expenseService.getExpenses();
    });
  }

  void _showAddExpenseDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController dateController = TextEditingController(
        text: DateTime.now().toLocal().toString().split(' ')[0]);
    String category = 'Food';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['Food', 'Travel', 'Shopping', 'Other']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) category = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text =
                          picked.toLocal().toString().split(' ')[0];
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newExpense = Expense(
                  id: const Uuid().v4(),
                  amount: double.parse(amountController.text),
                  category: category,
                  note: noteController.text,
                  date: DateTime.parse(dateController.text),
                );
                _expenseService.addExpense(newExpense);
                _loadExpenses();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: _expenses.isEmpty
          ? const Center(child: Text('No expenses yet!'))
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final exp = _expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(exp.category[0]),
                  ),
                  title: Text('${exp.category}: ₹${exp.amount}'),
                  subtitle: Text('${exp.note} | ${exp.date.toLocal().toString().split(' ')[0]}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}