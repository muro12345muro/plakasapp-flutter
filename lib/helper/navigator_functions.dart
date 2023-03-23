import 'package:flutter/material.dart';

class NavigatorFunctions{

  //navigationcontroller.push

  //navigationcontroller.pop

  //present

  //dismiss

  void nextScreen(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void nextScreenReplace(context, page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }
}