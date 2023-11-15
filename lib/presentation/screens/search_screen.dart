import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/data/utilty.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  late List<Transaction> filteredTransactions;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterTransactions('');
  }

  void filterTransactions(String query) {
    final box = Hive.box<Transaction>('transactions');
    filteredTransactions = box.values
        .where((transaction) =>
            transaction.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Search'),
        centerTitle: true,
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              cursorColor: primaryColor,
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by description',
                labelStyle: const TextStyle(color: primaryColor),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  color: primaryColor,
                  onPressed: () {
                    searchController.clear();
                    filterTransactions('');
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                filterTransactions(value);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'images/${transaction.category.categoryIcon}',
                      height: 40,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${transaction.createAt.day}/${transaction.createAt.month}/${transaction.createAt.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    formatCurrency(int.parse(transaction.amount)),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: transaction.type == 'Expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
