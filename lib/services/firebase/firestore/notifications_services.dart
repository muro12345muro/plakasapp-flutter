

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/helper/informator_functions.dart';

class NotificationsServices {
  FirebaseFirestore fsInstance = FirebaseFirestore.instance;

  Future<bool> setPushTokenDevice({
    required String token,
    String? userUid,
  }) async {
    try {
      userUid ??= await InformatorFunctions().getDevicesUniqueId();
      print("12d1d1 $userUid");
      if (userUid == null) return false;
      final dateFormatterDMYHM = DateFormat("dd/MM/yyyy HH:mm");
      final now = dateFormatterDMYHM.format(DateTime.now());
      fsInstance.collection("users_table").doc(userUid!).set({
        "date": now,
        "fcmToken": token,
      });
      return true;
    } catch (e) {
      log("asd23ff $e");
      return false;
    }
  }

  Future<String?> getPushTokenOfUser({
    String? userUid,
  }) async {
    try {
      userUid ??= await InformatorFunctions().getDevicesUniqueId();
      print("12d1d1 $userUid");
      if (userUid == null) return null;
      final snapshot = await fsInstance.collection("users_table").doc(userUid!).get();
      if (snapshot.exists) {
        return snapshot.data()!["fcmToken"];
      } else{
        return null;
      }
    } catch (e) {
      log("asd23ff $e");
      return null;
    }
  }
}