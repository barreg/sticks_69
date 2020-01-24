import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'Models.dart';
import 'Singleton.dart';

class DisplayPicture extends StatefulWidget {
  final PicDetails pic;
  DisplayPicture(PicDetails picDetails) : this.pic = picDetails;
  @override
  _DisplayPictureState createState() => _DisplayPictureState(pic);
}

class _DisplayPictureState extends State<DisplayPicture> {
  _DisplayPictureState(this.pic);
  PicDetails pic;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: NetworkImage(pic.imageURL), fit: BoxFit.contain)),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 20,
                right: 20,
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
        ));
  }
}
