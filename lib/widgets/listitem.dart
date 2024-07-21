import 'package:expensetracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListItem extends StatelessWidget {
  ListItem({
    required this.expensetitle,
    required this.expenseamount,
    required this.expenseCategory,  // Category enum
    required this.expensedate,
    required this.expensemode,
    required this.extype,
  });

  final String expensetitle;
  final String expenseamount;
  final Category expenseCategory;  // Category enum
  final DateTime expensedate;
  final String expensemode;
  final String extype;

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ListTile(
          title: Text(expensetitle),
          leading: Icon(Categoryicons[expenseCategory]),  // Use Category enum to get icon
          subtitle: Row(
            children: [
              Text(expensemode),
              SizedBox(width: 10), // Add space between mode and date
              Text(DateFormat('d MMM y').format(expensedate)),
            ],
          ),
          trailing: Text(expenseamount,style: TextStyle(color: extype =="Income"? Colors.green :Colors.red,fontSize: 16),),
        ),
      ),
    );
  }
}
