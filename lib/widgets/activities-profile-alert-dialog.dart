import 'package:flutter/material.dart';
import 'package:sscarapp/shared/app_constants.dart';

import 'custom_widgets.dart';

activitiesProfileAlertDialog({
  required BuildContext context,
  String? title,
  String? biography,
  String? phoneNumber,
  String? profilePicture,
}) {
  // set up the buttons
  
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    // titlePadding: EdgeInsets.all(100), // dikey uzatti 100
    //contentPadding: EdgeInsets.zero, // dikey uzatti 100
    // insetPadding: EdgeInsets.all(100), // yanlardan baskiladi 100
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0))
    ),
    title: Text(title ?? "İsimsiz Kullanıcı", textAlign: TextAlign.center,),
    content: Text(biography ?? "", textAlign: TextAlign.center,),
    icon: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 20,),
              constraints: const BoxConstraints(maxHeight: 30),

              onPressed: (){
                Navigator.of(context).pop();
              },

            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: AppConstants().secondaryColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.phone, color: Colors.white,),
                iconSize: 18,
              ),
            ),
            NonEmptyCircleAvatar(radius: 50, profilePictureURL: profilePicture,),
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  color: AppConstants().secondaryColor,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.message, color: Colors.white,),
                iconSize: 18,
              ),
            ),

          ],
        ),
      ],
    ),
    actions: [
      //   Divider(),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/*Container(
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
    )*/



/*EmojisCollectionWidget(isSignedIn: _isSignedIn, userEmojisCollection: userEmojisCollection, targetUserUid: widget.targetUserUid, plateNumber: plateNumber)
*/