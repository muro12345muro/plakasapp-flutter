import 'package:flutter/material.dart';

class ModalBottomSheetSelfProfileWidget extends StatelessWidget {
  const ModalBottomSheetSelfProfileWidget({
    Key? key,
    required this.signOutFunction,
    required this.editProfileFunction,
    required this.contactDetailsFunction,
    required this.preferencesFunction,
    required this.myLicensePlatesFunction,
    required this.contactUsFunction,
  }) : super(key: key);

  final Function signOutFunction;
  final Function editProfileFunction;
  final Function contactDetailsFunction;
  final Function preferencesFunction;
  final Function myLicensePlatesFunction;
  final Function contactUsFunction;

  @override
  Widget build(BuildContext context) {
    print("32f32f23f");
    return Container(
      alignment: Alignment.center,
      height: 380,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(//
        children: [//
          Container(
            alignment: Alignment.center,
            height: 3,
            width: 60,
            //margin disarinin sana uygulayacagi itme
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            height: (6*60)+(6*1) - 5,
            child: Column(children: [//
              ListTile(
                  title: const Text("Profilimi Düzenle"),
                  leading: const Icon(Icons.settings_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    editProfileFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("İletişim Bilgilerim"),
                  leading: const Icon(Icons.contact_phone_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    contactDetailsFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("Tercihler"),
                  leading: const Icon(Icons.settings_input_composite_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    preferencesFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("Plakalarım"),
                  leading: const Icon(Icons.directions_car_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    myLicensePlatesFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("Yardım"),
                  leading: const Icon(Icons.info_outline),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    contactUsFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("Çıkış Yap", style: TextStyle(color: Colors.red),),
                  leading: const Icon(Icons.logout_outlined, color: Colors.red),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    signOutFunction();
                  }
              ),
              Divider(),

            ],),
          ),
        ],
      ),
    );
  }
}
