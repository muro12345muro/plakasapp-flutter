import 'dart:io';

class AdmobAdsHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7198758748123978/5092657969';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7198758748123978/2626176064';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return '<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7198758748123978/6685512057';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7198758748123978/8190795687';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}