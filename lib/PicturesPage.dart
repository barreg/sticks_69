import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticks_69/LoadingBarrier.dart';
import 'package:sticks_69/Singleton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'DisplayPicture.dart';
import 'Models.dart';

class PicturesPage extends StatefulWidget {
  @override
  _PicturesPageState createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage>
    with AutomaticKeepAliveClientMixin<PicturesPage> {
  @override
  bool get wantKeepAlive => true;
  List<CameraDescription> cameras = [];
  File _currentImage;
  bool _bLoading = false;
  List<Image> images = [];
  List<PicDetails> pics = [];

  @override
  void initState() {
    Singleton().picsRef.getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; i++) {
          images.add(Image.network(docs.documents[i].data['imageURL']));
          pics.add(new PicDetails(
              docs.documents[i].documentID,
              docs.documents[i].data['creationTime'],
              docs.documents[i].data['imageURL']));
        }
      }
    });
    super.initState();
  }

  void checkCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  }

  void _takePicture() async {
    checkCameras();
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: const Text("Tu la veux d'où ta pic boi ?"),
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
    PicDetails pic = new PicDetails.fromJson(null, new Map());
    pic.creationTime = DateTime.now().toIso8601String();

    File image = await ImagePicker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      _currentImage = image;
      _bLoading = true;
    });

    StorageTaskSnapshot uploadPic = await FirebaseStorage.instance
        .ref()
        .child("pics")
        .child(pic.creationTime)
        .putFile(_currentImage)
        .onComplete;

    String url = await uploadPic.ref.getDownloadURL();
    pic.imageURL = url;

    setState(() {
      _bLoading = false;
    });

    DocumentReference doc = await Singleton()
        .picsRef
        .add({"imageURL": pic.imageURL, "creationTime": pic.creationTime});
    pic.id = doc.documentID;

    setState(() {
      images.add(Image.file(image));
      pics.add(pic);
    });

    await Fluttertoast.showToast(
        msg: "c posté gone !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).buttonColor,
        textColor: Colors.white,
        fontSize: 24.0);
    Navigator.pop(context);
  }

  Widget _image(PicDetails picDetails, Image image) {
    return GestureDetector(
        child: Image.network(
          picDetails.imageURL,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).focusColor)),
            );
          },
        ),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPicture(picDetails, image),
            )));
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
        body: Column(children: [
          Expanded(
              child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4, crossAxisSpacing: 4, crossAxisCount: 3),
            itemCount: images.length,
            itemBuilder: (_, int index) {
              return _image(pics[index], images[index]);
            },
          )),
          LoadingBarrier(
            text: "2 sec stp ...",
            bIsLoading: _bLoading,
          )
        ]));
  }
}
