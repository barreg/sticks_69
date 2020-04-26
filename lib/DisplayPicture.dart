import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'Models.dart';
import 'Singleton.dart';

class DisplayPicture extends StatefulWidget {
  final PicDetails pic;
  DisplayPicture(PicDetails pic)
      : this.pic = pic;
  @override
  _DisplayPictureState createState() => _DisplayPictureState(pic);
}

class _DisplayPictureState extends State<DisplayPicture> {
  _DisplayPictureState(this.pic);
  PicDetails pic;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(pic.imageURL),
              loadingBuilder:
                  (BuildContext context, ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return Container();
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
          ),
          Positioned(
              top: 50,
              right: 30,
              child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  iconSize: 35,
                  onPressed: () async => await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text("Ca la tej ?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () async {
                                    try {                                                                         
                                      FirebaseStorage.instance
                                          .ref()
                                          .child("pics")
                                          .child(pic.creationTime)
                                          .delete();
                                      Singleton()
                                          .picsRef
                                          .document(pic.id)
                                          .delete();

                                      await Fluttertoast.showToast(
                                          msg: "c taillé gone !",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIos: 1,
                                          backgroundColor:
                                              Theme.of(context).buttonColor,
                                          textColor: Colors.white,
                                          fontSize: 24.0);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } catch (err) {}
                                  },
                                  child: Text("WE",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).errorColor))),
                              FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("NON ZBI"),
                              ),
                            ],
                          );
                        },
                      )))
        ],
      ),
    );
  }
}
