import 'dart:core';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/pages/DM/dm_chat_page.dart';
import 'package:sscarapp/services/firebase/database/common_services.dart';

import '../../../../models/models.dart';
import '../user/user_database_service.dart';

class UserDMServices {
  final String userUid;

  UserDMServices({required this.userUid});

  var usersDMDateFormatterYMD = DateFormat('yyyy/MM/dd');
  var regularDateFormatterDMYHMS = DateFormat('dd-MM-yyyy HH:mm:ss');
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  final databaseInstanceRef = FirebaseDatabase.instance.ref();
  final usersDMsChildInstances = FirebaseDatabase.instance.ref().child(
      "users-DMs");

  ///<READS>
  Future<List<UserConversationChatInfo>?>? getDMChatConversation({
    required String convoId,
    required String byDateDay,
    required bool isUser,
  }) async {
    log("fire_base_action_get_called getDMChatConversation");
    String domainNode = "users-DMs";
    if (!isUser) domainNode = "plates-DMs";
    try {
      final snapshot = await databaseInstanceRef.child(
          "$domainNode/$convoId/$byDateDay").get();
      if (snapshot.exists) {
        List<UserConversationChatInfo> messagesList = [];
        final json = snapshot.value as Map<dynamic, dynamic>;
        for (var mapEntry in json.entries) {
          final String? messageId = mapEntry.key as String?;
          if (messageId != null) {
            final bool? isActive = mapEntry.value["isActive"] as bool?;
            if (isActive ?? true) {
              final data = UserConversationChatInfo.fromJson(mapEntry.value);
              messagesList.add(data);
            }
          }
        }
        messagesList.sort((a, b) {
          var dateTime1 = DateFormat('dd-MM-yyyy HH:mm:ss').parse(a.date);
          var dateTime2 = DateFormat('dd-MM-yyyy HH:mm:ss').parse(b.date);
          return dateTime2.compareTo(dateTime1);
        });

        return messagesList;
      }else{
        print("bos dondu 124124 $byDateDay");
      }
    } catch (e){
      print("object error cathc 2414 $e");
    }
    return null;
  }

//
  /*Future<List> activateChatListener() async {

    var msg;

    _receivedChatsStream = _messagesRef.onValue.listen((event) {

      event.snapshot.children.forEach((snapshot) {
        dataList.add(snapshot.value);

      });

      //Some other code that returns a future
      return dataList;
    });


  }*/
  //

  Future<List<UserConversationChatInfo>?>? listenToDMChatConversation({
    required String convoId,
    required String byDateDay,
    required bool isUser,
  }) async {
    log("fire_base_action_get_called listenToDMChatConversation");
    String domainNode = "users-DMs";
    if (!isUser) domainNode = "plates-DMs";
    try {
      List<UserConversationChatInfo> messagesList = [];
      final f = await databaseInstanceRef.child(
          "$domainNode/$convoId/$byDateDay").onValue.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final json = event.snapshot.value as Map<dynamic, dynamic>;
          for (var mapEntry in json.entries) {
            final String? messageId = mapEntry.key as String?;
            if (messageId != null) {
              final bool? isActive = mapEntry.value["isActive"] as bool?;
              if (isActive ?? true) {
                final data = UserConversationChatInfo.fromJson(mapEntry.value);
                messagesList.add(data);
              }
            }
          }
          messagesList.sort((a, b) {
            var dateTime1 = DateFormat('dd-MM-yyyy HH:mm:ss').parse(a.date);
            var dateTime2 = DateFormat('dd-MM-yyyy HH:mm:ss').parse(b.date);
            return dateTime2.compareTo(dateTime1);
          });
        }else{
          print("bos dondu 124124 $byDateDay");
        }

      });
      return messagesList;
      print("21321321 $messagesList");
      return messagesList;
    } catch (e){
      print("object error cathc 2414 $e");
    }
    print("21321321 null");
    return null;
  }



  Future<List<dynamic>?> getUsersDMChatDates({
    required String convoId,
    required bool isUser,
  }) async {
    log("fire_base_action_get_called getUsersDMChatDates");
    String domainNode = "users-DMs";
    if (!isUser) domainNode = "plates-DMs";
    try {
      final snapshot = await databaseInstanceRef.child(
          "$domainNode/$convoId/dates").get();

      log("$domainNode/$convoId/dates 12d23f");
      if (snapshot.exists) {
        final json = snapshot.value as List<dynamic>;
        print(" eda 43214 ${json}");
        return json;
      } else{
        print("doner dhaa 3249fdf23");
      }
    } catch (e) {
      print("object err 12414 $e");
    }
  }

  Future<int?> getUsersDMListUnreadConvosCountData() async {
    log("fire_base_action_get_called getUsersDMListUnreadConvosCountData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(
        userUid).child("conversations").get();
    int? unreadCount;
    if (snapshot.exists) {
      final json = snapshot.value as Map<dynamic, dynamic>?;
      if(json != null){
        json.forEach((key, value) {
          final convo = value as Map<dynamic, dynamic>?;
          if(convo != null) {
            final isRead = convo["isRead"] as bool?;
            if(!(isRead ?? true)){
              unreadCount = (unreadCount ?? 0) + 1;
            }
          }
        });
      }
      return unreadCount;
    }else{
      return null;
    }
  }

  Future<List<UserDMListInfo>?> getUsersDMListData(String byDateDay) async {
    log("fire_base_action_get_called getUsersDMListData");
    final snapshot = await databaseInstanceRef.child("kullanicilar").child(userUid).child("conversations").get();
    try{
      if (snapshot.exists) {
        List<UserDMListInfo> posts = [];
        final json = snapshot.value as Map<dynamic, dynamic>;
        log("j9j_uhu $json");
        for (var mapEntry in json.entries) {
          final String? sendingToUid = mapEntry.key as String?;
          if (sendingToUid != null) {
            final bool? isUser = mapEntry.value["isUser"] as bool?;
            if (isUser ?? true) {
              final String? senderPpUrl = await CommonServices()
                  .getUsersSingleDataNode(
                      data: SingleDataOps.profilePicture,
                      userUid: sendingToUid);
              if (senderPpUrl != null) {
                mapEntry.value["senderPpUrl"] = senderPpUrl;
              }
              final String? senderNickname = await CommonServices()
                  .getUsersSingleDataNode(
                      data: SingleDataOps.nickname, userUid: sendingToUid);
              if (senderNickname != null) {
                mapEntry.value["senderNickname"] = senderNickname;
              }
            }
            mapEntry.value["sendingToUid"] = sendingToUid;
            final data = UserDMListInfo.fromJson(mapEntry.value);
            posts.add(data);
          }
        }
        posts.sort((a, b) {
          var dateTime1 = DateFormat('dd-MM-yyyy HH:mm').parse(a.date);
          var dateTime2 = DateFormat('dd-MM-yyyy HH:mm').parse(b.date);
          return dateTime2.compareTo(dateTime1);
        });
        return posts;
      } else {
        return null;
      }
    } catch (e){
      log("q3g3qg_Gq3g $e");
    }
  }
  ///</READS>



  ///<WRITES>
  Future<bool> setUserConversationRead(String targetUserUid) async {
    try{
      await databaseInstanceRef.child("kullanicilar").child(userUid).child("conversations")
          .child(targetUserUid).update({"isRead": true});
      return true;
    } catch (e){
      print("object error send mnessage $e");
      return false;
    }
  }

  Future<bool> sendUserDMChatMesage({
    required String content,
    List<dynamic>? currentDates,
    required String targetUserUid,
    required DirectMessageKinds messageKind,
    required String convoId,
    required bool isUser,
  }) async {
    String domainNode = "users-DMs";
    if (!isUser) domainNode = "plates-DMs";
    final now = DateTime.now();
    final childDate = usersDMDateFormatterYMD.format(now);
    final date = regularDateFormatterDMYHMS.format(now);
    final message = UserConversationChatInfo(isUser: isUser, content: content, date: date, isActive: true, targetUseruid: targetUserUid, type: DirectMessageKindsExtension(messageKind).nameByKind, useruid: userUid);
    try{
      final autoId = databaseInstanceRef.child(domainNode).child(convoId).child(childDate).push().key;
      if(autoId == null) return false;
      //return false;
      await  databaseInstanceRef.child(domainNode).child(convoId).child(childDate).child(autoId).set(message.toJson());
      return true;
    } catch (e){
      print("object error send mnessage $e");
      return false;
    }
  }

  Future<bool> addTodayToMessagesDateList({
    required String convoId,
    List<dynamic>? currentDates,
    required bool isUser,
  }) async {
    String domainNode = "users-DMs";
    if (!isUser) domainNode = "plates-DMs";
    final now = DateTime.now();
    final childDate = usersDMDateFormatterYMD.format(now);
    //  Future<List<dynamic>?>
    /*<>*/
    List<dynamic> newList = List.empty(growable: true);
    if (currentDates != null) {
      //newList.add({"date": childDate});
      newList = List.empty(growable: true) + currentDates;
      newList.add({"date": childDate});
    }else{
      newList = [{"date": childDate}];
      //newList.add({"date": childDate});
    }
    log("$newList");
    // return false;
    try{
      await databaseInstanceRef.child(domainNode).child(convoId).child("dates").set(newList);
      return true;
    } catch (e){
      print("object error send mnessage $e");
      return false;
    }
  }

  Future<bool> sendMessageAddToConversations(
      {required String content,
        required bool isUser,
        required String type,
        required String targetUserUid,
        required String userUid}) async {
    final date = regularDateFormatterDMYHMS.format(DateTime.now());
    final message = UserDMListInfo(
        content: content,
        date: date,
        isActive: true,
        targetUseruid: targetUserUid,
        type: type, useruid: userUid,
        isRead: true,
        isUser: isUser,
        unreadCount: 0
    );
    final messageForTarget = UserDMListInfo(
        content: content,
        date: date,
        isActive: true,
        targetUseruid: targetUserUid,
        type: type, useruid: userUid,
        isRead: false,
        isUser: isUser,
        unreadCount: 0
    );
    try{
      await databaseInstanceRef.child("kullanicilar/$userUid/conversations").child(targetUserUid).set(message.toJson());
      if(!isUser) return true;
      await databaseInstanceRef.child("kullanicilar/$targetUserUid/conversations").child(userUid).set(messageForTarget.toJson());
      return true;
    } catch(e){
      print("asdasd214 $e errpr");
      return false;
    }
  }


///</WRITES>

}