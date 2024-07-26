import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/models/category.dart';
import 'package:expensetracker/widgets/listitem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
 ExpensesList({required this.date, super.key});
 final DateTime date;

 @override
 Widget build(BuildContext context) {
  var user = FirebaseAuth.instance.currentUser;
  DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
  DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  return StreamBuilder(
   stream: FirebaseFirestore.instance.collection('expense')
       .where('Userid', isEqualTo: user?.uid)
       .where('ExpenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
       .where('ExpenseDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
       .orderBy('CreatedAt')
       .snapshots(),
   builder: (ctx, AsyncSnapshot<QuerySnapshot> listSnapshots) {
    if (listSnapshots.connectionState == ConnectionState.waiting) {
     return const Center(
      child: CircularProgressIndicator(),
     );
    }
    if (listSnapshots.hasError) {
     return Center(child: Text("Something went wrong: ${listSnapshots.error}"));
    }
    if (!listSnapshots.hasData || listSnapshots.data!.docs.isEmpty) {
     print('No expenses found');  // Debugging print
     return   Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Opacity(
          opacity:0.5,
          child: Image.asset("assets/images/wallet.png",height: 100,width: 100,)),
       SizedBox(height: 10,),
       Text("No Expenses Found For the Day Try Adding Some..!!")
     ],);
    }

    final listofexpenses = listSnapshots.data!.docs;
    return ListView.builder(
     itemCount: listofexpenses.length,
     itemBuilder: (ctx, index) {
      final exdata = listofexpenses[index].data() as Map<String, dynamic>;
      final expenseCategoryString = exdata["ExpenseCategory"];
      final expenseCategory = stringToCategory(expenseCategoryString);
      // Convert to Category enum
      return ListItem(
       expensetitle: exdata["ExpenseName"],
       expenseamount: exdata["ExpenseAmount"].toString(),  // Ensure expenseAmount is a string
       expenseCategory: expenseCategory,  // Pass Category enum
       expensedate: (exdata["ExpenseDate"] as Timestamp).toDate(),
       expensemode: exdata["ExpenseMode"],
       extype:exdata["ExpenseType"],
      );
     },
    );
   },
  );
 }
}
