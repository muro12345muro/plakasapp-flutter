import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';

import '../../helper/push_notification_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../tabBarPages/self_user_profile_page.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/new_wall_post_section.dart';
import '../../widgets/pages_default_app_bar.dart';
import '../../widgets/show_text_field_alert_dialog.dart';

class ViewAllWallPostsPage extends StatefulWidget {
  final String targetUserUid;
  final String? userUid;
  final String? plateNumber;

  const ViewAllWallPostsPage({
    Key? key,
    required this.targetUserUid,
    this.userUid,
    this.plateNumber,
  }) : super(key: key);

  @override
  State<ViewAllWallPostsPage> createState() => _ViewAllWallPostsPageState();
}

class _ViewAllWallPostsPageState extends State<ViewAllWallPostsPage> {
  bool _isLoading = true;
  bool _isPremium = false;
  List<UserWallPosts>? userWallPosts;
  String? _nickname;
  String? _profilePictureUrl;
  AppConstants appCons = AppConstants();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWallPosts();

    if (widget.plateNumber != null) {
      getUserDefNickname();
      getUserDefProfilePicture();
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

  Future getWallPosts() async {
    _isPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
    userWallPosts = await UserDatabaseService(userUid: widget.targetUserUid).getUsersWallPostsData(isPremium: _isPremium)
        ?.catchError((onErr) {
      log("23d_F23f_23f $onErr");
    });
    setState(() {
      _isLoading = false;
    });
    log("23f23f $userWallPosts");
  }


  Future<void> _pullRefresh() async {
    HapticFeedback.lightImpact();
    final List<UserWallPosts>? freshUserNotisList   = await UserDatabaseService(userUid: widget.targetUserUid).getUsersWallPostsData(isPremium: _isPremium);
    setState(() {
      userWallPosts = freshUserNotisList;
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
    appBar: const PagesDefaultAppBar(title: 'Duvar Yazıları', leftIcon: Icons.arrow_back_ios_new,),
    body:  _isLoading
        ?
    const Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red))
        :
    GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: availableHeight,
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                 // border: Border.all(width: 0.5, color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: const [
                  ],
                ),
                child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  color: AppConstants().primaryColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: userWallPosts != null ? userWallPosts!.length : 0,
                          controller: PageController(viewportFraction: 0.8),
                          itemBuilder: (_, index) {
                            final comment = userWallPosts![index];
                            return Container(
                              height: 200,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    children: [
                                      Container(
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  color: appCons.primaryColor,
                                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                                                ),
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
                                      ),
                                      const SizedBox(width: 8,),
                                      Container(
                                        width: width-80,
                                        padding: EdgeInsets.symmetric(vertical: 10),
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
                                                Text(comment.senderNickname ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                                const SizedBox(width: 6,),
                                                const Icon(Icons.access_time, size: 12,),
                                                const SizedBox(width: 2,),
                                                Text(comment.postDate, style: TextStyle(fontSize: 12),),
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
                                                        userUid: widget.userUid ?? "anonim",
                                                        type: ModeratorReportCases.wallPost,
                                                      );
                                                    },
                                                    icon: const Icon(Icons.report_gmailerrorred, size: 16, color: Colors.redAccent,)
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 5,),
                                            Container(
                                              padding: const EdgeInsets.only(left: 5),
                                              // height: 5,
                                              width: 200,
                                              child: Text(
                                                userWallPosts![index].content,
                                                style: const TextStyle(
                                                    fontSize: 14
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ]
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      widget.plateNumber == null ? const SizedBox() :
                      NewWallPostSectionWidget(
                        userUid: widget.userUid,
                        plateNumber: widget.plateNumber,
                        targetUserUid: widget.targetUserUid,
                      ),
                    ],
                  ),
                )
            ),
          )
      ),
    );
  }


}


