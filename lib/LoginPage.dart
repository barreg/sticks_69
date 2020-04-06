import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
            SizedBox(height: 20),
            Container(
                width: 300,
                child: Center(
                    child: Text(
                  "Là gone, ça s'identifie avec Facebook stp la fami ! ",
                  style: TextStyle(
                      color: Theme.of(context).textSelectionColor,
                      fontSize: 20),
                ))),
            SizedBox(height: 20),
            FacebookSignInButton(onPressed: () {
              _logIn();
            }),
            FacebookSignInButton(onPressed: () {
              _logOut();
            }),
            Container(
              child: Center(
                child: isLogged
                    ? _displayUserData(profileData)
                    : null,
              ),
            )
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
      FirebaseUser user = await _auth.signInWithCredential(credential);      
      return user;
    }
    return null;
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() {});
    });
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

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          "Logged in as: ${profileData['name']}",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }
}
