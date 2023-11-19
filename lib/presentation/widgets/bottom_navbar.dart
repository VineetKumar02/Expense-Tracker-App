import 'package:flutter/material.dart';
import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/presentation/screens/add_transaction.dart';
import 'package:expense_tracker/presentation/screens/category_screen.dart';
import 'package:expense_tracker/presentation/screens/home.dart';
import 'package:expense_tracker/presentation/screens/search_screen.dart';
import 'package:expense_tracker/presentation/screens/statistic.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int indexColor = 0;
  List screens = [
    const Home(),
    const Statistics(),
    const CategoryScreen(),
    const SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: indexColor == 0 // Check if it's the home page
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddScreen()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null, // If not the home page, set to null to hide
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  indexColor = 0;
                });
              },
              icon: Icon(
                Icons.home,
                size: 30,
                color: indexColor == 0 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  indexColor = 1;
                });
              },
              icon: Icon(
                Icons.bar_chart_outlined,
                size: 30,
                color: indexColor == 1 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  indexColor = 2;
                });
              },
              icon: Icon(
                Icons.category_outlined,
                size: 30,
                color: indexColor == 2 ? primaryColor : secondaryColor,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  indexColor = 3;
                });
              },
              icon: Icon(
                Icons.search_outlined,
                size: 30,
                color: indexColor == 3 ? primaryColor : secondaryColor,
              ),
            ),
          ],
        ),
      ),
      body: screens[indexColor],
    );
  }
}
