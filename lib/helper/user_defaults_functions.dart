import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sscarapp/shared/app_constants.dart';

import '../models/models.dart';

class UserDefaultsFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userUidKey = "USERUIDKEY";
  static String userUsernameKey = "USERNAMEKEY";
  static String userProfilePictureURlKey = "USERPROFILEPICTUREURLKEY";
  static String userFullnameKey = "USERFULLNAMEKEY";
  static String userTokenCountKey = "USERTOKENCOUNTKEY";
  static String userTokenDateKey = "USERTOKENDATEKEY";
  static String userPremiumCheckDateKey = "USERPREMIUMCHECKDATEKEY";
  static String userIsPremiumKey = "ISUSERPREMIUMKEY";
  static String userVendorIdKey = "USERVENDORIDKEY";
  static String userIsIntroductionViewedKey = "USERISINTRODUCTIONVIEWEDKEY";

  static DateFormat regularDMYformatter = DateFormat("yyyy/MM/dd");
  static DateFormat regularDMYHMformatter = DateFormat("dd-MM-yyyy HH:mm");

  ///<WRITES>
  static Future<bool> setUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }


  static Future<bool> saveUserUidSF(String userUid) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userUidKey, userUid);
  }

  static Future<bool> saveUserUsernameSF(String? userUsername) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userUsernameKey, userUsername ?? "");
  }

  static Future<bool> saveUserProfilePictureURLSF(String profilePictureUrl) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userProfilePictureURlKey, profilePictureUrl);
  }

  static Future<bool> saveUserFullnameSF(String? userFullname) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userFullnameKey, userFullname ?? "Isimsiz Kullanici");
  }

  static Future<bool> saveUserPremiumCheckDateSF() async {
    var now = DateTime.now();
    String formattedDate = regularDMYformatter.format(now);
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userPremiumCheckDateKey, formattedDate);
  }

  static Future<bool> saveUserIsPremiumSF(bool? isPremium) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userIsPremiumKey, isPremium ?? false);
  }

  static Future<Tokens?> setInitialTokensSF(int count) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final res1 = await sf.setInt(userTokenCountKey, count);
    final date = regularDMYHMformatter.format(DateTime.now());
    final res2 = await sf.setString(userTokenDateKey, date);
    if(res1 && res2){
      return Tokens(lastFreeGivenDate: date, tokenCount: count.toString());
    }
    return null;
  }

  static Future<bool> giveFreeTokensDaily({required int tokens}) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final res1 =  await sf.setInt(userTokenCountKey, AppConstants.dailyFreeTokenCount + tokens);
    final res2 = await sf.setString(userTokenDateKey, regularDMYHMformatter.format(DateTime.now()));
    return(res1 && res2);
  }

  static Future<bool> addTokensSF({required int tokens}) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final hasToken = sf.getInt(userTokenCountKey);
    return await sf.setInt(userTokenCountKey, hasToken ?? AppConstants.initialTokenCount + tokens);
  }

  static Future<bool> decreaseTokenPlateSearchSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final hasToken = sf.getInt(userTokenCountKey);
    int newTokenCount = AppConstants.initialTokenCount - AppConstants.substractTokenPlateSearched;
    if (hasToken != null) {
      newTokenCount = hasToken - AppConstants.substractTokenPlateSearched;
      if(hasToken <= 0) return false;
    }
    return await sf.setInt(userTokenCountKey, newTokenCount);
  }

  static Future<bool> saveVendorIdSF(String vendorId) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userVendorIdKey, vendorId);
  }

  static Future<bool> saveIntroductionViewed() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userIsIntroductionViewedKey, true);
  }
  ///</WRITES>

  ///<READ>

  static Future<bool> isIntroductionViewed() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool? isViewed = sf.getBool(userIsIntroductionViewedKey);
    if (isViewed == null) return false;
    return isViewed;
  }

  static Future<bool> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool? loggedIn = sf.getBool(userLoggedInKey);
    if (loggedIn == null) return false;
    return loggedIn;
  }

  static Future<String?> getUserUidFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userUidKey);
  }

  static Future<String?> getVendorIdSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userVendorIdKey);
  }

  static Future<String?> getUserUsernameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userUsernameKey);
  }

  static Future<String?> getUserProfilePictureUrlFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userProfilePictureURlKey);
  }

  static Future<String?> getUserFullnameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userFullnameKey);
  }

  static Future<bool> getUserPremiumCheckDateIsValidSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final checkedDate = sf.getString(userPremiumCheckDateKey);
    if(checkedDate == null) return false;
    var dateTime1 = DateFormat('yyyy/MM/dd').parse(checkedDate);
    final int diffInHours = DateTime.now().difference(dateTime1).inDays;
    if(diffInHours.isNegative) return false;
    log("checkedDate $checkedDate 123");
    log("diffInHours $diffInHours 133323");
    return true;
  }
  static Future<bool> getUserIsPremiumSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final isPrem = sf.getBool(userIsPremiumKey);
    if (isPrem == null) return false;
    return isPrem;
  }

  static Future<String?> getUserGivenTokenDateSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final isPrem = sf.getString(userTokenDateKey);
    if (isPrem == null) return null;
    return isPrem;
  }

  static Future<Tokens?> getUserTokenInfoSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    final tokenDate = sf.getString(userTokenDateKey);
    print("23000f2f ${tokenDate}");
    if (tokenDate == null) return null;
    final tokens = sf.getInt(userTokenCountKey);
    print("23f2f ${tokens}");
    if (tokens == null) return null;
    final tokensInfo = Tokens(
        lastFreeGivenDate: tokenDate,
        tokenCount: tokens.toString());
    return tokensInfo;
  }
  ///</READ>


  ///<DELETES>
  static Future<bool> removeUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userLoggedInKey);
  }

  static Future<bool> removeUserUidSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userUidKey);
  }

  static Future<bool> removeUserUsernameSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userUsernameKey);
  }

  static Future<bool> removeUserProfilePictureUrlSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userProfilePictureURlKey);
  }

  static Future<bool> removeUserFullnameSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userFullnameKey);
  }

  static Future<bool> removeUserPremiumCheckDateSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userPremiumCheckDateKey);
  }

  static Future<bool> removeUserIsPremiumSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userIsPremiumKey);
  }

  static Future<bool> removeUserTokenDataSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.remove(userTokenCountKey).then((value) async {
      if(value == false) return false;
      return await sf.remove(userTokenDateKey);
    });
    return false;
  }


  static Future<bool> removeIsIntroductionViewedSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.remove(userIsIntroductionViewedKey);
  }
///</DELETES>

}