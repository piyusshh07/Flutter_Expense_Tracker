import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/widgets/bottomsheet.dart';
import 'package:expensetracker/widgets/expenseslist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentDate = DateTime.now();
  String _formattedDate = DateFormat('d MMM y').format(DateTime.now());
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _updateDate() {
    setState(() {
      _formattedDate = DateFormat('d MMM y').format(_currentDate);
    });
  }

  void _previousDate() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
      _updateDate();
    });
  }

  void _nextDate() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 1));
      _updateDate();
    });
  }

  Future<void> _calculateTotals() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('expense')
        .where('Userid', isEqualTo: user.uid)
        .get();

    double income = 0.0;
    double expense = 0.0;

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      try {
        double amount = double.parse(data['ExpenseAmount']);
        String type = data['ExpenseType']; // Assuming 'type' is 'income' or 'expense'

        if (type == 'Income') {
          income += amount;
        } else if (type == 'Expense') {
          expense += amount;
        }
      } catch (e) {
        print("Error parsing ExpenseAmount: ${data['ExpenseAmount']}");
        // Optionally, handle the error, e.g., by logging or showing a message to the user
      }
    }

    setState(() {
      totalIncome = income;
      totalExpense = expense;
      totalBalance = income - expense;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 20),
                    Container(width: 100, child: Text('Logout')),
                  ],
                ),
                onTap: FirebaseAuth.instance.signOut,
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) => bottomsheet(),
          ).then((_) => _calculateTotals()); // Recalculate totals when the bottom sheet is closed
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousDate,
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                ),
                Text(
                  _formattedDate,
                  style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: _nextDate,
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 0, right: 3, left: 3),
            child: Container(
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("INCOME", style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(totalIncome.toString(), style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Text("EXPENSE", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(totalExpense.toString(), style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Text("BALANCE", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(totalBalance.toString(), style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600))
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(  // Make sure the list expands properly
            child: ExpensesList(date: _currentDate),
          ),
        ],
      ),
    );
  }
}
