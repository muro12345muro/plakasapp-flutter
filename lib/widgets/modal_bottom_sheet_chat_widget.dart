import 'package:flutter/material.dart';

class ModalBottomSheetChatWidget extends StatelessWidget {
  const ModalBottomSheetChatWidget({
    Key? key,
    required this.isUserBlockedByMe,
    required this.isSignedIn,
    this.predefinedMessagesFunc,
    required this.blockUserFunc,
    required this.reportUserFunc,
    required this.isUser,
    this.showPredefinedMessages
  }) : super(key: key);

  final Function? predefinedMessagesFunc;
  final Function blockUserFunc;
  final Function reportUserFunc;
  final bool isUserBlockedByMe;
  final bool isUser;
  final bool isSignedIn;
  final bool? showPredefinedMessages;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height:  predefinedMessagesFunc == null ? 170 : (isUser) ? 220 :100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 3,
            width: 50,
            //margin disarinin sana uygulayacagi itme
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
           // height: isUser ? (3*60)+(3*1) + 10 : (1*60)+(1*1) + 20 ,
            child: Column(children: [
              predefinedMessagesFunc != null ?
              ListTile(
                  title: const Text("Hazır Mesajlar"),
                  leading: const Icon(Icons.textsms_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    if (predefinedMessagesFunc == null) return;
                    predefinedMessagesFunc!();
                  }
              ) : const SizedBox.shrink(),
              const Divider(thickness: 1,),
              (isUser && isSignedIn) ?
              ListTile(
                  title: Text( !isUserBlockedByMe ? "Engelle" : "Engeli Kaldır"),
                  leading: const Icon(Icons.block),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    blockUserFunc();
                  }
              ) :
              const SizedBox.shrink(),
              isUser ?
              const Divider(thickness: 1,) :
              const SizedBox.shrink(),
              isUser ? ListTile(
                  title: const Text("Şikayet Et", style: TextStyle(color: Colors.redAccent),),
                  leading: const Icon(Icons.report_gmailerrorred_outlined, color: Colors.redAccent,),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    reportUserFunc();
                  }
              ) :
              const SizedBox.shrink(),
              isUser ? const Divider(thickness: 1,) :
              const SizedBox.shrink(),
            ],),
          ),
        ],
      ),
    );
  }
}
