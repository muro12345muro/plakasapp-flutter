
import 'package:flutter/material.dart';
import '../shared/app_constants.dart';

class PagesDefaultAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final IconData leftIcon;
  final Function? leftButtonBackFunction;
  final String? rightButtonText;
  final int? rightButtonWidth;
  final IconData? rightButtonIcon;
  final Function? rightButtonActionFunction;
  final bool? dataEditedShouldReload;

  const PagesDefaultAppBar({
    Key? key,
    required this.title,
    required this.leftIcon,
    this.leftButtonBackFunction,
    this.rightButtonText,
    this.rightButtonWidth,
    this.rightButtonIcon,
    this.rightButtonActionFunction,
    this.dataEditedShouldReload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    void popTheIndex() async {
      Navigator.pop(context, dataEditedShouldReload);
    }

    final double titleLeftPush = (rightButtonWidth?.toDouble() ?? 80) - 80;

    return AppBar(
      centerTitle: true,
      //leadingWidth:  12,
      elevation: 0,
      backgroundColor: AppConstants().secondaryColor,
      title: Container(padding:EdgeInsets.only(left: titleLeftPush),child: Center(child: Text(title))),
      leading: IconButton(icon: Icon(leftIcon), onPressed: () {
        leftButtonBackFunction == null ? popTheIndex() : leftButtonBackFunction!();
      },),
      actions: rightButtonText == null ?
      [Container(width: rightButtonWidth?.toDouble() ?? 80)]
          :
      [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12, right: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants().primaryColor)),
          alignment: Alignment.center,
          width: rightButtonWidth?.toDouble() ?? 80,
          child: TextButton( onPressed: () {
            if (rightButtonActionFunction == null) return;
            rightButtonActionFunction!();
          },
            child: Text(
              rightButtonText ?? "",
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
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
