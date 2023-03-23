import 'package:flutter/material.dart';

showAlertDialog(BuildContext context) {

  // set up the buttons
  Widget remindButton = TextButton(
    child: Text("Remind me later"),
    onPressed:  () {},
  );
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );
  Widget launchButton = TextButton(
    child: Text("Okay"),
    onPressed:  () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0))),
    title: Text("Notice", textAlign: TextAlign.center,),
    content: Text("Launching this missile will destroy the entire universe. Is this what you intended to do?", textAlign: TextAlign.center,),
    actions: [
      Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cancelButton,
          Container(color: Colors.black12, width: 1, height:50,),
          //Container(color: Colors.black, width: 2, height: 20,),
          launchButton,
        ],
      ),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}