

import 'dart:developer';

import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';

class CommonServices {

  Future<dynamic>? getUsersSingleDataNode({
    required String userUid,
    required SingleDataOps data,
  }) async {
    try {
      log("fire_base_action_get_called getUsersSingleDataNode");
      final snapshot = await databaseInstanceRef.child("kullanicilar").child(
          userUid).child(data.nodeName).once();
      final json = snapshot.snapshot.value as dynamic;
      if (json == null) throw "null dondu";
      return json;
    } catch (e) {
      print("23421412 $e");
      return null;
    }
  }

  Future updateUsersSingleNode({
    required String userUid,
    required dynamic data,
    required SingleDataOps node,
  }) async {
     await databaseInstanceRef
        .child("kullanicilar")
        .child(userUid).update({node.nodeName: "$data"});
  }

}