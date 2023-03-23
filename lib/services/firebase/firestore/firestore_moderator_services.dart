import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DeclinedPlates{
  final String videoUrl;
  final String plaka;
  final String userUid;

  DeclinedPlates({
    required this.videoUrl,
    required this.plaka,
    required this.userUid,
  });


  Map<String, dynamic> toJson() => (<String, dynamic>{
    'videoUrl': videoUrl,
    'plaka': plaka,
    'userUid': userUid,
  });

  DeclinedPlates.fromJson(Map<dynamic, dynamic> json)
      : videoUrl = json['videoUrl'],
        plaka = json['plaka'],
        userUid = json['userUid'];
}

class FirestoreModeratorServices{
  FirebaseFirestore fsInstance = FirebaseFirestore.instance;

/*
  Future<String?> getModetatorsList() async {
    try {
      final snapshot = await fsInstance.collection("moderators").doc(userUid!).get();
      if (snapshot.exists) {
        return snapshot.data()!["fcmToken"];
      } else{
        return null;
      }
    } catch (e) {
      log("asd23ff $e");
      return null;
    }
  }*/


  Future<String?> searchWaitingVideos() async {
    try{
      final dbref = FirebaseDatabase.instance.ref();
      final desertRef = await dbref.child("plaka-submissions/declined/").get();
      final json = desertRef.value as Map<dynamic, dynamic>;
      var i = 0;
      List<List<DeclinedPlates>> postsofPost = [];
      for(var mapEntry in json.entries) {
        log("32f2_2f3 $mapEntry");
        i++;
        List<DeclinedPlates> posts = [];
        log("23f_232111 ${mapEntry.key}");
        log("23f_232dd111 ${mapEntry.value}");
        for(var mapEntry1 in mapEntry.value) {
          log("3200f2_2f3 $mapEntry1");
          mapEntry.value["userUid"] = mapEntry1.key;
          log("3200f2_002f3 ${mapEntry1.key}");
          final notiData = DeclinedPlates.fromJson(mapEntry1.value);
          posts.add(notiData);
        }
        postsofPost.add(posts);
        if(i == 5) {
          log("23f_fo30_2f3 $postsofPost");
          break;
        }
      }
      //Map<String, List<Map<String, dynamic>>>;
      log("23f_gko30 $json");
    } catch (e){
      log("23f_f2_f23 $e");
    }

  }

  Future<String?> deleteAndBackupVideos() async {
    searchWaitingVideos();
    final url = "https://firebasestorage.googleapis.com/v0/b/plakasapp.appspot.com/o/plaka_kanit_videos%2F1MUjLBVpznc8qswR41pVozuGODH330-01-2023%2020%3A06_profile_picture.mp4?alt=media&token=ffa52118-4ade-4c5b-991d-0eb1f905ec66";
    final decodedUrl = Uri.decodeFull(url);
    final splitted = decodedUrl.split("?");
    final droppedMediaParam = splitted[0];
    log("23f_32f00  ${splitted[0]}");
    final droppedBaseUrl = droppedMediaParam.split("plaka_kanit_videos");
    final finalFilePath = droppedBaseUrl[1];
    log("23_f23 $finalFilePath");

    try{
      final storageRef = FirebaseStorage.instance.ref();
      final desertRef = await storageRef.child("plaka_kanit_videos/$finalFilePath").getDownloadURL();
      print("23f_gko30 $desertRef");
    } catch (e){
      log("23f_f2_f23 $e");
    }
    return null;
  }
}

//https://firebasestorage.googleapis.com/v0/b/plakasapp.appspot.com/o/plaka_kanit_videos/1MUjLBVpznc8qswR41pVozuGODH330-01-2023 20:06_profile_picture.mp4?alt=media&token=ffa52118-4ade-4c5b-991d-0eb1f905ec66
