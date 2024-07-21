import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/models/category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class bottomsheet extends StatefulWidget {
  @override
  State<bottomsheet> createState() {
    return _bottomsheetState();
  }
}

class _bottomsheetState extends State<bottomsheet> {
  var defaultdecoration = BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10));
  var _incomedecore = BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10));
  var _expensedecore = BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10));
  var boxdecore = BoxDecoration(border: Border.all(color: Colors.black54), borderRadius: BorderRadius.circular(10));

  DateTime? _selecteddate;
  Category _selectedcategory = Category.Other;
  var _selectedtype = "";
  final formatter = DateFormat('d MMM y');
  final _form = GlobalKey<FormState>();
  var _issaving = false;

  String Toasttext = "";
  var _expensename;
  double? _examount;
  var selectedmodevalue = 'Cash';

  void _datepicker() async {
    final now = DateTime.now();
    final firstdate = DateTime(now.year - 1, now.month, now.day);
    final lastdate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstdate,
      lastDate: lastdate,
      initialDate: now,
    );
    setState(() {
      _selecteddate = pickedDate;
    });
  }

  void _incomeselected() {
    setState(() {
      _incomedecore = BoxDecoration(
        border: Border.all(color: Colors.green),
        color: Color.fromARGB(136, 106, 234, 71),
        borderRadius: BorderRadius.circular(10),
      );
      _expensedecore = defaultdecoration;
      _selectedtype = "Income";
    });
  }

  void _expenseselected() {
    setState(() {
      _expensedecore = BoxDecoration(
        border: Border.all(color: Colors.red),
        color: Color.fromARGB(136, 244, 73, 73),
        borderRadius: BorderRadius.circular(10),
      );
      _incomedecore = defaultdecoration;
      _selectedtype = "Expense";
    });
  }

  void submitdata() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      print("Form is not valid"); // Debug print
      return;
    }

    if (_selectedtype == "") {
      setState(() {
        Toasttext = "Please select a type";
      });
      Fluttertoast.showToast(
        msg: Toasttext,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (_selecteddate == null) {
      setState(() {
        Toasttext = "Please select a date";
      });
      Fluttertoast.showToast(
        msg: Toasttext,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    _form.currentState!.save();

    final user = FirebaseAuth.instance.currentUser!;
    final expenseData = {
      "ExpenseName": _expensename,
      "ExpenseAmount": _examount.toString(),
      "ExpenseDate": Timestamp.fromDate(_selecteddate!),
      "ExpenseCategory": categoryToString(_selectedcategory),
      "ExpenseType": _selectedtype,
      "ExpenseMode": selectedmodevalue,
      "Userid": user.uid,
      "CreatedAt": Timestamp.now(),
    };
    print("Submitting data: $expenseData"); // Debug print

    try {
      setState(() {
        _issaving = true;
      });
      await FirebaseFirestore.instance.collection("expense").add(expenseData);
      Navigator.pop(context);
    } catch (error) {
      print("Failed to submit data: $error"); // Debug print
      Fluttertoast.showToast(
        msg: "Failed to submit data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _issaving = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Container(
        height: 900,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, keyboard + 16),
          child: Column(
            children: [
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _incomeselected,
                    child: Container(
                      height: 50, width: 150,
                      decoration: _incomedecore,
                      child: Center(child: Text("Income", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)),
                    ),
                  ),
                  GestureDetector(
                    onTap: _expenseselected,
                    child: Container(
                      height: 50, width: 150,
                      decoration: _expensedecore,
                      child: Center(child: Text("Expense", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Title for transaction', style: TextStyle(color: Colors.black,),),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || value.trim().length < 2) {
                            return "Please enter a valid name for expense";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _expensename = value;
                        },
                      ),
                      SizedBox(height: 10,),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: TextFormField(
                              decoration: InputDecoration(
                                prefix: Icon(Icons.currency_rupee, size: 18),
                                label: Text('Amount', style: TextStyle(color: Colors.black,),),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty || value == "0") {
                                  return "Please enter a valid Amount";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _examount = double.tryParse(value ?? '0');
                              },
                            ),
                          ),
                          Container(
                            child: Center(child: DropdownButton<String>(
                              value: selectedmodevalue,
                              onChanged: (String? newvalue) {
                                setState(() {
                                  selectedmodevalue = newvalue!;
                                });
                              }, items: [
                              DropdownMenuItem<String>(value: 'Cash', child: Text('Cash')),
                              DropdownMenuItem<String>(value: 'Card', child: Text('Card')),
                              DropdownMenuItem<String>(value: 'Online', child: Text('Online')),
                            ],
                            )),
                            width: 100,
                            height: 50,
                            decoration: boxdecore,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      GestureDetector(
                        onTap: _datepicker,
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: boxdecore,
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.date_range),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(_selecteddate == null ? 'Select Date' : formatter.format(_selecteddate!),
                                      style: TextStyle(color: Colors.black,fontSize: 18),),
                                  ),

                                ],
                              ),
                          ),
                          ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        height: 60,
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: boxdecore,
                        child:  DropdownButton<Category>(
                            value: _selectedcategory,
                            items: Category.values.map((Category) => DropdownMenuItem(value: Category, child: Text(Category.name))).toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  _selectedcategory = value;
                                }
                              });
                            },

                        ),
                      ),
                      SizedBox(height: 20,),
                       (_issaving) ? CircularProgressIndicator() :
                        Container( width: 400,child: ElevatedButton(
                          onPressed: submitdata, child: Text("Add Expense"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.black54),
                        )
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
