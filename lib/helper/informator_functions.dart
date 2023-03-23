import 'dart:developer';
import 'dart:math';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show NetworkInterface, Platform;

import 'package:flutter/foundation.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';

import 'manuplator_functions.dart';

class InformatorFunctions {

  DevicesTypes? getDeviceType(){
    if (Platform.isAndroid) {
      return DevicesTypes.android;
    } else if (Platform.isIOS) {
      return DevicesTypes.ios;
    }else if (kIsWeb) {
      return DevicesTypes.web;
    }else{
      return null;
    }
  }


  Future<String?> getDevicesUniqueId() async {
    final device = getDeviceType();
    if(device == null) return null;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    switch(device){
      case DevicesTypes.ios:
        IosDeviceInfo ios = await deviceInfo.iosInfo;
        return ios.identifierForVendor;
      case DevicesTypes.android:
        final id = getnSetCustomUniqueIdForVendor();
        return id;
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      case DevicesTypes.web:
        WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
        return webBrowserInfo.userAgent;
    }
  }

  Future<String> getnSetCustomUniqueIdForVendor() async {
    final vendorId = await UserDefaultsFunctions.getVendorIdSF();
    if (vendorId != null) return vendorId;
    final newId =  getRandomString(32);
    await UserDefaultsFunctions.saveVendorIdSF(newId);
    return newId;
  }

  String getRandomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  bool isValidEmail(String text) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(text);
  }

  bool isValidPhoneNumber(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    }
    else if (!regExp.hasMatch(value)) {
      return false;
    }
    else if(value.substring(0,1) != "+") {
      return false;
    }
    return true;
  }

  TextInputType returnKeyboardType(String inputText){
    String safePlate = StringPlateExtensions.makePlateNumberSafe(inputText);

    if(safePlate.length <= 1){
      return TextInputType.number;
    }
    if (StringPlateExtensions.isNumeric(safePlate.substring(inputText.length)) && inputText.length <= 2) {
      return TextInputType.number;
    }  else {
      return TextInputType.text;
    }

  }

  Future<String> getUsersIpAddress() async {
    final ipv4 = await Ipify.ipv4();
    return ipv4;
  }

}

enum DevicesTypes{
  ios,
  android,
  web,
}