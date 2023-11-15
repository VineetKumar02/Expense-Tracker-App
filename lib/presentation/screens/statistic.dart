import 'package:expense_tracker/Constants/color.dart';
import 'package:expense_tracker/data/utilty.dart';
import 'package:expense_tracker/domain/models/transaction_model.dart';
import 'package:expense_tracker/presentation/widgets/circular_chart.dart';
import 'package:expense_tracker/presentation/widgets/column_chart.dart';
// import 'package:expense_tracker/presentation/widgets/spline_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  get selectedDate => null;

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics>
    with SingleTickerProviderStateMixin {
  ValueNotifier<int> notifier = ValueNotifier<int>(0);
  final box = Hive.box<Transaction>('transactions');

  List day = ['Day', 'Week', 'Month', 'Year'];
  List listTransaction = [[], [], [], []];
  List<Transaction> currListTransaction = [];
  int indexColor = 0;

  DateTime selectedDate = DateTime.now();
  late int totalIn;
  late int totalEx;
  late int total;

  late TabController _tabController;
  late bool isCircularChartSelected;

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  void initializeState() {
    notifier.value = 0;
    isCircularChartSelected = false;
    _tabController = TabController(length: 2, vsync: this);
    box.listenable().addListener(updateNotifier);
    fetchTransactions();
  }

  @override
  void dispose() {
    box.listenable().removeListener(updateNotifier);
    _tabController.dispose();
    super.dispose();
  }

  void updateNotifier() {
    fetchTransactions();
  }

  void fetchTransactions() {
    listTransaction[0] = getTransactionToday(selectedDate);
    listTransaction[1] = getTransactionWeek(selectedDate);
    listTransaction[2] = getTransactionMonth(selectedDate);
    listTransaction[3] = getTransactionYear(selectedDate);
    totalIn = totalFilterdIncome(currListTransaction);
    totalEx = totalFilterdExpense(currListTransaction);
    total = totalIn - totalEx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ValueListenableBuilder<int>(
          valueListenable: notifier,
          builder: (BuildContext context, int value, Widget? child) {
            currListTransaction = listTransaction[value];
            fetchTransactions();
            return buildCustomScrollView();
          },
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Text('Statistics'),
      centerTitle: true,
      toolbarHeight: 60,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  CustomScrollView buildCustomScrollView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 30),
              buildDateSelector(),
              const SizedBox(height: 20),
              buildDateInfo(),
              // SplineChart(
              //   transactions: currListTransaction,
              //   currIndex: indexColor,
              // ),
              const SizedBox(height: 15),
              buildChartSelector(),
              const SizedBox(height: 15),
              isCircularChartSelected
                  ? buildCircularCharts()
                  : buildColumnChart(),
              const SizedBox(height: 20),
              buildTransactionSummary(),
              const SizedBox(height: 30),
              buildTopSpendingHeader(),
            ],
          ),
        ),
        buildTransactionList(),
      ],
    );
  }

  Row buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...List.generate(4, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                indexColor = index;
                notifier.value = index;
                selectedDate = indexColor == 1
                    ? DateTime.now()
                        .subtract(Duration(days: DateTime.now().weekday - 1))
                    : DateTime.now();
                fetchTransactions();
              });
            },
            child: Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: indexColor == index ? primaryColor : Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(
                day[index],
                style: TextStyle(
                  color: indexColor == index ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Padding buildDateInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getFormattedDate(indexColor, selectedDate),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          buildDateNavigationButtons(),
        ],
      ),
    );
  }

  Row buildDateNavigationButtons() {
    return Row(
      children: [
        IconButton(
          onPressed: () => updateSelectedDate(-1),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: () => updateSelectedDate(1),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  void updateSelectedDate(int daysToAdd) {
    setState(() {
      selectedDate = indexColor == 0
          ? selectedDate.add(Duration(days: daysToAdd))
          : indexColor == 1
              ? selectedDate.add(Duration(days: 7 * daysToAdd))
              : indexColor == 2
                  ? DateTime(selectedDate.year, selectedDate.month + daysToAdd,
                      selectedDate.day)
                  : DateTime(selectedDate.year + daysToAdd, selectedDate.month,
                      selectedDate.day);
      fetchTransactions();
    });
  }

  Container buildChartSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TabBar(
        controller: _tabController,
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: 'Column'),
          Tab(text: 'Circular'),
        ],
        onTap: (index) {
          setState(() {
            isCircularChartSelected = index == 1;
          });
        },
      ),
    );
  }

  Column buildCircularCharts() {
    return Column(
      children: [
        CircularChart(
            title: "Income",
            currIndex: indexColor,
            transactions: currListTransaction),
        CircularChart(
            title: "Expense",
            currIndex: indexColor,
            transactions: currListTransaction),
      ],
    );
  }

  ColumnChart buildColumnChart() {
    return ColumnChart(
        transactions: currListTransaction, currIndex: indexColor);
  }

  Padding buildTransactionSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          buildSummaryRow('Income', totalIn, Colors.green),
          const SizedBox(height: 10),
          buildSummaryRow('Expenses', totalEx, Colors.red),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.grey, thickness: 1),
          const SizedBox(height: 10),
          buildSummaryRow('Total', total, Colors.white),
        ],
      ),
    );
  }

  Row buildSummaryRow(String label, int value, Color color) {
    IconData icon;
    if (label == 'Income') {
      icon = Icons.arrow_upward;
    } else if (label == 'Expenses') {
      icon = Icons.arrow_downward;
    } else {
      // Assume 'Total'
      icon = Icons.attach_money;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
                radius: 13,
                backgroundColor: color,
                child: Icon(icon, size: 19)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 17, color: color),
            ),
          ],
        ),
        Text(
          formatCurrency(value),
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 17, color: color),
        ),
      ],
    );
  }

  Padding buildTopSpendingHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Top Spending',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Icon(Icons.swap_vert, size: 25, color: Colors.grey),
        ],
      ),
    );
  }

  SliverList buildTransactionList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                'images/${currListTransaction[index].category.categoryIcon}',
                height: 40,
              ),
            ),
            title: Text(
              currListTransaction[index].description,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${currListTransaction[index].createAt.day}/${currListTransaction[index].createAt.month}/${currListTransaction[index].createAt.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              formatCurrency(int.parse(currListTransaction[index].amount)),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: currListTransaction[index].type == 'Expense'
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          );
        },
        childCount: currListTransaction.length,
      ),
    );
  }
}



// import 'package:expense_tracker/Constants/color.dart';
// import 'package:expense_tracker/presentation/widgets/circular_chart.dart';
// import 'package:expense_tracker/presentation/widgets/column_chart.dart';
// import 'package:expense_tracker/presentation/widgets/spline_chart.dart';
// import 'package:expense_tracker/data/utilty.dart';
// import 'package:expense_tracker/domain/models/transaction_model.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/adapters.dart';

// class Statistics extends StatefulWidget {
//   const Statistics({super.key});

//   get selectedDate => null;

//   @override
//   State<Statistics> createState() => _StatisticsState();
// }

// ValueNotifier<int> notifier = ValueNotifier<int>(0);

// class _StatisticsState extends State<Statistics>
//     with SingleTickerProviderStateMixin {
//   final box = Hive.box<Transaction>('transactions');

//   List day = ['Day', 'Week', 'Month', 'Year'];
//   List listTransaction = [[], [], [], []];
//   List<Transaction> currListTransaction = [];
//   int indexColor = 0;

//   DateTime selectedDate = DateTime.now();
//   late int totalIn;
//   late int totalEx;
//   late int total;

//   late TabController _tabController;
//   late bool isCircularChartSelected;
//   @override
//   void initState() {
//     super.initState();
//     notifier.value = 0;
//     isCircularChartSelected = false;
//     _tabController = TabController(length: 2, vsync: this);
//     box.listenable().addListener(updateNotifier);
//     fetchTransactions();
//   }

//   @override
//   void dispose() {
//     box.listenable().removeListener(updateNotifier);
//     _tabController.dispose();
//     super.dispose();
//   }

//   void updateNotifier() {
//     fetchTransactions();
//   }

//   void fetchTransactions() {
//     listTransaction[0] = getTransactionToday(selectedDate);
//     listTransaction[1] = getTransactionWeek(selectedDate);
//     listTransaction[2] = getTransactionMonth(selectedDate);
//     listTransaction[3] = getTransactionYear(selectedDate);
//     totalIn = totalFilterdIncome(currListTransaction);
//     totalEx = totalFilterdExpense(currListTransaction);
//     total = totalIn - totalEx;
//     // print(
//     //   'total: $total $totalIn $totalEx',
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: const Text('Statistics'),
//         centerTitle: true,
//         toolbarHeight: 60,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(20),
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder<int>(
//         valueListenable: notifier,
//         builder: (BuildContext context, int value, Widget? child) {
//           // print(value);
//           // print(currListTransaction);
//           currListTransaction = listTransaction[value];
//           totalIn = totalFilterdIncome(currListTransaction);
//           totalEx = totalFilterdExpense(currListTransaction);
//           total = totalIn - totalEx;
//           // print(
//           //   'total: $total $totalIn $totalEx',
//           // );
//           fetchTransactions();
//           return customScrollView();
//         },
//       ),
//     );
//   }

//   CustomScrollView customScrollView() {
//     return CustomScrollView(
//       slivers: [
//         SliverToBoxAdapter(
//           child: Column(children: [
//             const SizedBox(height: 30),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ...List.generate(4, (index) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           indexColor = index;
//                           notifier.value = index;
//                           if (indexColor == 1) {
//                             selectedDate = DateTime.now().subtract(
//                                 Duration(days: DateTime.now().weekday - 1));
//                           } else {
//                             selectedDate = DateTime.now();
//                           }

//                           fetchTransactions();
//                         });
//                         // print(selectedDate);
//                       },
//                       child: Container(
//                         height: 40,
//                         width: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color:
//                               indexColor == index ? primaryColor : Colors.white,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           day[index],
//                           style: TextStyle(
//                             color: indexColor == index
//                                 ? Colors.white
//                                 : Colors.black,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       getFormattedDate(indexColor, selectedDate),
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 if (indexColor == 0) {
//                                   selectedDate = selectedDate
//                                       .subtract(const Duration(days: 1));
//                                 } else if (indexColor == 1) {
//                                   selectedDate = selectedDate
//                                       .subtract(const Duration(days: 7));
//                                 } else if (indexColor == 2) {
//                                   selectedDate = DateTime(selectedDate.year,
//                                       selectedDate.month - 1, selectedDate.day);
//                                 } else if (indexColor == 3) {
//                                   selectedDate = DateTime(selectedDate.year - 1,
//                                       selectedDate.month, selectedDate.day);
//                                 }
//                               });
//                               fetchTransactions();
//                             },
//                             icon: const Icon(Icons.arrow_back_ios_new)),
//                         const SizedBox(width: 15),
//                         IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 if (indexColor == 0) {
//                                   selectedDate =
//                                       selectedDate.add(const Duration(days: 1));
//                                 } else if (indexColor == 1) {
//                                   selectedDate =
//                                       selectedDate.add(const Duration(days: 7));
//                                 } else if (indexColor == 2) {
//                                   selectedDate = DateTime(selectedDate.year,
//                                       selectedDate.month + 1, selectedDate.day);
//                                 } else if (indexColor == 3) {
//                                   selectedDate = DateTime(selectedDate.year + 1,
//                                       selectedDate.month, selectedDate.day);
//                                 }
//                                 fetchTransactions();
//                               });
//                             },
//                             icon: const Icon(Icons.arrow_forward_ios)),
//                       ],
//                     )
//                   ],
//                 )),

//             SplineChart(
//               transactions: currListTransaction,
//               currIndex: indexColor,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: TabBar(
//                 controller: _tabController,
//                 indicatorColor: primaryColor,
//                 labelColor: primaryColor,
//                 unselectedLabelColor: Colors.white,
//                 tabs: const [
//                   Tab(text: 'Column'),
//                   Tab(text: 'Circular'),
//                 ],
//                 onTap: (index) {
//                   setState(() {
//                     isCircularChartSelected = index == 1;
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(height: 15),
//             isCircularChartSelected
//                 ? Column(
//                     children: [
//                       CircularChart(
//                           title: "Income",
//                           currIndex: indexColor,
//                           transactions: currListTransaction),
//                       CircularChart(
//                           title: "Expense",
//                           currIndex: indexColor,
//                           transactions: currListTransaction),
//                     ],
//                   )
//                 : ColumnChart(
//                     transactions: currListTransaction,
//                     currIndex: indexColor,
//                   ),

//             const SizedBox(height: 20),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 13,
//                             backgroundColor: Colors.green,
//                             child: Icon(
//                               Icons.arrow_upward,
//                               size: 19,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             'Income',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 17,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         formatCurrency(totalIn),
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 17,
//                           color: Colors.green,
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 13,
//                             backgroundColor: Colors.red,
//                             child: Icon(
//                               Icons.arrow_downward,
//                               size: 19,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Text(
//                             'Expenses',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 17,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         formatCurrency(totalEx),
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 17,
//                           color: Colors.red,
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const Divider(
//                     height: 1,
//                     color: Colors.grey,
//                     thickness: 1,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           SizedBox(width: 30),
//                           Text(
//                             'Total:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         formatCurrency(total),
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 15,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Top Spending',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Icon(
//                     Icons.swap_vert,
//                     size: 25,
//                     color: Colors.grey,
//                   )
//                 ],
//               ),
//             )
//           ]),
//         ),
//         SliverList(
//           delegate: SliverChildBuilderDelegate((context, index) {
//             return ListTile(
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(5),
//                 child: Image.asset(
//                     'images/${currListTransaction[index].category.categoryIcon}',
//                     height: 40),
//               ),
//               title: Text(
//                 currListTransaction[index].description,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               subtitle: Text(
//                 '${currListTransaction[index].createAt.day}/${currListTransaction[index].createAt.month}/${currListTransaction[index].createAt.year}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               trailing: Text(
//                 formatCurrency(int.parse(currListTransaction[index].amount)),
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 17,
//                   color: currListTransaction[index].type == 'Expense'
//                       ? Colors.red
//                       : Colors.green,
//                 ),
//               ),
//             );
//           }, childCount: currListTransaction.length),
//         )
//       ],
//     );
//   }
// }
