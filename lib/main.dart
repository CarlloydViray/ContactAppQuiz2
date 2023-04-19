import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_2_mad/firebase_options.dart';
import 'package:quiz_2_mad/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xffF2E3DB),
          appBarTheme: AppBarTheme(backgroundColor: Color(0xff263A29))),
      home: homeScreen(),
    );
  }
}
