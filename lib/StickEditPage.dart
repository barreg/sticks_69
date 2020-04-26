import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sticks_69/Models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Singleton.dart';

class StickEditPage extends StatefulWidget {
  final StickDetails stick;
  final GeoPoint position;
  StickEditPage(StickDetails stickDetails, GeoPoint myPositoin)
      : this.stick = stickDetails,
        this.position = myPositoin;

  @override
  _StickEditPageState createState() => _StickEditPageState(stick, position);
}

class _StickEditPageState extends State<StickEditPage> {
  _StickEditPageState(this.stick, this.position);
  final StickDetails stick;
  final GeoPoint position;
  String _error;
  String _error2;
  TextEditingController _nameController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _descriptionController = new TextEditingController();
    _nameController.text = stick.name;
    _descriptionController.text = stick.description;
  }

  void _onSave() async {
    if (_nameController.text == "") {
      setState(() {
        _error = "donne un blaz wesh !";
      });
      return null;
    }
    if (_descriptionController.text == "") {
      setState(() {
        _error2 = "lâche d indices fdp !";
      });
      return null;
    }
    stick.name = _nameController.text;
    stick.description = _descriptionController.text;
    stick.location = position;
    DocumentReference doc = await Singleton().sticksRef.add({
      "coordonnées":
          new GeoPoint(stick.location.latitude, stick.location.longitude),
      "name": stick.name,
      "description": stick.description
    });
    stick.id = doc.documentID;
    await Fluttertoast.showToast(
        msg: "c stické gone !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).buttonColor,
        textColor: Colors.white,
        fontSize: 24.0);
    Navigator.pop(context, stick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Pimp ton Stick", textScaleFactor: 1.2),
          actions: <Widget>[
            FlatButton(
                child: Icon(Icons.check,
                    size: 30, color: Theme.of(context).textSelectionColor),
                onPressed: () {
                  _onSave();
                })
          ],
        ),
        body: Stack(children: [
          ListView(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: <Widget>[
                    TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _error = null;
                          });
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                        controller: _nameController,
                        decoration: InputDecoration(
                            hintText: 'Blaz de ton Stick', errorText: _error)),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CircleAvatar(
                            maxRadius: 175,
                            backgroundImage: AssetImage("assets/logo.jpeg"))),
                    SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _error2 = null;
                          });
                        },
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                        controller: _descriptionController,
                        decoration: InputDecoration(
                            hintText: 'la petite description pour le trouver',
                            errorText: _error2)),
                    SizedBox(
                      height: 30.0,
                    ),
                  ]),
                )
              ])
        ]));
  }
}
