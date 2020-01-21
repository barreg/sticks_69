import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticks_69/Singleton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PicturesPage extends StatefulWidget {
  @override
  _PicturesPageState createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage>
    with AutomaticKeepAliveClientMixin<PicturesPage> {
  Map<dynamic, File> _images = {};
  List<String> _urls = [];
  File _currentImage;
  dynamic _uploadFileURL;
  List<CameraDescription> cameras;
  @override
  bool get wantKeepAlive => true;

  void initState() async {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    _getPictures();
  }

  void dispose() {
    super.dispose();
  }

  void _initPicture(request) {
    _urls.add(request["imageURL"]);
    print(_urls);
  }

  void _getPictures() {
    Singleton().picsRef.getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          _initPicture(docs.documents[i].data);
        }
      }
    });
  }

  void _takePicture() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: const Text("Tu la veux d'où ta pic boy ?"),
              actions: <Widget>[
                RaisedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("ça la prend"),
                ),
                RaisedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.image),
                  label: Text("de mes pics"),
                )
              ]);
        });
  }

  void _pickImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _currentImage = image;
    });
    StorageReference ref = Singleton().storageReference;
    var uuid = Uuid();
    await ref.child(uuid.toString()).putFile(_currentImage).onComplete;
    await ref.child(uuid.toString()).getDownloadURL().then((fileURL) {
      setState(() {
        _uploadFileURL = fileURL;
        _images[_uploadFileURL] = _currentImage;
        _urls.add(fileURL);
      });
    });
    Singleton().picsRef.add({"imageURL": _uploadFileURL});

    await Fluttertoast.showToast(
        msg: "c posté gone !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        fontSize: 24.0);
  }

  Widget _image(String imageURL) {
    return Image(image: NetworkImage(imageURL));
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
        body: ListView(children: [
          Column(children: [for (var i in _urls) _image(i)])
        ]));
  }
}
