import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:developer';

import 'package:sscarapp/services/revenue_cat/products_info_services.dart';

class RevenueCatPurchaseServices {

  Future<bool> buyTokens({ required TokenOptions tokenOptions }) async {
    try {
      final offerings = await ProductsInfoServices.fetchOffersByIds([TokenOptionsExtensions(tokenOptions!).getStringId]);
      if (offerings.isNotEmpty) {
        await Purchases.purchasePackage(offerings[0].availablePackages[0]);
        return true;
      }else{
        return false;
      }
    } catch (e){
      print("23f0032_d23d3 buyTokens $e");
      return false;
    }
  }

  Future<bool> buyPremiumAccount({ required PremiumAccountOptions premiumAccountOptions }) async {
    try {
     /* print(PremiumAccountOptionsExtensions(premiumAccountOptions!).getStringId);
      final offerings = await ProductsInfoServices.fetchOffersByIds([PremiumAccountOptionsExtensions(premiumAccountOptions!).getStringId]);
      if (offerings.isNotEmpty) {
        await Purchases.purchasePackage(offerings[0].availablePackages[0]);
        print("23fd__23f");
        return true;
      }else{
        print("err23fd__23f");
        return false;
      }*/
      await Purchases.purchaseProduct(PremiumAccountOptionsExtensions(premiumAccountOptions).getStringId);
      return true;
    } catch (e){
      print("23f32_d23d3 buyPremiumAccount $e");
      return false;
    }
  }

}


enum PremiumAccountOptions{
  premiumAccountMonthly,
  premiumAccountAnnual,
}


extension PremiumAccountOptionsExtensions on PremiumAccountOptions {

  String get getStringId {
    switch (this) {
      case PremiumAccountOptions.premiumAccountMonthly:
        return "sscar_premium_acc_monthly";
      case PremiumAccountOptions.premiumAccountAnnual:
        return "sscar_premium_acc_anually";
      default:
        return "";
    }
  }

  int get getDaysOfPremium {
    switch (this) {
      case PremiumAccountOptions.premiumAccountMonthly:
        return 30;
      case PremiumAccountOptions.premiumAccountAnnual:
        return 360;
      default:
        return 0;
    }
  }

}

enum TokenOptions{
  token100,
  token300,
  token500,
}

extension TokenOptionsExtensions on TokenOptions {
  String get getStringId {
    switch (this) {
      case TokenOptions.token100:
        return "100_token";
      case TokenOptions.token300:
        return "300_token";
      case TokenOptions.token500:
        return "500_token";
      default:
        return "";
    }
  }

  String get getPrice {
    switch (this) {
      case TokenOptions.token100:
        return "16,99₺";
      case TokenOptions.token300:
        return "34,99₺";
      case TokenOptions.token500:
        return "49,99₺";
      default:
        return "";
    }
  }

  String get getTokenCountString {
    switch (this) {
      case TokenOptions.token100:
        return "100";
      case TokenOptions.token300:
        return "300";
      case TokenOptions.token500:
        return "500";
      default:
        return "";
    }
  }
}
