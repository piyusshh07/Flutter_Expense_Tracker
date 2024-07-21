import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/models/category.dart';
import 'package:uuid/uuid.dart';

const uuid=Uuid();
class Expense{
Expense({required this.title,
  required this.amount,
  required this.date,
  required this.category,
  required this.Type,
  required this.mode}):id=uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final String Type;
  final String mode;

}