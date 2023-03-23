import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/auth/register_user_page.dart';
import 'package:sscarapp/pages/view_single_photo.dart';
import 'package:sscarapp/services/firebase/database/report_us/report_services.dart';
import 'package:sscarapp/services/firebase/firestore/notifications_services.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:sscarapp/widgets/emoji_reactions_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/push_notification_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/database/user/user_database_service.dart';
import '../../widgets/driving_points_action_widget.dart';
import '../../widgets/modal_bottom_sheet_chat_widget.dart';
import '../../widgets/show_text_field_alert_dialog.dart';
import '../../widgets/target_user_app_bar_widget.dart';
import '../../widgets/wall_posts_container_widget.dart';
import '../DM/dm_chat_page.dart';


class TargetUserProfilePage extends StatefulWidget {
  final String targetUserUid;
  final String plateNumber;

  const TargetUserProfilePage({Key? key, required this.targetUserUid, required this.plateNumber}) : super(key: key);

  @override
  State<TargetUserProfilePage> createState() => _TargetUserProfilePageState();
}

class _TargetUserProfilePageState extends State<TargetUserProfilePage> {
  bool _isSignedIn = false;
  String? _userUid;
  bool _isLoading = true;
  bool _isPremium = true;
  String? _userFcmToken;
  bool? _userDrivingGivenScoreHigher;
  double userDrivingAverageScore = 0.0;
  int? userDrivingGivenScore;
  int userWallPostCount = 0;
  bool _isTargetUserBlocked = false;
  bool _isSelfBlockedByTarget = false;

  AppConstants appCons = AppConstants();

  UserPersonalDataModel? userInfo;
  List<String>? userOwnedPlates;
  List<UserWallPosts>? userWallPosts;
  EmojisCollection? userEmojisCollection = EmojisCollection();
  UserDrivingPointsInfo? userDrivingPoints = UserDrivingPointsInfo();

  EmojiKinds? givenEmoji;

  @override
  void initState() {
    // TODO: implement initState
    getUserLoggedInStatus();
    super.initState();
  }

  getUserLoggedInStatus() async {
    await UserDefaultsFunctions.getUserLoggedInStatus().then((value) async {
      setState(() {
        _isSignedIn = value;
      });
      if (value) {
        _userUid = await UserDefaultsFunctions.getUserUidFromSF();
        getGivenEmojiInfo(_userUid!);
        _userFcmToken = await NotificationsServices().getPushTokenOfUser(userUid: widget.targetUserUid!);
        userDrivingGivenScore = await UserDatabaseService(userUid: _userUid!).checkUsersGivenDrivingPoints(
            isUser: true, targetUserUid: widget.targetUserUid
        );

        _isTargetUserBlocked = await UserDatabaseService(userUid: _userUid!)
            .getUserIsBlocked( targetUserUid: widget.targetUserUid);
        _isSelfBlockedByTarget = await UserDatabaseService(userUid: widget.targetUserUid)
            .getUserIsBlocked( targetUserUid: _userUid!);
        if (_isSelfBlockedByTarget) {

          setState(() {});
          showSnackbar(context: context, color: Colors.redAccent, message: "Bu kişi sizi engellemiş", isInfinite: true);
          return;
        }else{
          getUsersInfo();
        }
      }else{
        getUsersInfo();
      }
    });
  }

  getUsersInfo() async {
    if(_isSelfBlockedByTarget) {
      showSnackbar(context: context, color: Colors.redAccent, message: "Bu kişi sizi engellemiş", isInfinite: true);
      return;
    }

    userInfo = await UserDatabaseService(userUid: widget.targetUserUid).getUsersAllData()
        .catchError((onErr) {
      log(onErr);
    });

    if(userInfo?.ownedSignPlates != null) {
      userOwnedPlates = ManuplatorFunctions().ownedLicensePlatesConverter(userInfo!.ownedSignPlates!);
    }
    _isPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
    userWallPosts = await UserDatabaseService(userUid: widget.targetUserUid).getUsersWallPostsData(maxNumber: 10, isPremium: _isPremium)
        ?.catchError((onErr) {
      log(onErr);
    });

    userEmojisCollection = await UserDatabaseService(userUid: widget.targetUserUid).getUsersEmojisCountData(isUser: true)?.catchError((onErr) {
      log(" 3121231 $onErr");
    });

    userDrivingPoints = await UserDatabaseService(userUid: widget.targetUserUid).getUsersDrivingPointsCountData(isUser: true)?.catchError((onErr) {
      log(" 3121231 $onErr");
    });
    if (userDrivingPoints != null) userDrivingAverageScore = userDrivingPoints!.totalDrivingPoints! / userDrivingPoints!.pointSendersCount!;

    setState(() {
      _isLoading = false;
    });
  }



  void getGivenEmojiInfo(String userUid) async {
    givenEmoji = await UserDatabaseService(userUid: userUid).checkAndSupplyGivenEmojis(targetUserUid: widget.targetUserUid, isUser: true);

  }

  void emojiButtonTapped(EmojiKinds emoji) async {
    if(_isSignedIn){
      final isDone = await UserDatabaseService(userUid: _userUid!).userSendNewEmoji(emoji: emoji, targetUseruid: widget.targetUserUid, toPlaka: widget.plateNumber, isUser: true);
      userEmojisCollection = await UserDatabaseService(userUid: widget.targetUserUid).getUsersEmojisCountData(isUser: true)?.catchError((onErr) {
        log(" 3121231 $onErr");
      });
      if(isDone){
        await HapticFeedback.heavyImpact();
        setState(() {
          givenEmoji = emoji;
          log(" get 22314123");
          UserDatabaseService(userUid: _userUid!).addNewNotification(
              content: EmojiKindsExtension(emoji).name,
              toPlaka: widget.plateNumber,
              targetUserUid: widget.targetUserUid,
              kind: NotificationKinds.emoji).then((value){
            log("f2_2f3_2000f3 $value");

          });
          PushNotificationsFunctions().sendPushNotification(
            fcmToken: _userFcmToken ?? "",
            body: "Bir kullanıcı sana '${EmojiKindsExtension(emoji).emojiItself}' yolladı!",
            title: "Yeni bir emoji",
          ).then((value) => print("2131d1 $value"));
        });
      }

    }else{
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return const RegisterUserPage();
      }));
      return;
    }
  }

  void sendDrivingPointsTapped(int points) async {
    if(_userUid != null){
      final res = await UserDatabaseService(userUid: _userUid!).sendDrivingPoints(
          targetUserUid: widget.targetUserUid,
          plateNumber: widget.plateNumber,
          isUser: true,
          points: points,
          drivingPointsInfo: userDrivingPoints
      );
      if(res){
        await HapticFeedback.heavyImpact();
        setState(() {
          log("f23ff2 $userDrivingGivenScore");
          userDrivingGivenScore = points;
          if (userDrivingPoints != null) userDrivingAverageScore = (userDrivingPoints!.totalDrivingPoints! + points) / (userDrivingPoints!.pointSendersCount! + 1);
          if (points > (userDrivingAverageScore ?? 0)) {
            _userDrivingGivenScoreHigher = true;
            log("f2aa3ff2 $userDrivingGivenScore");
          }else{
            _userDrivingGivenScoreHigher = false;
            log("f23bbff2 $userDrivingGivenScore");
          }
          print(" get 22314123");
          UserDatabaseService(userUid: _userUid!).addNewNotification(
              content: "$points",
              toPlaka: widget.plateNumber,
              targetUserUid: widget.targetUserUid,
              kind: NotificationKinds.driverPoints).then((value){
                log("f2_2f3_2f3 $value");
          });

          PushNotificationsFunctions().sendPushNotification(
            fcmToken: _userFcmToken ?? "",
            body: "Bir kullanıcı sana $points puan yolladı!",
            title: "Yeni bir sürücü puanı",
          ).then((value) => print("2131d1 $value"));
        });
      }else{
        log("d23fff falseee");
      }
    }else{

    }
  }

  Color setGivenEmojiBackgroundColor(EmojiKinds forEmoji){
    if(givenEmoji == null) return Colors.grey.shade300;
    if(givenEmoji == forEmoji){
      return Colors.grey.shade300;
    }else{
      return Colors.grey.shade300.withOpacity(0.3);
    }
  }

  Color setGivenEmojiLabelColor(EmojiKinds forEmoji){
    if(givenEmoji == null) return Colors.black;
    if(givenEmoji == forEmoji){
      return Colors.black;
    }else{
      return Colors.black.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {

    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double heightOfScreen = MediaQuery.of(context).size.height;

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    showModalBottomSheetTapped(){
      showTextFieldAlertDialog(
        context: context,
        title: "Kullanıcı şikayet et",
        description: "Yaşadığınız sorunu bize birkaç cümle ile anlatır mısınız?",
        buttonTitle: "Gönder",
        userUid: _userUid ?? "unregistered",
        entryId: widget.targetUserUid,
        type: ModeratorReportCases.user,
      );
    }


    void openSettingsIconButton() async {
      await showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return ModalBottomSheetChatWidget(
            isUser: true,
            isUserBlockedByMe: _isTargetUserBlocked,
            blockUserFunc: () async {
              if(_isTargetUserBlocked){
                await UserDatabaseService(userUid: _userUid!).userUnblocksUser(targetUserUid: widget.targetUserUid).then((value) {
                  if (value) {
                    _isTargetUserBlocked = !value;
                  }
                });
              } else{
                await UserDatabaseService(userUid: _userUid!).userBlocksUser(targetUserUid: widget.targetUserUid).then((value) {
                  if (value) {
                    _isTargetUserBlocked = value;
                  }
                });
              }
            },
            reportUserFunc: () async {
              showModalBottomSheetTapped();
            },
            isSignedIn: _isSignedIn,
          );
        },
      );
    }


    return Scaffold(
      appBar: TargetUserAppBarWidget(
        title: userInfo?.nickname ?? "",
        leftIcon: Icons.arrow_back_ios_new,
        rightButtonActionFunction: _isSelfBlockedByTarget ? null : openSettingsIconButton,
      ),
      body: _isLoading
          ?
      circularProgressIndicator()
          :
      GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Container(
                    // height: availableHeight-85,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 1.0,
                                        offset: Offset(0.0, 0.0)
                                    )
                                  ],
                                ),
                                // height: 300,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      // mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  // backgroundColor: Colors.red
                                                ),
                                                children: [
                                                  const WidgetSpan(
                                                    alignment: PlaceholderAlignment.top,
                                                    child: Icon(Icons.star, size: 12),
                                                  ),
                                                  TextSpan(
                                                    text: " ${(userDrivingAverageScore ?? ((userDrivingGivenScore?.toDouble() ?? "-.-"))).toString().substring(0,3)}",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500,
                                                      color: _userDrivingGivenScoreHigher == null ? appCons.secondaryColor : (_userDrivingGivenScoreHigher! ? Colors.green : Colors.redAccent),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Text(
                                              "Sürücü Puanı",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(userInfo?.profilePicture == null) return;
                                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                                              return ViewSinglePhoto(imageProvider: NetworkImage(userInfo!.profilePicture!),);
                                            }));
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: AppConstants().primaryColor,
                                            radius: 63.0,
                                            child: CircleAvatar(
                                              backgroundImage:  userInfo?.profilePicture != null ? NetworkImage(userInfo!.profilePicture!) : null,
                                              radius: 60,
                                              backgroundColor: Colors.grey,
                                              child: userInfo?.profilePicture == null ? Icon(Icons.person, size: 100, color: Colors.white,) : null,
                                            ),
                                          ),
                                        ),                                  Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                    alignment: PlaceholderAlignment.top,
                                                    child: Icon(Icons.book_sharp, size: 12),
                                                  ),
                                                  TextSpan(
                                                    text: " ${userWallPosts?.length ?? "0"} ",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500,
                                                      color: appCons.secondaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Text(
                                              "Duvar Yazıları",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),//puan - pp - duvar yazilari
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: appCons.secondaryColor.withOpacity(0.7),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: appCons.secondaryColor,
                                                    borderRadius: BorderRadius.circular(25)
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    if (!_isSignedIn) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                        return const RegisterUserPage();
                                                      }));
                                                      return;
                                                    }
                                                    var snack = showSnackbar(context: context, color: Colors.yellow, message: "Kişi numarasını gizlemiş");
                                                    userInfo?.phoneSettings == null ? snack :
                                                    userInfo!.phoneSettings!.showNumber ?
                                                    launchUrl(Uri.parse("tel://${userInfo?.phoneSettings?.phoneNumber}"), mode: LaunchMode.externalApplication) : snack;
                                                  },
                                                  icon: const Icon(Icons.call),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Text("Ara"),
                                          ],
                                        ),
                                        Text(
                                          userInfo?.fullname ?? "İsimsiz Kullanıcı",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: appCons.secondaryColor.withOpacity(0.7),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: appCons.secondaryColor,
                                                    borderRadius: BorderRadius.circular(25)
                                                ),
                                                child: IconButton(
                                                  onPressed: (){
                                                    if (!_isSignedIn) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                        return const RegisterUserPage();
                                                      }));
                                                      return;
                                                    }
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                      return DMChatPage(
                                                        userUid: _userUid!,
                                                        displayName: userInfo?.fullname ?? "",
                                                        targetUserUid: widget.targetUserUid,
                                                        isUser: true,
                                                        profilePictureURL: userInfo?.profilePicture,
                                                      );
                                                    }));
                                                  },
                                                  icon: const Icon(Icons.message),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Text("Mesaj"),
                                          ],
                                        ),
                                      ],
                                    ),//isim
                                    const SizedBox(height: 2,),
                                    Container(
                                      height: 40,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: userOwnedPlates == null ? 0 : userOwnedPlates!.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            height: 38,
                                            width: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: AppConstants().primaryColor, width: 2),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  height: userOwnedPlates == null ? 0 : 40,
                                                  width: 25,
                                                  alignment: Alignment.center,
                                                  color: appCons.primaryColor,
                                                  child: const Text(
                                                    "TR",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4,),
                                                Text(
                                                  StringPlateExtensions.makePlateVisualString(userOwnedPlates![index]),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder:  (_, _i) {
                                          return Container(
                                            child: const VerticalDivider(),
                                          );
                                        },
                                      ),
                                    ),//plaka
                                    const SizedBox(height: 10,),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        userInfo?.biography ?? "",
                                        style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ),//bio
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8,),
                              InkWell(
                                onTap: (){
                                  if (!_isSignedIn) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return const RegisterUserPage();
                                    }));
                                    return;
                                  }
                                },//
                                child: IgnorePointer(
                                  ignoring: !_isSignedIn,
                                  child: DrivingPointsActionWidget(
                                    initialRating: userDrivingAverageScore,
                                    givenRating: userDrivingGivenScore,
                                    titleBgColor: appCons.primaryColor,
                                    drivingPointsTapped: sendDrivingPointsTapped,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8,),
                              /*IgnorePointer(
                                ignoring: givenEmoji != null,
                                child: Container(
                                  //height: 50,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 1.0,
                                          offset: Offset(0.0, 0.0)
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          emojiButtonTapped(EmojiKinds.clap);
                                        },
                                        child: Container(
                                          //height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(30),
                                                    color: setGivenEmojiBackgroundColor(EmojiKinds.clap)
                                                ),
                                                child: Text(
                                                  "👏",
                                                  style: TextStyle(
                                                      fontSize: 30,
                                                      color: setGivenEmojiLabelColor(EmojiKinds.clap)
                                                  ),
                                                ),
                                              ),//emoji
                                              Text(
                                                userEmojisCollection?.clap?.toString() ?? "0",
                                                style: TextStyle(
                                                    color: setGivenEmojiLabelColor(EmojiKinds.clap)
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          emojiButtonTapped(EmojiKinds.heart);
                                        },
                                        child: Container(
                                          //height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: setGivenEmojiBackgroundColor(EmojiKinds.heart),
                                                ),
                                                child: Text(
                                                  "❤️",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: setGivenEmojiLabelColor(EmojiKinds.heart),
                                                  ),
                                                ),
                                              ),//emoji
                                              Text(
                                                userEmojisCollection?.heart?.toString() ?? "0",
                                                style: TextStyle(
                                                  color: setGivenEmojiLabelColor(EmojiKinds.heart),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          emojiButtonTapped(EmojiKinds.fire);
                                        },
                                        child: Container(
                                          //height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: setGivenEmojiBackgroundColor(EmojiKinds.fire),
                                                ),
                                                child: Text(
                                                  "🔥️",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: setGivenEmojiLabelColor(EmojiKinds.fire),
                                                  ),
                                                ),
                                              ),//emoji
                                              Text(userEmojisCollection?.fire?.toString() ?? "0",
                                                style: TextStyle(
                                                  color: setGivenEmojiLabelColor(EmojiKinds.fire),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          emojiButtonTapped(EmojiKinds.onehundret);
                                        },
                                        child: Container(
                                          //height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: setGivenEmojiBackgroundColor(EmojiKinds.onehundret),
                                                ),
                                                child: Text(
                                                  "💯",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: setGivenEmojiLabelColor(EmojiKinds.onehundret),
                                                  ),
                                                ),
                                              ),//emoji
                                              Text(userEmojisCollection?.onehundret?.toString() ?? "0",
                                                style: TextStyle(
                                                  color: setGivenEmojiLabelColor(EmojiKinds.onehundret),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const VerticalDivider(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          emojiButtonTapped(EmojiKinds.swearing);
                                        },
                                        child: Container(
                                          //height: 50,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: setGivenEmojiBackgroundColor(EmojiKinds.swearing),
                                                ),
                                                child: Text(
                                                  "🤬",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    color: setGivenEmojiLabelColor(EmojiKinds.swearing),
                                                  ),
                                                ),
                                              ),//emoji
                                              Text(userEmojisCollection?.swearing?.toString() ?? "0",
                                                style: TextStyle(
                                                  color: setGivenEmojiLabelColor(EmojiKinds.swearing),
                                                ),),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                              EmojiReactionsSectionWidget(
                                  userEmojisCollection: userEmojisCollection,
                                  emojiButtonTapped: emojiButtonTapped,
                                  givenEmoji: givenEmoji
                              ),
                              const SizedBox(height: 5,),
                              WallPostsContainerWidget(
                                userUid: _userUid,
                                targetUserUid: widget.targetUserUid,
                                userWallPosts: userWallPosts,
                                plateNumber: widget.plateNumber,
                              ),
                            ],
                          )
                      )
                  )
              )
          )
      ),
    );
  }
}
