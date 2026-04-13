import 'package:flutter/material.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/services/income_service.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../expense/screens/add_expense_screen.dart';
import '../../income/screens/add_income_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();

  List<Expense> expenses = [];
  List<Income> incomes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final expenseData = _expenseService.getExpenses();
    final incomeData = _incomeService.getIncomes();

    setState(() {
      expenses = expenseData;
      incomes = incomeData;
    });
  }

  double get totalExpense {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalIncome {
    return incomes.fold(0.0, (sum, i) => sum + i.amount);
  }

  double get netBalance {
    return totalIncome - totalExpense;
  }

  bool get hasTodayExpense {
    final now = DateTime.now();
    return expenses.any((expense) {
      final date = expense.date.toLocal();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    });
  }

  List<Map<String, dynamic>> get recentTransactions {
    final combined = <Map<String, dynamic>>[];

    combined.addAll(incomes.map((income) {
      return {
        'type': 'income',
        'title': income.source,
        'subtitle': income.note ?? 'Income received',
        'amount': income.amount,
        'date': income.date,
      };
    }));

    combined.addAll(expenses.map((expense) {
      return {
        'type': 'expense',
        'title': expense.category,
        'subtitle': expense.note ?? 'Expense recorded',
        'amount': expense.amount,
        'date': expense.date,
      };
    }));

    combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return combined;
  }

  void _navigateToAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
      ),
    );
    _loadData();
  }

  void _navigateToAddIncome() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddIncomeScreen(),
      ),
    );
    _loadData();
  }

  void _showNotReadyMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not ready yet')),
    );
  }

  String get _headerDate {
    final now = DateTime.now();
    const months = [
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wealth Vault',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _headerDate,
                            style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 0.6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 171, 64, 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Pending Entry',
                              style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1B2340),
                    child: const Icon(Icons.person, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF19234A), Color(0xFF12183A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasTodayExpense ? 'Daily Tracker' : 'Daily Tracker',
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.75),
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      hasTodayExpense
                          ? 'You’ve entered today’s expense'
                          : 'You haven’t entered today’s expense',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToAddExpense,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Expense Now', style: TextStyle(color: Color(0xFF151B35))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7F83FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _smallActionCard(
                    title: 'Add Expense',
                    icon: Icons.wallet_outlined,
                    color: Colors.white,
                    onTap: _navigateToAddExpense,
                  ),
                  const SizedBox(width: 12),
                  _smallActionCard(
                    title: 'Add Income',
                    icon: Icons.money,
                    color: Colors.greenAccent,
                    onTap: _navigateToAddIncome,
                  ),
                  const SizedBox(width: 12),
                  _smallActionCard(
                    title: 'Add Investment',
                    icon: Icons.trending_up,
                    color: Colors.purpleAccent,
                    onTap: () => _showNotReadyMessage('Invest'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'View History',
                    style: TextStyle(
                      color: Color(0xFF7F83FF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final item = recentTransactions[index];
                  final isIncome = item['type'] == 'income';
                  return _transactionTile(
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    amount: item['amount'] as double,
                    isIncome: isIncome,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showNotReadyMessage('Export'),
                      icon: const Icon(Icons.upload_outlined, color: Colors.white70),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddExpense,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Quick Entry', style: TextStyle(color: Color(0xFF151B35))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F83FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _smallActionCard({
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF11182F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(46),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _transactionTile({
  required String title,
  required String subtitle,
  required double amount,
  required bool isIncome,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF11182F),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: isIncome ? Colors.greenAccent.withAlpha(46) : Colors.redAccent.withAlpha(46),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isIncome ? Icons.download : Icons.shopping_bag_outlined,
            color: isIncome ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.65)),
              ),
            ],
          ),
        ),
        Text(
          '${isIncome ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
