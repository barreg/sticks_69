import 'package:flutter/material.dart';

class BenzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: AssetImage("assets/BenzBicycle.gif"),
                fit: BoxFit.contain)));
  }
}
