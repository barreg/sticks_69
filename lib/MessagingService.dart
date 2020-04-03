import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///This class is not yet used, but will be when notifications will be send to users.
class MessagingService {
  final String uid;
  MessagingService({@required this.uid}) {
    assert(uid != null);
    _setupMessaging(uid);
  }

  final CollectionReference userRef = Firestore.instance.collection("users");

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _setupMessaging(String uid) async {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      bool _bNotifications = _prefs.getBool('bNotifications') ?? true;
      userRef.document(uid).collection("data").document("metadata").setData(
          {"token": token, "bPushEnabled": _bNotifications},
          merge: true);
    });
  }

  updatePushMessaging(uid) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool _bNotifications = _prefs.getBool('bNotifications') ?? true;
    await userRef
        .document(uid)
        .collection("data")
        .document("metadata")
        .setData({"bPushEnabled": _bNotifications}, merge: true);
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //print("Settings registered: $settings");
    });
  }
}
