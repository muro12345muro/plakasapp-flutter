import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sscarapp/helper/push_notification_functions.dart';
import 'package:sscarapp/models/models.dart';

import '../../services/firebase/database/auth/database_auth.dart';
import '../../services/firebase/database/user/user_database_service.dart';
import '../../shared/app_constants.dart';
import '../../tabBarPages/main_controller.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/pages_default_app_bar.dart';
import '../auth/login_page.dart';

class PreferencesSettingsPage extends StatefulWidget {
  final String userUid;
  const PreferencesSettingsPage({Key? key, required this.userUid,}) : super(key: key);

  @override
  State<PreferencesSettingsPage> createState() => _PreferencesSettingsPageState();
}

class _PreferencesSettingsPageState extends State<PreferencesSettingsPage> {
  var forSaleLinkFormFieldController = TextEditingController();
  bool isForSale = false;
  bool onlyReadyMessages = false;

  bool _isLoading = true;

  UserPreferencesInfo? userPreferencesInfo;

  void getUserInfo() async {
    _isLoading = true;
    log("message");
    userPreferencesInfo = await UserDatabaseService(userUid: widget.userUid).getUsersPreferencesData()
        ?.catchError((onErr) {
      log(onErr);
    });
    forSaleLinkFormFieldController.text = userPreferencesInfo?.forSaleLink ?? "";
    isForSale = userPreferencesInfo?.isForSale ?? false;
    onlyReadyMessages = userPreferencesInfo?.onlyReadyMessages ?? false;

    setState(() {
      _isLoading = false;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();

  }

  void saveEdits() async {
    final UserPreferencesInfo editedInfo = UserPreferencesInfo(
      forSaleLink: forSaleLinkFormFieldController.text,
      isForSale: isForSale,
      onlyReadyMessages: onlyReadyMessages,
    );
    await UserDatabaseService(userUid: widget.userUid).updateUserPreferencesInfo(editedInfo);
    if (!mounted) return;
    Navigator.pop(context, editedInfo);
  }


  signOutFunction() {
    DatabaseAuth().signOut().then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return MainControllerTabBar(isSignedIn: false,);
      }));
      setState(() {
        showSnackbar(context: context, color: Colors.grey, message: "Hesap silindi");
        //12d1f1
      });
    });
  }

  void disableCurrentAccount() async {
    await UserDatabaseService(userUid: widget.userUid).setUsersAccountDisabled(true);
    if (!mounted) return;
    signOutFunction();
    Navigator.pop(context);
    PushNotificationsFunctions().sendNotificationToAllModerators(
      notificationKind: ModeratorReportCases.accountDeletion,
    );
  }

  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: PagesDefaultAppBar(title: "Tercihler", leftIcon: Icons.arrow_back_ios_new, rightButtonText: "Kaydet", rightButtonActionFunction: saveEdits,),
      body: _isLoading ?
      Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red))
          :
      GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: availableHeight-85,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 2,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 200, child: const Text("Aracım satılıktır", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                        Container(
                          height: 30,
                          child: Switch(
                            activeColor: AppConstants().primaryColor,
                            value: isForSale,
                            onChanged: (value) {
                              setState(() {
                                isForSale = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(padding: EdgeInsets.symmetric(horizontal: 15), width: 300, child: const Text("(Aracınızın satılık olduğu profilinizde gözükecektir)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      children: [
                        Container(width: 120, child: Text("Sahibinden link", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                        Expanded(
                            child: TextFormField(
                              controller: forSaleLinkFormFieldController,
                              onChanged: (_val) {
                                userPreferencesInfo?.forSaleLink = _val;
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
                  const Divider(thickness: 2,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(child: const Text("Yalnızca hazır mesajları kabul et", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                        Container(
                          height: 30,
                          child: Switch(
                            activeColor: AppConstants().primaryColor,
                            value: onlyReadyMessages,
                            onChanged: (value) {
                              setState(() {
                                onlyReadyMessages = value;
                              });
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  const Divider(thickness: 2,),
                  Center(
                    child: TextButton(
                        onPressed: (){
                          disableCurrentAccount();
                        },
                        child: const Text(
                            "Hesabımı sil",
                          style: TextStyle(
                            color: Colors.red
                          ),
                        )
                    ),
                  )
              /*    Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: TextButton(
                      onPressed: () {

                      },
                      child: const Text("Hesabımı sil", style: TextStyle(fontSize: 15, color: Colors.redAccent, fontWeight: FontWeight.w500),),
                    )
                  ),*/

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
