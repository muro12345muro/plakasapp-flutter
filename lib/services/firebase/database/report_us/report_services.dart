import 'dart:core';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/helper/push_notification_functions.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/license_plates/license_plates_services.dart';
import 'package:sscarapp/services/firebase/database/moderation/firebase_moderation_services.dart';
import 'package:sscarapp/services/firebase/firestore/notifications_services.dart';


class ReportServices {
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  final dbInstance = FirebaseDatabase.instance;
  final reportsChildInstances = FirebaseDatabase.instance.ref().child(
      "reports");
  var regularYDMClassifierFormatter = DateFormat('yyyy/MM/dd');
  var regularDMYHMFormatter = DateFormat('dd-MM-yyyy HH:mm');

  ///<WRITES>
  Future<bool> reportProfileComment(ReportCommentPost reportCommentPost) async {
    var now = DateTime.now();
    String formattedDate = regularYDMClassifierFormatter.format(now);
    DatabaseReference reportUpdateChild = reportsChildInstances.child(
        "wall-posts");
    try {
      final String? autoChild = reportUpdateChild
          .push()
          .key;
      if (autoChild == null) return false;
      await reportUpdateChild.child(autoChild).update(
          reportCommentPost.toJson());
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<bool> reportUserProfile(ReportUserAccount reportUserAccount) async {
    var now = DateTime.now();
    String formattedDate = regularYDMClassifierFormatter.format(now);
    DatabaseReference reportUpdateChild = reportsChildInstances.child(
        "user");

    try {
      final String? autoChild = reportUpdateChild
          .push()
          .key;
      if (autoChild == null) return false;
      await reportUpdateChild.child(autoChild).update(
          reportUserAccount.toJson());
      return true;
    } catch (e) {
      log("asc22_23gf $e");
      return false;
    }
  }

  Future<bool> contactUsFormApply(ContactUsForm contactUsForm) async {
    var now = DateTime.now();
    String formattedDate = regularYDMClassifierFormatter.format(now);
    DatabaseReference reportUpdateChild = reportsChildInstances.child(
        "contact-us");
    try {
      log("@3f2f23f_32gf32");
      final String? autoChild = reportUpdateChild
          .push()
          .key;
      if (autoChild == null) return false;
      await reportUpdateChild.child(autoChild).update(
          contactUsForm.toJson());
      return true;
    } catch (e) {
      log("asc22_23gf $e");
      return false;
    }
  }

  Future<bool> reportSuggestPredefinedMessage(
      {required String message, String? userUid, String? userDeviceId}) async {
    var now = DateTime.now();
    String formattedDate = regularDMYHMFormatter.format(now);
    DatabaseReference reportUpdateChild = reportsChildInstances.child(
        "suggest-quoted-message");
    try {
      final String? autoChild = reportUpdateChild
          .push()
          .key;
      if (autoChild == null) return false;
      await reportUpdateChild.child(autoChild).update({
        "date": formattedDate,
        "message": message,
        "user": (userUid ?? userDeviceId) ?? "",
      });
      return true;
    } catch (e) {
      log("f2323fv $e");
      return false;
    }
  }

  Future<bool> reportUserFromDMChat(
      {required String message, String? userUid, required String targetUserUid, String? userDeviceId}) async {
    var now = DateTime.now();
    String formattedDate = regularDMYHMFormatter.format(now);
    DatabaseReference reportUpdateChild = reportsChildInstances.child(
        "suggest-quoted-message");
    try {
      final String? autoChild = reportUpdateChild
          .push()
          .key;
      if (autoChild == null) return false;
      await reportUpdateChild.child(autoChild).update({
        "date": formattedDate,
        "message": message,
        "user": (userUid ?? userDeviceId) ?? "",
      });
      return true;
    } catch (e) {
      log("f2323fv $e");
      return false;
    }
  }
}