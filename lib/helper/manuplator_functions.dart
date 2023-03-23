import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:video_compress/video_compress.dart';

class ManuplatorFunctions{

  List<String> ownedLicensePlatesConverter(Map<dynamic, dynamic> ownedPlates){
    List<String> licensePlates = [];
    ownedPlates.forEach((key, value) {
      licensePlates.add(key as String);
    });
    return licensePlates;
  }

  String makeLicensePlateReadable(String plateNum){
    return plateNum;
  }

  Future<String?> fileToBase64StringConverter(File file) async {
    try{
      var bytesFile = file.readAsBytesSync();
      log("23ff_f32 $bytesFile");
      List<int> bytesListFile = List<int>.from(bytesFile);
      log("23f2222f_f32 $bytesListFile");
      String base64File = base64Encode(bytesListFile);
      log("23f2000222f_f32 $base64File");
      return base64File;
    } catch (e) {
      log("23f23f_g43 $e");
      return null;
    }
  }

  Future<File?> videoFileCompressor(File videoFile) async {
    final info = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.MediumQuality, // default(VideoQuality.DefaultQuality)
      deleteOrigin: false, // default(false)
    );
    return info?.file;
  }
}
extension StringPlateExtensions on String {

  static bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  static String onlyAlphabetic(String string){
    return string.replaceAll(RegExp(r'[^\w\s]+'),'')
        .replaceAll(" ",'');
  }

  static String removeSpaces(String string){
    return string.replaceAll(" ",'');
  }

  static bool checkIfOnlyAlphabetic(String string){
    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(string);

  }

  static String makePlateNumberSafe(String plateNum) {
    return onlyAlphabetic(removeSpaces(plateNum).toUpperCase());
  }

//07njd849
//07nj49
  static String makePlateVisualString(String string){
    String plate = "";
    string = removeSpaces(string);
    for(int i=0; i<string.length; i++) {
      var char = string[i].toUpperCase();
      if (i+1 < string.length){
        var charPlus = string[i+1];
        if (isNumeric(char) && isNumeric(charPlus)) {
          plate += char;
        } else if (!isNumeric(char) && !isNumeric(charPlus)) {
          plate += char;
        } else {
          plate += "$char ";
        }
      }else{
        plate += char;
      }
    }
    return plate;

  }

  static bool isRepresentingSignPlate(String plate) {
    plate = plate.replaceAll(" ",'');
    if (plate.length < 3) return false;
    if (plate.length > 9) return false;
    if (!isNumeric(plate.substring(plate.length - 1))) return false;
    if (!isNumeric(plate.substring(0,2))) return false;
    if (isNumeric(plate[2])) return false;
    if (!checkIfOnlyAlphabetic(plate)) return false;
    if (int.parse(plate.substring(0,2)) > 81) return false;
    if (int.parse(plate.substring(0,2)) < 1) return false;
    return true;
  }
}

extension StringDateExtensions on String {
  static String makeDMYHMStoDMY(String timestamp) {
    timestamp = timestamp.substring(0, 10);
    return timestamp;
  }

  static String displayTimeAgoFromDMYHM(String timestamp) {
    // dd-mm-yyyy HH:mm
    final year = int.parse(timestamp.substring(6, 10));
    final month = int.parse(timestamp.substring(3, 5));
    final day = int.parse(timestamp.substring(0, 2));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime videoDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(videoDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = 'dak';
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = 'sa';
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = 'gün';
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = 'hafta';
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = 'ay';
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = 'yıl';
    }

    timeAgo = '$timeValue $timeUnit';
    timeAgo += timeValue > 1 ? '' : '';
    if (timeValue == 0) return "az önce";
    return '$timeAgo';
  }

  static String displayTimeAgoFromDMYHMS(String timestamp) {
    // dd-mm-yyyy HH:mm
    final year = int.parse(timestamp.substring(6, 10));
    final month = int.parse(timestamp.substring(3, 5));
    final day = int.parse(timestamp.substring(0, 2));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime videoDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(videoDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
      timeValue = diffInMinutes;
      timeUnit = 'dakika';
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      timeUnit = 'saat';
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      timeUnit = 'gün';
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      timeValue = (diffInHours / (24 * 7)).floor();
      timeUnit = 'hafta';
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      timeValue = (diffInHours / (24 * 30)).floor();
      timeUnit = 'ay';
    } else {
      timeValue = (diffInHours / (24 * 365)).floor();
      timeUnit = 'yıl';
    }

    timeAgo = '$timeValue $timeUnit';
    timeAgo += timeValue > 1 ? '' : '';

    return '$timeAgo önce';
  }
}
