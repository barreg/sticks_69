import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'BenzPage.dart';
import 'DatabaseService.dart';
import 'DisplayPicture.dart';
import 'Models.dart';

class PicturesPage extends StatefulWidget {
  @override
  _PicturesPageState createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage>
    with AutomaticKeepAliveClientMixin<PicturesPage> {
  //@override
  bool get wantKeepAlive => true;
  List<CameraDescription> cameras = [];
  File _currentImage;

  @override
  void initState() {
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
    pic.creator = Provider.of<Userdata>(context, listen: false).uid;

    File image = await ImagePicker.pickImage(source: source);

    if (image == null) return;
    setState(() {
      _currentImage = image;
    });

    StorageTaskSnapshot uploadPic = await FirebaseStorage.instance
        .ref()
        .child("pics")
        .child(pic.creationTime)
        .putFile(_currentImage)
        .onComplete;

    String url = await uploadPic.ref.getDownloadURL();
    pic.imageURL = url;

    pic.id = await Provider.of<DatabaseService>(context, listen: false)
        .createPic(pic);

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Hero(
                    tag: "benz",
                    child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage("assets/Benz.jpeg")),
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BenzPage()),
                );
              }),
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
              child: StreamBuilder<List<PicDetails>>(
                  stream: Provider.of<DatabaseService>(context).streamPics(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<PicDetails>> snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            crossAxisCount: 3),
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, int index) {
                          final PicDetails pic = snapshot.data[index];
                          return GestureDetector(
                              child: Image.network(
                                pic.imageURL,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).focusColor)),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DisplayPicture(pic),
                                    ));
                              });
                        });
                  })),
        ]));
  }
}
