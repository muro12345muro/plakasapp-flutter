import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';

import '../helper/push_notification_functions.dart';
import '../helper/user_defaults_functions.dart';
import '../models/models.dart';
import '../services/revenue_cat/products_info_services.dart';
import '../services/revenue_cat/revenuecat_purchase_services.dart';
import '../shared/app_constants.dart';
import 'custom_widgets.dart';

class ModalBottomSheetBuyTokensWidget extends StatefulWidget {
  final String? userUid;
  final Tokens tokenInfo;
  const ModalBottomSheetBuyTokensWidget({
    Key? key,
    this.userUid,
    required this.tokenInfo
  }) : super(key: key);

  @override
  State<ModalBottomSheetBuyTokensWidget> createState() => _ModalBottomSheetBuyTokensWidgetState();
}

class _ModalBottomSheetBuyTokensWidgetState extends State<ModalBottomSheetBuyTokensWidget> {
  String? userIdentifier;
  TokenOptions? tokenSelected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userIdentifier = widget.userUid;
    if (widget.userUid == null) {
      InformatorFunctions().getDevicesUniqueId().then((value) {
        userIdentifier = value;
      });
    }
  }

  void purchaseTokenButtonTapped() async {
    if(tokenSelected == null) return;
    RevenueCatPurchaseServices().buyTokens(tokenOptions: tokenSelected!).then((value) {
      if (value) {
        PushNotificationsFunctions()
            .sendNotificationToAllModerators(
            notificationKind: ModeratorReportCases.token100,
            additionalInfo: "$tokenSelected eklendi, bilginize");
        if (widget.userUid != null) {
          UserDatabaseService(userUid: widget.userUid!).addTokensToUser(
              tokenInfo: widget.tokenInfo,
              tokens: int.parse(TokenOptionsExtensions(tokenSelected!).getTokenCountString)
          );
        }  else{
          UserDefaultsFunctions
              .addTokensSF(tokens: int.parse(TokenOptionsExtensions(tokenSelected!).getTokenCountString));
        }
      } else{
        showSnackbar(context: context, color: Colors.redAccent, message: "İşleminizi şu an gerçekleştiremiyoruz");
        //problem occured
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 340,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 3,
            width: 50,
            //margin disarinin sana uygulayacagi itme
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        tokenSelected = TokenOptions.token100;
                      });
                    },
                    child: BuyTokensBottomSheetTokenContainer(tokenOptions: TokenOptions.token100,
                      isSelected: tokenSelected == TokenOptions.token100,)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        tokenSelected = TokenOptions.token500;

                      });
                    },
                    child: BuyTokensBottomSheetTokenContainer(tokenOptions: TokenOptions.token500,
                      isSelected: tokenSelected == TokenOptions.token500,)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        tokenSelected = TokenOptions.token300;
                      });
                    },
                    child: BuyTokensBottomSheetTokenContainer(tokenOptions: TokenOptions.token300,
                      isSelected: tokenSelected == TokenOptions.token300,)
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 1.3,
            child: SizedBox(
              height: 100,
              child: Image.asset(
                "assets/case_with_shadow.png",
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: tokenSelected != null ? AppConstants().primaryColor :
                    AppConstants().primaryColor.withOpacity(0.6),
                  ),
                  child: TextButton(
                    onPressed: tokenSelected == null ? null : purchaseTokenButtonTapped,
                    child: const Text(
                      "Satın al",
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class BuyTokensBottomSheetTokenContainer extends StatefulWidget {
  final TokenOptions tokenOptions;
  final bool? isSelected;

  const BuyTokensBottomSheetTokenContainer({
    Key? key,
    required this.tokenOptions,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<BuyTokensBottomSheetTokenContainer> createState() => _BuyTokensBottomSheetTokenContainerState();
}

class _BuyTokensBottomSheetTokenContainerState extends State<BuyTokensBottomSheetTokenContainer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.topRight,
        children:[
          Container(
            height: 130,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                  colors: [
                    AppConstants().primaryColor,
                    const Color(0xFFffffFF),
                  ],
                  begin: const FractionalOffset(0.2, 0.4),
                  end: const FractionalOffset(0.5, 0.9),
                  stops: const [0.0, 1],
                  tileMode: TileMode.clamp
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 0.0)
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TokenOptionsExtensions(widget.tokenOptions).getTokenCountString,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),
                ),
                const Text(
                  "token",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                      color: AppConstants().secondaryColor,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Text(
                    TokenOptionsExtensions(widget.tokenOptions).getPrice,
                    style: const TextStyle(
                      color: Colors.white,

                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5, bottom: 5),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.isSelected ?? false ? Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, size: 15,),
            ) : null,
          ),
        ]
    );
  }
}

