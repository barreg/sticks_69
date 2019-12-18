import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class StickDetailsPage extends StatefulWidget {
  final Marker marker;
  StickDetailsPage(Marker marker) : this.marker = marker;
  @override
  _StickDetailsPageState createState() => _StickDetailsPageState(marker);
}

class _StickDetailsPageState extends State<StickDetailsPage> {
  _StickDetailsPageState(this.marker);
  Marker marker;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}