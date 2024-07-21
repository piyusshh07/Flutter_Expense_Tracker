import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authscreen extends StatefulWidget {
  @override
  State<Authscreen> createState() => _AuthscreenState();
}

final _firebase = FirebaseAuth.instance;

class _AuthscreenState extends State<Authscreen> {
  @override
  final _form = GlobalKey<FormState>();
  var _registerationpage = false;
  var enteredusername = '';
  var enteredemail = '';
  var enteredpassword = '';
  var _isAuthenticating = false;


  void submit() async {
    final _isvalid = _form.currentState!.validate();
    if (!_isvalid || _registerationpage && enteredusername == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_registerationpage) {
        final usercredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredemail, password: enteredusername);
      }
      else
        final checkuser = await _firebase.signInWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
    }
    on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')
          )
      );
    }
    setState(() {
      _isAuthenticating = false;
    });
    final user=FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection("UserData")
        .doc(user!.uid)
    .set({
      'UserName': enteredusername,
      'EmailId': enteredemail,
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/wallet.png', height: 70, width: 70,),
                      Text('Expense Tracker')],
                  ),
                ),
                Card(
                    margin: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Form(
                                key: _form,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(_registerationpage)
                                        TextFormField(
                                          decoration: InputDecoration(
                                              label: Text('Enter your name'),
                                              border: OutlineInputBorder()
                                          ),
                                          validator: (value) {
                                            if (value == null || value
                                                .trim()
                                                .isEmpty) {
                                              return "please enter a valid username";
                                            }
                                          },
                                          onSaved: (value) {
                                            enteredusername = value!;
                                          },
                                        ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            label: Text('Email Id'),
                                            border: OutlineInputBorder()
                                        ),
                                        validator: (value) {
                                          if (value == null || value
                                              .trim()
                                              .isEmpty ||
                                              !value.trim().contains('@')) {
                                            return "please enter a valid Email id";
                                          }
                                        },
                                        onSaved: (value) {
                                          enteredemail = value!;
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            label: Text('Password'),
                                            border: OutlineInputBorder()
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value
                                              .trim()
                                              .isEmpty || value
                                              .trim()
                                              .length <= 6) {
                                            return "Password must be at least 6 characters";
                                          }
                                        },
                                        onSaved: (value) {
                                          enteredpassword = value!;
                                        },
                                      ),
                                      if(_isAuthenticating) CircularProgressIndicator(),
                                      if(!_isAuthenticating)
                                        ElevatedButton(onPressed: submit
                                          ,
                                          child: Text(_registerationpage
                                              ? 'LOG IN'
                                              : 'SIGN IN'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .deepPurpleAccent,
                                              foregroundColor: Colors.black),),
                                      TextButton(onPressed: () {
                                        setState(() {
                                          _registerationpage =
                                          !_registerationpage;
                                        });
                                      }
                                        , child: Text(_registerationpage
                                            ? 'I already have an account'
                                            : 'Create new user'),),

                                    ]
                                )
                            )
                        )
                    )
                )
              ],
            )
        )
    );
  }
}