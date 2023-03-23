import 'dart:core';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/services/revenue_cat/purchase_premium_services.dart';

import '../../../revenue_cat/revenuecat_purchase_services.dart';

class PremiumUserDatabaseServices{
  final String userUid;
  PremiumUserDatabaseServices({required this.userUid});
  var regularDMYHMformatter = DateFormat('dd-MM-yyyy HH:mm');
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  final usersChildInstances = FirebaseDatabase.instance.ref().child("kullanicilar");

  ///<READS>


  Future<bool> checkIfUserPremium() async {
    final snapshot = await usersChildInstances.child(userUid).child("premium").get();
    final json = snapshot.value as String?;
    log("$json 1252313 ");
    if(json == null) return false;
    var dateTime1 = DateFormat('yyyy/MM/dd').parse(json);
    final int diffInDays = dateTime1.difference(DateTime.now()).inDays;
    log("$diffInDays 1522313");
    if (diffInDays.isNegative) {
      return false;
    }
    return true;
  }


  ///</READS>

  ///<WRITES>

  Future<bool> premiumSubscriptionBought(PremiumAccountOptions premiumOptions) async {
    try {
      final addedDate = DateTime.now().add(Duration(
          days: PremiumAccountOptionsExtensions(premiumOptions).getDaysOfPremium));
      var dateFormatter = DateFormat('yyyy/MM/dd');
      final dateString = dateFormatter.format(addedDate);
      await usersChildInstances.child(userUid).update({"premium": dateString});
      return true;
    } catch (e) {
      print("23d_23d $e");
      return false;
    }
  }

  ///</WRITES>

}