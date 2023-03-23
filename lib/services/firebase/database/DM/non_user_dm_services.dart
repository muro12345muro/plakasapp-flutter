import 'dart:core';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/pages/DM/dm_chat_page.dart';
import 'package:sscarapp/services/firebase/database/common_services.dart';

import '../../../../models/models.dart';
import '../user/user_database_service.dart';

class NonUserDMServices {
  final String plateNumber;
  final String userUid;

  NonUserDMServices({required this.plateNumber, required this.userUid,});

  var usersDMDateFormatterYMD = DateFormat('yyyy/MM/dd');
  var regularDateFormatterDMYHMS = DateFormat('dd-MM-yyyy HH:mm:ss');
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  final databaseInstanceRef = FirebaseDatabase.instance.ref();
  final usersDMsChildInstances = FirebaseDatabase.instance.ref().child(
      "plates-DMs");

  ///<READS>
  Future<List<UserConversationChatInfo>?>? getDMChatConversation({
    required String convoId,
    required String byDateDay,
  }) async {
    try {
      final snapshot = await databaseInstanceRef.child(
          "users-DMs/$convoId/$byDateDay").get();
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


  Future<List<UserConversationChatInfo>?>? listenToDMChatConversation({
    required String byDateDay,
  }) async {
    try {
      List<UserConversationChatInfo> messagesList = [];
      final f = await usersDMsChildInstances.child(
          "$plateNumber/$userUid/$byDateDay").onValue.listen((DatabaseEvent event) {
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
          print(" dondu 324523 $byDateDay");


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
  }) async {
    try {
      final snapshot = await usersDMsChildInstances.child(
          "$plateNumber/$userUid/dates").get();
      if (snapshot.exists) {
        final json = snapshot.value as List<dynamic>;
        print(" eda 43214 ${json}");
        return json;
      } else{
        print("doner dhaa 324923");
      }
    } catch (e) {
      print("object err 12414 $e");
    }
  }

  ///</READS>

  ///<WRITES>
  Future<bool> sendUserDMChatMesage({
    required String content,
    List<dynamic>? currentDates,
    required String targetUserUid,
    required DirectMessageKinds messageKind,
    required String convoId}) async{
    final now = DateTime.now();
    final childDate = usersDMDateFormatterYMD.format(now);
    final date = regularDateFormatterDMYHMS.format(now);
    final message = UserConversationChatInfo(isUser: false, content: content, date: date, isActive: true, targetUseruid: targetUserUid, type: DirectMessageKindsExtension(messageKind).nameByKind, useruid: userUid);
    try{
      final autoId = usersDMsChildInstances.child("$plateNumber/$userUid").child(childDate).push().key;
      if(autoId == null) return false;
      print("e12dd31 $convoId $childDate $autoId");
      //return false;
      await usersDMsChildInstances.child(convoId).child(childDate).child(autoId).set(message.toJson());
      return true;
    } catch (e){
      print("object error send mnessage $e");
      return false;
    }
  }

  Future<bool> addTodayToMessagesDateList({required String convoId, List<dynamic>? currentDates, }) async {
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
      await usersDMsChildInstances.child(convoId).child("dates").set(newList);
      return true;
    } catch (e){
      print("object error send mnessage $e");
      return false;
    }
  }
///</WRITES>

}