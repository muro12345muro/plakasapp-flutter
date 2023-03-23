import 'package:flutter/material.dart';

class ModalBottomSheetRegisterPlateWidget extends StatelessWidget {
  const ModalBottomSheetRegisterPlateWidget({
    Key? key,
    required this.openCameraFunction,
    required this.fromAlbumFunction,
  }) : super(key: key);

  final Function openCameraFunction;
  final Function fromAlbumFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 220,
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
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            height: (3*60)+(3*1) + 10,
            child: Column(children: [
              ListTile(
                  title: const Text("Kamerayı Aç"),
                  leading: const Icon(Icons.camera_alt_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    openCameraFunction();
                  }
              ),
              Divider(),
              ListTile(
                  title: const Text("Albümden Seç"),
                  leading: const Icon(Icons.image_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    fromAlbumFunction();
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
