import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/Constants/days.dart';
import 'package:expense_tracker/data/utilty.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Transaction transactionHistory;
  final box = Hive.box<Transaction>('transactions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 300, child: _buildHeader()),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: box.length,
                itemBuilder: (context, index) {
                  transactionHistory = box.values.toList()[index];
                  return _buildTransactionItem(index, transactionHistory);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(int index, Transaction transaction) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text(
                  "Are you sure you want to delete this transaction?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        transaction.delete();
      },
      child: _buildTransaction(index, transaction),
    );
  }

  ListTile _buildTransaction(int index, Transaction transaction) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset('images/${transaction.category.categoryIcon}',
            height: 40),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${days[transaction.createAt.weekday - 1]}  ${transaction.createAt.day}/${transaction.createAt.month}/${transaction.createAt.year}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        formatCurrency(int.parse(transaction.amount)),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: transaction.type == 'Expense' ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  Stack _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Text(
              "Dashboard",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Container(
              height: 180,
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        formatCurrency(totalBalance()),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTransactionType(
                          'Income', Icons.arrow_upward, totalIncome()),
                      _buildTransactionType(
                          'Expenses', Icons.arrow_downward, totalExpense()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _buildTransactionType(String label, IconData icon, int total) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: label == 'Income' ? Colors.green : Colors.red,
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              formatCurrency(total),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
