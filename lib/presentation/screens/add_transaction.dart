import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/Constants/default_categories.dart';
import 'package:expense_tracker/Constants/limits.dart';
import 'package:expense_tracker/data/utilty.dart';
import 'package:expense_tracker/domain/models/category_model.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<CategoryModel> incomeCategories = defaultIncomeCategories;
  List<CategoryModel> expenseCategories = defaultExpenseCategories;

  final boxTransaction = Hive.box<Transaction>('transactions');
  DateTime date = DateTime.now();
  CategoryModel? selectedCategoryItem;
  String? selectedTypeItem;

  late Box<CategoryModel> box;
  List<CategoryModel> categories = [];

  final List<String> types = ['Income', 'Expense'];
  final TextEditingController explainC = TextEditingController();
  FocusNode explainFocus = FocusNode();
  final TextEditingController amountC = TextEditingController();
  FocusNode amountFocus = FocusNode();

  bool isAmountValid = true;

  @override
  void initState() {
    super.initState();
    explainFocus.addListener(() {
      setState(() {});
    });
    amountFocus.addListener(() {
      setState(() {});
    });

    openBox().then((_) {
      fetchCategories();
    });
  }

  Future<void> openBox() async {
    box = await Hive.openBox<CategoryModel>('categories');
  }

  Future<void> fetchCategories() async {
    categories = box.values.toList();
    setState(() {
      incomeCategories = [
        ...defaultIncomeCategories,
        ...box.values.where((category) => category.type == 'Income'),
      ];
      expenseCategories = [
        ...defaultExpenseCategories,
        ...box.values.where((category) => category.type == 'Expense'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Add Transaction'),
        centerTitle: true,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(child: SingleChildScrollView(child: mainAddContainer())),
      ),
    );
  }

  SizedBox mainAddContainer() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          typeField(),
          const SizedBox(height: 35),
          categoryField(),
          const SizedBox(height: 35),
          amountField(),
          const SizedBox(height: 35),
          descriptionField(),
          const SizedBox(height: 35),
          timeField(),
          const SizedBox(height: 35),
          addTransaction(),
        ],
      ),
    );
  }

  GestureDetector addTransaction() {
    bool isWarningShown = false;

    void showErrorDialog(String title, String content) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (selectedCategoryItem == null ||
            selectedTypeItem == null ||
            explainC.text.isEmpty ||
            amountC.text.isEmpty) {
          showErrorDialog('Error', 'Please fill in all the fields.');
          return;
        }

        double amount = double.tryParse(amountC.text) ?? 0.0;
        if (selectedTypeItem == 'Expense' &&
            amount > limitPerExpense &&
            !isWarningShown) {
          showErrorDialog(
            'Warning',
            'The amount exceeds the spending limit(${formatCurrency(limitPerExpense)}).',
          );
          isWarningShown = true;
          return;
        }

        var newTransaction = Transaction(
          selectedTypeItem!,
          selectedCategoryItem!,
          amountC.text,
          explainC.text,
          date,
        );
        boxTransaction.add(newTransaction);
        Navigator.of(context).pop();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
        ),
        height: 50,
        width: 140,
        child: const Text(
          'Add',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Container typeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: DropdownButton<String>(
        value: selectedTypeItem,
        items: types.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                SizedBox(width: 40, child: Image.asset('images/$e.png')),
                const SizedBox(width: 10),
                Text(e, style: const TextStyle(fontSize: 15)),
              ],
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) => types.map((e) {
          return Row(
            children: [
              SizedBox(width: 40, child: Image.asset('images/$e.png')),
              const SizedBox(width: 10),
              Text(e),
            ],
          );
        }).toList(),
        hint: const Text('Select Type', style: TextStyle(color: Colors.white)),
        isExpanded: true,
        underline: Container(),
        onChanged: ((value) {
          setState(() {
            selectedTypeItem = value!;
            selectedCategoryItem = null;
          });
        }),
      ),
    );
  }

  Container categoryField() {
    final List<CategoryModel> currCategories =
        selectedTypeItem == 'Income' ? incomeCategories : expenseCategories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: DropdownButton<CategoryModel>(
        value: selectedCategoryItem,
        items: currCategories.map((e) {
          return DropdownMenuItem<CategoryModel>(
            value: e,
            child: Row(
              children: [
                SizedBox(
                    width: 40, child: Image.asset('images/${e.categoryIcon}')),
                const SizedBox(width: 10),
                Text(e.title, style: const TextStyle(fontSize: 15)),
              ],
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) => currCategories.map((e) {
          return Row(
            children: [
              SizedBox(
                  width: 40, child: Image.asset('images/${e.categoryIcon}')),
              const SizedBox(width: 10),
              Text(e.title),
            ],
          );
        }).toList(),
        hint: const Text('Select category',
            style: TextStyle(color: Colors.white)),
        isExpanded: true,
        underline: Container(),
        onChanged: (value) {
          setState(() {
            selectedCategoryItem = value;
          });
        },
      ),
    );
  }

  TextField amountField() {
    return TextField(
      keyboardType: TextInputType.number,
      focusNode: amountFocus,
      controller: amountC,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        labelText: 'Amount',
        labelStyle: const TextStyle(fontSize: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 2, color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 2, color: Colors.green),
        ),
        errorText: isAmountValid ? null : 'Amount must be greater than 0',
      ),
      onChanged: (value) {
        setState(() {
          if (value.isEmpty) {
            isAmountValid = true;
          } else {
            isAmountValid =
                double.tryParse(value) != null && double.parse(value) > 0;
          }
        });
      },
    );
  }

  TextField descriptionField() {
    return TextField(
      focusNode: explainFocus,
      controller: explainC,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        labelText: 'Description',
        labelStyle: const TextStyle(fontSize: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 2, color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 2, color: Colors.green),
        ),
      ),
    );
  }

  Container timeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.white),
      ),
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(2030),
          );
          if (newDate == null) return;
          setState(() {
            date = newDate;
          });
        },
        child: Text(
          'Date : ${date.day}/${date.month}/${date.year}',
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Column backgroundAddContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Column(children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                    ),
                  ),
                  const Text(
                    "Add Transaction",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.attach_file_outlined,
                  )
                ],
              ),
            )
          ]),
        )
      ],
    );
  }
}
