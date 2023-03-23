
import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sscarapp/models/models.dart';

final storageInstanceRef = FirebaseStorage.instance.ref();

class UserStorageService {
  final String userUid;
/*asd
* 5Sc2k3fVOnRCJEFQxK2GdqE2sZV2_06-09-2022 12:39_profile_picture.png

5TMhzyvkyYQHywEyNe9eB8Gnu142_09-12-2022 10:42_profile_picture.png
*
* */
  UserStorageService({required this.userUid});

  Future<String?> uploadProfilePicture(File file) async {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    var formattedDate = formatter.format(now);
    final String ppPath = "pp-images/$userUid${formattedDate}_profile_picture.png";
    final userPPImageRef = storageInstanceRef.child(ppPath);
    try {
      return await userPPImageRef.putFile(file).then((p0) async {
        log("667755 ${p0.state}");
        return await userPPImageRef.getDownloadURL();
      });
    } on FirebaseException catch (e) {
      return "$e";
    }
  }

  //photo_message_LPouPC2SVCZKmkQsYUVx7hqfC4B3-swYGcsJqvLOgaeVVLVdJP22sS1C3-2022-08-15-16:40:16-+0000.png
  Future<String?> uploadImageToConversation({required File file, required String targetUseruid}) async {
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy-HH:mm:ss');
    var formattedDate = formatter.format(now);
    final String ppPath = "conversation/DM-images/photo_message_$userUid-$targetUseruid${formattedDate}.png";
    final imageToConversationRef = storageInstanceRef.child(ppPath);
    try {
      return await imageToConversationRef.putFile(file).then((p0) async {
        log("667755 ${p0.state}");
        return await imageToConversationRef.getDownloadURL();
      });
    } on FirebaseException catch (e) {
      log("$e hata meydana geldi");
      return null;
    }
  }

  Future<String?> uploadLicensePlateVideo(File file) async {
    log("23f23f3_2f23aa");
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    var formattedDate = formatter.format(now);
    final String videoPath = "plaka_kanit_videos/$userUid${formattedDate}_profile_picture.mp4";
    final userPlateVideoRef = storageInstanceRef.child(videoPath);
    try {
      return await userPlateVideoRef.putFile(file, SettableMetadata(contentType: 'video/mp4')).then((p0) async {
        log("667755 ${p0.state}");
        log("667_aa755 ${p0}");
        return await userPlateVideoRef.getDownloadURL();
      });
    } on FirebaseException catch (e) {
      log("$e hata meydana geldi");
      return null;
    }
  }

  // upload image to dm conversation

}