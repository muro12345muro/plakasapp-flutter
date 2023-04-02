import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sscarapp/helper/request_functions.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/pages/DM/dm_list_page.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/services/firebase/firestore/notifications_services.dart';
import 'package:sscarapp/tabBarPages/activities_page.dart';
import 'package:sscarapp/tabBarPages/home_page_main.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/tabBarPages/main_controller.dart';
import 'package:sscarapp/tabBarPages/self_user_profile_page.dart';


Future main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  //initRevenue();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(const MyApp());
}

/*
*
*
* plakayi kimler bakmis ozleligi ekle
* once kayit olmasi gereksin
* sonra plakayi sahiplenmesi
* sonra ilk 3 kisiyi goster sonrasi icin premium iste
* premium alirsa tum listeyi goster activities usulu
*
*
* */



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isSignedIn = false;
  String? _uUid;
  Timer? lastSeenTimer;

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserLoggedInStatus();
    _initGoogleMobileAds();

    UserDefaultsFunctions.getUserUidFromSF().then((value){
      if(value == null) return;
      _uUid = value;
      setPushToken();
      startSettingLastSeen();
      UserDatabaseService(userUid: value).setUsersOnlineActivityBool(isActive: true,);
    });
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    lastSeenTimer?.cancel();
    if (_uUid != null) {
      UserDatabaseService(userUid: _uUid!).setUsersOnlineActivityBool(isActive: false,);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startSettingLastSeen();
      if (_uUid != null) {
        UserDatabaseService(userUid: _uUid!).setUsersOnlineActivityBool(
          isActive: true,);
      }
    } else{
      lastSeenTimer?.cancel();
      if (_uUid != null) {
        UserDatabaseService(userUid: _uUid!).setUsersOnlineActivityBool(
          isActive: false,
        );
      }
    }
  }

  void startSettingLastSeen(){
    if(lastSeenTimer?.isActive ?? false) return;
    lastSeenTimer = Timer.periodic(const Duration(seconds: 2), (Timer t){
      UserDefaultsFunctions.getUserUidFromSF().then((value){
        if (value == null) {
          return;
        }
        UserDatabaseService(userUid: value).setUsersLastSeenNow();
      });
    });
  }


  setPushToken() async {
    RequestFunctions().getPushToken().then((value) async {
      log("getPushToken d23f23df23f $value");
      if(value == null) return;
      if (await NotificationsServices().setPushTokenDevice(token: value, userUid: _uUid)) {
        log("23f2fww2f $_uUid");
      }else{
        print("32d21d2d err setPushTokenDevice");
      }
    });
  }

  getUserLoggedInStatus() async {
    await UserDefaultsFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
          log("from maindart: is signed in $_isSignedIn");
        });
      } else{
        setState(() {
          _isSignedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //print("object i am called 123124");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: AppConstants().primaryColor,
          scaffoldBackgroundColor: Colors.white
      ),
      routes: {
        '/': (context) => MainControllerTabBar(isSignedIn: _isSignedIn,),
        '/home-page': (context) => const HomePageMain(),
        '/activities': (context) => const ActivitiesPage(),
        '/self-user-profile-page': (context) => const SelfUserProfilePage(),
        '/dm-list-page': (context) => const DMListPage(),
      },
    );
  }
}
