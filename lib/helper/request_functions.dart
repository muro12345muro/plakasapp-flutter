import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestFunctions{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestPermissionNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("granted permissionf or noti");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional){
      print("granted provisional permissionf or noti");
    } else{
      print("user declined or has not accepted  for noti");
    }
  }

  Future<String?> getPushToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<bool> requestNotificationsPermission() async {
    try{
      final permission = await Permission.notification.request();
      return permission.isGranted;
    } catch(e) {
      log("requestCameraPermission 234g_dsfg_dfg $e");
      return false;
    }
  }

  Future<bool> requestCameraPermission() async {
    try{
      final permission = await Permission.camera.request();
      return permission.isGranted;
    } catch(e) {
      log("requestCameraPermission 234g_dsfg_dfg $e");
      return false;
    }
  }

  Future<bool> requestMicrophonePermission() async {
    try{
      final permission = await Permission.microphone.request();
      return permission.isGranted;
    } catch(e) {
      log("requestmicrophonePermission 234g_dsfg_dfg $e");
      return false;
    }
  }


  Future<bool> requestPhotosPermission() async {
    try{
      final permission = await Permission.photos.request();
      return permission.isGranted;
    } catch(e) {
      log("requestmediaLibraryPermission 234g_dsfg_dfg $e");
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try{
      final permission = await Permission.location.request();
      return permission.isGranted;
    } catch(e) {
      log("requestlocationPermission 234g_dsfg_dfg $e");
      return false;
    }
  }

  Future<bool> requestLocationWhenInUsePermission() async {
    try{
      final permission = await Permission.locationWhenInUse.request();
      return permission.isGranted;
    } catch(e) {
      log("requestlocationWhenInUsePermission 234g_dsfg_dfg $e");
      return false;
    }
  }

  Future<bool> requestLocationAlwaysPermission() async {
    try{
      final permission = await Permission.locationAlways.request();
      return permission.isGranted;
    } catch(e) {
      log("requestlocationAlwaysPermission 234g_dsfg_dfg $e");
      return false;
    }
  }



  Future<bool> isLocationPermissionGiven() async {
    try{
      return await Permission.location.isGranted;
    } catch(e) {
      return false;
    }
  }


  Future<bool> isPhotosPermissionGiven() async {
    try{
      return await Permission.photos.isGranted;
    } catch(e) {
      return false;
    }
  }

}