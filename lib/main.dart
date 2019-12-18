import 'package:flutter/material.dart';
import 'StartPage.dart';



void main() => runApp(MyApp());
  
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
            primaryColor: Colors.redAccent, primaryColorLight: Colors.white),
      home: StartPage(),
      builder: (BuildContext context, Widget child) {
        return Scaffold(body: child);
      }
    );
  }
}