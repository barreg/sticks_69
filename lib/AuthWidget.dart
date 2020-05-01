import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticks_69/DatabaseService.dart';
import 'package:sticks_69/LoginPage.dart';
import 'package:sticks_69/StartPage.dart';
import 'AccountSetupPage.dart';
import 'Models.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
class AuthWidget extends StatelessWidget {
  const AuthWidget({Key key, @required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<FirebaseUser> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        try {
        if (Provider.of<Userdata>(context).name == "") {         
          return AccountSetupPage();
        }
        return StartPage();
        } catch (err) {}
      } else
        return LoginPage();
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
