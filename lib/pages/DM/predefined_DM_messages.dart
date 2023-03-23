import 'dart:developer';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/DM/user_dm_services.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/DM_chat_page_message_tile_widget.dart';
import 'package:sscarapp/widgets/pages_default_app_bar.dart';
import 'package:sscarapp/widgets/show_text_field_alert_dialog.dart';
import '../../helper/push_notification_functions.dart';
import '../../shared/predefined_DM_messages_list.dart';
import '../premium/get_premium_page.dart';

class PredefinedDMMessages extends StatefulWidget {
  final String userUid;
  final String? userSelfFullname;
  final String targetUserUid;
  final String? userFcmToken;
  final String convoId;
  final bool isUser;
  final bool isPremium;
  //

  final List<dynamic>? isUsersDMChatDatesListNull;

  const PredefinedDMMessages({Key? key,  required this.isUsersDMChatDatesListNull,  required this.userUid,  required this.convoId, required this.isPremium,  required this.isUser, required this.targetUserUid, this.userFcmToken, this.userSelfFullname}) : super(key: key);

  @override
  State<PredefinedDMMessages> createState() => _PredefinedDMMessagesState();
}

class _PredefinedDMMessagesState extends State<PredefinedDMMessages> {
  final List<Menu> _predefinedMessages = [];
  final Map<String, bool> _selectedMessage = {};
  late final bool? isAppendDateRes;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    loadPredefinedMessages();
  }

  Future loadPredefinedMessages() async {
    final phoneNumber = await UserDatabaseService(userUid: widget.userUid).getUsersContactData();
    final predefinedMessagesList = await PredefinedMessagesModellingList(phoneNumber: phoneNumber?.phoneNumber).getPredefinedMessagesList();
    for (var element in predefinedMessagesList) {
      _predefinedMessages.add(Menu.fromJson(element));
    }
    if (!mounted) return;
    setState(() {});
  }

  void suggestPredefinedMessageTapped() async {
    await showTextFieldAlertDialog(
        context: context,
        title: "Mesaj Öner",
        description: "Göndermek istediğin hazır mesajı gir ve yolla, biz de ekleyelim!",
        buttonTitle: "Yolla",
        userUid: widget.userUid,
        iconData: Icons.edit_note_rounded,
        type: ModeratorReportCases.predefinedMessage
    );
  }

  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: PagesDefaultAppBar(title: 'Hazır Mesajlar', leftIcon: Icons.chevron_left_outlined, rightButtonActionFunction: suggestPredefinedMessageTapped, rightButtonText: "Mesaj Öner", rightButtonWidth: 100,),
      body: GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: availableHeight,
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: _predefinedMessages.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _buildList(_predefinedMessages[index]),
                      separatorBuilder: (_,s){
                        return const Divider();
                      },
                    ),
                  ),
                  _selectedMessage.isEmpty ? Container() :
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: DMChatPageMessageTile(
                      messageContext: toBeginningOfSentenceCase(_selectedMessage.keys.elementAt(0)?.replaceAll("-", " ")) ?? "",
                      date: '.',
                      sentByMe: true,
                      type: DirectMessageKinds.text,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 20,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppConstants().primaryColor,
                            ),
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith((states) => Colors.white10),
                              ),
                              onPressed: () {
                                if (widget.isPremium) {
                                  Navigator.pop(context);
                                }else{
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_){
                                            return GetPremiumPage(userUid: widget.userUid,);
                                          }
                                      )
                                  );
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.diamond_outlined,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Text(
                                      " Dilediğin mesajı yaz.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ),
                      Expanded(
                        flex: 13,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppConstants().secondaryColor.withOpacity(1),
                          ),
                          child: TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith((states) => Colors.white10),
                            ),
                            onPressed: () async {
                              if (_selectedMessage.keys.isNotEmpty) {
                                final message = toBeginningOfSentenceCase(_selectedMessage.keys.elementAt(0)!.replaceAll("-", " "))!;
                                final messageRes = await UserDMServices(userUid: widget.userUid)
                                    .sendUserDMChatMesage(content: message,
                                    targetUserUid: widget.targetUserUid,
                                    messageKind: DirectMessageKinds.text,
                                    convoId: widget.convoId,
                                    isUser: widget.isUser
                                );

                                if (messageRes) {
                                  final now = DateTime.now();
                                  final formatter = intl.DateFormat("yyyy/MM/dd");
                                  if (widget.isUsersDMChatDatesListNull == null) {
                                    await UserDMServices(userUid: widget.userUid!)
                                        .addTodayToMessagesDateList(
                                        convoId: widget.convoId, isUser: widget.isUser);
                                  } else if (widget.isUsersDMChatDatesListNull![widget.isUsersDMChatDatesListNull!.length -
                                      1]["date"] as String != formatter.format(now)) {
                                    await UserDMServices(userUid: widget.userUid!)
                                        .addTodayToMessagesDateList(convoId: widget.convoId,
                                        currentDates: widget.isUsersDMChatDatesListNull,
                                        isUser: widget.isUser);
                                  }
                                  await UserDMServices(userUid: widget.userUid).sendMessageAddToConversations(
                                      content: message,
                                      isUser: widget.isUser,
                                      type: DirectMessageKindsExtension(DirectMessageKinds.text).nameByKind,
                                      targetUserUid: widget.targetUserUid,
                                      userUid: widget.userUid);
                                  setState(() {
                                    PushNotificationsFunctions().sendPushNotification(
                                      fcmToken: widget.userFcmToken ?? "",
                                      body: message,
                                      title: widget.userSelfFullname ?? "İsimsiz Kullanıcı",
                                    );
                                  });
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Expanded(
                                  child: Text(
                                    "Böyle gönder ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.send_sharp,
                                  color: Colors.white,
                                  size: 18,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildList(Menu list) {
    if (list.subMenu.isEmpty) {
      return Builder(
          builder: (context) {
            final code = (list.name).replaceAll(" ", "-").toLowerCase();
            return Column(
              children: [
                CheckboxListTile(

                  // shape: CircleBorder(),
                  activeColor: AppConstants().primaryColor,
                  checkColor: Colors.white,
                  title: Text(list.name),//
                  value: (_selectedMessage?[code] ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    if(value == null)return;
                    _selectedMessage.clear();
                    _selectedMessage[code] = value;

                    setState(() {
                    });
                  },
                ),
                const Divider(),
              ],
            );
          }
      );
    }
    return ExpansionTile(
      leading: Icon(list.icon, color: AppConstants().primaryColor,),
      title: Text(
        list.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54 ),
      ),
      children: list.subMenu.map(_buildList).toList(),
    );
  }
}


