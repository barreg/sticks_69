import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'Models.dart';
import 'Singleton.dart';

class DisplayPicture extends StatefulWidget {
  final PicDetails pic;
  final Image image;
  DisplayPicture(PicDetails picDetails, Image image)
      : this.pic = picDetails,
        this.image = image;
  @override
  _DisplayPictureState createState() => _DisplayPictureState(pic, image);
}

class _DisplayPictureState extends State<DisplayPicture> {
  _DisplayPictureState(this.pic, this.image);
  PicDetails pic;
  Image image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.network(
              pic.imageURL,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
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
                                  onPressed: () {
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
