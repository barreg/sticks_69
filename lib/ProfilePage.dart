import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'DatabaseService.dart';
import 'Models.dart';
import 'LoadingBarrier.dart';
import 'SettingsPage.dart';
import 'UserAvatar.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final String photoURL;
  final String heroName;
  ProfilePage(this.uid, this.photoURL, this.heroName);

  @override
  _ProfilePageState createState() =>
      _ProfilePageState(this.uid, this.photoURL, this.heroName);
}

class _ProfilePageState extends State<ProfilePage> {
  String photoURL;
  bool _bEditing = false;
  bool _bLoading = false;
  File _croppedPath;
  int numPoints;
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _descriptionController =
      new TextEditingController();

  final String uid;
  final String heroName;
  _ProfilePageState(this.uid, this.photoURL, this.heroName);

  loadData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(user.uid)
        .snapshots()
        .forEach((DocumentSnapshot snapshot) {
      setState(() {
        Userdata data = Userdata.fromJson(user.uid, snapshot.data);
        this._nameController.text = data.name;
        this._descriptionController.text = data.description;
        this.photoURL = data.photoURL;
        this.numPoints = data.numPoints;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final _width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).backgroundColor,
        floatingActionButton: _bEditing && !_bLoading
            ? FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _bEditing = false;
                    //Update Data on Server
                    updateUserData();
                  });
                },
                icon: Icon(Icons.check_circle),
                label: Text("Save"),
              )
            : null,
        appBar: AppBar(
            title: Text('Profil',
                textScaleFactor: 1.5,
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: <Widget>[
              _bEditing || Provider.of<Userdata>(context).uid != this.uid
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          _bEditing = true;
                        });
                      },
                    ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage())),
              )
            ]),
        body: ListView(
          padding: EdgeInsets.fromLTRB(5, 40, 5, 20),
          children: <Widget>[
            // Opacity(
            //   opacity: 0.1,
            //   child: new Image.asset(
            //     'assets/Caisson_Gone.png',
            //     width: _width,
            //     height: _height,
            //     fit: BoxFit.fill,
            //   ),
            // ),
            StreamBuilder<Userdata>(
              stream:
                  Provider.of<DatabaseService>(context).streamUserWithId(uid),
              builder:
                  (BuildContext context, AsyncSnapshot<Userdata> userdata) {
                if (userdata.data != null) {
                  this._nameController.text = userdata.data.name;
                  this._descriptionController.text = userdata.data.description;
                  this.photoURL = userdata.data.photoURL == ""
                      ? this.photoURL
                      : userdata.data.photoURL;
                  this.numPoints = userdata.data.numPoints;
                }
                return Center(
                  child: ListView(shrinkWrap: true, children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        if (!_bEditing) return;
                        addImage();
                      },
                      child: !_bLoading
                          ? Center(
                              child: Hero(
                                tag: heroName,
                                child: UserAvatar(url: photoURL, radius: 140),
                              ),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    SizedBox(height: 20),
                    TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration.collapsed(hintText: "Blaz"),
                        enabled: _bEditing,
                        style: TextStyle(
                            fontSize: 45.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    TextField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            InputDecoration.collapsed(hintText: "Description"),
                        enabled: _bEditing,
                        maxLines: 2,
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center),
                    // Text(
                    //   this.numPoints.toString() +
                    //       " Point" +
                    //       (this.numPoints == 1 ? "" : "s"),
                    //   style: TextStyle(fontSize: 20),
                    //   textAlign: TextAlign.center,
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Préférences",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Icon(
                                Icons.attach_money,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Icon(
                              Icons.audiotrack,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                            Icon(
                              Icons.smoking_rooms,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                );
              },
            )
          ],
        ));
  }

  void updateUserData() async {
    Userdata user = Provider.of<Userdata>(context, listen: false);
    user.description = _descriptionController.text;
    user.name = _nameController.text;
    user.photoURL = photoURL;
    Provider.of<DatabaseService>(context, listen: false).updateUserdata(user);
  }

  void addImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          titlePadding: EdgeInsets.all(0.0),
          title: Container(
              padding: EdgeInsets.all(20.0),
              color: Theme.of(context).primaryColor,
              child: Row(children: [
                Text(
                  'Select Source',
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                )
              ])),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //_buildAboutText(),
              new ListTile(
                  leading:
                      Icon(Icons.image, color: Theme.of(context).primaryColor),
                  title: Text("Select from Images"),
                  onTap: () {
                    Navigator.pop(context);
                    _importImageFromGallery(ImageSource.gallery);
                  }),
              new ListTile(
                  leading: Icon(Icons.camera_alt,
                      color: Theme.of(context).primaryColor),
                  title: Text("Take a Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _importImageFromGallery(ImageSource.camera);
                  }),
              //UserData.accessToken==null?Container():new ListTile(leading: Icon(MdiIcons.facebook, color: Colors.black), title: Text("Import from Facebook"),onTap: () {
              //Navigator.pop(context);
              //importImageFromFacebook(context);
              //}),
              //_buildLogoAttribution(),
            ],
          ),
        );
      },
    );
  }

  _importImageFromGallery(ImageSource source) async {
    File file = await ImagePicker.pickImage(source: source);
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
      this._bLoading = true;
    });

    Userdata user = Provider.of<Userdata>(context, listen: false);
    if (_croppedPath != null) {
      StorageTaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child("users")
          .child(user.uid)
          .child("photo")
          .putFile(_croppedPath)
          .onComplete;
      String url = await task.ref.getDownloadURL();

      setState(() {
        this.photoURL = url;
        this._bLoading = false;
      });
      updateUserData();
    }
  }
}

class GetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.lineTo(0.0, size.height / 2);
    path.lineTo(size.width + size.width / 2, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
