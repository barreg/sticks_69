import 'package:cloud_firestore/cloud_firestore.dart';

class Userdata {
  final String uid;
  String name;
  String description;
  String photoURL;
  int numPoints;
  final bool isAdmin;

  Userdata(this.uid, this.name, this.description, this.photoURL, this.numPoints,
      this.isAdmin);

  factory Userdata.fromJson(uid, Map<String, dynamic> json) {
    json = json ?? {};
    return Userdata(uid, json["name"], json["description"], json["photoURL"],
        json["numPoints"], json["isAdmin"] ?? false);
  }
}

class Friend {
  String id;
  String name;
  String photoURL;
  DateTime date;
  int numPoints;

  Friend(this.id, this.name, this.photoURL, this.date, this.numPoints);

  factory Friend.fromJson(String id, Map<String, dynamic> json) {
    json = json ?? {};
    return Friend(id, json["name"], json["photoURL"], json["date"]?.toDate(),
        json["numPoints"] ?? 0);
  }
}

class StickDetails {
  String id;
  String creator;
  String name;
  String description;
  GeoPoint location;

  StickDetails(
    this.id,
    this.creator,
    this.name,
    this.description,
    this.location,
  );

  factory StickDetails.fromJson(id, Map<String, dynamic> json) {
    return StickDetails(
      id,
      json["creator"] ?? "",
      json["name"] ?? "",
      json["description"] ?? "",
      json["coordonnées"] ?? null,
    );
  }
}

class PicDetails {
  String id;
  String creator;
  String creationTime;
  String imageURL;

  PicDetails(this.id, this.creator, this.creationTime, this.imageURL);

  factory PicDetails.fromJson(id, Map<String, dynamic> json) {
    return PicDetails(id, json["creator"] ?? "", json["creationTime"] ?? "",
        json["imageURL"] ?? "");
  }
}
