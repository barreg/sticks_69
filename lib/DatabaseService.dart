import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sticks_69/Models.dart';

class DatabaseService {
  DatabaseService({@required this.uid}) : assert(uid != null);
  final String uid;

  static final CollectionReference userRef =
      Firestore.instance.collection("users");
  static final CollectionReference logRef =
      Firestore.instance.collection("logs");

  Stream<Userdata> streamUserdata() {
    return userRef
        .document(uid)
        .snapshots()
        .map((snap) => Userdata.fromJson(uid, snap.data));
  }

  Future<void> updateUserdata(Userdata userdata) {
    return userRef.document(uid).setData({
      'name': userdata.name,
      'name_insensitive': userdata.name?.toLowerCase(),
      'description': userdata.description,
      'photoURL': userdata.photoURL
    });
  }

  Stream<List<Friend>> streamFriends() {
    return userRef.document(uid).collection("friends").snapshots().map((snap) =>
        snap.documents
            .map((friend) => Friend.fromJson(friend.documentID, friend.data))
            .toList());
  }


  Stream<List<Userdata>> streamUsersWithName(String name) {
    return userRef
        .where('name_insensitive', isGreaterThanOrEqualTo: name.toLowerCase())
        .where('name_insensitive', isLessThan: name.toLowerCase() + 'z')
        .snapshots()
        .map((users) => users.documents
            .map((user) => Userdata.fromJson(user.documentID, user.data))
            .toList());
  }

  Stream<Userdata> streamUserWithId(String id) {
    return userRef
        .document(id)
        .snapshots()
        .map((snap) => Userdata.fromJson(snap.documentID, snap.data));
  }

  

  

 

  Future<void> deleteFriend(String friendId) {
    return userRef
        .document(uid)
        .collection("friends")
        .document(friendId)
        .delete();
  }

  Future<Friend> getFriend(String friendId) async {
    DocumentSnapshot document = await userRef
        .document(uid)
        .collection("friends")
        .document(friendId)
        .get();
    if (document == null || !document.exists) return null;
    return Friend.fromJson(document.documentID, document.data);
  }

  Future<void> addFriend(Userdata friend) {
    return userRef
        .document(uid)
        .collection("friends")
        .document(friend.uid)
        .setData({
      "uid": friend.uid,
      "date": FieldValue.serverTimestamp(),
      "name": friend.name,
      "photoURL": friend.photoURL,
      "numPoints": friend.numPoints
    });
  }
}
