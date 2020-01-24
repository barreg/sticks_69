import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sticks_69/Models.dart';
import 'package:sticks_69/StickEditPage.dart';
import 'Singleton.dart';
import 'package:sticks_69/BenzPage.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _controller;
  static const LatLng _center = const LatLng(45.723849, 4.832572);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType;
  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  bool _isSelected = false;

  @override
  void initState() {
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = res;
      _currentMapType = MapType.normal;
    });
  }

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
          request['coordonnées'].latitude, request['coordonnées'].longitude),
      infoWindow: InfoWindow(
        title: request['name'],
        snippet: request['description'],
      ),
      onTap: () => {setTrue(markerId)},
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  populateClients() {
    Singleton().sticksRef.getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
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

  void _onAddMarkerButtonPressed() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StickEditPage(
                StickDetails.fromJson(null, new Map()),
                GeoPoint(
                    _lastMapPosition.latitude, _lastMapPosition.longitude))));
    if (result != null) {
      StickDetails stick = result;
      setState(() {
        final MarkerId markerId = MarkerId(stick.id);
        final Marker marker = Marker(
          markerId: markerId,
          position: _lastMapPosition,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: stick.name, snippet: stick.description),
          onTap: () => {setTrue(markerId)},
        );
        markers[markerId] = marker;
      });
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

  void setTrue(MarkerId markerId) {
    setState(() {
      _isSelected = true;
      selectedMarker = markerId;
    });
  }

  void setFalse(LatLng latLng) {
    setState(() {
      _isSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sticks_69',
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                  child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: CircleAvatar(
                          maxRadius: 23,
                          backgroundImage: AssetImage("assets/Benz.jpeg"))),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BenzPage()),
                  ),
                ))
          ],
        ),
        body: Stack(children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            mapType: _currentMapType,
            markers: Set<Marker>.of(markers.values),
            onCameraMove: _onCameraMove,
            onTap: setFalse,
            //onLongPress: ,
          ),
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
                    SizedBox(
                      height: 16.0,
                    ),
                    button(_goToMyLocation, Icons.my_location, 3),
                  ]))),
          _isSelected
              ? Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async => await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text("Le stick est mort ?"),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () {
                                        try {
                                          Singleton()
                                              .sticksRef
                                              .document(selectedMarker.value)
                                              .delete();
                                          Navigator.pop(context);
                                          setState(() {
                                            markers.remove(selectedMarker);
                                          });
                                        } catch (err) {}
                                      },
                                      child: Text("WE",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .errorColor))),
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("NON ZBI"),
                                  ),
                                ],
                              );
                            },
                          )))
              : Container(),
        ]));
  }
}
