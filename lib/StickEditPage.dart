import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sticks_69/Models.dart';

class StickEditPage extends StatefulWidget {
  final StickDetails stick;
  StickEditPage(StickDetails stickDetails) : this.stick = stickDetails;

  @override
  _StickEditPageState createState() => _StickEditPageState(stick);
}

class _StickEditPageState extends State<StickEditPage> {
  _StickEditPageState(this.stick);
  final StickDetails stick;
  File _filePath;
  String _error;
  String _error2;
  bool _bLoading = false;
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  // final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _descriptionController = new TextEditingController();
    _nameController.text = stick.name;
    _descriptionController.text = stick.description;
  }

  void _onSave() {
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
    stick.latLng = stick.latLng;
    Firestore.instance.collection('sticks').add({
      "coordonnées":
          new GeoPoint(stick.latLng.latitude, stick.latLng.longitude),
      "name": stick.name,
      "description": stick.description
    });
  Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("pimp ton stick"),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  "save",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 20.0),
                ),
                onPressed: () {
                  _onSave();
                })
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(children: <Widget>[
            TextFormField(
                onChanged: (value) {
                  setState(() {
                    _error = null;
                  });
                },
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40),
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: 'blaz de ton stick', errorText: _error)),
            SizedBox(
              height: 30.0,
            ),
            Container(
                width: 190.0,
                height: 190.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage("assets/logo.jpeg")))),
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
                style: TextStyle(fontSize: 20),
                controller: _descriptionController,
                decoration: InputDecoration(
                    hintText: 'la petite description pour le trouver',
                    errorText: _error2)),
            SizedBox(
              height: 30.0,
            ),
          ]),
        ));
  }
}
