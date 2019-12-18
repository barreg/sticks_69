import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sticks_69/StickDetailsPage.dart';


class StickDetails {
  String id;
  String name;
  String description;
  LatLng latLng;
  String imageURL;
  Marker marker;

  StickDetails(
    this.id,
    this.name,
    this.description,
    this.latLng,
    this.imageURL,
    this.marker,
  );

  factory StickDetails.create(LatLng latLng){
    return StickDetails("", "", "", latLng, "", Marker(markerId: MarkerId(latLng.toString())));
  }
}

