import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FirebaseModerationServices {
  FirebaseDatabase fbDbInstance = FirebaseDatabase.instance;

  Future<Map<dynamic, dynamic>?> getModetatorsList() async {
      final snap = await fbDbInstance.ref().child("app-settings/moderators").get();
      if (snap.exists) {
        final json = snap.value as Map<dynamic, dynamic>?;
        print("23f23f2 $json");
        return json;
      } else {
        return null;
      }
  }
  
  ///<WRITES>
  ///
  ///
  Future<bool> setLocationCoordinate(String userUid, String location) async {
    var folderingDateFormat = DateFormat('yyyy/MM/dd/HH/mm');
    var currentDate = DateFormat('dd-MM-yyyy HH:mm');
    final now = DateTime.now();
    final foldering = folderingDateFormat.format(now);
    final date = currentDate.format(now);

    //random
    //-coordinates
    //-date
    final data = {"coordinates": location, "date": date};
    fbDbInstance.ref().child("users-geoloc").child(userUid).child(foldering).update(data);
    return true;
  }

  ///
  ///
  ///</WRITES>


}


