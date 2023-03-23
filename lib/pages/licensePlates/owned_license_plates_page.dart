import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/pages/licensePlates/add_new_license_plate_page.dart';
import 'package:sscarapp/widgets/modal_bottom_sheet_plates.dart';

import '../../services/firebase/database/user/user_database_service.dart';
import '../../shared/app_constants.dart';
import '../../widgets/activities-profile-alert-dialog.dart';
import '../../widgets/pages_default_app_bar.dart';

class OwnedLicensePlatesPage extends StatefulWidget {
  final String userUid;
  const OwnedLicensePlatesPage({Key? key, required this.userUid,}) : super(key: key);

  @override
  State<OwnedLicensePlatesPage> createState() => _OwnedLicensePlatesPageState();
}

class _OwnedLicensePlatesPageState extends State<OwnedLicensePlatesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>>? appliedLicensePlates;

  void getUserInfo() async {
    _isLoading = true;
    log("message");
    appliedLicensePlates = await UserDatabaseService(userUid: widget.userUid).getUsersOwnedLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });

    List<Map<String, dynamic>>? temporaryWaitingPlates = await UserDatabaseService(userUid: widget.userUid).getUsersWaitingLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });
    if(temporaryWaitingPlates != null){
      appliedLicensePlates = [...?appliedLicensePlates, ...temporaryWaitingPlates];
    }

    List<Map<String, dynamic>>? temporaryDeclinedPlates = await UserDatabaseService(userUid: widget.userUid).getUsersDeclinedLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });
    if(temporaryDeclinedPlates != null){
      appliedLicensePlates = [...?appliedLicensePlates, ...temporaryDeclinedPlates];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void removeLicensePlate(String plateNum, int index) async {
    UserDatabaseService(userUid: widget.userUid).deleteUsersOwnedPlate(plateNum).then((value) {
      if (value) {
        setState(() {
          appliedLicensePlates?.removeAt(index);
        });
      }
    });
  }

  Future<void> _pullRefresh() async {
    HapticFeedback.lightImpact();
    appliedLicensePlates = await UserDatabaseService(userUid: widget.userUid).getUsersOwnedLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });

    List<Map<String, dynamic>>? temporaryWaitingPlates = await UserDatabaseService(userUid: widget.userUid).getUsersWaitingLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });
    if(temporaryWaitingPlates != null){
      appliedLicensePlates = [...?appliedLicensePlates, ...temporaryWaitingPlates];
    }

    List<Map<String, dynamic>>? temporaryDeclinedPlates = await UserDatabaseService(userUid: widget.userUid).getUsersDeclinedLicensePlatesData()
        ?.catchError((onErr) {
      log(onErr);
    });
    if(temporaryDeclinedPlates != null){
      appliedLicensePlates = [...?appliedLicensePlates, ...temporaryDeclinedPlates];
    }
    setState(() {

    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: PagesDefaultAppBar(title: "Plaka Başvurularım", leftIcon: Icons.arrow_back_ios_new,),
      body:  _isLoading
          ?
      Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red))
          :
      GestureDetector(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                height: availableHeight-60,
                color: Colors.transparent,
                child: Column(
                  children: [
                    appliedLicensePlates == null
                        ?
                    const Expanded(
                        child: Center(
                          child: Text(
                              "Plaka sahiplenme başvurusu bulunamadı"
                          ),
                        )
                    )
                        :
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _pullRefresh,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          itemCount: appliedLicensePlates == null ? 0 : appliedLicensePlates!.length,
                          itemBuilder: (context, index) {
                            final application = appliedLicensePlates![index];
                            final int statusCode = application["statusCode"];
                            final String plateId = application["plate"];
                            final String plate = StringPlateExtensions.makePlateVisualString(plateId);
                            final String description = application["description"];
                            final String? modDescription = application["modDescription"];
                            return ListTile(
                              minLeadingWidth: 20,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plate,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,

                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        description,
                                        style: statusCode == 0 ? const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ) : statusCode == 1 ? const TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ) : const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Container(margin: const EdgeInsets.only(left: 16, right: 10) , width: 1, height: 45, color: Colors.grey.shade300,),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: (){
                                          showModalBottomSheet<void>(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ModalBottomSheetPlatesWidget(
                                                plate: plate,
                                                description: description,
                                                statusCode: statusCode,
                                                modDescription: modDescription,
                                                removePlateFunction: statusCode == 1 ? removeLicensePlate : null,
                                                plateId: plateId,
                                                index: index,
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.more_horiz),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              leading: Image.asset(
                                "assets/license-plate-icon.png",
                                //width: 40,
                                height: 40,
                              ),
                              onTap: () {
                                showModalBottomSheet<void>(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ModalBottomSheetPlatesWidget(plate: plate, description: description, statusCode: statusCode, modDescription: modDescription, removePlateFunction: statusCode == 1 ? removeLicensePlate : null, plateId: plateId, index: index);
                                  },
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        // padding: EdgeInsets.zero,
                      ),
                      onPressed: () async  {
                        dynamic isPlateAdded = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) {
                                  return AddNewLicensePlatePage(userUid: widget.userUid,);
                                }
                            )
                        );
                        if (isPlateAdded != null) {
                          if (isPlateAdded) {
                            getUserInfo();
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border( ),
                          borderRadius: BorderRadius.circular(5),
                          color: AppConstants().primaryColor,
                        ),
                        alignment: Alignment.center,
                        height: 40,
                        width: 200,
                        child: Text(
                          "Plaka Ekle",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      ),
    );



  }
}
