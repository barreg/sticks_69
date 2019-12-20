import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sticks_69/Models.dart';
import 'package:sticks_69/StickEditPage.dart';
import 'Singleton.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with 
            AutomaticKeepAliveClientMixin<MapPage>{

  @override
  bool get wantKeepAlive => true;

  GoogleMapController _controller;
  static const LatLng _center = const LatLng(45.723849, 4.832572);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType;
  Position _currentPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;

  @override
  void initState() {
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  void dispose(){
    super.dispose();
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
        infoWindow: InfoWindow(title: request['name'], snippet: request['description']),);
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
                StickDetails.fromJson(null, new Map(), _lastMapPosition))));
    if(result != null){
      final StickDetails stick = result;
      final MarkerId markerId = MarkerId(stick.id);
      final Marker marker = Marker(
          markerId: markerId,
          position: _lastMapPosition,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: stick.name, snippet: stick.description));
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sticks_69', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
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
          onCameraMove: _onCameraMove),
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
              ])))
    ])
    );
  }
}
