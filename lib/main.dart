import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sticks_69/AuthWidget.dart';
import 'AuthWidgetBuilder.dart';
import 'StartPage.dart';

List<CameraDescription> cameras;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthWidgetBuilder(builder: (context, userSnapshot) {
      return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.red,
            focusColor: Colors.red[900],
            accentColor: Colors.red.shade50,
            backgroundColor: Colors.red.shade200,
            primaryColorLight: Colors.white,
            dialogBackgroundColor: Colors.red.shade50,
            textSelectionColor: Colors.black,
            buttonColor: Colors.blueAccent,
            dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(16))),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            snackBarTheme: SnackBarThemeData(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35))),
            fontFamily: "Merriweather",
            errorColor: Colors.redAccent),
        debugShowCheckedModeBanner: false,
        home: AuthWidget(
          userSnapshot: userSnapshot,
        ),
      );
    });
  }
}
