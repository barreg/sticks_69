import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String url;
  final double radius;
  UserAvatar({@required this.url, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: url == null || url == ""
            ? AssetImage("assets/default_user.png")
            : NetworkImage(url));
  }
}
