import 'package:flutter/material.dart';

class ModalBottomSheetEditProfileWidget extends StatelessWidget {
  const ModalBottomSheetEditProfileWidget({
    Key? key,
    required this.openCameraFunction,
    required this.fromAlbumFunction,
    this.removePhotoFunction,
  }) : super(key: key);

  final Function openCameraFunction;
  final Function fromAlbumFunction;
  final Function? removePhotoFunction;

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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            height: (3*60)+(3*1) + 10,
            child: Column(children: [
              ListTile(
                  title: const Text("Kamerayı Aç"),
                  leading: const Icon(Icons.camera_alt_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    openCameraFunction();
                  }
              ),
              const Divider(),
              ListTile(
                  title: const Text("Albümden Seç"),
                  leading: const Icon(Icons.image_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    fromAlbumFunction();
                  }
              ),
              const Divider(),
              removePhotoFunction == null ? Container() :
              ListTile(
                  title: const Text("Fotoğrafı Kaldır", style: TextStyle(color: Colors.redAccent),),
                  leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent,),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: -4), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    removePhotoFunction!();
                  }
              ),
              const Divider(),
            ],),
          ),
        ],
      ),
    );
  }
}
