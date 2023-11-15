import 'package:expense_tracker/presentation/widgets/bottom_navbar.dart';
import 'package:expense_tracker/domain/models/category_model.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

// Future<void> clearData() async {
//   await Hive.initFlutter();
//   Hive.registerAdapter(TransactionAdapter());
//   Hive.registerAdapter(CategoryModelAdapter());

//   // Open both boxes
//   await Hive.openBox<Transaction>('transactions');
//   await Hive.openBox<CategoryModel>('categories');

//   // Clear data from both boxes
//   await Hive.box<Transaction>('transactions').clear();
//   await Hive.box<CategoryModel>('categories').clear();

//   // Close Hive
//   await Hive.close();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await clearData();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<CategoryModel>('categories');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          background: Color(0xff151515),
          primary: Colors.blue,
          onPrimary: Colors.black,
          primaryContainer: Colors.blue,
          onPrimaryContainer: Colors.black,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const Bottom(),
    );
  }
}
