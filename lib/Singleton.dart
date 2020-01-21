import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  

  Singleton._internal();

}