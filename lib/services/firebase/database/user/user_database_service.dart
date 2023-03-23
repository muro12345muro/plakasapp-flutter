
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/common_services.dart';
import 'package:sscarapp/shared/app_constants.dart';

DatabaseReference databaseInstanceRef = FirebaseDatabase.instance.ref();

class UserDatabaseService {
  final String userUid;

  UserDatabaseService({required this.userUid});

  var regularDMYHMformatter = DateFormat('dd-MM-yyyy HH:mm');

  ///<WRITES>
  Future<bool> registerUserToUsers(String email, String password,
      String? deviceId) async {
    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);
    deviceId = await InformatorFunctions().getDevicesUniqueId();
    Map<String, Object> data = {
      "registerDate": formattedDate,
      "lastSeen": formattedDate,
      "emailVerified": false,
      "email": email,
      "deviceId": deviceId ?? "",
    };
    //0 - ios
    //1 - android
    if (Platform.isAndroid) {
      data["os"] = 1;
    } else if (Platform.isIOS){
      data["os"] = 0;
    } else{
      data["os"] = 9;
    }
    try {
      return await databaseInstanceRef.child("kullanicilar").child(userUid)
          .update(data)
          .then((_) async {
        return true;
      })
          .catchError((e) {
        return false;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendDrivingPoints({
    required String targetUserUid,
    required String plateNumber,
    required bool isUser,
    required int points,
    UserDrivingPointsInfo? drivingPointsInfo,
  }) async {
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    final date = regularDMYHMformatter.format(DateTime.now());

    try {
      await databaseInstanceRef.child("driverPoints/$domainNode/$targetUserUid")
          .update({
        "pointSendersCount": (drivingPointsInfo?.pointSendersCount ?? 0) + 1,
        "totalDrivingPoints": (drivingPointsInfo?.totalDrivingPoints ?? 0) +
            points
      });
      final autoId = await databaseInstanceRef
          .child("driverPoints/$domainNode/$targetUserUid/givenBy/$userUid")
          .push()
          .key;
      await databaseInstanceRef.child(
          "driverPoints/$domainNode/$targetUserUid/givenBy/$userUid/$autoId")
          .update({
        "date": date,
        "plate": plateNumber,
        "point": points,
      });
      return true;
    } catch (e) {
      log("error sending point $e");
      return false;
    }
  }

  Future<bool> saveNewProfilePicture(String imageURL) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).update({"profilePicture": imageURL});
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<bool> updateUserProfileInfo(UserEditProfileInfo editedInfo) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).update(editedInfo.toJson());
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<bool> updateUserContactInfo(
      UserEditContactInfo editedContactInfo) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("phoneSettings").update(
          editedContactInfo.toJson());
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<bool> updateUserPreferencesInfo(
      UserPreferencesInfo editedPreferencesInfo) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("preferences").update(
          editedPreferencesInfo.toJson());
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }


  Future<bool> userBlocksUser({ required String targetUserUid}) async {
    try {
      await databaseInstanceRef.child("users-blockings")
          .child(userUid).update({targetUserUid: true});
      return true;
    } catch (e) {
      log("block errior $e");
      return false;
    }
  }


  Future<bool> userUnblocksUser({required String targetUserUid}) async {
    try {
      await databaseInstanceRef.child("users-blockings")
          .child(userUid).update({targetUserUid: false});
      return true;
    } catch (e) {
      log("block errior $e");
      return false;
    }
  }

  Future<bool> updatePhoneNumber({required String phoneNumber}) async {
    try {
      final date = regularDMYHMformatter.format(DateTime.now());
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("phoneSettings").update({"phoneNumber": phoneNumber, "date": date});
      return true;
    } catch (e) {
      log("phone errior $e");
      return false;
    }
  }

  Future<bool> addNewNotification(
      {required String content, required String toPlaka, required String targetUserUid, required NotificationKinds kind,}) async {
    final date = regularDMYHMformatter.format(DateTime.now());
    final UserInAppNotifications noti = UserInAppNotifications(content: content,
        date: date,
        kind: NotificationKindsExtension(kind).nameByKind,
        senderid: userUid,
        toPlaka: toPlaka);
    try {
      final String? autoId = databaseInstanceRef
          .child("inapp-notifications/")
          .child(targetUserUid)
          .push()
          .key;
      if (autoId == null) return false;
      await databaseInstanceRef.child("inapp-notifications")
          .child(targetUserUid).child(autoId).update(noti.toJson());
      return true;
    } catch (e) {
      log("23rf_f00f23_f2 $e");
      return false;
    }
  }

  Future<bool> userSendNewEmoji({required EmojiKinds emoji,
    required String targetUseruid,
    required String toPlaka,
    required bool isUser,
  }) async {
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);
    try {
      final String? autoId = databaseInstanceRef
          .child("sentEmojis/$domainNode")
          .child(targetUseruid)
          .child("emojiGivenBy")
          .child(userUid)
          .push()
          .key;
      if (autoId == null) return false;
      final emojiCountSnap = await databaseInstanceRef.child(
          "sentEmojis/$domainNode").child(targetUseruid)
          .child("recievedEmojis")
          .child(emoji.name)
          .get();
      await databaseInstanceRef.child("sentEmojis/$domainNode").child(
          targetUseruid).child("emojiGivenBy").child(userUid).child(autoId)
          .update(
          {"date": formattedDate, "emoji": emoji.name, "toPlaka": toPlaka});
      final emojiCount = emojiCountSnap.value as int?;
      log("sentemojis/$domainNode/$targetUseruid/emojigivenby/$userUid");
      int newCount = 1;
      if (emojiCount != null) {
        newCount += emojiCount;
      }
      log("${emoji.name} $newCount d2d");
      await databaseInstanceRef.child("sentEmojis/$domainNode").child(
          targetUseruid).child("recievedEmojis").update({emoji.name: newCount});
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<bool> setUserInitialTokenCount() async {
    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);
    final Tokens tokensData = Tokens(lastFreeGivenDate: formattedDate, tokenCount: AppConstants.initialTokenCount.toString());
    try {
      databaseInstanceRef.child("kullanicilar").child(userUid)
          .child("tokens")
          .update(tokensData.toJson());
      return true;
    }catch(e){
      log("err setusrf def token $e");
      return false;
    }
  }

  Future<bool> giveFreeTokensDaily(int exToken) async {
    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);
    final Tokens tokensData = Tokens(lastFreeGivenDate: formattedDate, tokenCount: (AppConstants.dailyFreeTokenCount + exToken).toString());
    try {
      databaseInstanceRef.child("kullanicilar").child(userUid)
          .child("tokens")
          .update(tokensData.toJson());
      return true;
    }catch(e){
      log("err setusrf def token $e");
      return false;
    }
  }
///bakilacak
  Future<bool> addTokensToUser({required Tokens tokenInfo, int? tokens}) async {
    tokens ??= AppConstants.watchAdsEarnToken;
    final Tokens tokensData = Tokens(lastFreeGivenDate: tokenInfo.lastFreeGivenDate, tokenCount: (tokens + int.parse(tokenInfo.tokenCount)).toString());
    try {
      databaseInstanceRef.child("kullanicilar").child(userUid)
          .child("tokens")
          .update(tokensData.toJson());
      return true;
    }catch(e){
      log("err setusrf def token $e");
      return false;
    }
  }

  Future<bool> plateSearchedDecreaseToken(Tokens tokenInfo) async {
    if(int.parse(tokenInfo.tokenCount) <= 0) return false;
    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);
    final Tokens tokensData = Tokens(tokenCount: (int.parse(tokenInfo.tokenCount) - AppConstants.substractTokenPlateSearched).toString(), lastFreeGivenDate: tokenInfo.lastFreeGivenDate);
    try {
      databaseInstanceRef.child("kullanicilar").child(userUid)
          .child("tokens")
          .update(tokensData.toJson());
      return true;
    } catch(e){
      log("err setusrf def token $e");
      return false;
    }
  }

  Future<bool> setUsersOnlineActivityBool({required bool isActive}) async {
    final active = isActive ? "1" : "0";
    try {
      await databaseInstanceRef.child("kullanicilar").child(userUid).update({"activity": active});
      return true;
    } catch (e) {
      log("setUsersOnlineActivity errior $e");
      return false;
    }
  }

  Future<bool> setUsersOnlineActivityUserUid({required String targetUserUid}) async {
    try {
      await databaseInstanceRef.child("kullanicilar").child(userUid).update({"activity": targetUserUid});
      return true;
    } catch (e) {
      log("setUsersOnlineActivity errior $e");
      return false;
    }
  }

  Future<bool> setUsersLastSeenNow() async {
    try {
      final date = regularDMYHMformatter.format(DateTime.now());
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).update({"lastSeen": date});
      return true;
    } catch (e) {
      log("setUsersLastSeenNow errior $e");
      return false;
    }
  }

  Future<bool> setUsersAccountDisabled(bool disabled) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).update({"disabled": disabled});
      return true;
    } catch (e) {
      log("setUsersAccountDisabled errior $e");
      return false;
    }
  }


  Future<bool> sendNewWallPostToUser({
    required String plateNumber,
    String? targetUseruid,
    required String content,
    required bool isUser,
  }) async {
    log("23gf112g23g_23g2g");

    try {
      final userCheck = isUser ? "1" : "0";
      final node = targetUseruid ?? plateNumber;
      final date = regularDMYHMformatter.format(DateTime.now());
      final ipAddress = await InformatorFunctions().getUsersIpAddress();
      final data = UserWallPosts(
          content: content,
          isUser: userCheck,
          plaka: plateNumber,
          postDate: date,
          senderIpAddress: ipAddress,
          senderUuid: userUid
      );
      final autoChild = await databaseInstanceRef.child("plaka-duvar-yazilar/waiting")
          .child(node).push();
      await autoChild.update(data.toJson());
      log("23gf112g23g_23g2g");

      return true;
    } catch (e) {
      log("sendNewWallPost errior $e");
      return false;
    }
  }


  ///</WRITES>


  ///<DELETES>

  Future<bool> deleteUsersOwnedPlate(String plateNum) async {
    try {
      await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("ownedSignPlates").child(plateNum).remove();
      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  ///</DELETES>

  ///<READS>

  Future<bool> getUsersAccountIsDisabled() async {
    log("fire_base_action_get_called getUsersAccountIsDisabled");
    try {
      final snap = await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("disabled").get();
      if (snap.exists) {
        final json = snap.value as bool?;
        if(json == null) return false;
        return json;
      } else{
        return false;
      }
    } catch (e) {
      log("setUsersAccountDisabled errior $e");
      return false;
    }
  }


  Future<String?> getUsersLastSeen() async {
    log("fire_base_action_get_called getUsersLastSeen");

    try {
      final snap = await databaseInstanceRef.child("kullanicilar")
          .child(userUid).child("lastSeen").get();
      if (snap.exists) {
        final json = snap.value as String?;
        if(json == null) return null;
        return json;
      } else{
        return null;
      }
    } catch (e) {
      log("getUsersLastSeen error $e");
      return null;
    }
  }

  Future<bool> getUserIsBlocked({ required String targetUserUid}) async {
    log("fire_base_action_get_called getUserIsBlocked");
    try {
      final snap = await databaseInstanceRef.child("users-blockings")
          .child(userUid).child(targetUserUid).get();
      if (snap.exists) {
        final json = snap.value as bool?;
        log("23fd23f $json");
        if(json == null) return false;
        return json;
      }
      return false;
    } catch (e) {
      log("block errior $e");
      return false;
    }
  }

  Future<Tokens?> getUsersTokenInfo() async {
    log("fire_base_action_get_called getUsersTokenInfo");
    try {
      final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).child("tokens").get();
      if (snapshot.exists) {
        final json = snapshot.value as Map<dynamic, dynamic>;
        final tokenInfo = Tokens.fromJson(json);
        return tokenInfo;
      }else{
        log("tokenyok");
        return null;
      }
    }catch (e){
      log("err token 12dwf $e");
      return null;
    }
  }

  Future<UserPersonalDataModel?> getUsersAllData() async {
    log("fire_base_action_get_called getUsersAllData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).get();
    if (snapshot.exists) {
      // final data = json.decode(snapshot.value.toString()).cast<UserPersonalDataModel>();
      final json = snapshot.value as Map<dynamic, dynamic>;
      final asd = utf8.encode(" $json");
      final message = UserPersonalDataModel.fromJson(json);
      return message;
    } else {
      return null;
    }
  }

  Future<UserEditContactInfo?>? getUsersContactData() async {
    log("fire_base_action_get_called getUsersContactData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).child("phoneSettings").get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      final message = UserEditContactInfo.fromJson(json);
      return message;
    }else{
      return null;
    }
  }

  Future<UserPreferencesInfo?>? getUsersPreferencesData() async {
    log("fire_base_action_get_called getUsersPreferencesData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).child("preferences").get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      utf8.encode("$json");
      final message = UserPreferencesInfo.fromJson(json);
      return message;
    }else{
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?>? getUsersOwnedLicensePlatesData() async {
    log("fire_base_action_get_called getUsersOwnedLicensePlatesData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).child("ownedSignPlates").get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> list = [];
      json.forEach((key, value) {
        list.add({"plate" : key, "description": "Onaylandı.", "statusCode": 1});
      });
      return list;
    }else{
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?>? getUsersWaitingLicensePlatesData() async {
    log("fire_base_action_get_called getUsersWaitingLicensePlatesData");
    final snapshot = await databaseInstanceRef.child("plaka-submissions/waiting").child(userUid).get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> list = [];
      json.forEach((key, value) {
        list.add({"plate" : value["plaka"], "description": "Onay bekliyor.", "statusCode": 0});
      });

      return list;
    }else{
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?>? getUsersDeclinedLicensePlatesData() async {
    log("fire_base_action_get_called getUsersDeclinedLicensePlatesData");
    final snapshot = await databaseInstanceRef.child("plaka-submissions/declined").child(userUid).get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> list = [];
      json.forEach((key, value) {
        list.add({"plate" : value["plaka"], "description": "Reddedildi.", "statusCode": 2, "modDescription": value["redSebebi"]});
      });
      return list;
    }else{
      return null;
    }
  }

  Future<List<UserInAppNotifications>?>? getUsersInAppNotificationsData({required bool isPremium}) async {
    log("fire_base_action_get_called getUsersInAppNotificationsData");

    //      final String? autoId = databaseInstanceRef.child("inapp-notifications/").child(userUid).push().key;
    final snapshot = await databaseInstanceRef.child("inapp-notifications").child(userUid).limitToLast(15).once();
    if (snapshot.snapshot.exists) {
      List<UserInAppNotifications> notis = [];
      final json = snapshot.snapshot.value as Map<dynamic, dynamic>;
      /* json.forEach((key, value) {
        notis.add(UserInAppNotifications.fromJson(value));
      });*/

      for(var mapEntry in json.entries){
        final String? senderUuid = mapEntry.value["senderid"] as String?;
        log("message 123312 $senderUuid");
        if (isPremium && senderUuid != null){
          final String? senderPpUrl = await CommonServices().getUsersSingleDataNode(userUid: senderUuid, data: SingleDataOps.profilePicture,  );
          if(senderPpUrl != null) mapEntry.value["senderPpUrl"] = senderPpUrl;
          //final String? senderNickname = await CommonServices().getUsersSingleDataNode(userUid: senderUuid, data: SingleDataOps.nickname, );
         // if(senderNickname != null) mapEntry.value["senderNickname"] = senderNickname;
          //final String? senderBiography = await CommonServices().getUsersSingleDataNode(userUid: senderUuid, data: SingleDataOps.biography, );
          //if(senderBiography != null) mapEntry.value["senderBiography"] = senderNickname;
          final bool? senderShowNumber = await CommonServices().getUsersSingleDataNode(userUid: senderUuid, data: SingleDataOps.showNumber, );
          if (senderShowNumber ?? false) {
            final String? senderPhoneNumber = await CommonServices().getUsersSingleDataNode(userUid: senderUuid, data: SingleDataOps.phoneNumber, );
            if(senderPhoneNumber != null) mapEntry.value["senderPhoneNumber"] = senderPhoneNumber;
          }
        }else{

        }
        final notiData = UserInAppNotifications.fromJson(mapEntry.value);
        notis.add(notiData);
      }
      //notis.sort((a,b)=> a.date.compareTo(b.date));
      ///
      notis.sort((a,b) {
        var dateTime1 = DateFormat('dd-MM-yyyy HH:mm').parse(a.date);
        var dateTime2 = DateFormat('dd-MM-yyyy HH:mm').parse(b.date);
        return dateTime2.compareTo(dateTime1);
      });

      log("message 4324ff3 ${notis.length}");
      return notis;
    }else{
      return null;
    }
  }
//plaka-duvar-yazilar/accepted/ownedByUserPlates
  Future<List<UserWallPosts>?>? getUsersWallPostsData({int? maxNumber, required bool isPremium}) async {
    log("fire_base_action_get_called getUsersWallPostsData");

    //      final String? autoId = databaseInstanceRef.child("inapp-notifications/").child(userUid).push().key;
    log("2300000f23f $userUid");
    final snapshot = await databaseInstanceRef.child("plaka-duvar-yazilar/accepted/ownedByUserPlates").child(userUid).limitToLast(10).get();
    if (snapshot.exists) {
      List<UserWallPosts> posts = [];
      //final json = snapshot.value as Map<dynamic, dynamic>;
      var snap = snapshot.value as Map<dynamic, dynamic>;
      if (snapshot.value == null) return null;
      bool infinite = false;
      int i = 0;
      if(maxNumber == null) infinite = true;
      for(var mapEntry in snap.entries) {
        i++;
        if (i < (maxNumber ?? 0) || infinite) {
          final String? senderUuid = mapEntry.value["senderUuid"] as String?;
          if (senderUuid == null) return null;

          print("2312213");

          final String? ppurl = await CommonServices().getUsersSingleDataNode(data: SingleDataOps.profilePicture, userUid: senderUuid, );
          final String? nickname = await CommonServices().getUsersSingleDataNode(data: SingleDataOps.nickname, userUid: senderUuid, );
          if(ppurl != null) mapEntry.value["ppUrl"] = ppurl;
          if(nickname != null) mapEntry.value["nickname"] = nickname;

          if(mapEntry.key != null) mapEntry.value["commentId"] = mapEntry.key;
        }
        final wallpostData = UserWallPosts.fromJson(mapEntry.value);
        posts.add(wallpostData);
      }
      posts.sort((a,b) {
        var dateTime1 = DateFormat('dd-MM-yyyy HH:mm').parse(a.postDate);
        var dateTime2 = DateFormat('dd-MM-yyyy HH:mm').parse(b.postDate);
        return dateTime2.compareTo(dateTime1);
      });
      return posts;
    }else{
      log("23f23f_fg43g");
      return null;
    }
  }



  Future<EmojisCollection?> getUsersEmojisCountData({
    required bool isUser,
  }) async {
    log("fire_base_action_get_called getUsersEmojisCountData");
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    final snapshot = await databaseInstanceRef.child("sentEmojis").child(domainNode).child(userUid).child("recievedEmojis").get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      final message = EmojisCollection.fromJson(json);
      print("object claled 1249814921");
      return message;
    }else{
      return null;
    }
  }

  Future<int?> checkUsersGivenDrivingPoints({
    required bool isUser,
    required String targetUserUid,
  }) async {
    log("fire_base_action_get_called checkUsersGivenDrivingPoints");
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    final snapshot = await databaseInstanceRef.child("driverPoints/$domainNode/$targetUserUid/givenBy/$userUid/").limitToLast(1).get();
    log("d23df2df");
    int? returnInt;
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>?;
      if(json == null) return null;
      final now = DateTime.now();
      json.forEach((key, value) {
        final data = value as Map<dynamic, dynamic>?;
        if(data == null) return;
        final date = data["date"];
        if (now.difference(regularDMYHMformatter.parse(date)).inDays == 0) {
          returnInt = data["point"] as int;
        }
        log("now.difference(regularDMYHMformatter.parse(date)).inDays ${now.difference(regularDMYHMformatter.parse(date)).inDays}");
      });
      log("d13d1d $json");
      return returnInt;
    }else{
      log("d13d1d notfound");
      return returnInt;
    }
  }

  Future<UserDrivingPointsInfo?> getUsersDrivingPointsCountData({required bool isUser,
  }) async {
    log("fire_base_action_get_called getUsersDrivingPointsCountData");
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    final snapshot = await databaseInstanceRef.child("driverPoints").child(domainNode).child(userUid).get();
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>;
      log("json 123412 $json");
      final message = UserDrivingPointsInfo.fromJson(json);
      log("message 123412 $message");
      return message;
    }else{
      return null;
    }
  }

  Future<EmojiKinds?> checkAndSupplyGivenEmojis({
    required bool isUser,
    required String targetUserUid,
  }) async {
    log("fire_base_action_get_called checkAndSupplyGivenEmojis");
    String domainNode = "ownedByUserPlates";
    if (!isUser) domainNode = "unownedPlates";
    final snapshot = await databaseInstanceRef.child("sentEmojis/$domainNode").child(targetUserUid).child("emojiGivenBy").child(userUid).limitToLast(1).get();
    final json = snapshot.value as Map<dynamic, dynamic>?;
    if(json == null) return null;
    final dataList = json.values.toList();
    var dateTime1 = regularDMYHMformatter.parse(dataList[0]["date"]);
    final int diffInDays = dateTime1.difference(DateTime.now()).inDays;
    if(diffInDays == 0){
      return (dataList[0]["emoji"].toString()).kindByEmojiString;
    }

  }


///</READS>

}

enum SingleDataOps{
  profilePicture,
  fullname,
  nickname,
  showNumber,
  phoneNumber,
  biography,
}

extension SingleDataOpsGetExtension on SingleDataOps{
  String get nodeName {
    switch (this) {
      case SingleDataOps.profilePicture:
        return 'profilePicture';
      case SingleDataOps.fullname:
        return 'fullname';
      case SingleDataOps.nickname:
        return 'nickname';
      case SingleDataOps.showNumber:
        return 'phoneSettings/showNumber';
      case SingleDataOps.phoneNumber:
        return 'phoneSettings/phoneNumber';
      case SingleDataOps.biography:
        return 'biography';
      default:
        return "";
    }
  }
}