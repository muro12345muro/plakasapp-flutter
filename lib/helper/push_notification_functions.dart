import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../services/firebase/database/moderation/firebase_moderation_services.dart';

class PushNotificationsFunctions{

  Future<bool>  sendPushNotificationAndroid({
    required String fcmToken,
    required String body,
    required String title,
  }) async {
    try{
      final notiBody = jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              "sound":"default",
              //'android_channel_id': 'dbfood'
            },
            'to': fcmToken,
          }//
      );
      final res = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=AAAAnUz8T38:APA91bFcKmyBSWQXN6RhSzGbxmgB1V1TJdsnUTQD7GfzKUJYHqLzYry4Xem-t7Oqg0Mc2EkS6tY4RLnII6RxEZQRMXn2M45M_KRHjyQmc97h-bjzNsLJyQS3wYTxlhrZ03XAEacakphW"
        },
        body: notiBody,
      );
      log("32gg_G23g ${res.body}");
      log("23gf_3gf01f ${notiBody}");
      log(" sentt");
      return true;
    } catch(e) {
      log("_userFcmToken error push noti $e");
      return false;
    }
  }

  Future<bool> sendPushNotification({required String fcmToken, required String body, required String title}) async {
    try{
      final res = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=AAAAnUz8T38:APA91bFcKmyBSWQXN6RhSzGbxmgB1V1TJdsnUTQD7GfzKUJYHqLzYry4Xem-t7Oqg0Mc2EkS6tY4RLnII6RxEZQRMXn2M45M_KRHjyQmc97h-bjzNsLJyQS3wYTxlhrZ03XAEacakphW"
        },
        body: jsonEncode(
            <String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': body,
                'title': title,
              },

              'notification': <String, dynamic>{
                'title': title,
                'body': body,
                'android_channel_id': 'dbfood'
              },
              'to': fcmToken,
            }//
        ),
      );
      return true;
    } catch(e) {
      log("dad213d32 error push noti $e");
      return false;
    }
  }


  Future<void> sendNotificationToAllModerators(
      {required ModeratorReportCases notificationKind,
        String? additionalInfo}) async {
    final moderatorsDic = await FirebaseModerationServices().getModetatorsList();
    if(moderatorsDic == null)return;
    moderatorsDic.forEach((key, value) async {
      print("d32f23f");
      await PushNotificationsFunctions().sendPushNotification(
          fcmToken: value,
          body:"Yeni bir '" + (additionalInfo ?? ModeratorReportCasesExtension(notificationKind).getTitle)  + "' eklendi, bilginize.",
          title:"${ModeratorReportCasesExtension(notificationKind).getEmoji}${ModeratorReportCasesExtension(notificationKind).getEmoji} "
              "${ModeratorReportCasesExtension(notificationKind).getTitle}"
      );
    });
  }
///</WRITES>

}

enum ModeratorReportCases{
  user,
  predefinedMessage,
  wallPost,
  contactUs,
  plateSubmission,
  monthlySubscription,
  annualSubscription,
  token100,
  token300,
  token500,
  accountDeletion,
}

extension ModeratorReportCasesExtension on ModeratorReportCases{
  String get getTitle {
    switch (this) {
      case ModeratorReportCases.contactUs:
        return "İletişim Formu";
        break;
      case ModeratorReportCases.wallPost:
        return "Duvar Yazısı Şikayeti";
        break;
      case ModeratorReportCases.plateSubmission:
        return "Plaka Kaydı";
        break;
      case ModeratorReportCases.monthlySubscription:
        return "Aylık Premium Üyelik (M)";
        break;
      case ModeratorReportCases.annualSubscription:
        return "Aylık Premium Üyelik (Y)";
        break;
      case ModeratorReportCases.token100:
        return "Token Satın Alımı: 100";
        break;
      case ModeratorReportCases.token300:
        return "Token Satın Alımı: 300";
        break;
      case ModeratorReportCases.token500:
        return "Token Satın Alımı: 500";
        break;
      case ModeratorReportCases.user:
        return "Üyelik Şikayeti";
        break;
      case ModeratorReportCases.predefinedMessage:
        return "Hazır Mesaj Önerisi";
        break;
      case ModeratorReportCases.accountDeletion:
        return "Hesap Silinme Aksiyonu";
        break;
        default:
          return "";
    }
  }

  String get getDescription {
    switch (this) {
      case ModeratorReportCases.contactUs:
        return "İletişim Formu";
        break;
      case ModeratorReportCases.wallPost:
        return "Duvar Yazısı";
        break;
      case ModeratorReportCases.plateSubmission:
        return "Plaka Kaydı";
        break;
      case ModeratorReportCases.monthlySubscription:
        return "Aylık Premium Üyelik (Y)";
        break;
      case ModeratorReportCases.annualSubscription:
        return "Aylık Premium Üyelik (M)";
        break;
      case ModeratorReportCases.token100:
        return "Token Satın Alımı: 100";
        break;
      case ModeratorReportCases.token300:
        return "Token Satın Alımı: 300";
        break;
      case ModeratorReportCases.token500:
        return "Token Satın Alımı: 500";
        break;
      case ModeratorReportCases.user:
        return "Üyelik Şikayeti";
        break;
      case ModeratorReportCases.accountDeletion:
        return "Hesap Silinme Aksiyonu";
        break;
      default:
        return "";
    }
  }

  String get getEmoji {
    switch (this) {
      case ModeratorReportCases.contactUs:
        return "📝️⨁";
        break;
      case ModeratorReportCases.wallPost:
        return "⚠️️✍";
        break;
      case ModeratorReportCases.plateSubmission:
        return "🚗⨁";
        break;
      case ModeratorReportCases.annualSubscription:
        return "🤑";
        break;
      case ModeratorReportCases.predefinedMessage:
        return "⨁";
        break;
      case ModeratorReportCases.monthlySubscription:
        return "💲";
        break;
      case ModeratorReportCases.token100:
        return "🪙 ";
        break;
      case ModeratorReportCases.token300:
        return "🪙";
        break;
      case ModeratorReportCases.token500:
        return "🪙";
        break;
      case ModeratorReportCases.user:
        return "⚠️💂🏻‍️";
      case ModeratorReportCases.accountDeletion:
        return "⚠␡";
        break;
      default:
        return "🟡";
    }
  }

}

/*

extension PremiumOptionsExtensions on PremiumOptions {
  String get getString {
    switch (this) {
      case PremiumOptions.monthlyPremiumSubscription:
        return "sscar_premium_acc_monthly";
      case PremiumOptions.annuallyPremiumSubscription:
        return "sscar_premium_acc_anually";
      default:
        return "";
    }
  }
}*/
