import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'Models.dart';

class Singleton {
  static final Singleton _singleton = new Singleton._internal();

  factory Singleton() {
    return _singleton;
  }

  // AuthCredential credential;

  final CollectionReference sticksRef = Firestore.instance.collection('sticks');
  final CollectionReference picsRef = Firestore.instance.collection('pics');
  final StorageReference storageReference = FirebaseStorage().ref();
  //final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event)
  // final CollectionReference userRef = Firestore.instance.collection("users");
  // final CollectionReference logRef = Firestore.instance.collection("logs");

  Stream<List<PicDetails>> streamPics() {
    Stream<QuerySnapshot> snapshots = picsRef.snapshots();
    Stream<List<PicDetails>> result = snapshots.map((snap) => snap.documents
        .map((pic) => PicDetails.fromJson(pic.documentID, pic.data))
        .toList());
        print(result.length);
    return result;
  }

  Stream<List<StickDetails>> streamSticks() {
    Stream<QuerySnapshot> snapshots = sticksRef.snapshots();
    Stream<List<StickDetails>> result = snapshots.map((snap) => snap.documents
        .map((stick) => StickDetails.fromJson(stick.documentID, stick.data))
        .toList());
    return result;
  }

  Singleton._internal();
}
