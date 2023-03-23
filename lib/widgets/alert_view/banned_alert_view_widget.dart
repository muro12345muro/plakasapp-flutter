import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/shared/app_constants.dart';

bannedAlertViewWidget({
  required BuildContext context,
  required DateTime date,
}) {
  DateFormat dateFormat = DateFormat("dd-MM-yyyy hh:MM");
  final String currentLeftDate = dateFormat.format(date);

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(

    titlePadding: const EdgeInsets.all(0),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)
        )
    ),
    title: const Text("Üyeliğiniz cezalandırılmış", textAlign: TextAlign.center,),
    content: Text(
      "Hesabınız $currentLeftDate  tarihinde açılacaktır.",
      textAlign: TextAlign.center,
    ),
    icon: Icon(Icons.generating_tokens_rounded, color: AppConstants().primaryColor, size: 50,),
    actions: [
      //   Divider(),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            ],
          ),
        ],
      ),
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
          child: alert
      );
    },
  );
}