import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/Constants/default_categories.dart';
import 'package:expense_tracker/data/utilty.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/domain/models/category_model.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  late Box<CategoryModel> box;
  List<CategoryModel> expenseCategories = [];
  List<CategoryModel> incomeCategories = [];

  @override
  void initState() {
    super.initState();
    openBox().then((_) {
      fetchCategories();
    });
  }

  Future<void> openBox() async {
    box = await Hive.openBox<CategoryModel>('categories');
  }

  Future<void> fetchCategories() async {
    expenseCategories = [
      ...box.values.where((category) => category.type == 'Expense'),
      ...defaultExpenseCategories
    ];

    incomeCategories = [
      ...box.values.where((category) => category.type == 'Income'),
      ...defaultIncomeCategories
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Categories'),
        centerTitle: true,
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCategorySection('Income', Colors.green, incomeCategories),
              _buildCategoryList(incomeCategories),
              _buildCategorySection('Expense', Colors.red, expenseCategories),
              _buildCategoryList(expenseCategories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String title, Color color, List<CategoryModel> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Text(
        title,
        style: TextStyle(fontSize: 17, color: color),
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: Image.asset('images/${category.categoryIcon}', height: 40),
          title: Text(category.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryDetailsScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }
}


class CategoryDetailsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late List<Transaction> filteredTransactions;

  @override
  void initState() {
    super.initState();
    filterTransactions();
  }

  void filterTransactions() {
    final box = Hive.box<Transaction>('transactions');
    filteredTransactions = box.values
        .where((transaction) =>
            transaction.category.title == widget.category.title)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: primaryColor,
        centerTitle: true,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                  color:
                      transaction.type == 'Expense' ? Colors.red : Colors.green,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
