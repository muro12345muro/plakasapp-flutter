import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/DM/dm_chat_page.dart';
import 'package:sscarapp/pages/licensePlates/add_new_license_plate_page.dart';
import 'package:sscarapp/pages/view_single_photo.dart';
import 'package:sscarapp/services/firebase/database/license_plates/license_plates_services.dart';
import 'package:sscarapp/services/mysql/custom_api_requests.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:sscarapp/widgets/pages_default_app_bar.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/database/user/user_database_service.dart';
import '../../widgets/driving_points_action_widget.dart';
import '../../widgets/emoji_reactions_section.dart';
import '../../widgets/modal_bottom_sheet_edit_profile.dart';
import '../../widgets/wall_posts_container_widget.dart';
import '../auth/register_user_page.dart';


class TargetNonuserPlateProfilePage extends StatefulWidget {
  final String plateNumber;

  const TargetNonuserPlateProfilePage({Key? key, required this.plateNumber}) : super(key: key);

  @override
  State<TargetNonuserPlateProfilePage> createState() => _TargetNonuserPlateProfilePageState();
}

class _TargetNonuserPlateProfilePageState extends State<TargetNonuserPlateProfilePage> {
  bool _isSignedIn = false;
  String? _userUid;
  String? _plateImageByApi;
  bool _isLoading = true;
  bool _isPremium = true;
  bool? _userDrivingGivenScoreHigher;
  String? _cityByCityCode;
  int _wallPostsInitCardIndex = 0;
  double? userDrivingAverageScore;
  int? userDrivingGivenScore;
  int userWallPostCount = 0;

  AppConstants appCons = AppConstants();

  List<String>? userOwnedPlates;
  List<UserWallPosts>? userWallPosts;
  EmojisCollection? userEmojisCollection = EmojisCollection();
  UserDrivingPointsInfo? userDrivingPoints = UserDrivingPointsInfo();

  List<PlateImageUserUpload>? _plateImageUserUploadList;

  EmojiKinds? givenEmoji;

  @override
  void initState() {
    // TODO: implement initState
    getUsersInfo();
    super.initState();
    fillCityByCityCode();
    getUserLoggedInStatus();
    getPlatesImageByAPI();
    _getPlatesGalleryImages();

  }

  _getPlatesGalleryImages() async {
    _plateImageUserUploadList = await LicensePlatesServices(safePlateNumber: widget.plateNumber)
        .getLicensePlateImageUploadeds();
    log("@3f23f23_32f2f23f ${_plateImageUserUploadList?[0].imagePath}");
    if (_plateImageUserUploadList != null) {
      setState(() { });
    }
  }


  getPlatesImageByAPI() async {
    final visualPlate = StringPlateExtensions.makePlateVisualString(widget.plateNumber);
    log("23f23f2f_f23 $_plateImageByApi");
    _plateImageByApi = await CustomAPIRequests().getPlateImageAPI(plateNumber: visualPlate);
    if(!mounted) return;
    setState(() {
      log("23f23f2f_f23 $_plateImageByApi");
    });
  }

  getUserLoggedInStatus() async {
    await UserDefaultsFunctions.getUserLoggedInStatus().then((value) async {
      setState(() {
        _isSignedIn = value;
      });
      if (value) {
        _userUid = await UserDefaultsFunctions.getUserUidFromSF();
        getGivenEmojiInfo(_userUid!);
      }
    });
  }

  getUsersInfo() async {
    _isPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
    userWallPosts = await UserDatabaseService(userUid: widget.plateNumber).getUsersWallPostsData(maxNumber: 10, isPremium: _isPremium)
        ?.catchError((onErr) {
      log(onErr);
    });

    userEmojisCollection = await UserDatabaseService(userUid: widget.plateNumber).getUsersEmojisCountData(isUser: false)?.catchError((onErr) {
      log(" 3121231 $onErr");
    });

    userDrivingPoints = await UserDatabaseService(userUid: widget.plateNumber).getUsersDrivingPointsCountData(isUser: false)?.catchError((onErr) {
      log(" 3121231 $onErr");
    });

    if (_userUid != null) {
      userDrivingGivenScore = await UserDatabaseService(userUid: _userUid!).checkUsersGivenDrivingPoints(
          isUser: false, targetUserUid: widget.plateNumber
      );
      print("f23f2f $userDrivingGivenScore");
    }

    if (userDrivingPoints != null) userDrivingAverageScore = userDrivingPoints!.totalDrivingPoints! / userDrivingPoints!.pointSendersCount!;

    setState(() {
      _isLoading = false;
      log("3d3d $userWallPosts");
    });
  }

  void getGivenEmojiInfo(String userUid) async {
    givenEmoji = await UserDatabaseService(userUid: userUid).checkAndSupplyGivenEmojis(targetUserUid: widget.plateNumber, isUser: false);
  }



  void getGivenDrivingPointsInfo(String userUid) async {
  }

  void emojiButtonTapped(EmojiKinds emoji) async {
    if(_isSignedIn){
      final isDone = await UserDatabaseService(userUid: _userUid!).userSendNewEmoji(emoji: emoji, targetUseruid: widget.plateNumber, toPlaka: widget.plateNumber, isUser: false);
      userEmojisCollection = await UserDatabaseService(userUid: widget.plateNumber).getUsersEmojisCountData(isUser: false)?.catchError((onErr) {
        log(" 3121231 $onErr");
      });
      if(isDone){
        await HapticFeedback.heavyImpact();
        setState(() {
          givenEmoji = emoji;
        });
      }

    }else{
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return const RegisterUserPage();
      }));
      return;
    }
  }

  Color setGivenEmojiBackgroundColor(EmojiKinds forEmoji){
    if(givenEmoji == null) return Colors.grey.shade300;
    if(givenEmoji == forEmoji){
      return Colors.grey.shade300;
    } else{
      return Colors.grey.shade300.withOpacity(0.3);
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

  void sendDrivingPointsTapped(int points) async {
    if(_userUid != null){
      final res = await UserDatabaseService(userUid: _userUid!).sendDrivingPoints(
          targetUserUid: widget.plateNumber,
          plateNumber: widget.plateNumber,
          isUser: false,
          points: points,
          drivingPointsInfo: userDrivingPoints
      );
      if(res){
        await HapticFeedback.heavyImpact();
        userDrivingGivenScore = points;
        if (userDrivingPoints != null) userDrivingAverageScore = (userDrivingPoints!.totalDrivingPoints! + points) / (userDrivingPoints!.pointSendersCount! + 1);
        if (points > (userDrivingAverageScore ?? 0)) {
          _userDrivingGivenScoreHigher = true;
        }else{
          _userDrivingGivenScoreHigher = false;
        }
        if (!mounted) return;
        setState(() {
        });
      }else{
        log("d23fff falseee");
      }
    }else{

    }
  }

  void fillCityByCityCode(){
    _cityByCityCode = cityByPlateCodeDic[widget.plateNumber.substring(0,2)];
  }

  @override
  Widget build(BuildContext context) {

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

    return Scaffold(
      appBar: PagesDefaultAppBar(title: _cityByCityCode ?? "", leftIcon: Icons.arrow_back_ios_new,),
      body: _isLoading
          ?
      circularProgressIndicator()
          :
      GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
              child: SingleChildScrollView(
                  child: Container(
                    //height: availableHeight-85,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Divider(thickness: 2, color: AppConstants().primaryColor,)),
                                  const SizedBox(width: 5,),
                                  InkWell(
                                    onTap: (){
                                      if (!_isSignedIn) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                                          return const RegisterUserPage();
                                        }));
                                        return;
                                      } else{
                                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                                          return AddNewLicensePlatePage(userUid: _userUid!, plateNumber: StringPlateExtensions.makePlateVisualString(widget.plateNumber),);
                                        }));
                                        return;
                                      }
                                    },
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppConstants().primaryColor,
                                          border: Border.all(color: Colors.yellow, width: 2),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.add_circle_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            Text(
                                              " Bu plaka bana ait!",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  Expanded(child: Divider(thickness: 2, color: AppConstants().primaryColor,)),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.all(12),
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
                                                    text: " ${(userDrivingAverageScore ?? ((userDrivingGivenScore?.toDouble() ?? "-.-"))).toString().substring(0,3)}",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w500,
                                                      color: _userDrivingGivenScoreHigher == null ? appCons.secondaryColor : (_userDrivingGivenScoreHigher! ? Colors.green : Colors.redAccent),
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
                                            /* if(userInfo?.profilePicture == null) return;
                                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                                              return ViewSinglePhoto(imageProvider: NetworkImage(userInfo!.profilePicture!),);
                                            }));*/
                                          },
                                          child: GestureDetector(
                                            onTap: (){
                                              if(_plateImageByApi == null) return;
                                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                return ViewSinglePhoto(imageProvider: NetworkImage(_plateImageByApi!),);
                                              }));
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: AppConstants().primaryColor,
                                              radius: 63.0,
                                              child: CircleAvatar(
                                                backgroundImage: _plateImageByApi == null ? null : NetworkImage(_plateImageByApi!),
                                                radius: 60,
                                                backgroundColor: Colors.grey,
                                                child: _plateImageByApi == null ? const Icon(Icons.person, size: 100, color: Colors.white,) : null,
                                              ),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: appCons.secondaryColor.withOpacity(0.7),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: appCons.secondaryColor,
                                                    borderRadius: BorderRadius.circular(25)
                                                ),
                                                child: IconButton(
                                                  onPressed: (){
                                                    if (!_isSignedIn) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                        return const RegisterUserPage();
                                                      }));
                                                      return;
                                                    }else{
                                                      showSnackbar(context: context, color: Colors.orangeAccent, message: "Kişi numarası ekli değil");
                                                    }
                                                  },
                                                  icon: const Icon(Icons.call),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Text("Ara")
                                          ],
                                        ),
                                        const Text(
                                          "Anonim Plaka",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: appCons.secondaryColor.withOpacity(0.7),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: appCons.secondaryColor,
                                                    borderRadius: BorderRadius.circular(25)
                                                ),
                                                child: IconButton(
                                                  onPressed: (){
                                                    if (!_isSignedIn) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                        return const RegisterUserPage();
                                                      }));
                                                      return;
                                                    }
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                      return DMChatPage(
                                                        userUid: _userUid!,
                                                        displayName: StringPlateExtensions.makePlateVisualString(widget.plateNumber),
                                                        targetUserUid: widget.plateNumber,
                                                        isUser: false,
                                                      );
                                                    }));
                                                  },
                                                  icon: const Icon(Icons.message),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const Text("Mesaj"),
                                          ],
                                        ),
                                      ],
                                    ),//isim
                                    const SizedBox(height: 10,),
                                    Container(
                                      height: 40,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 1,
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
                                                  StringPlateExtensions.makePlateVisualString(widget.plateNumber),
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
                                    ),//plaka
                                    SizedBox(height: 10,),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: const Text(
                                        "",
                                        style: TextStyle(
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
                              InkWell(
                                onTap: (){
                                  if (!_isSignedIn) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return const RegisterUserPage();
                                    }));
                                    return;
                                  }
                                },
                                child: IgnorePointer(
                                  ignoring: !_isSignedIn,
                                  child: DrivingPointsActionWidget(
                                    initialRating: userDrivingAverageScore,
                                    givenRating: userDrivingGivenScore,
                                    titleBgColor: appCons.primaryColor,
                                    drivingPointsTapped: sendDrivingPointsTapped,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              /* IgnorePointer(
                                ignoring: givenEmoji != null,
                                child: Container(
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
                                ),
                              ),*/
                              EmojiReactionsSectionWidget(
                                  userEmojisCollection: userEmojisCollection,
                                  emojiButtonTapped: emojiButtonTapped,
                                  givenEmoji: givenEmoji
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                padding: const EdgeInsets.only(left: 8,  top: 12, bottom: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 1.0,
                                        offset: Offset(0.0, 0.0)
                                    )//
                                  ],
                                ),
                                // height: 300,
                                child: (_plateImageUserUploadList?.isEmpty ?? true) ?
                                GestureDetector(
                                  onTap: (){
                                    showModalBottomSheet<void>(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ModalBottomSheetEditProfileWidget(openCameraFunction: openCameraFunction, fromAlbumFunction: pickFromGallery ,);
                                      },
                                    );
                                  },
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                          child: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                            size: 38,
                                          )
                                      ),
                                      Text(
                                        "Fotoğraf ekle",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17,
                                        ),
                                      )
                                    ],
                                  ),
                                ) :
                                Container(
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [//
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount:( _plateImageUserUploadList?.isEmpty ?? true ) ? 0 : (_plateImageUserUploadList?.length)! , // total number of items in the grid
                                          scrollDirection: Axis.horizontal,
                                          padding: EdgeInsets.only(left: 3, bottom: 5),
                                          itemBuilder: (BuildContext context, int index) {
                                            // return the widget for the corresponding index
                                            final plateImage = _plateImageUserUploadList?[index];
                                            if (plateImage == null) return const SizedBox();
                                            return GestureDetector(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                  return ViewSinglePhoto(imageProvider: NetworkImage(plateImage.imagePath),);
                                                }));
                                              },
                                              child: Container(
                                                width: 120,
                                                margin: const EdgeInsets.only(left: 3, right: 3),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(plateImage.imagePath),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors.grey,
                                                ),
                                                child: null,
                                              ),
                                            );

                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppConstants().primaryColor,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 2, horizontal: 20)),
                                          ),
                                          onPressed: (){
                                            showModalBottomSheet<void>(
                                              backgroundColor: Colors.transparent,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ModalBottomSheetEditProfileWidget(openCameraFunction: openCameraFunction, fromAlbumFunction: pickFromGallery ,);
                                              },
                                            );
                                          },
                                          child: Text(
                                            "Fotoğraf ekle",
                                            style: TextStyle(
                                              color: AppConstants().secondaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              WallPostsContainerWidget(
                                userUid: _userUid,
                                targetUserUid: widget.plateNumber,
                                plateNumber: widget.plateNumber,
                                userWallPosts: userWallPosts,
                              ),
                            ],
                          )
                      )
                  )
              )
          )
      ),
    );
  }


  Future pickProfilePhoto(ImageSource source) async {
    try{
      log("object");
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        log("message return dondu image 253");
        return;
      }
      final imageTemparory = File(image.path);
      final imageFile = await cropImage(imageFile: imageTemparory);
      if (imageFile == null) return;
      if(!mounted) return;
      showSnackbar(context: context, color: AppConstants().primaryColor, message: "Fotoğraf yükleniyor", showProgressCircle: true);
      final fistPhoto = await CustomAPIRequests().uploadUsersPlateImage(
        file: imageFile,
        plate: widget.plateNumber,
      );

      log("@#f23f2_f23f232f_23f23 $fistPhoto");
      if (fistPhoto != null) {
        await LicensePlatesServices(safePlateNumber: widget.plateNumber).newLicensePlateImageUploaded(
          pathOfImage: fistPhoto,
        );
        final fristPhotoObj = PlateImageUserUpload(
          imagePath: fistPhoto,
          user: _userUid ?? "",
          date: DateTime.now().millisecondsSinceEpoch,
          isUser: _isSignedIn,
        );
        _plateImageUserUploadList = (_plateImageUserUploadList?.isEmpty ?? true) ? [] : _plateImageUserUploadList;
        _plateImageUserUploadList?.add(fristPhotoObj);

      }
      setState(() {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    } on PlatformException catch (e) {
      log("$e 511");
    } catch (e) {
      log("$e 532");

    }
  }

  void openCameraFunction(){
    pickProfilePhoto(ImageSource.camera);
  }

  void pickFromGallery(){
    pickProfilePhoto(ImageSource.gallery);
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) {
      return null;
    }
    return File(croppedImage.path);
  }

}
