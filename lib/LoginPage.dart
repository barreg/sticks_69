import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticks_69/DatabaseService.dart';
import 'package:sticks_69/Models.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogged = false;
  FirebaseUser myUser;
  var profileData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: Column(children: [
            Container(
                height: 300,
                width: 300,
                child: Image.asset("assets/Vieu_Logo.png")),
            SizedBox(height: 50),
            Container(
                width: 300,
                child: Center(
                    child: Text(
                  "Là gone, ça s'identifie avec Facebook stp la fami ! ",
                  style: TextStyle(
                      color: Theme.of(context).textSelectionColor,
                      fontSize: 20),
                ))),
            SizedBox(height: 50),
            FacebookSignInButton(onPressed: () {
              _logIn();
            }),
          ], mainAxisAlignment: MainAxisAlignment.center),
        ))));
  }

  Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logIn(['email']);

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      // in case ur fucked, redownload GoogleService-info.plist

      FirebaseUser user = await _auth.signInWithCredential(credential);
      var docRef = Firestore.instance.collection("users").document(user.uid);
      docRef.get().then((doc) {
        if (doc.exists) {
          return user;
        } else {
          Firestore.instance.collection("users").document(user.uid).setData({
            'name': "",
            'description': "",
            'photoURL': "",
            'numPoints': 0,
            'isAdmin': false
          });
          return user;
        }
      });
    }
    return null;
  }

  void _logIn() {
    _loginWithFacebook().then((response) {
      if (response != null) {
        myUser = response;
        isLogged = true;
        setState(() {});
      }
    });
  }
}
