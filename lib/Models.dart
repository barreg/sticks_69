import 'package:cloud_firestore/cloud_firestore.dart';

class StickDetails {
  String id;
  String name;
  String description;
  GeoPoint location;

  StickDetails(
    this.id,
    this.name,
    this.description,
    this.location,
  );

  factory StickDetails.fromJson(id, Map<String, dynamic> json) {
    return StickDetails(
      id,
      json["name"] ?? "",
      json["description"] ?? "",
      json["coordonnées"] ?? null,
    );
  }
}

class PicDetails {
  String id;
  String creationTime;
  String imageURL;

  PicDetails(this.id, this.creationTime, this.imageURL);

  factory PicDetails.fromJson(id, Map<String, dynamic> json) {
    return PicDetails(id, json["creationTime"] ?? "", json["imageURL"] ?? "");
  }
}
