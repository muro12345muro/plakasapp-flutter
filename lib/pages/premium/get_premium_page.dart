import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/models/models.dart';
import 'package:sscarapp/services/firebase/database/premium/premium_user_database_services.dart';
import 'package:sscarapp/services/revenue_cat/revenuecat_purchase_services.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/push_notification_functions.dart';
import '../../widgets/premium_account_get_price_widget.dart';

class GetPremiumPage extends StatefulWidget {
  final String userUid;
  const GetPremiumPage({Key? key, required this.userUid}) : super(key: key);

  @override
  State<GetPremiumPage> createState() => _GetPremiumPageState();
}

class _GetPremiumPageState extends State<GetPremiumPage> {
  final timeNow1 = DateTime.now();
  int estimateTs = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour < 12 ? 12 : 24, 15, 30).millisecondsSinceEpoch; // set needed date
  int estimateTs1 = DateTime.now().millisecondsSinceEpoch; // set needed date

  final PremiumAccountDetails _annualPremiumDetails = PremiumAccountDetails(
      title: "Yıllık",
      oldPrice: "89,99 TL",
      newPrice: "59,99 TL",
      discountPercent: "67%"
  );

  final PremiumAccountDetails _monthlyPremiumDetails = PremiumAccountDetails(
      title: "Aylık",
      oldPrice: "14,99 TL",
      newPrice: "6,99 TL",
      discountPercent: "53%"
  );

  void getPremiumAccountMonthly() async {
    print("23__f23f");
    /* try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Display packages for sale
        print("3414_1 ${offerings.current!.availablePackages}");
      }
    } on PlatformException catch (e) {
      // optional error handling
      print("3_223f2 $e");
    }*/
    /*
    final prids = await Purchases.getProducts(["premiumAcc"]);
    log("12d12312 $prids");
    final ok = await PurchaseTokenServices().buyTokens(tokenOptions: TokenOptions.token100);
    if (ok) {
      PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorNotificationsKinds.inAppPurchasesMonthlyEntry, additionalInfo: "token alindi");
    }
    //final asd = await Purchases.getProducts(["sscar_premium_acc_anually"]);
   // print("23000f23f23 $asd");*/

    RevenueCatPurchaseServices().buyPremiumAccount(premiumAccountOptions: PremiumAccountOptions.premiumAccountAnnual).then((value) async {
      if (value) {
        final done = await PremiumUserDatabaseServices(userUid: widget.userUid).premiumSubscriptionBought(PremiumAccountOptions.premiumAccountAnnual);
        PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.monthlySubscription);
        Navigator.pop(context);
      } else{
        showSnackbar(context: context, color: Colors.redAccent, message: "İşleminizi şu an gerçekleştiremiyoruz");
        //problem occured
      }
    });
    //og("$ok");
  }


  void getPremiumAccountAnnual() async {
    RevenueCatPurchaseServices().buyPremiumAccount(premiumAccountOptions: PremiumAccountOptions.premiumAccountAnnual).then((value) {
      if (value) {
        PremiumUserDatabaseServices(userUid: widget.userUid).premiumSubscriptionBought(PremiumAccountOptions.premiumAccountAnnual);
        PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.monthlySubscription);
        Navigator.pop(context);
      } else{
        showSnackbar(context: context, color: Colors.redAccent, message: "İşleminizi şu an gerçekleştiremiyoruz");
        //problem occured
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final done = PremiumUserDatabaseServices(userUid: widget.userUid).premiumSubscriptionBought(PremiumAccountOptions.premiumAccountAnnual);

  }

  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
        body: ProgressHUD(
          child: Builder(
            builder: (context) {
              return GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              AppConstants().primaryColor,
                              const Color(0xFFffffFF),
                            ],
                            begin: const FractionalOffset(1.0, 0.0),
                            end: const FractionalOffset(0.0, 1.5),
                            stops: const [0.0, 1.0],
                            tileMode: TileMode.clamp),
                      ),
                      child: SafeArea(
                          child: SingleChildScrollView(
                              child: Container(
                                height: availableHeight,
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: IconButton(
                                            padding: const EdgeInsets.all(0.0),
                                            icon: const Icon(Icons.close, size: 30.0, color: Colors.white,),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.yellow.withOpacity(0.8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.diamond_outlined, color: Colors.white, size: 30,),
                                            Text(
                                              " ssCar Premium Paket",
                                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "   Limitsiz özelliklerden faydalan!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                      height: 240,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "Plakanı sahiplenmeden önce gelen özel mesajları aç",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "Plakalara istediğin özel mesajı atabilirsin",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "Günlük 2x token kazan",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "Plakana emoji ve puan yollayanları gör",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "5 plakaya kadar sahiplenebilme hakkı",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                          Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 6,),
                                                Expanded(
                                                  child: Text(
                                                    "Reklamları kaldır",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                )
                                              ]
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5,),
                                    const Text(
                                      "%50 indirim için son ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                    StreamBuilder(
                                        stream: Stream.periodic(Duration(seconds: 1), (i) => i),
                                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                          DateFormat format = DateFormat("mm:ss");
                                          int now = DateTime
                                              .now()
                                              .millisecondsSinceEpoch;
                                          Duration remaining = Duration(milliseconds: estimateTs - now);
                                          var dateString = '${remaining.inHours}:${format.format(
                                              DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
                                          return Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.redAccent.withOpacity(0.7),
                                            ),
                                            child: Text(
                                              dateString,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),);
                                        }),
                                    Row( // satin al fiyat butonlari
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        PremiumAccountGetPriceWidget(
                                          progressContext: context,
                                          userUid: widget.userUid,
                                          premiumAccountDetails: _monthlyPremiumDetails,
                                          premiumAccountOptions: PremiumAccountOptions.premiumAccountMonthly,
                                        ),
                                        const SizedBox(width: 15,),
                                        PremiumAccountGetPriceWidget(
                                          progressContext: context,
                                          userUid: widget.userUid,
                                          premiumAccountDetails: _annualPremiumDetails,
                                          premiumAccountOptions: PremiumAccountOptions.premiumAccountAnnual,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      // width: 200,
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              if (await canLaunchUrl(Uri.parse(AppConstants.conditionsAgreementURL))) {
                                                await launchUrl(Uri.parse(AppConstants.conditionsAgreementURL));
                                              }else{
                                                print("12e12er1");
                                              }
                                            },
                                            child: const Text(
                                              "Hüküm ve Koşullar",
                                              style: TextStyle(
                                                  color: Colors.grey
                                              ),
                                            ),
                                          ),
                                          //SizedBox(width: 8,),
                                          const Text(
                                            " - ",
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (await canLaunchUrl(Uri.parse(AppConstants.privacyAgreementURL))) {
                                                await launchUrl(Uri.parse(AppConstants.privacyAgreementURL));
                                              }
                                            },
                                            child: const Text(
                                              "Gizlilik     ",
                                              style: TextStyle(
                                                  color: Colors.grey
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    const Text(
                                      "*Diledigin zaman iptal edebilirsin",
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          )
                      )
                  )
              );
            }
          ),
        )
    );
  }
}
