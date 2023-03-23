import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/shared/app_constants.dart';

import '../helper/push_notification_functions.dart';
import '../models/models.dart';
import '../services/firebase/database/report_us/report_services.dart';
import 'custom_widgets.dart';

showTextFieldAlertDialog({
  required BuildContext context,
  required ModeratorReportCases type,
  required String title,
  required String description,
  required String buttonTitle,
  String? entryId,
  IconData? iconData,
  required String userUid,
}) {
  TextEditingController textEditingController = TextEditingController();

  void reportSuggestPredefinedMessage({required String content, required String userUid}) {
    ReportServices().reportSuggestPredefinedMessage(
        message: content,
        userUid: userUid
    );
    PushNotificationsFunctions()
        .sendNotificationToAllModerators(
        notificationKind: ModeratorReportCases.predefinedMessage,
        additionalInfo: content
    );
  }


  void reportWallPost({required String content, required String commentId, required String userUid}){
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    var now = DateTime.now();
    String formattedDate = formatter.format(now);
    ReportCommentPost report = ReportCommentPost(content: content, date: formattedDate, selfUserUid: userUid, commentId: commentId);
    ReportServices().reportProfileComment(report).then((value)
    {
      if (value) {
        showSnackbar(context: context, color: Colors.green, message: "Şikayetin bize ulaştı, teşekkürler.");
        PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.wallPost, additionalInfo: content);

      } else{
        showSnackbar(context: context, color: Colors.red, message: "Şikayetin bize ulaşamadı.");
      }
    });
  }


  void contactUs({required String content, required String userUid}){
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    var now = DateTime.now();
    String formattedDate = formatter.format(now);
    ContactUsForm report = ContactUsForm(content: content, date: formattedDate, selfUserUid: userUid,);
    ReportServices().contactUsFormApply(report).then((value)
    {
      if (value) {
        showSnackbar(context: context, color: Colors.green, message: "Mesajın bize ulaştı, teşekkürler.");
        PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.contactUs, additionalInfo: content);

      } else{
        showSnackbar(context: context, color: Colors.red, message: "Şikayetin bize ulaşamadı.");
      }
    });
  }


  void reportTargetUser({required String content, required String targetUserUid, required String userUid}){
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    var now = DateTime.now();
    String formattedDate = formatter.format(now);
    ReportUserAccount report = ReportUserAccount(content: content, date: formattedDate, selfUserUid: userUid, targetUseruid: targetUserUid);
    ReportServices().reportUserProfile(report).then((value)
    {
      if (value) {
        showSnackbar(context: context, color: Colors.green, message: "Şikayetin bize ulaştı, teşekkürler.");
        PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.user, additionalInfo: content);

      } else{
        showSnackbar(context: context, color: Colors.red, message: "Şikayetin bize ulaşamadı.");
      }
    });
  }


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
    onPressed: (){
      final content = textEditingController.text;
      Navigator.pop(context);
      if(content.replaceAll(" ", "") == ""){
        showSnackbar(context: context, color: Colors.red, message: "Şikayet boş yollanamaz!");
        return;
      }
      switch (type){
        case ModeratorReportCases.user:
          if (entryId != null) {
            reportTargetUser(content: textEditingController.text, targetUserUid: entryId, userUid: userUid);
          }
          break;
        case ModeratorReportCases.wallPost:
          if (entryId != null) {
            reportWallPost(content: textEditingController.text, commentId: entryId, userUid: userUid);
          }
          break;
        case ModeratorReportCases.contactUs:
          contactUs(content: textEditingController.text, userUid: userUid);
          break;
        case ModeratorReportCases.predefinedMessage:
          reportSuggestPredefinedMessage(content: textEditingController.text, userUid: userUid,);
          break;
        default:
          break;
      }

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
      child: Text("İptal", style: TextStyle(color: Colors.white),),
    ),
    onPressed:  () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    titlePadding: const EdgeInsets.all(0),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0))),
    title: Text(title, textAlign: TextAlign.center,),
    content: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            Text(description, textAlign: TextAlign.center,),
            Expanded(
                child: TextFormField(
                  controller: textEditingController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (val) {
                    // userInfo?.biography = _val;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 10.0),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppConstants().primaryColor),
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    ),
    icon: Icon(iconData ?? Icons.report_problem_outlined, color: AppConstants().primaryColor, size: 50,),
    actions: [
      //   Divider(),
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

enum ReportCases{
  comment,
  user,
  predefinedMessage,
  wallPost,
  contactUs,
}