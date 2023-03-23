import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';

import '../../services/firebase/database/user/user_database_service.dart';
import '../../shared/app_constants.dart';
import '../../widgets/pages_default_app_bar.dart';
import '../../widgets/verify_phone_number_alert_dialog.dart';

class ContactInfoEditPage extends StatefulWidget {
  final String userUid;
  const ContactInfoEditPage({Key? key, required this.userUid}) : super(key: key);

  @override
  State<ContactInfoEditPage> createState() => _ContactInfoEditPageState();
}

class _ContactInfoEditPageState extends State<ContactInfoEditPage> {
  TextEditingController phoneNumberFormFieldController = TextEditingController();
  bool showPhoneNumber = false;
  bool _isLoading = true;
  String _initialPhoneNumber = "";

  UserEditContactInfo? userContactInfo;

  void getUserContactInfo() async {
    _isLoading = true;
    log("message");
    userContactInfo = await UserDatabaseService(userUid: widget.userUid).getUsersContactData()
        ?.catchError((onErr) {
      log(onErr);
    });

    phoneNumberFormFieldController.text = userContactInfo?.phoneNumber ?? "";
    _initialPhoneNumber = userContactInfo?.phoneNumber ?? "";
    showPhoneNumber = userContactInfo?.showNumber ?? false;
    log("${userContactInfo?.toJson()}");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserContactInfo();
  }

  @override
  Widget build(BuildContext context) {

    void saveEdits(BuildContext progressContext) async {
      print("12r12r_12e12 ${_initialPhoneNumber} 2 ${phoneNumberFormFieldController.text}");
      final enteredPhone = phoneNumberFormFieldController.text;
      if (!InformatorFunctions().isValidPhoneNumber(enteredPhone)) {
        showSnackbar(
            context: context,
            color: Colors.redAccent,
            message: "Lüfen +90 ile başlayan geçerli bir telefon numarası girin"
        );
        return;
      }
      //+905349175761
      if (_initialPhoneNumber != enteredPhone) {
        final res = await UserDatabaseService(userUid: widget.userUid).updatePhoneNumber(phoneNumber: enteredPhone);
        if (res) {
          showSnackbar(context: context, color: Colors.green, message: "Numaranız güncellendi");
          Navigator.pop(context);
        }
        return;
        ///firebase no dogrulama sms servisi
        print("21df32f2f_2ff2f");
        try {
          final progress = ProgressHUD.of(progressContext);
          progress?.show();
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNumberFormFieldController.text,
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (FirebaseAuthException e) {
              print("12d12_12d12 verificationFailed $e");
            },
            codeSent: (String verificationId, int? resendToken) {
              print("1d12d21d $verificationId");
              progress?.dismiss();
              verifyPhoneNumberAlertDialog(
                context: context,
                verificationId: verificationId,
                phoneNumber: enteredPhone,
                userUid: widget.userUid,
              );
            },
            //timeout: ,
            codeAutoRetrievalTimeout: (String verificationId) {},
          ).catchError((e){
            progress?.dismiss();
            print("d21f2_23f23 $e");
          });
        } on PlatformException catch (e){
          print("error phone code sending 1d_12d12 $e");
        }
      } else{
        var now = DateTime.now();
        var formatter = DateFormat('dd-MM-yyyy HH:mm');
        String formattedDate = formatter.format(now);

        final UserEditContactInfo editedInfo = UserEditContactInfo(
          date: formattedDate,
          phoneNumber: phoneNumberFormFieldController.text,
          showNumber: showPhoneNumber,
          //  email: emailFormFieldController.text,
        );
        await UserDatabaseService(userUid: widget.userUid).updateUserContactInfo(editedInfo);
        if (!mounted) return;
        Navigator.pop(context);
      }

    }

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;


    return ProgressHUD(
      child: Builder(
          builder: (context) {
            return Scaffold(
              // appBar: PagesDefaultAppBar(title: "İletişim Ayarları", leftIcon: Icons.arrow_back_ios_new, rightButtonText: "Kaydet", rightButtonActionFunction: saveEdits,),
              appBar:  AppBar(
                centerTitle: true,
                //leadingWidth:  12,
                elevation: 0,
                backgroundColor: AppConstants().secondaryColor,
                title: Container(padding:const EdgeInsets.only(left: 0),child: const Center(child: Text("İletişim Ayarları"))),
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () {
                  Navigator.pop(context);
                },),
                actions:[
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12, right: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppConstants().primaryColor)),
                    alignment: Alignment.center,
                    width: 80,
                    child: TextButton( onPressed: () {
                      saveEdits(context);
                    },
                      child: const Text(
                        "Kaydet",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  )
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
              ),
              body: _isLoading ?
              const Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red))
                  :
              ProgressHUD(
                child: Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            child: Container(
                              //height: availableHeight-85,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  const Divider(thickness: 2,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    child: Row(
                                      children: [
                                        Container(width: 150, child: Text("Telefon Numarası", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                                        Expanded(
                                            child: TextFormField(
                                              controller: phoneNumberFormFieldController,
                                              onChanged: (_val) {
                                                userContactInfo?.phoneNumber = _val;
                                              },
                                              decoration: InputDecoration(
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: AppConstants().primaryColor),
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(width: 200, child: Text("Numarayı profilimde göster", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                                        Container(
                                          height: 30,
                                          child: Switch(
                                            activeColor: AppConstants().primaryColor,
                                            value: showPhoneNumber,
                                            onChanged: (value) {
                                              setState(() {
                                                showPhoneNumber = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 2,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),
            );
          }
      ),
    );
  }
}
