import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/widgets/show_text_field_alert_dialog.dart';
import '../helper/manuplator_functions.dart';
import '../helper/push_notification_functions.dart';
import '../pages/auth/register_user_page.dart';
import '../pages/licensePlates/view_all_wall_posts_page.dart';
import '../shared/app_constants.dart';
import '../tabBarPages/self_user_profile_page.dart';
import 'custom_widgets.dart';
import 'package:dart_ipify/dart_ipify.dart';

import 'new_wall_post_section.dart';

class WallPostsContainerWidget extends StatefulWidget {
  final String? targetUserUid;
  final List<UserWallPosts>? userWallPosts;
  final String? userUid;
  final String? plateNumber;

  const WallPostsContainerWidget({
    Key? key,
    this.targetUserUid,
    this.userUid,
    this.userWallPosts,
    this.plateNumber,
  }) : super(key: key);

  @override
  State<WallPostsContainerWidget> createState() => _WallPostsContainerWidgetState();
}

class _WallPostsContainerWidgetState extends State<WallPostsContainerWidget> {
  int _wallPostsInitCardIndex = 0;
  final AppConstants appCons = AppConstants();

  @override
  Widget build(BuildContext context) {

    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double heightOfScreen = MediaQuery.of(context).size.height;

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    return Column(
      children: [
        Container(
          height: widget.userWallPosts == null ? 100 : 180, // card height\
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.grey),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 1.0,
                  offset: Offset(0.0, 0.0)
              )
            ],
          ),
          child: widget.userWallPosts == null ? Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("-_-", style: TextStyle(fontSize: 25),),
                SizedBox(height: 15,),
                Text("Henüz plakaya duvar yazısı yazılmamış."),
              ],
            ),
          ) : Column(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ViewAllWallPostsPage(
                      userUid: widget.userUid,
                      targetUserUid: widget.targetUserUid!,
                      plateNumber: widget.plateNumber,
                    );
                  }));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text("Tümünü gör", style: TextStyle(
                          fontSize: 15
                      ),),
                      Icon(Icons.arrow_forward_ios, size: 18,)
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: widget.userWallPosts != null ? widget.userWallPosts!.length : 0,
                  controller: PageController(viewportFraction: 0.85),
                  onPageChanged: (int index) => setState(() => _wallPostsInitCardIndex = index),
                  itemBuilder: (_, index) {
                    final comment = widget.userWallPosts![index];
                    return Transform.scale(
                      scale: index == _wallPostsInitCardIndex ? 1 : 0.85,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: appCons.primaryColor,
                                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 8,),
                              Expanded(
                                child: Container(
                                  // width: width-120,
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          NonEmptyCircleAvatar(radius: 18, profilePictureURL: comment.senderPpUrl,),
                                          const SizedBox(width: 5,),
                                          FittedBox(fit: BoxFit.scaleDown, child: Text(comment.senderNickname ?? "", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)),
                                          const SizedBox(width: 6,),
                                          const Icon(Icons.access_time, size: 12,),
                                          const SizedBox(width: 2,),
                                          Expanded(child: Text(StringDateExtensions.displayTimeAgoFromDMYHM(comment.postDate), style: const TextStyle(fontSize: 12),)),
                                          const Spacer(),
                                          IconButton(
                                            // alignment: Alignment.center,
                                              padding: const EdgeInsets.only(left: 20),
                                              alignment: Alignment.topCenter,
                                              constraints: const BoxConstraints(maxHeight: 40),
                                              onPressed: () async {
                                                //report comment button func

                                                // if(inputContent == null) return;
                                                final commentId = comment.commentId;
                                                log("$commentId 235415");
                                                if(commentId == null) return;
                                                String content = "";
                                                setTextFieldValue(String text){
                                                  content = text;
                                                }
                                                await showTextFieldAlertDialog(
                                                  context: context,
                                                  title: "Bize Bildir",
                                                  description: "Kısaca rahatsız olduğun durumu açıklayın, en geç 24 saat içerisinde mailinize dönüş yapılacaktır.",
                                                  buttonTitle: "Yolla",
                                                  entryId: commentId,
                                                  userUid: widget.userUid!,
                                                  type: ModeratorReportCases.wallPost,
                                                );
                                                log("12451 $content");
                                              },
                                              icon: const Icon(Icons.report_gmailerrorred, size: 16, color: Colors.redAccent,)
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        // height: 5,
                                        //width: 200,
                                        child: Text(
                                          makeCommentShorter(widget.userWallPosts![index].content),
                                          style: const TextStyle(
                                              fontSize: 14
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ]
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
        widget.plateNumber == null ? const SizedBox() :
        NewWallPostSectionWidget(
          userUid: widget.userUid,
          plateNumber: widget.plateNumber,
          targetUserUid: widget.targetUserUid,
        ),
      ],
    );
  }


}
