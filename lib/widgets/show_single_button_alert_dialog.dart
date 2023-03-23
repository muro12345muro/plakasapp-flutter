import 'package:flutter/material.dart';
import 'package:sscarapp/shared/app_constants.dart';

import '../pages/auth/register_user_page.dart';

showSingleButtonAlertDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String buttonTitle,
  required Function buttonAction,
  bool? showSignup,
}) {
  // set up the buttons
  Widget remindButton = TextButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppConstants().primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      side: const BorderSide(width: 2, color: Colors.yellow,),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20.0),
      child: Text(buttonTitle, style: const TextStyle(color: Colors.white),),
    ),
    onPressed: () {
      buttonAction();
    },
  );

  Widget cancelButton = OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.grey.shade400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      side: BorderSide(width: 2, color: Colors.grey.shade500,),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
      child: Text("Cancel", style: TextStyle(color: Colors.white),),
    ),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );

  Widget signupButton = OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.grey.shade400,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      side: BorderSide(width: 2, color: Colors.grey.shade500,),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
      child: Text("Üye ol +10 Token kazan", style: TextStyle(color: Colors.white),),
    ),
    onPressed:  () async {
      Navigator.pop(context);
      dynamic pushLogin = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_){
                return const RegisterUserPage();
              }
          )
      );
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
      titlePadding: const EdgeInsets.all(0),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)
        )
    ),
    title: Text(title, textAlign: TextAlign.center,),
    content: Text(description, textAlign: TextAlign.center,),
    icon: Icon(Icons.generating_tokens_rounded, color: AppConstants().primaryColor, size: 50,),
    actions: [
   //   Divider(),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cancelButton,
            //  Container(color: Colors.black12, width: 1, height:50,),
              //  Container(color: Colors.black, width: 2, height: 20,),
              remindButton,
            ],
          ),
          showSignup ?? false ? signupButton : Container(),
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