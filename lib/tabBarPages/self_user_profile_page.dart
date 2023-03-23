import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/licensePlates/owned_license_plates_page.dart';
import 'package:sscarapp/pages/view_single_photo.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:sscarapp/widgets/login_to_see_page_details.dart';
import 'package:sscarapp/widgets/wall_posts_container_widget.dart';
import '../helper/user_defaults_functions.dart';
import '../services/firebase/database/user/user_database_service.dart';
import '../widgets/emoji_reactions_section.dart';

class SelfUserProfilePage extends StatefulWidget {
  //final VoidCallback? nicknameHasChanged; only to trigger no params passed
  final Function(String)? nicknameHasChanged;
  const SelfUserProfilePage({
    Key? key,
    this.nicknameHasChanged,
  }) : super(key: key);

  @override
  State<SelfUserProfilePage> createState() => _SelfUserProfilePageState();
}

class _SelfUserProfilePageState extends State<SelfUserProfilePage> {
  bool _isSignedIn = false;
  bool _isPremium = false;
  String? _userUid;
  bool _isLoading = true;
  double userDrivingAverageScore = 0.0;
  int userWallPostCount = 0;

  AppConstants appCons = AppConstants();

  UserPersonalDataModel? userInfo;
  List<String>? userOwnedPlates;
  List<UserWallPosts>? userWallPosts;
  EmojisCollection? userEmojisCollection = EmojisCollection();
  UserDrivingPointsInfo? userDrivingPoints = UserDrivingPointsInfo();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await UserDefaultsFunctions.getUserLoggedInStatus().then((value) async {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
          print("object $value 1231d");
        });
        if (value) {
          _userUid =  await UserDefaultsFunctions.getUserUidFromSF();
          print("d1231d $_userUid");
          if(_userUid == null) return;
          userInfo = await UserDatabaseService(userUid: _userUid!).getUsersAllData()
              .catchError((onErr) {
            log(onErr);
          });
          log("dds2fdf2 $userInfo");
          _isPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
          if(userInfo?.ownedSignPlates != null){
            userOwnedPlates = ManuplatorFunctions().ownedLicensePlatesConverter(userInfo!.ownedSignPlates!);
          }
          userWallPosts = await UserDatabaseService(userUid: _userUid!).getUsersWallPostsData(maxNumber: 10, isPremium: _isPremium)
              ?.catchError((onErr) {
            log(onErr);
          });
          log("1sf3fssd $userWallPosts");

          userEmojisCollection = await UserDatabaseService(userUid: _userUid!).getUsersEmojisCountData(isUser: true)?.catchError((onErr) {
            log(" 3121231 $onErr");
          });
          log("1sf3fssd $userEmojisCollection");

          userDrivingPoints = await UserDatabaseService(userUid: _userUid!).getUsersDrivingPointsCountData(isUser: true)?.catchError((onErr) {
            log(" 3121231 $onErr");
          });
          log("1sf3fssd $userDrivingPoints");

          if (userDrivingPoints != null) userDrivingAverageScore = userDrivingPoints!.totalDrivingPoints! / userDrivingPoints!.pointSendersCount!;
          log("message 123404 ${userDrivingPoints?.toJson()}");

        }
      } else{
        setState(() {
          _isSignedIn = false;
          print("d231notsignein");
        });
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

/*
    if (_userUid != null) {
      UserDatabaseService(userUid: _userUid!).getUsersAllData().then((value) {
        userInfo = value;
        if(!mounted) return;
        setState(() { });
      });
    }*/

    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double heightOfScreen = MediaQuery.of(context).size.height;

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return  _isLoading
        ?
    circularProgressIndicator()
        :
    _isSignedIn
        ?
    GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
             // height: availableHeight-85,
              color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                    child: Column(
                     // crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
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
                         // height: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                               // mainAxisSize: MainAxisSize.max,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                             // backgroundColor: Colors.red
                                          ),
                                          children: [
                                            const WidgetSpan(
                                              alignment: PlaceholderAlignment.top,
                                              child: Icon(Icons.star, size: 12),
                                            ),
                                            TextSpan(
                                              text: " ${userDrivingAverageScore.toString().substring(0,3)}",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                color: appCons.secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        "Sürücü Puanı",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      if(userInfo?.profilePicture == null) return;
                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                        return ViewSinglePhoto(imageProvider: NetworkImage(userInfo!.profilePicture!),);
                                      }));
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: AppConstants().primaryColor,
                                      radius: 63.0,
                                      child: CircleAvatar(
                                        backgroundImage:  userInfo?.profilePicture != null ? NetworkImage(userInfo!.profilePicture!) : null,
                                        radius: 60,
                                        backgroundColor: Colors.grey,
                                        child: userInfo?.profilePicture == null ? Icon(Icons.person, size: 100, color: Colors.white,) : null,
                                      ),
                                    ),
                                  ),                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const WidgetSpan(
                                              alignment: PlaceholderAlignment.top,
                                              child: Icon(Icons.book_sharp, size: 12),
                                            ),
                                            TextSpan(
                                              text: " ${userWallPosts?.length ?? "0"} ",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                color: appCons.secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        "Duvar Yazıları",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),//puan - pp - duvar yazilari
                              const SizedBox(height: 10,),
                              Text(
                                  userInfo?.fullname ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),//isim
                              const SizedBox(height: 10,),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                                    return OwnedLicensePlatesPage(userUid: _userUid!);
                                  }));
                                },
                                child: Container(
                                  height: 40,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: userOwnedPlates == null ? 1 : userOwnedPlates!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        height: 38,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: AppConstants().primaryColor, width: 2),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 25,
                                              alignment: Alignment.center,
                                              color: appCons.primaryColor,
                                              child: const Text(
                                                "TR",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4,),
                                            Text(
                                              userOwnedPlates == null ? "Plaka ekle" : StringPlateExtensions.makePlateVisualString(userOwnedPlates![index]),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder:  (_, _i) {
                                      return Container(
                                        child: const VerticalDivider(),
                                      );
                                    },
                                  ),
                                ),
                              ),//plaka
                              SizedBox(height: 10,),
                              Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  userInfo?.biography ?? "",
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),//bio
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        EmojiReactionsSectionWidget(
                            userEmojisCollection: userEmojisCollection,
                            emojiButtonTapped: emojiButtonTapped,
                            givenEmoji: null,
                        ),
                        const SizedBox(height: 5,),
                        WallPostsContainerWidget(
                          targetUserUid: _userUid!,
                          userWallPosts: userWallPosts,
                        ),
                      ],
                    )
                )
            )
          )
        )
    )
        :
    Container(child: LoginToSeePageDetails());
  }
}

void emojiButtonTapped(EmojiKinds emojiKinds){

}

String makeCommentShorter(String bigSentence){
  print(bigSentence.length );
  if(bigSentence.length > 120){
    return '${bigSentence.substring(0,120)}...';
  }
  else{
    return bigSentence;
  }
}