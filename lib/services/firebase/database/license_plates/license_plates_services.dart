
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/models/models.dart';

DatabaseReference dbInstanceRef = FirebaseDatabase.instance.ref();

class LicensePlatesServices {
  final String safePlateNumber;
  final databaseRef = FirebaseDatabase.instance.ref();
  var regularDMYHMformatter = DateFormat('dd-MM-yyyy HH:mm');
  var regularDateFormatterDMYHMS = DateFormat('dd-MM-yyyy HH:mm:ss');
  LicensePlatesServices({required this.safePlateNumber,});
  
  ///WRITES
  Future<bool> registerLicensePlateWaitings(
      {required String email,
        required String ipAddress,
        required String deviceId,
        required String userUid,
        required String videoUrl}) async {

    var now = DateTime.now();
    String formattedDate = regularDMYHMformatter.format(now);

    Map<String, Object> data = {
      "date": formattedDate,
      "ipAddress": ipAddress,
      "plaka": safePlateNumber,
      "email": email,
      "deviceId": deviceId ?? "",
      "videoUrl": videoUrl ?? "",
    };
    try{
      final autoKey = dbInstanceRef.child("plaka-submissions/waiting").child(userUid).push().key;
      if(autoKey == null) return false;
      return await dbInstanceRef.child("plaka-submissions/waiting").child(userUid).child(autoKey).update(data)
          .then((_) async {
        return true;
      }).catchError((e) {
        print("235 $e");
        return false;
      });
    } catch (e) {
      print("456 $e");
      return false;
    }
  }


  Future<bool> newLicensePlateLookupSave({String? userUid}) async {
    try{
      final date = regularDMYHMformatter.format(DateTime.now());
      userUid ??= await InformatorFunctions().getDevicesUniqueId();
      print("23fd23f32 $userUid");
      print("10023 plate-lookups/$safePlateNumber $userUid $date");
      if (userUid == null) return false;
      print("23f23f");
      await dbInstanceRef.child("plate-lookups/$safePlateNumber").update({ userUid: date });
      print("@3f23f2f2");
      return true;
    } catch (e) {
      print("@3f23f2f2false $e");

      return false;
    }
  }

  ///</WRITES>

  ///<READS>
  Future<String?> getPlatesOwnerUserUid() async {
    final cityCode = safePlateNumber.substring(0,2);
    log("123141 $safePlateNumber , $cityCode");
    final snap = await databaseRef.child("kayitli-plakalar").child(cityCode).child(safePlateNumber).get();
    final json = snap.value as dynamic;
    log("123141 $json");
    if(json == null) return null;
    return json;
  }
///</READS>

  ///<DELETES>
  String deleteUsersLicensePlate(){
return "";
  }
///</DELETES>
}