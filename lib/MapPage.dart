import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sticks_69/Models.dart';
import 'package:sticks_69/StickEditPage.dart';
import 'DatabaseService.dart';
import 'ProfilePage.dart';
import 'SettingsPage.dart';
import 'package:sticks_69/BenzPage.dart';

import 'StickDetailsPage.dart';
import 'UserAvatar.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  @override
  bool get wantKeepAlive => true;
  GoogleMapController _controller;
  List<StickDetails> sticks = [];
  static const LatLng _center = const LatLng(45.723849, 4.832572);
  MapType _currentMapType;
  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  StickDetails selectedStick;
  String uid;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = res;
      _currentMapType = MapType.normal;
    });
  }

  void initMarker(StickDetails stick) {
    var markerIdVal = stick.id;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(stick.location.latitude, stick.location.longitude),
      infoWindow: InfoWindow(
          title: stick.name,
          snippet: stick.description,
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StickDetailsPage(stick)));
            if (result != null && result) {
              markers.remove(markerId);
            }
          }),
    );
    markers[markerId] = marker;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed(LatLng latLng) async {
    StickDetails stick = StickDetails.fromJson(null, new Map());
    stick.location = GeoPoint(latLng.latitude, latLng.longitude);
    stick.creator = Provider.of<Userdata>(context, listen: false).uid;
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => StickEditPage(stick)));
    if (result != null) {
      StickDetails stick = result;
      initMarker(stick);
    }
  }

  void _goToMyLocation() {
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      zoom: 16.0,
    )));
  }

  Widget button(Function function, IconData icon, int nb) {
    return FloatingActionButton(
      heroTag: nb.toString(),
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Theme.of(context).buttonColor,
      foregroundColor: Theme.of(context).primaryColorLight,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  void setTrue(MarkerId markerId, StickDetails stick) {
    setState(() {
      selectedMarker = markerId;
      selectedStick = stick;
    });
  }

  void setFalse(LatLng latLng) {
    setState(() {
      selectedStick = null;
    });
  }

  Set<Marker> _markers() {
    Provider.of<DatabaseService>(context).streamSticks().listen((sticks) {
      for (StickDetails stick in sticks) {
        initMarker(stick);
      }
    });
    return Set.of(markers.values);
  }

  Widget _imageForLogURL(String url) {
    return UserAvatar(url: url, radius: 20);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Sticks_69',
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            InkWell(
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Hero(
                      tag: "profile",
                      child: _imageForLogURL(
                          Provider.of<Userdata>(context)?.photoURL),
                    )),
                onTap: () {
                  Userdata userdata =
                      Provider.of<Userdata>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                            userdata.uid, userdata.photoURL, userdata.name)),
                  );
                })
          ],
        ),
        body: Stack(children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            mapType: _currentMapType,
            markers: _markers(),
            onTap: setFalse,
            onLongPress: _onAddMarkerButtonPressed,
          ),
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(children: [
                    button(_onMapTypeButtonPressed, Icons.map, 1),
                    SizedBox(
                      height: 20.0,
                    ),
                    button(_goToMyLocation, Icons.my_location, 3),
                  ]))),
        ]));
  }
}
