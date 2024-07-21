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

  void _updateDate() {
    setState(() {
      _formattedDate = DateFormat('d MMM y').format(_currentDate);
      print('Updated date: $_formattedDate');  // Debugging print
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
          );
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
          SizedBox(height: 0,),
          Expanded(  // Make sure the list expands properly
            child: ExpensesList(date: _currentDate),
          ),
        ],
      ),
    );
  }
}
