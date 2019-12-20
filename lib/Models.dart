import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sticks_69/StickDetailsPage.dart';


class StickDetails {
  String id;
  String name;
  String description;
  LatLng latLng;

  StickDetails(
    this.id,
    this.name,
    this.description,
    this.latLng,
  );

  factory StickDetails.fromJson(id, Map<String, dynamic> json, LatLng latLng){
    return StickDetails(
      id,
      "", 
      "", 
      latLng
      );
  }
}

