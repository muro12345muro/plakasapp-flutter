
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProductsInfoServices {

  static Future<List<Offering>> fetchOffersByIds(List<String> ids) async {
    final offers = await fetchOffers();
    return offers.where((element) => ids.contains(element.identifier)).toList();
  }

  static Future<List<Offering>> fetchOffers({ bool all = true }) async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      if (!all) {
        final current = offerings.current;
        print("23f_2fd23 $current");
        print("${current?.availablePackages.length} 12d111e1 ");
        return current == null ? [] : [current];
      }  else{
        return offerings.all.values.toList();
      }
    } on PlatformException catch (e){
      print("error 23f32_d23d fetching offerings $e");
      return [];
    }
  }
}