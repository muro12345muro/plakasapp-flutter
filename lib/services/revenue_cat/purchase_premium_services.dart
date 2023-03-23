import 'dart:developer';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sscarapp/services/revenue_cat/revenuecat_purchase_services.dart';

class PurchasePremiumServices {
  final String userUid;
  PurchasePremiumServices({required this.userUid});

  Future<bool> buyPremiumAccount({required PremiumAccountOptions premiumOptions}) async {
    try{
      final purchase = await Purchases.purchaseProduct(premiumOptions.getStringId);
      return true;
    } catch (e){
      log("$e");
      return false;
    }
  }

}

