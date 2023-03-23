import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'custom_widgets.dart';

verifyPhoneNumberAlertDialog({
  required BuildContext context,
  required String verificationId,
  required String phoneNumber,
  required String userUid,
}) {
  TextEditingController textEditingController = TextEditingController();
  // set up the buttons
  Widget remindButton = TextButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppConstants().primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      side: const BorderSide(width: 2, color: Colors.yellow,),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10.0),
      child: Text("Onayla", style: TextStyle(color: Colors.white),),
    ),
    onPressed: () async {
      final content = textEditingController.text;
      String smsCode = content;

      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
        print("verified123_123");
        await UserDatabaseService(userUid: userUid).updatePhoneNumber(phoneNumber: phoneNumber);
        Navigator.pop(context);
        showSnackbar(context: context, color: Colors.redAccent, message: "Numara doğrulama başarılı");
      }).onError((error, stackTrace){
        print("error verifying 123_123 $error");
        showSnackbar(context: context, color: Colors.redAccent, message: "Kod yanlış girildi!");
      });

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
    title: const Text("Mesaj Gönderildi", textAlign: TextAlign.center,),
    content: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: 120,
        child: Column(
          children: [
            const Text("Telefonuna SMS olarak gönderdiğimiz kodu kullanarak numaranı doğrula", textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            TextFormField(
              controller: textEditingController,
              maxLines: null,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (val) {
                // userInfo?.biography = _val;
              },
              style: TextStyle(
                fontSize: 20,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppConstants().primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    icon: Icon(Icons.sms_outlined ?? Icons.report_problem_outlined, color: AppConstants().primaryColor, size: 50,),
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