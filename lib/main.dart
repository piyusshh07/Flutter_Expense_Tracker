import 'package:expensetracker/firebase_options.dart';
import 'package:expensetracker/screens/authscreen.dart';
import 'package:expensetracker/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/screens/splashscreen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder:(ctx,snapshot)
      {
       if(snapshot.connectionState==ConnectionState.waiting) {
        return SplashScreen();
       }
       if(snapshot.hasData){
         return HomeScreen();
       }
       return Authscreen();
      } ,)
    );
  }
}
