import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';

class ModalBottomSheetPlatesWidget extends StatelessWidget {
  const ModalBottomSheetPlatesWidget({
    Key? key,
    this.plateId,
    required this.plate,
    required this.description,
    this.modDescription,
    required this.statusCode,
    this.removePlateFunction,
    this.index,
  }) : super(key: key);

  final String plate;
  final String? plateId;
  final String description;
  final String? modDescription;
  final int statusCode;
  final int? index;
  final Function(String, int)? removePlateFunction;

  @override
  Widget build(BuildContext context) {
    if (removePlateFunction == null) {
      log("boski 2345356");
      log("boski $statusCode 2345356");
    }
    return Container(
      alignment: Alignment.center,
      height: removePlateFunction != null ? 170 : 120,
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
            padding: EdgeInsets.only(top: 10),
            child: Text(
              description,
              style: statusCode == 0 ? const TextStyle(
                  color: Colors.grey,
                  fontSize: 22,
                  fontWeight: FontWeight.w700
              ) : statusCode == 1 ? const TextStyle(
                  color: Colors.lightGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w700
              ) : const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w700
              ),
            ),
          ),
          modDescription == null ? Container() : Container(
            child: Text(
              "($modDescription)",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300
              ),
            ),
          ),
          const Divider(thickness: 1,),

          Container(
            child: Text(
              plate,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),

          // Divider(),
          removePlateFunction == null ? Container() : Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            height: (1*71)+(1*1),
            child: Column(children: [
              ListTile(
                  title: const Text("Plakayı sil", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),),
                  leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent,),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  horizontalTitleGap: 0,
                  visualDensity: const VisualDensity(vertical: 0), // to compact
                  onTap: () {
                    Navigator.pop(context);
                    if(plateId == null) print("552213");
                    if(index == null) print("54999");
                    removePlateFunction!(plateId!, index!);
                    showSnackbar(context: context, color: Colors.green, message: "$plate plaka silindi");
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
