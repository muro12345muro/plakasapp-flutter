import 'dart:async';
import 'dart:developer';
import 'dart:math' as algebra;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/pages/premium/get_premium_page.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/activities-profile-alert-dialog.dart';
import '../helper/request_functions.dart';
import '../helper/user_defaults_functions.dart';
import '../models/models.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/login_to_see_page_details.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  bool _isSignedIn = false;
  bool _isPremium = false;
  String? _userUid;
  bool _isLoading = true;
  List<UserInAppNotifications>? notis;


  Timer? timer;

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
        });
        if (value) {
          _userUid =  await UserDefaultsFunctions.getUserUidFromSF();
          if(_userUid == null) return;
          _isPremium = await UserDefaultsFunctions.getUserIsPremiumSF();
          await getUsersInAppNotifications();
        }
      } else{
        setState(() {
          _isSignedIn = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    });
  }


  getUsersInAppNotifications() async {
    int counterr = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      log('23f_G23g_g23 TImer active');
      counterr++;
    });

    if(_userUid == null) return;
    await UserDatabaseService(userUid: _userUid!).getUsersInAppNotificationsData(isPremium: _isPremium)?.then((value) {
      notis = value;
      if (!mounted) return;
      setState(() { });
      timer?.cancel();
      log("23f_G23g_gfinal23 ${counterr}");
    });//
  }

  Future<void> _pullRefresh() async {
    HapticFeedback.lightImpact();
    final List<UserInAppNotifications>? freshUserNotisList  = await UserDatabaseService(userUid: _userUid!).getUsersInAppNotificationsData(isPremium: _isPremium);
    setState(() {
      notis = freshUserNotisList;
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  String randomProfilePicGenerator(String basedOn){
    basedOn = basedOn.substring(basedOn.length - 2, basedOn.length);
    algebra.Random random = algebra.Random();
    int randomNumber = random.nextInt(31);
    if (StringPlateExtensions.isNumeric(basedOn)) {
      final numBasedOn = int.parse(basedOn);
      if (numBasedOn > 20) {
        return "assets/user-default-profile-picture.png";//
      }
    }
    return "assets/random-pictures/random-pp-$basedOn.jpeg";//
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

    return  _isLoading
        ?
    const Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red))
        :
    _isSignedIn
        ?
    notis != null ?
    GestureDetector(
      child: SafeArea(
        child: SingleChildScrollView(
            child: Container(
              height: availableHeight-85,
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: _pullRefresh,
                color: AppConstants().primaryColor,
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: notis == null ? 0 : notis!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      minLeadingWidth: 20,
                      title: Text(userActivitiesTextGenerator(kinds: notificationKindsByName(notis![index].kind), content: notis![index].content)),
                      leading: _isPremium ? NonEmptyCircleAvatar(
                        radius: 25,
                        profilePictureURL: notis?[index].senderPpUrl,) : SizedBox(
                        height: 50,
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Stack(
                            children: [
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5, tileMode: TileMode.decal),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(randomProfilePicGenerator(notis![index].date)),
                                  radius: 25,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(12.5),
                                  child: Icon(Icons.question_mark, color: Colors.white.withOpacity(0.5),)
                              )
                            ],
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            StringDateExtensions.displayTimeAgoFromDMYHM(notis![index].date),
                          ),
                        ],
                      ),
                      onTap: () {
                        _isPremium ?
                        activitiesProfileAlertDialog(context: context, title: notis?[index].senderNickname, biography: notis?[index].senderBiography, phoneNumber: notis?[index].senderPhoneNumber, profilePicture: notis?[index].senderPpUrl)
                            :
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_){
                                  return GetPremiumPage(userUid: _userUid!,);
                                }
                            )
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Row(
                      children: const [
                        SizedBox(width: 20,),
                        Expanded(child: Divider()),
                      ],
                    );
                  },
                ),
              ),
            )
        ),
      ),
    )
        :
    const Center(
        child: Text(
            "Gösterilecek bildirim bulunamadı"
        )
    )
        :
    Container(child: const LoginToSeePageDetails());
  }

  String userActivitiesTextGenerator({
    required String content,
    required NotificationKinds kinds}){
    String notificationTitle = "";
    switch (kinds){
      case NotificationKinds.driverPoints:
        notificationTitle = "Yeni bir sürücü puanı aldın: $content";
        break;
      case NotificationKinds.emoji:
        final emoji = emojiByName(content);
        notificationTitle = "Bir kullanıcı sana '$emoji' ifadesi bıraktı";
        break;
    }
    return notificationTitle;
  }

  NotificationKinds notificationKindsByName(String name){
    switch (name) {
      case 'emoji':
        return NotificationKinds.emoji;
      case 'driverPoints':
        return NotificationKinds.driverPoints;
      case 'wallpost':
        return NotificationKinds.wallpost;
      default:
        return NotificationKinds.emoji;
    }
  }

  String emojiByName(String name){
    switch (name) {
      case 'clap':
        return "👏";
      case 'heart':
        return  "❤️";
      case 'onehundret':
        return "💯";
      case 'fire':
        return "🔥";
      case 'swearing':
        return "🤬";
      default:
        return "";
    }
  }

}
