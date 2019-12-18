import 'dart:async';
import 'dart:io';
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:shared_preferences/shared_preferences.dart';


import 'Models.dart';

class Singleton {
  static final Singleton _singleton = new Singleton._internal();

  factory Singleton() {
    return _singleton;
  }

  // AuthCredential credential;

  // final CollectionReference sticksRef = Firestore.instance.collection('sticks');
  // final CollectionReference userRef = Firestore.instance.collection("users");
  // final CollectionReference logRef = Firestore.instance.collection("logs");

  

  Singleton._internal();

}