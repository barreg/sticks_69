import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingBarrier extends StatefulWidget {
  final String text;
  final bool bIsLoading;
  LoadingBarrier({@required this.text, @required this.bIsLoading});

  @override
  _LoadingBarrierState createState() => new _LoadingBarrierState();
}

class _LoadingBarrierState extends State<LoadingBarrier> {
  @override
  Widget build(BuildContext context) {
    return widget.bIsLoading
        ? Stack(children: [
            new Opacity(
              opacity: 0.9,
              child: ModalBarrier(
                  dismissible: false,
                  color: Theme.of(context).primaryColorLight),
            ),
            new Center(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  SpinKitCubeGrid(
                    itemBuilder: (_, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                        ),
                      );
                    },
                    size: 100,
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    widget.text,
                    style: TextStyle(fontSize: 20.0),
                  )
                ]))
          ])
        : Container();
  }
}
