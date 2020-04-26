import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sticks_69/Models.dart';
import 'package:sticks_69/StickEditPage.dart';
import 'DatabaseService.dart';
import 'SettingsPage.dart';
import 'package:sticks_69/BenzPage.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  @override
  bool get wantKeepAlive => true;
  GoogleMapController _controller;
  static const LatLng _center = const LatLng(45.723849, 4.832572);
  MapType _currentMapType;
  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  StickDetails selectedStick;
  bool _isSelected = false;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
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
      infoWindow: InfoWindow(title: stick.name, snippet: stick.description),
      onTap: () => {setTrue(markerId, stick)},
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
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StickEditPage(
                StickDetails.fromJson(null, new Map()),
                GeoPoint(latLng.latitude, latLng.longitude))));
    if (result != null) {
      StickDetails stick = result;
      setState(() {
        final MarkerId markerId = MarkerId(stick.id);
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(latLng.latitude, latLng.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: stick.name, snippet: stick.description),
          onTap: () => {setTrue(markerId, stick)},
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

  void setTrue(MarkerId markerId, StickDetails stick) {
    setState(() {
      _isSelected = true;
      selectedMarker = markerId;
      selectedStick = stick;
    });
  }

  void setFalse(LatLng latLng) {
    setState(() {
      _isSelected = false;
      selectedStick = null;
    });
  }

  void _sureDeleteStick(StickDetails stick) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Il s'est fait tej ?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    _deleteStick(selectedStick);
                    Navigator.of(context).pop(true);
                  },
                  child: Text("WE",
                      style: TextStyle(color: Theme.of(context).errorColor))),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("NON ZBI"),
              ),
            ],
          );
        });
  }

  void _deleteStick(StickDetails stick) async {
    await Provider.of<DatabaseService>(context, listen: false)
        .deleteStick(stick.id);
    await Fluttertoast.showToast(
        msg: "Ciao le stick !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).buttonColor,
        textColor: Colors.white,
        fontSize: 24.0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage())),
              icon: Icon(
                Icons.settings,
                size: 40,
              )),
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
          StreamBuilder<List<StickDetails>>(
              stream: Provider.of<DatabaseService>(context).streamSticks(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<StickDetails>> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                for (int index = 0; index < snapshot.data.length; index++) {
                  final StickDetails stick = snapshot.data[index];
                  initMarker(stick);
                }
                return GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                  mapType: _currentMapType,
                  markers: Set<Marker>.of(markers.values),
                  onTap: setFalse,
                  onLongPress: _onAddMarkerButtonPressed,
                );
              }),
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
                      onPressed: () => _sureDeleteStick(selectedStick)))
              : Container(),
        ]));
  }
}
