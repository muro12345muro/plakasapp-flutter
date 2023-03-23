import 'dart:developer';
import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/DM/dm_list_page.dart';
import 'package:sscarapp/pages/auth/set_nickname_page.dart';
import 'package:sscarapp/pages/editProfile/contact_info_edit_page.dart';
import 'package:sscarapp/pages/editProfile/edit_profile_page.dart';
import 'package:sscarapp/pages/editProfile/preferences_settings_page.dart';
import 'package:sscarapp/pages/licensePlates/owned_license_plates_page.dart';
import 'package:sscarapp/services/firebase/database/premium/premium_user_database_services.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/tabBarPages/activities_page.dart';
import 'package:sscarapp/tabBarPages/home_page_main.dart';
import 'package:sscarapp/tabBarPages/self_user_profile_page.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:sscarapp/widgets/modal_bottom_sheet_buy_tokens_widget.dart';
import 'package:sscarapp/widgets/show_single_button_alert_dialog.dart';
import 'package:sscarapp/widgets/show_text_field_alert_dialog.dart';
import '../helper/manuplator_functions.dart';
import '../helper/push_notification_functions.dart';
import '../helper/user_defaults_functions.dart';
import '../pages/auth/login_page.dart';
import '../pages/profile/target_nonuser_plate_profile_page.dart';
import '../pages/profile/target_user_profile_page.dart';
import '../services/firebase/database/DM/user_dm_services.dart';
import '../services/firebase/database/auth/database_auth.dart';
import '../services/firebase/database/license_plates/license_plates_services.dart';
import '../services/revenue_cat/store_config.dart';
import '../widgets/alert_view/banned_alert_view_widget.dart';
import '../widgets/bottom-navifation-tab-bar.dart';
import '../widgets/login_to_see_page_details.dart';
import '../widgets/modal_bottom_sheet_profile.dart';

class MainControllerTabBar extends StatefulWidget {
  MainControllerTabBar({Key? key, required this.isSignedIn}) : super(key: key);

  late bool isSignedIn;

  @override
  State<MainControllerTabBar> createState() => MainControllerTabBarState();
}

class MainControllerTabBarState extends State<MainControllerTabBar> {

  int tabBarIndex = 1;
  int? _unreadDMCount;
  String? _userUid;
  String? _userNickname;
  Tokens? _userTokenInfo;
  DateTime? bannedUntil;

  UserPersonalDataModel? usersData;

  late bool isAndroid = true;

  List<double> appBarSignedInLeadingWidths = [
    110,//0
    120,
    30,//0
  ];

  List<double> appBarLeadingWidths = [
    0,//0
    120,
    0,//0
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
    //initPlatformState();
    initPlatformStates();
    isDeviceTypeAndorid();
  }

  void isDeviceTypeAndorid() {
    isAndroid = InformatorFunctions().getDeviceType() == DevicesTypes.android;
  }

  Future<void> initPlatformStates() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey);
      /*if (buildingForAmazon) {
        // use your preferred way to determine if this build is for Amazon store
        // checkout our MagicWeather sample for a suggestion
        configuration = AmazonConfiguration("public_amazon_sdk_key");
      }*/
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey);
    }
    if(configuration == null) return;
    try{
      await Purchases.configure(configuration);
      print("2003f23f_asd ");
    } catch (e){
      print("23f23f_asd $e");
    }
  }

  Future<void> initPlatformState() async {
    // Enable debug logs before calling `configure`.
    await Purchases.setDebugLogsEnabled(true);

    /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids
    - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
    PurchasesConfiguration configuration;
    if (StoreConfig.isForAmazonAppstore()) {
      configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    } else{
      configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..observerMode = false;
    }
    await Purchases.configure(configuration);

  }

  getUserInfo() async{
    bool signed = await UserDefaultsFunctions.getUserLoggedInStatus();
    widget.isSignedIn = signed;
    await UserDefaultsFunctions.getUserUidFromSF().then((value) async {
      if (value != null) {
        _userUid = value;
        log("logged in user $_userUid");
        usersData = await UserDatabaseService(userUid: value).getUsersAllData()
            .catchError((onErr) {
          log(onErr);
        });

        log("23f2_f32f32f_@#f23 ${usersData?.bannedUntil}");

        bannedUntil = _checkIfBanned(usersData?.bannedUntil);
        if (bannedUntil != null) {
          if (!mounted) return;
          bannedAlertViewWidget(
              context: context,
              date: bannedUntil!
          );
        }

        final isValid = await UserDefaultsFunctions.getUserPremiumCheckDateIsValidSF();
        if (!isValid) {
          PremiumUserDatabaseServices(userUid: value).checkIfUserPremium().then((value) {
            UserDefaultsFunctions.saveUserIsPremiumSF(value);
            UserDefaultsFunctions.saveUserPremiumCheckDateSF();
          });
        }
        final asd = await UserDefaultsFunctions.getUserIsPremiumSF();
        //await UserDefaultsFunctions.removeUserPremiumCheckDateSF();

        if (usersData?.nickname == null) {
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return SetNicknamePage(userUid: value,);
          }));
        } else{
          UserDefaultsFunctions.saveUserUsernameSF(usersData?.nickname);
        }

        if (usersData?.profilePicture != null) {
          UserDefaultsFunctions.saveUserProfilePictureURLSF(usersData!.profilePicture!);
        }

        UserDefaultsFunctions.saveUserFullnameSF(usersData?.fullname);
        getUsersTokenInfo(value);
        getUserUsernameSF(value);
        getUnreadConvosCount();
      }else{
        getNonuserTokenInfo();
      }
    });

  }

  DateTime? _checkIfBanned(int? milliSinceEpoch){
    if (milliSinceEpoch ==null)return null;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(milliSinceEpoch  , isUtc: true);
    log("23f23f23f32f_32f23gff2 $date");
    final dateNow = DateTime.now();

    log("23f2F_32gf32g_32g32 ${dateNow.add(Duration(days: 2)).millisecondsSinceEpoch}");
    if (!dateNow.difference(date).isNegative) {
      return null;
    }
    return date;
  }

  getUnreadConvosCount(){
    UserDMServices(userUid: _userUid!).getUsersDMListUnreadConvosCountData()
        .then((value){
      setState(() {
        _unreadDMCount = value;
      });
    });
  }

  void getUsersTokenInfo(String userUid) async {
    _userTokenInfo = await UserDatabaseService(userUid: userUid).getUsersTokenInfo();
    setState(() { });
    log("c2cv2f ${_userTokenInfo?.tokenCount}");
    final dateFormatter = DateFormat("dd-MM-yyyy HH:mm");
    if (_userTokenInfo == null) {
      final date = dateFormatter.format(DateTime.now());
      UserDatabaseService(userUid: userUid).setUserInitialTokenCount();
      _userTokenInfo = Tokens(lastFreeGivenDate: date, tokenCount: AppConstants.initialTokenCount.toString());
      log("c2cv222f ${_userTokenInfo?.tokenCount}");
    }else{
      final dateFormatter = DateFormat("dd-MM-yyyy HH:mm");
      log("${dateFormatter.parse(_userTokenInfo!.lastFreeGivenDate!)} ${DateTime.now()} 43f2f");
      if (DateTime.now().difference(dateFormatter.parse(_userTokenInfo!.lastFreeGivenDate!)).inDays > 0) {
        UserDatabaseService(userUid: userUid).giveFreeTokensDaily(int.parse(_userTokenInfo!.tokenCount!));
        final tokenCount = (int.parse(_userTokenInfo!.tokenCount) + AppConstants.dailyFreeTokenCount).toString();
        _userTokenInfo = Tokens(lastFreeGivenDate: dateFormatter.format(DateTime.now()), tokenCount: tokenCount);
        log("c2cvsdfsdf2f ${_userTokenInfo?.tokenCount}");

      }
    }

    setState(() {
      log("setstate 213f ${_userTokenInfo?.tokenCount}");

    });
  }

  void getNonuserTokenInfo() async {
    _userTokenInfo = await UserDefaultsFunctions.getUserTokenInfoSF();
    print("1df1df12 ${_userTokenInfo?.tokenCount} ${_userTokenInfo?.lastFreeGivenDate}");
    final dateFormatter = DateFormat("dd-MM-yyyy HH:mm");
    if(_userTokenInfo == null){
      _userTokenInfo = await UserDefaultsFunctions.setInitialTokensSF(AppConstants.initialTokenCount);
      setState(( ) {
        log("d23f2f32f ${_userTokenInfo?.tokenCount} ${_userTokenInfo?.lastFreeGivenDate}");
      });
    }else{
      if (DateTime.now().difference(dateFormatter.parse(_userTokenInfo!.lastFreeGivenDate!)).inDays > 0) {
        UserDefaultsFunctions.giveFreeTokensDaily(tokens: int.parse(_userTokenInfo!.tokenCount!));
        _userTokenInfo = await UserDefaultsFunctions.getUserTokenInfoSF();
      }
    }
    setState(( ) {
      log("23fd2f32 ${_userTokenInfo?.tokenCount} ${_userTokenInfo?.lastFreeGivenDate}");
    });
  }

  void getUserUsernameSF(String userUid) async {
    await UserDefaultsFunctions.getUserUsernameFromSF().then((value) async {
      _userNickname = value;
    });
  }

  void nicknameChanged(String nickname){
    setState(() {
      _userNickname = nickname;
    });
  }

  Future<bool> watchAdsEarnToken() async {
    print("d123f32f tryng");
    if (_userTokenInfo == null) return false;
    if(_userUid != null){
      print("d123f32f tryng user");
      final res = await UserDatabaseService(userUid: _userUid!)
          .addTokensToUser(tokenInfo: _userTokenInfo!);
      if(!res){
        showSnackbar(context: context, color: Colors.redAccent, message: "olmadi?");
        return false;
      }
      print("d123f32f tryng user $res");

      Future.delayed(const Duration(seconds: 2), () {
        getUsersTokenInfo(_userUid!);
      });
      return true;
    } else{
      final res = await UserDefaultsFunctions.addTokensSF(tokens: AppConstants.watchAdsEarnToken);
      if(!res){
        showSnackbar(context: context, color: Colors.redAccent, message: "olmadi");
        return false;
      }
      getNonuserTokenInfo();
      return true;
    }
  }

  Future<bool> plateSearchedDecreaseToken() async {
    print("23d23e234 plateSearchedDecreaseToken ");
    if (_userTokenInfo == null) return false;
    if(_userUid != null){
      print("23d23e234 useruidnul degil ");
      final res = await UserDatabaseService(userUid: _userUid!)
          .plateSearchedDecreaseToken(_userTokenInfo!);
      if(!res){
        if(!mounted) return false;
        showSnackbar(context: context, color: Colors.redAccent, message: "Token yetersiz?");
        return false;
      }
      Future.delayed(const Duration(seconds: 2), () {
        getUsersTokenInfo(_userUid!);
      });
      return true;
    } else{
      final res = await UserDefaultsFunctions.decreaseTokenPlateSearchSF();
      if(!res){
        if(!mounted) return false;
        showSnackbar(context: context, color: Colors.redAccent, message: "Yetersiz token.");
        return false;
      }

      Future.delayed(const Duration(seconds: 2), () {
        getNonuserTokenInfo();
      });
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {


    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double heightOfScreen = MediaQuery.of(context).size.height;

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final bottomSafeAreaHeight =      mediaQueryData.padding.bottom;


    List<Widget> appBarLeadings = [
      Container(),
      OpenCameraActionButton(isAndroid: isAndroid, userUid: _userUid ,),
      Container(),
    ];

    log("$bottomSafeAreaHeight f23f_2f3");

    signOutFunction() {
      DatabaseAuth().signOut().then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return LoginPage();
        }));
        setState(() {
          widget.isSignedIn = false;
          showSnackbar(context: context, color: Colors.grey, message: "Oturum kapatıldı");
          //12d1f1
          getNonuserTokenInfo();
        });
      });
    }

    editProfileFunction() {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            if(_userUid==null) return Container();
            return EditProfilePage(userUid: _userUid!,);
          })
      ).then((value) {
        UserEditProfileInfo? info = value as UserEditProfileInfo?;
        _userNickname = info?.nickname;

        setState(() {});
      });
    }

    contactDetailsFunction() {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            if(_userUid==null) return Container();
            return ContactInfoEditPage(userUid: _userUid!,);
          })
      ).then((value) {

        setState(() {});
      });

    }

    preferencesFunction() {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            if(_userUid==null) return Container();
            return PreferencesSettingsPage(userUid: _userUid!,);
          })
      ).then((value) {
        UserPreferencesInfo info = value as UserPreferencesInfo;
        log("message info got it : ${info.forSaleLink}");
        //_userNickname = info.nickname;
        setState(() {});
      });
    }

    myLicensePlatesFunction() {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            if(_userUid==null) return Container();
            return OwnedLicensePlatesPage(userUid: _userUid!,);
          })
      ).then((value) {
        UserPreferencesInfo info = value as UserPreferencesInfo;
        log("message info got it : ${info.forSaleLink}");
        //_userNickname = info.nickname;
        setState(() {});
      });
    }

    contactUsFunction() {
      if (_userUid == null) {
        return;
      }
      showTextFieldAlertDialog(
          context: context,
          title: "Bize ulaş",
          description: "Size nasıl yardımcı olabiliriz?",
          buttonTitle: "Gönder",
          userUid: _userUid!,
          type: ModeratorReportCases.contactUs,
      );
    }

    List<Widget> appBarActions = [
      IncomingMessagesDisplayActionButton(badgeCountText: (_unreadDMCount ?? 0).toString(), isSignedIn: widget.isSignedIn,),
      TokenDisplayActionButton(
        tokenInfo: _userTokenInfo ?? Tokens(lastFreeGivenDate: "",
            tokenCount: "0"),
        isSignedIn: _userUid != null,
      ),
      SelfUserProfileSettingsActionButton(
        isSignedIn: widget.isSignedIn,
        signOutFunction: signOutFunction,
        editProfileFunction: editProfileFunction,
        contactDetailsFunction: contactDetailsFunction,
        preferencesFunction: preferencesFunction,
        myLicensePlatesFunction: myLicensePlatesFunction,
        contactUsFunction: contactUsFunction,
      ),
    ];


    List<String> appBarTitles = [
      "Aktiviteler",
      "ssCar",
      _userNickname ?? "",
    ];

    List<Widget> bodies = [
      const ActivitiesPage(),
      HomePageMain(plateSearchedDecreaseToken: plateSearchedDecreaseToken, watchAdsEarnToken: watchAdsEarnToken,),
      SelfUserProfilePage(nicknameHasChanged: nicknameChanged,),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
       bottomNavigationBar: Column(
         mainAxisAlignment: MainAxisAlignment.end,
         mainAxisSize: MainAxisSize.min,
         children: [
           BottomNavigationTabBar( ///safearea eklenecek
             index: 0,
             onTap: (int index) {
               setState(() {
                 tabBarIndex = index;
               });
             },
           ),
           Container(
             height: bottomSafeAreaHeight,
             color: Colors.grey.shade200,
           )
         ],
       ),
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: widget.isSignedIn ? appBarSignedInLeadingWidths[tabBarIndex] : appBarLeadingWidths[tabBarIndex],
        elevation: 0,
        backgroundColor: AppConstants().secondaryColor,
        title: Center(child: Text(appBarTitles[tabBarIndex])),
        actions: [appBarActions[tabBarIndex]],
        leading: appBarLeadings[tabBarIndex],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: tabBarIndex == 1 ?
      bodies[tabBarIndex] :
      widget.isSignedIn ?
      bodies[tabBarIndex] :
      Container(child: LoginToSeePageDetails()),
    );
  }
}

class SelfUserProfileSettingsActionButton extends StatelessWidget {
  const SelfUserProfileSettingsActionButton({
    Key? key,
    bool? this.isSignedIn = false,
    required this.signOutFunction,
    required this.editProfileFunction,
    required this.contactDetailsFunction,
    required this.preferencesFunction,
    required this.myLicensePlatesFunction,
    required this.contactUsFunction,
  }) : super(key: key);

  final isSignedIn;
  final Function signOutFunction;
  final Function editProfileFunction;
  final Function contactDetailsFunction;
  final Function preferencesFunction;
  final Function myLicensePlatesFunction;
  final Function contactUsFunction;

  @override
  Widget build(BuildContext context) {
    print("SelfUserProfileSettingsActionButton is rebuilt");
    return isSignedIn ? Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: IconButton(
        icon: const Icon(Icons.settings),
        color: Colors.white,
        onPressed: () {
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) {
              return ModalBottomSheetSelfProfileWidget(
                signOutFunction: signOutFunction,
                editProfileFunction: editProfileFunction,
                contactDetailsFunction: contactDetailsFunction,
                preferencesFunction: preferencesFunction,
                myLicensePlatesFunction: myLicensePlatesFunction,
                contactUsFunction: contactUsFunction,
              );
            },
          );
        },
      ),
    )  :  Container();
  }
}


class IncomingMessagesDisplayActionButton extends StatefulWidget {
  const IncomingMessagesDisplayActionButton({Key? key, required this.badgeCountText, bool? this.isSignedIn = false}) : super(key: key);

  final String badgeCountText;
  final isSignedIn;

  @override
  State<IncomingMessagesDisplayActionButton> createState() => _IncomingMessagesDisplayActionButtonState();
}

class _IncomingMessagesDisplayActionButtonState extends State<IncomingMessagesDisplayActionButton> {
  @override
  Widget build(BuildContext context) {
    return widget.isSignedIn ? Container(
      margin: const EdgeInsets.fromLTRB(60, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppConstants().primaryColor ,
      ),
      child: badge.Badge(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        badgeContent: Text(widget.badgeCountText),
        child: GestureDetector(
          child: const Icon(Icons.chat_rounded, color: Colors.white,),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_){
                      return const DMListPage();
                    }
                )
            );
          },
        ),
      ),
    ) : Container();
  }
}


class TokenDisplayActionButton extends StatefulWidget {
  const TokenDisplayActionButton({
    Key? key,
    required this.tokenInfo,
    required this.isSignedIn,
    this.userUid
  }) : super(key: key);
  final Tokens tokenInfo;
  final bool isSignedIn;
  final String? userUid;

  @override
  State<TokenDisplayActionButton> createState() => _TokenDisplayActionButtonState();
}

class _TokenDisplayActionButtonState extends State<TokenDisplayActionButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          final dateFormatter = DateFormat("dd-MM-yyyy HH:mm");
          print("${widget.tokenInfo.lastFreeGivenDate} 3df2f32");
          final dateDiff = DateTime.now().difference(dateFormatter.parse(widget.tokenInfo.lastFreeGivenDate)).inHours;
          showSingleButtonAlertDialog(
              context: context,
              title: "Token nedir?",
              description: "ssCar olarak yalnızca gerektiği durumlarda, araç sahiplerini rahatsız etmeyecek şekilde iletişime geçmenizi amaçladık, bu yüzden sorgulamaya belirli bir sınır getirdik. Hesabına her 24 saatte bir 20 token otomatik olarak transfer edilecektir. Tüyo: Üye ol, ekstra token kazan! Hediye token için kalan süre $dateDiff saat",
              buttonTitle: "Token satin al!",
              showSignup: !widget.isSignedIn,
              buttonAction: () async {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return ModalBottomSheetBuyTokensWidget(
                        userUid: widget.userUid,
                        tokenInfo: widget.tokenInfo,
                      );
                    }
                );
              }
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          height: 20,
          decoration: BoxDecoration(
              border: Border.all(color: AppConstants().primaryColor),
              borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            children: [
              const Icon(Icons.token, color: Colors.yellow, size: 20,),
              Text(
                "Token: ${widget.tokenInfo.tokenCount}",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpenCameraActionButton extends StatelessWidget {
  final bool isAndroid;
  final String? userUid;
  const OpenCameraActionButton({
    Key? key,
    required this.isAndroid,
    this.userUid,
  }) : super(key: key);

  static const taramaChannel = MethodChannel("com.bakiryazilim.sscar/taramaChannel");

  @override
  Widget build(BuildContext context) {
    Future openTarama() async {
      final openTaramaPageResult = await taramaChannel.invokeMethod("openTaramaPage");
      final safePlate = StringPlateExtensions.makePlateNumberSafe(openTaramaPageResult);
      if(StringPlateExtensions.isRepresentingSignPlate(openTaramaPageResult)){
        // await Feedback.forTap(context);
        await HapticFeedback.heavyImpact();
              LicensePlatesServices(safePlateNumber: safePlate).getPlatesOwnerUserUid().then((value){
                LicensePlatesServices(safePlateNumber: safePlate,).newLicensePlateLookupSave(userUid: userUid);
                if(value == null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return TargetNonuserPlateProfilePage(plateNumber: safePlate, );
                  }));
                }else{
                  if (value == userUid) {
                    showSnackbar(context: context, color: Colors.yellow, message: "Bu plaka zaten size ait");
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return TargetUserProfilePage(targetUserUid: value, plateNumber: safePlate, );
                  }));
                }
              });

      }else{
        showSnackbar(context: context, color: Colors.redAccent, message: "Bunun bir plaka olduguna emin misin?");
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: isAndroid ? () {
          showSnackbar(context: context, color: Colors.orangeAccent, message: "Plaka tarama çok yakında sizlerle...");
        } : openTarama,/* () {
          showSnackbar(context: context, color: Colors.orangeAccent, message: "Plaka tarama çok yakında sizlerle...");
        },,openTarama*/
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
         // height: 40,//
          //width: 20,
          decoration: BoxDecoration(
            border: Border.all(color: AppConstants().secondaryColor),
            borderRadius: BorderRadius.circular(10),
            color: AppConstants().primaryColor,
          ),
          //constraints: BoxConstraints(minWidth: 10, maxWidth: 50),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, color: Colors.white, size: 20,),
              Text("Tarama", style: TextStyle(fontSize: 14),),
            ],
          ),
        ),
      ),
    );
  }
}

enum tabBarIndexes{
  activities,
  searchPlate,
  profile,
}

extension tabBarIndexesExtension on tabBarIndexes {
  int get routeUrl {
    switch (this) {
      case tabBarIndexes.activities:
        return 0;
      case tabBarIndexes.searchPlate:
        return 1;
      case tabBarIndexes.profile:
        return 2;
      default:
        return 2;
    }
  }
}