import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'DatabaseService.dart';
import 'Models.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _fullnameController = new TextEditingController();
  final _descriptionController = new TextEditingController();
  File _croppedPath;


  _importImageFromGallery() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: file.path,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Theme.of(context).primaryColor,
          cropFrameColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).primaryColorLight,
          hideBottomControls: true),
      iosUiSettings: IOSUiSettings(
          aspectRatioPickerButtonHidden: true,
          resetButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      maxWidth: 250,
      maxHeight: 250,
    );
    if (croppedFile == null) return;

    setState(() {
      this._croppedPath = croppedFile;
    });
  }

  _submitData() async {
    String url;
    Userdata user = Provider.of<Userdata>(context);
    if (_croppedPath != null) {
      StorageTaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child("users")
          .child(user.uid)
          .child("photo")
          .putFile(_croppedPath)
          .onComplete;
      url = await task.ref.getDownloadURL();
    }

    Userdata userdata = new Userdata(user.uid, _fullnameController.text,
        _descriptionController.text, url, 0, false);
    await Provider.of<DatabaseService>(context).updateUserdata(userdata);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TextFormField(
              onChanged: (value) {},
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
              controller: _fullnameController,
              decoration: InputDecoration(hintText: 'Ton blaz ')),
          SizedBox(height: 30),
          TextFormField(
              onChanged: (value) {},
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
              controller: _fullnameController,
              decoration: InputDecoration(hintText: 'Description ')),
          SizedBox(height: 30),
          Column(children: [
              _croppedPath != null
                  ? Stack(children: [
                      Image.file(_croppedPath, height: 100, width: 100),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          iconSize: 30,
                          icon: Icon(
                            Icons.cancel,
                          ),
                          onPressed: () {
                            setState(() {
                              _croppedPath = null;
                            });
                          },
                          color: Colors.red.withOpacity(0.8),
                        ),
                      )
                    ])
                  : Image.asset("assets/default_user.png",
                      height: 100, width: 100),
              FlatButton.icon(
                  label: Text("Select from Library"),
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    _importImageFromGallery();
                  }),
              SizedBox(
                height: 20,
              )
            ]),
          RaisedButton(
            onPressed: () async {
              _submitData();
            },
            child: Text("Valider"),
          )
        ],
      ),
    );
  }
}
