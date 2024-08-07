import 'package:flutter/material.dart';

enum Category {
  Food,
  Drinks,
  Housing,
  Transportation,
  Vehicle,
  Bills,
  Investments,
  Rent,
  Salary,
  shopping,
  Other,
}

const Categoryicons = {
  Category.Food: Icons.fastfood_rounded,
  Category.Drinks: Icons.local_drink_rounded,
  Category.Housing: Icons.house_outlined,
  Category.Transportation: Icons.directions_bus_outlined,
  Category.Vehicle: Icons.car_repair_outlined,
  Category.Bills: Icons.my_library_books_rounded,
  Category.Investments: Icons.monitor_heart_rounded,
  Category.Rent: Icons.monetization_on_rounded,
  Category.Salary: Icons.currency_rupee,
  Category.Other: Icons.menu,
  Category.shopping : Icons.shopping_cart_outlined,
};
//Convert Category to String
String categoryToString(Category category) => category.toString().split('.').last;

// Convert String to Category
Category stringToCategory(String categoryString) {
  return Category.values.firstWhere(
        (e) => categoryToString(e) == categoryString,
    orElse: () => Category.Other,
  );
}