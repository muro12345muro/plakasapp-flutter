import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../models/models.dart';

class EmojiReactionsSectionWidget extends StatefulWidget {
  final EmojisCollection? userEmojisCollection;
  final Function(EmojiKinds) emojiButtonTapped;
  final EmojiKinds? givenEmoji;

   const EmojiReactionsSectionWidget({
    Key? key,
    this.userEmojisCollection,
    required this.emojiButtonTapped,
    required this.givenEmoji,
  }) : super(key: key);

  @override
  State<EmojiReactionsSectionWidget> createState() => _EmojiReactionsSectionWidgetState();
}

class _EmojiReactionsSectionWidgetState extends State<EmojiReactionsSectionWidget> {

  double emojisFontSize = 30;
  double emojisContainerSize = 50;

  Color setGivenEmojiBackgroundColor(EmojiKinds forEmoji){
    if(widget.givenEmoji == null) return Colors.grey.shade300;
    if(widget.givenEmoji == forEmoji){
      return Colors.grey.shade300;
    }else{
      return Colors.grey.shade300.withOpacity(0.3);
    }
  }

  Color setGivenEmojiLabelColor(EmojiKinds forEmoji){
    if(widget.givenEmoji == null) return Colors.black;
    if(widget.givenEmoji == forEmoji){
      return Colors.black;
    }else{
      return Colors.black.withOpacity(0.3);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fontSizeDecision();
  }

  void fontSizeDecision(){
    if (Platform.isAndroid) {
      // Android-specific code
    } else if (Platform.isIOS) {
      // iOS-specific code
      setState(() {
        emojisFontSize = 35;
        emojisContainerSize = 55;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.givenEmoji != null,
      child: Container(
        //height: emojisContainerSize,
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
                widget.emojiButtonTapped(EmojiKinds.clap);
              },
              child: Container(
                //height: emojisContainerSize,
                child: Column(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: setGivenEmojiBackgroundColor(EmojiKinds.clap)
                      ),
                      child: Text(
                        "👏",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: emojisFontSize,
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
                widget.emojiButtonTapped(EmojiKinds.heart);
              },
              child: Container(
                //height: emojisContainerSize,
                child: Column(
                  children: [
                    Container(
                      height: emojisContainerSize,
                      width: emojisContainerSize,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: setGivenEmojiBackgroundColor(EmojiKinds.heart),
                      ),
                      child: Text(
                        "❤️",
                        style: TextStyle(
                          fontSize: emojisFontSize,
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
                widget.emojiButtonTapped(EmojiKinds.fire);
              },
              child: Container(
                //height: emojisContainerSize,
                child: Column(
                  children: [
                    Container(
                      height: emojisContainerSize,
                      width: emojisContainerSize,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: setGivenEmojiBackgroundColor(EmojiKinds.fire),
                      ),
                      child: Text(
                        "🔥️",
                        style: TextStyle(
                          fontSize: emojisFontSize,
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
                widget.emojiButtonTapped(EmojiKinds.onehundret);
              },
              child: Container(
                //height: emojisContainerSize,
                child: Column(
                  children: [
                    Container(
                      height: emojisContainerSize,
                      width: emojisContainerSize,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: setGivenEmojiBackgroundColor(EmojiKinds.onehundret),
                      ),
                      child: Text(
                        "💯",
                        style: TextStyle(
                          fontSize: emojisFontSize,
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
                widget.emojiButtonTapped(EmojiKinds.swearing);
              },
              child: Container(
                //height: emojisContainerSize,
                child: Column(
                  children: [
                    Container(
                      height: emojisContainerSize,
                      width: emojisContainerSize,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: setGivenEmojiBackgroundColor(EmojiKinds.swearing),
                      ),
                      child: Text(
                        "🤬",
                        style: TextStyle(
                          fontSize: emojisFontSize,
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
      ),
    );
  }
}
