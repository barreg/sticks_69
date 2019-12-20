import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticks_69/Singleton.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PicturesPage extends StatefulWidget {
  @override
  _PicturesPageState createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage>
    with AutomaticKeepAliveClientMixin<PicturesPage> {
  @override
  bool get wantKeepAlive => true;

  void _takePicture() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: const Text("Tu la veux d'où ta pic boy ?"),
              actions: <Widget>[
                RaisedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Text("j'la prends"),
                ),
                RaisedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.image),
                  label: Text("de mes pics"),
                )
              ]);
        });
  }

  void _pickImage(ImageSource source) async {
    File file = await ImagePicker.pickImage(source: source);
    if(file == null) return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Photos',
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            FlatButton(
                child: Icon(Icons.add_a_photo,
                    size: 30, color: Theme.of(context).primaryColorLight),
                onPressed: () {
                  _takePicture();
                })
          ],
        ),
        body: Stack(children: [Text("hey")]));
  }
}
