import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/firebase/database/user/user_database_service.dart';

class EmojisCollectionWidget extends StatefulWidget {
  final bool isSignedIn;
  String? userUid;
  EmojisCollection? userEmojisCollection;
  final String targetUserUid;
  final String plateNumber;
  final bool isUser;

  EmojisCollectionWidget({
    Key? key, 
    required this.isSignedIn, 
    this.userUid, 
    this.userEmojisCollection,
    required this.targetUserUid, 
    required this.plateNumber,
    required this.isUser
  }) : super(key: key);
  
  @override
  State<EmojisCollectionWidget> createState() => _EmojisCollectionWidgetState();
}

class _EmojisCollectionWidgetState extends State<EmojisCollectionWidget> {
  EmojisCollection? newuserEmojisCollection;
  EmojiKinds? givenEmoji;

  void emojiButtonTapped(EmojiKinds emoji) async {
    if(widget.isSignedIn){
      final isDone = await UserDatabaseService(userUid: widget.userUid!).userSendNewEmoji(emoji: emoji, targetUseruid: widget.targetUserUid, toPlaka: widget.plateNumber, isUser: widget.isUser);
      newuserEmojisCollection = await UserDatabaseService(userUid: widget.targetUserUid).getUsersEmojisCountData(isUser: widget.isUser)?.catchError((onErr) {
        print(" 3121231 $onErr");
      });
      if(isDone){
        setState(() {
          givenEmoji = emoji;
          print(" get 22314123");
        });
      }
    }else{

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
  
  Color setGivenEmojiBackgroundColor(EmojiKinds forEmoji){
    if(givenEmoji == null) return Colors.grey.shade300;
    if(givenEmoji == forEmoji){
      return Colors.grey.shade300;
    }else{
      return Colors.grey.shade300.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    padding: EdgeInsets.all(5),
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
                    widget.userEmojisCollection?.clap?.toString() ?? "0",
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
                    widget.userEmojisCollection?.heart?.toString() ?? "0",
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
                  Text(widget.userEmojisCollection?.fire?.toString() ?? "0",
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
                  Text(widget.userEmojisCollection?.onehundret?.toString() ?? "0",
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
                  Text(widget.userEmojisCollection?.swearing?.toString() ?? "0",
                    style: TextStyle(
                      color: setGivenEmojiLabelColor(EmojiKinds.swearing),
                    ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
