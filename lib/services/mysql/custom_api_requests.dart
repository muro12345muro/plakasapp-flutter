import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../helper/manuplator_functions.dart';

class CustomAPIRequests{
  static const String token = "64b180198ee6156a24957918d3a13976";

  Future<bool> registrationMysqlWorks(String email, String initpass) async {
    final String signupURL = "https://bakiryazilim.com/a-projectbarkod/registeration/systemfunctions/adduser.php?token=64bfgor98ee6156a249g9w18d3a13p36&email=$email&tokenmd5=$token&init=$initpass";
    final urlResponse = await http.get(Uri.parse(signupURL));
    if (200 <= urlResponse.statusCode && urlResponse.statusCode <= 299) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return true;
    }
    return false;
  }

  Future<String?> getPlateImageAPI({required String plateNumber,}) async {
    plateNumber = plateNumber.replaceAll(" ", "%20");
    final String signupURL = "https://mubayazilim.com/sscar/api/get_images_google.php?plate=$plateNumber&token=64bfgor98ee6156a249g9w18d3a13p36";

   log("23fg_gg5_323 $signupURL");
    final urlResponse = await http.get(Uri.parse(signupURL));
    if (200 <= urlResponse.statusCode && urlResponse.statusCode <= 299) {
      var jsondata = json.decode(urlResponse.body); //decode json data
      final error = jsondata["error"] as bool?;
      if (error == true) {
        return null;
      }
      final message = jsondata["message"] as String?;
      return message;
    }else{
      log("2_3_f_3 muba yazilim returned server err");
      return null;

    }
  }

  Future<String?> uploadUsersPlateImage({required File file, required String plate, }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://mubayazilim.com/sscar/api/upload_users_plate_image.php?plate=$plate'),
    );

    // Create a new multipart file from the provided file path
    var multipartFile = await http.MultipartFile.fromPath('file', file.path);

    // Attach the file to the request
    request.files.add(multipartFile);

    try {
      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // File upload successful

        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        // Access the data in the JSON response
        final error = jsonResponse['error'] as bool?;
        final path = jsonResponse['msg'] as String?;

        if (error ?? true) {
          log("@3f23f_23f23f232f_@3f23f $path");
          return null;
        }
        return path;
      } else {
        // File upload failed
        return null;
      }
    } catch (e) {
      // Handle any errors
      return null;
    }
  }





/*
  Future<String?> uploadValidationVideoByPlate({required String plate, required Uint8List video}) async {
    String plateNum = StringPlateExtensions.makePlateNumberSafe(plate);
    log("df23f_f32 video upload $plate 3f23f_dsa $video");
    String uploadUrl = "http://mubayazilim.com/sscar/api/upload_video_kanit.php";
    final uploadUri = Uri.parse(uploadUrl);
    try{
      var videoAsBytesSync = video.readAsBytesSync();
      log("2zz333f_f32 ");
      List<int> videoBytes = List<int>.from(video);
      log("2zz223f_f32 $videoBytes ");
      String baseVideo = base64Encode(videoBytes);
      log("2zz311f_f32  $baseVideo");
      var response = await http.post(
          uploadUri,
          //99.95% == uptime sla timing since 2018 == ngn
          body: {
            'video': baseVideo,
            'token': "fkj39dortp2f3n20djf3",
            'plate': plateNum,
          }
      );
      if(response.statusCode == 200) {
        var jsonData = json.decode(response.body); //decode json data
        if(jsonData["error"]){ //check error sent from server
          log(jsonData["message"]);
          return null;
          //if error return from server, show message from server
        }else{
          log(jsonData["message"]);
          log(" df23f_f32 Upload successful");
          return jsonData["message"];
        }
      }else{
        log("df23f_f32 Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
        return null;
      }
    }catch(e){
      log("df23f_f32 Error $e");
      return null;
      //there is error during converting file image to base64 encoding.
    }
  }
*/


}
