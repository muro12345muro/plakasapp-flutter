import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';

import '../helper/push_notification_functions.dart';
import '../models/models.dart';
import '../services/firebase/database/premium/premium_user_database_services.dart';
import '../services/revenue_cat/revenuecat_purchase_services.dart';
import '../shared/app_constants.dart';
import 'custom_widgets.dart';

class PremiumAccountGetPriceWidget extends StatefulWidget {
  final String userUid;
  final PremiumAccountDetails premiumAccountDetails;
  final PremiumAccountOptions premiumAccountOptions;
  final BuildContext progressContext;

  const PremiumAccountGetPriceWidget({
    Key? key,
    required this.userUid,
    required this.premiumAccountDetails,
    required this.premiumAccountOptions,
    required this.progressContext,
  }) : super(key: key);

  @override
  State<PremiumAccountGetPriceWidget> createState() => _PremiumAccountGetPriceWidgetState();
}

class _PremiumAccountGetPriceWidgetState extends State<PremiumAccountGetPriceWidget> {

  void getPremiumAccount() async {
    final progress = ProgressHUD.of(widget.progressContext);
    progress?.show();
    RevenueCatPurchaseServices().buyPremiumAccount(premiumAccountOptions: widget.premiumAccountOptions).then((value) async {
      progress?.dismiss();
      if (value) {
        final done = await PremiumUserDatabaseServices(userUid: widget.userUid)
            .premiumSubscriptionBought(widget.premiumAccountOptions);
        final doneSF = await UserDefaultsFunctions.saveUserIsPremiumSF(true);
        PushNotificationsFunctions()
            .sendNotificationToAllModerators(notificationKind: ModeratorReportCases.monthlySubscription);
        Navigator.pop(context);
      } else{
        showSnackbar(context: context, color: Colors.redAccent, message: "İşleminizi şu an gerçekleştiremiyoruz");
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () {
            getPremiumAccount();
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppConstants().secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            height: 150,
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //const SizedBox(height: 5,),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          widget.premiumAccountDetails.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        width: 30,
                        height: 30,
                        color: AppConstants().primaryColor,
                        child: Text(
                          widget.premiumAccountDetails.discountPercent,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        widget.premiumAccountDetails.oldPrice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      widget.premiumAccountDetails.newPrice,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  padding: const EdgeInsets.fromLTRB(35, 5, 35, 5),
                  decoration: BoxDecoration(
                    color: AppConstants().primaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "Satın al",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
  }
}
