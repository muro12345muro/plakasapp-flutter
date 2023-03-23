import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/helper/request_functions.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/pages/profile/target_user_profile_page.dart';
import 'package:sscarapp/services/firebase/database/license_plates/license_plates_services.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import '../mobile_ads/admob/admob_ads_helper.dart';
import '../pages/introduction_screens/initial_introduction_page.dart';
import '../pages/profile/target_nonuser_plate_profile_page.dart';

class HomePageMain extends StatefulWidget {
  final Future<bool> Function()? plateSearchedDecreaseToken;
  final Future<bool> Function()? watchAdsEarnToken;
  const HomePageMain({Key? key, this.plateSearchedDecreaseToken, this.watchAdsEarnToken,}) : super(key: key);

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  TextEditingController textEditingController = TextEditingController();
  bool _isSignedIn = false;
  bool _isSearchPlateRunning = false;
  String? _userUid;
  //TextInputType _providedKeyboardType = TextInputType.numberWithOptions();
  // FocusNode _plateTextFieldFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfAppAvailable();
    loadStaticBanner();
    getUseruid();
    loadRewardedAd();
    showAppIntroduction();
  }

  late BannerAd staticAd;
  bool isStaticLoaded = false;
  bool isInlineLoaded = false;
  late BannerAd inlineAd;

  RewardedAd? _rewardedAd;

  static const AdRequest adRequest = AdRequest();
  
  void checkIfAppAvailable(){
    if (true) {
      
    }  
  }

  void getUseruid() async {
    _userUid = await UserDefaultsFunctions.getUserUidFromSF();
  }


  void showAppIntroduction() async {
    if (!(await UserDefaultsFunctions.isIntroductionViewed())) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return const InitialIntroductionPage();
        }));
      });
    }
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
            print("Ad onAdShowedFullScreenContent");
          },
          onAdDismissedFullScreenContent: (RewardedAd ad) {
            ad.dispose();
            loadRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
            ad.dispose();
            loadRewardedAd();
          }
      );

      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print("${reward.amount} 123 ${reward.type}");
        widget.watchAdsEarnToken!();
      });
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: AdmobAdsHelper.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              setState(() {
                _rewardedAd = ad;
              });
            },
            onAdFailedToLoad: (LoadAdError error) {
              log("f23f_Gadd $error");
              setState(() {
                _rewardedAd = null;
              });
            })
    );
  }
  void loadStaticBanner(){
    staticAd = BannerAd(
      adUnitId: AdmobAdsHelper.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
          onAdLoaded: (ad) {
            print("d23f32 adloaded");
            setState(() {
              isStaticLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, err){
            print("asdd32 $ad $err");
          }
      ),
      request: adRequest,
    );
    staticAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double heightOfScreen = MediaQuery.of(context).size.height;

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return ProgressHUD(
      child: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    height: availableHeight-100,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        //  mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _rewardedAd == null ? Container(height: 35,) :
                          Container(
                            height: 35,
                            //color:
                            decoration: BoxDecoration(
                              //border: Border.all(color: AppConstants().secondaryColor, width: 3),
                              borderRadius: BorderRadius.circular(8),
                              color: AppConstants().secondaryColor,
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                showRewardedAd();
                              },
                              icon: const Icon(Icons.play_circle_fill, color: Colors.yellow, size: 18,),
                              label: const Text("Reklamla Token Kazan", style: TextStyle(color: Colors.white, fontSize: 12),),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30, top: 40),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppConstants().primaryColor, width: 3),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    color: AppConstants().primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Image.asset(
                                        "assets/porsche-car-icon.png",
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      height: 50,
                                      child: TextFormField(
                                        controller: textEditingController,
                                        //  focusNode: _plateTextFieldFocusNode,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
                                        onChanged: (val) {
                                          log(val);
                                          textEditingController.text = StringPlateExtensions.makePlateVisualString(val);
                                          textEditingController.selection = TextSelection.collapsed(offset: textEditingController.text.length);
                                          /*
                                  if (returnKeyboardType(val) == _providedKeyboardType) {
                                    _providedKeyboardType = returnKeyboardType(val);
                                  }  else{
                                          setState(() {
                                            log("23f2f");
                                            _plateTextFieldFocusNode.unfocus();
                                            _providedKeyboardType = InformatorFunctions().returnKeyboardType(val);
                                            Future.delayed(const Duration(milliseconds: 50)).then((value) {
                                              _plateTextFieldFocusNode.requestFocus();
                                            });
                                          });*/
                                        },
                                        style: const TextStyle(fontSize: 43),
                                        decoration: const InputDecoration.collapsed(hintText: "07 SS 111", fillColor: Colors.white, filled: true),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Container(
                            height: 35,
                            width: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade500,
                            ),
                            child: TextButton(
                                style: const ButtonStyle(
                                  //padding: EdgeInsets.all(0)
                                ),
                                onPressed: () async {
                                  log("#f3");
                                  //FirestoreModeratorServices().deleteAndBackupVideos();
                                  if (_isSearchPlateRunning) return;
                                  setState(() {
                                    _isSearchPlateRunning = true;
                                  });
                                  final safePlate = StringPlateExtensions.makePlateNumberSafe(textEditingController.text);
                                  if(StringPlateExtensions.isRepresentingSignPlate(safePlate)){
                                    final progress = ProgressHUD.of(context);
                                    progress?.showWithText('Plaka sorgulanıyor...');
                                    // await Feedback.forTap(context);
                                    await HapticFeedback.heavyImpact();
                                    if(widget.plateSearchedDecreaseToken != null){
                                      widget.plateSearchedDecreaseToken!().then((value){
                                        if (value) {
                                          LicensePlatesServices(safePlateNumber: safePlate).getPlatesOwnerUserUid().then((value){
                                            LicensePlatesServices(safePlateNumber: safePlate,).newLicensePlateLookupSave(userUid: _userUid);
                                            progress?.dismiss();
                                            if(value == null) {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                return TargetNonuserPlateProfilePage(plateNumber: safePlate, );
                                              }));
                                            }else{
                                              if (value == _userUid) {
                                                showSnackbar(context: context, color: Colors.yellow, message: "Bu plaka zaten size ait");
                                                return;
                                              }
                                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                return TargetUserProfilePage(targetUserUid: value, plateNumber: safePlate, );
                                              }));
                                            }
                                          });
                                        }else{
                                          progress?.dismiss();
                                        }
                                      });
                                    }
                                  }else{
                                    showSnackbar(context: context, color: Colors.redAccent, message: "Bunun bir plaka olduguna emin misin?");
                                  }
                                  setState(() {
                                    _isSearchPlateRunning = false;
                                  });
                                },
                                child: Text(!_isSearchPlateRunning ? "Ara" : "Aranıyor... ", style: const TextStyle(color: Colors.white), )
                            ),
                          ),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              // alignment: Alignment.center,
                              //color: Colors.redAccent,
                              child: isStaticLoaded ? AdWidget(ad: staticAd,) : Container(height: 200,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}

