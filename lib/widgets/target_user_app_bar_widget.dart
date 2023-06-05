import 'dart:developer';

import 'package:flutter/material.dart';

import '../shared/app_constants.dart';

class TargetUserAppBarWidget extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final IconData leftIcon;
  final Function? leftButtonBackFunction;
  final Function? rightButtonActionFunction;

  const TargetUserAppBarWidget({
    Key? key,
    required this.title,
    required this.leftIcon,
    this.leftButtonBackFunction,
    this.rightButtonActionFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    void popTheIndex() async {
      Navigator.pop(context);
    }


    return AppBar(
      centerTitle: true,
      //leadingWidth:  12,
      elevation: 0,
      backgroundColor: AppConstants().secondaryColor,
      title: Container(padding:const EdgeInsets.only(left: 10),child: Center(child: Text(title))),
      leading: IconButton(icon: Icon(leftIcon), onPressed: () {
        leftButtonBackFunction == null ? popTheIndex() : leftButtonBackFunction!();
      },),
      actions:
      [
        IconButton(
            onPressed: (){
              if (rightButtonActionFunction != null) {
                rightButtonActionFunction!();
              }
            },
            icon: const Icon(Icons.more_vert)
        )
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
