import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/pages/DM/dm_chat_page.dart';
import 'package:sscarapp/shared/app_constants.dart';
import '../../helper/manuplator_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/database/DM/user_dm_services.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/pages_default_app_bar.dart';

class DMListPage extends StatefulWidget {
  const DMListPage({Key? key}) : super(key: key);

  @override
  State<DMListPage> createState() => _DMListPageState();
}

class _DMListPageState extends State<DMListPage> {
  String? _userUid;
  bool _isLoading = true;
  List<UserDMListInfo>? userDMList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUseruid();
  }

  getUseruid() async {
    await UserDefaultsFunctions.getUserUidFromSF().then((value) async {
      print(" buraya kadar geldik21431");
      if (value != null) {
        _userUid = value;
        await getUserDMList(_userUid!);
      }else{
        Navigator.pop(context);//
      }
    });
    if (!mounted) return;
    setState(() { });
  }

  getUserDMList(String userUid) async {
    userDMList = await UserDMServices(userUid: userUid).getUsersDMListData(userUid);
    _isLoading = false;
    if (!mounted) return;
    setState(() {
    });
  }

  Future<void> _pullRefresh() async {
    HapticFeedback.lightImpact();
    final List<UserDMListInfo>? freshUserDMList  = await UserDMServices(userUid: _userUid!).getUsersDMListData(_userUid!);
    userDMList = freshUserDMList;
    if (!mounted) return;
    setState(() {
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

    @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: const PagesDefaultAppBar(title: "Mesajlar", leftIcon: Icons.arrow_back_ios_new,),
      body: _isLoading ? circularProgressIndicator() :
        GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                height: availableHeight,
                color: Colors.white,
                child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  color: AppConstants().primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: userDMList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        minLeadingWidth: 20,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(targetUserDisplayName(index)),
                            Text(
                              userDMList?[index].type == "photo" ? "🖼 Fotoğraf" : makeDMShorter(userDMList?[index].content ?? ""),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                  fontSize: 13
                              ),
                            )
                          ],
                        ),
                        leading: NonEmptyCircleAvatar(radius: 25, profilePictureURL: userDMList?[index].senderPpUrl,),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            userDMList?[index].isRead ?? false ? const SizedBox.shrink() : badge.Badge(
                              badgeColor: AppConstants().primaryColor,
                              badgeContent: const Text(""),
                            )  ,
                            Text(
                              StringDateExtensions.displayTimeAgoFromDMYHM(userDMList?[index].date ?? ""),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            print("23fd23df ${userDMList![index].sendingToUid}");
                            return DMChatPage(
                              displayName: targetUserDisplayName(index),
                              profilePictureURL: userDMList?[index].senderPpUrl,
                              userUid: _userUid!,
                              targetUserUid: userDMList![index].sendingToUid!,
                              isUser: userDMList![index].isUser ?? true,
                            );
                          }));

                          //activitiesProfileAlertDialog(context: context, title: notis?[index].senderNickname, biography: notis?[index].senderBiography, phoneNumber: notis?[index].senderPhoneNumber, profilePicture: notis?[index].senderPpUrl);
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
                )
            ),
          ),
        ),
      ),
    );
  }

  String targetUserDisplayName(int index){
    if (userDMList?[index].targetUseruid.length == 28 || userDMList?[index].isUser == true) {

      return userDMList?[index].senderNickname ?? "İsimsiz Kullanıcı";
    }
    return StringPlateExtensions.makePlateVisualString(userDMList![index].targetUseruid);
  }

  String makeDMShorter(String bigSentence){
    print(bigSentence.length );
    if(bigSentence.length > 50){
      return '${bigSentence.substring(0,40)}...';
    }
    else{
      return bigSentence;
    }
  }
}

