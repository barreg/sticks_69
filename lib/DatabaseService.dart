import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sticks_69/Models.dart';

class DatabaseService {
  DatabaseService({@required this.uid}) : assert(uid != null);
  final String uid;

  static final CollectionReference userRef = Firestore.instance.collection("users");
  static final CollectionReference picsRef = Firestore.instance.collection("pics");
  static final CollectionReference sticksRef = Firestore.instance.collection("sticks");
  


  Stream<Userdata> streamUserdata() {
    return userRef
        .document(uid)
        .snapshots()
        .map((snap) => Userdata.fromJson(uid, snap.data));
  }

  Future<void> updateUserdata(Userdata userdata) {
    return userRef.document(uid).setData({
      'name': userdata.name,
      'description': userdata.description,
      'photoURL': userdata.photoURL,
      'numPoints': userdata.numPoints,
      'isAdmin': userdata.isAdmin
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

  Stream<List<PicDetails>> streamPics() {
    Stream<QuerySnapshot> snapshots;
    snapshots = picsRef.snapshots();
    
    Stream<List<PicDetails>> result = snapshots.map((snap) => snap.documents
        .map((task) => PicDetails.fromJson(task.documentID, task.data))
        .toList());
    return result;
  }

  Stream<List<StickDetails>> streamSticks() {
    Stream<QuerySnapshot> snapshots;
    snapshots = sticksRef.snapshots();
    
    Stream<List<StickDetails>> result = snapshots.map((snap) => snap.documents
        .map((task) => StickDetails.fromJson(task.documentID, task.data))
        .toList());
    return result;
  }
  Future<String> createStick(StickDetails stick) async {
    await userRef.document(uid).updateData({
      "numPoints": FieldValue.increment(1)
    });
    DocumentReference doc = await sticksRef.add({
      "coordonnées": stick.location,
      "name": stick.name,
      "description": stick.description,
      "creator": stick.creator
    });
    return doc.documentID;
  }

  Future<void> updateStick(StickDetails stick) async {
    await sticksRef.document(stick.id).updateData({
      "coordonnées": stick.location,
      "name": stick.name,
      "description": stick.description,
      "creator": stick.creator
    });
  }

  Future<void> deleteStick(StickDetails stick) {
    return sticksRef.document(stick.id).delete();
  }

  Future<String> createPic(PicDetails pic) async {
    DocumentReference doc = await picsRef.add({
      "imageURL": pic.imageURL, 
      "creator" : pic.creator,
      "creationTime": pic.creationTime
    });
    return doc.documentID;
  }

  Future<void> deletePic(PicDetails pic) {
    return picsRef.document(pic.id).delete();
  }

}
