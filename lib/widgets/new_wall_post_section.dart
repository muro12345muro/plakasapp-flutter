import 'dart:developer';

import 'package:flutter/material.dart';

import '../helper/user_defaults_functions.dart';
import '../pages/auth/register_user_page.dart';
import '../services/firebase/database/user/user_database_service.dart';
import '../shared/app_constants.dart';
import 'custom_widgets.dart';

class NewWallPostSectionWidget extends StatefulWidget {
  final String? userUid;
  final String? plateNumber;
  final String? targetUserUid;

  const NewWallPostSectionWidget({
    Key? key,
    this.userUid,
    this.plateNumber,
    this.targetUserUid,
  }) : super(key: key);

  @override
  State<NewWallPostSectionWidget> createState() => _NewWallPostSectionWidgetState();
}

class _NewWallPostSectionWidgetState extends State<NewWallPostSectionWidget> {
  String? _profilePictureUrl;
  final TextEditingController wallPostEditingController = TextEditingController();
  String? _nickname;
  bool _sendButtonActivated = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.plateNumber != null) {
      getUserDefNickname();
      getUserDefProfilePicture();
    }else{
      log("F23f32fnull");
    }

  }


  getUserDefNickname() async {
    _nickname = await UserDefaultsFunctions.getUserUsernameFromSF();
    log("23f2f232_f23 $_nickname");
    setState(() { });
  }

  getUserDefProfilePicture() async {
    _profilePictureUrl = await UserDefaultsFunctions.getUserProfilePictureUrlFromSF();
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.grey),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black54,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0)
          )
        ],
      ),
      child: widget.userUid != null ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NonEmptyCircleAvatar(
            radius: 16,
            profilePictureURL: _profilePictureUrl,
          ),
          const SizedBox(width: 5,),
          Expanded(
            child: ConstrainedBox(
              constraints:  const BoxConstraints(
                minHeight: 35.0,
                //maxHeight: 80.0,
                minWidth: double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: TextFormField(
                  controller: wallPostEditingController,
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: false,
                  textAlign: TextAlign.left,
                  textInputAction: TextInputAction.go,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration.collapsed(
                    hintText: "@$_nickname adıyla plakaya yorum ekle...",
                    fillColor: Colors.white,
                    filled: true,
                    border: InputBorder.none,
                    focusColor: AppConstants().primaryColor,
                  ),
                  onChanged: (val){
                    if (val.isNotEmpty && (val.replaceAll(' ', '') != '') && val.length > 2) {
                      if (!_sendButtonActivated) {
                        setState(() {
                          _sendButtonActivated = true;
                        });
                      }
                    } else{
                      setState(() {
                        _sendButtonActivated = false;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 5,),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: !_sendButtonActivated ?
              AppConstants().primaryColor.withOpacity(0.6) :
              AppConstants().primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _sendButtonActivated ? sendWallPostButtonTapped : null,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                )
            ),
          )
        ],
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Plakalara yorum yapabilmek için",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const RegisterUserPage();
              }));
              return;
            },
            child: Text(
              " kayıt ol",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppConstants().primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendWallPostButtonTapped() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.userUid == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return const RegisterUserPage();
      }));
      return;
    }

    final content = wallPostEditingController.text;
    if (widget.plateNumber == null) {
      return;
    }

    setState(() {
      _sendButtonActivated = false;
    });

    final res = await UserDatabaseService(userUid: widget.userUid!,)
        .sendNewWallPostToUser(
        plateNumber: widget.plateNumber!,
        content: content,
        targetUseruid: widget.targetUserUid,
        isUser: widget.userUid != null
    );

    if (res) {
      if (!mounted) return;
      showSnackbar(
          context: context,
          color: Colors.green,
          message: "Yorumunuz onaydan sonra yayınlanacaktır."
      );
    }else{
      if (!mounted) return;
      showSnackbar(
          context: context,
          color: Colors.red,
          message: "Yorum yollanırken hata meydana geldi."
      );
    }

    setState(() {
      wallPostEditingController.clear();
    });
  }

}
