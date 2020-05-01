import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sticks_69/Models.dart';
import 'DatabaseService.dart';
import 'StickEditPage.dart';
import 'UserAvatar.dart';

class StickDetailsPage extends StatefulWidget {
  final StickDetails stick;
  StickDetailsPage(StickDetails stickDetails) : this.stick = stickDetails;
  @override
  _StickDetailsPageState createState() => _StickDetailsPageState(stick);
}

class _StickDetailsPageState extends State<StickDetailsPage> {
  _StickDetailsPageState(this.stick);
  StickDetails stick;

  void _sureDeleteStick(StickDetails stick) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text("Il s'est fait tej ?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    _deleteStick(stick);
                    Navigator.of(context).pop(true);
                  },
                  child: Text("WE",
                      style: TextStyle(color: Theme.of(context).errorColor))),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("NON ZBI"),
              ),
            ],
          );
        });
  }

  void _deleteStick(StickDetails stick) async {
    await Provider.of<DatabaseService>(context, listen: false)
        .deleteStick(stick);
    await Fluttertoast.showToast(
        msg: "Ciao le stick !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Theme.of(context).buttonColor,
        textColor: Colors.white,
        fontSize: 24.0);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(stick.name),
          actions: <Widget>[
            Provider.of<Userdata>(context).uid == stick.creator
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StickEditPage(stick)),
                      );
                    })
                : Container()
          ],
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(height: 30),
          StreamBuilder<Userdata>(
              stream: Provider.of<DatabaseService>(context)
                  .streamUserWithId(stick.creator),
              builder:
                  (BuildContext context, AsyncSnapshot<Userdata> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: UserAvatar(
                            url: snapshot.data.photoURL,
                            radius: 175,
                          )),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Ce stick a été stické par :",
                      textScaleFactor: 1.5,
                    ),
                    Text(
                      snapshot.data.name,
                      textScaleFactor: 2,
                      style: TextStyle(color: Theme.of(context).buttonColor),
                    ),
                    SizedBox(height: 20)
                  ],
                );
              }),
          Text(stick.description),
          SizedBox(height: 30),
          RaisedButton(
            onPressed: () {
              _sureDeleteStick(stick);
            },
            child: Text("Supprimer"),
          )
        ])));
  }
}
