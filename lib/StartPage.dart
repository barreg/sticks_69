import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as prefix0;
import 'package:sticks_69/Models.dart';
import 'package:sticks_69/StickEditPage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'Singleton.dart';
import 'StickDetailsPage.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  GoogleMapController _controller;
  static const LatLng _center = const LatLng(45.723849, 4.832572);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  Widget _child;

  @override
  void initState() {
    _child = SpinKitRipple(color: Colors.redAccent);
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      _currentPosition = res;
      _child = mapWidget();
    });
  }

  Widget mapWidget() {
    return Stack(children: [
      GoogleMap(
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
          mapType: _currentMapType,
          markers: Set<Marker>.of(markers.values),
          onCameraMove: _onCameraMove,
          compassEnabled: true),
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(children: [
                button(_onMapTypeButtonPressed, Icons.map, 1),
                SizedBox(
                  height: 16.0,
                ),
                button(_onAddMarkerButtonPressed, Icons.add_location, 2),
                // FloatingActionButton(
                //   heroTag: "btn2",
                //   onPressed: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => StickEditPage(
                //                 StickDetails.create(_lastMapPosition))));
                //     _onAddMarkerButtonPressed;
                //   },
                //   materialTapTargetSize: MaterialTapTargetSize.padded,
                //   backgroundColor: Colors.blueAccent,
                //   child: Icon(
                //     Icons.add_location,
                //     size: 36.0,
                //   ),
                // ),
                SizedBox(
                  height: 16.0,
                ),
                button(_goToMyLocation, Icons.my_location, 3),
              ])))
    ]);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
            request['coordonnées'].latitude, request['coordonnées'].longitude),
        infoWindow: InfoWindow(title: request['name']));
    setState(() {
      markers[markerId] = marker;
    });
  }

  populateClients() {
    Firestore.instance.collection('sticks').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed() {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position: _lastMapPosition,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "title"));
    setState(() {
      markers[markerId] = marker;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StickEditPage(StickDetails.create(_lastMapPosition))));
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
      backgroundColor: Colors.blueAccent,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sticks_69'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _child,
    );
  }
}
