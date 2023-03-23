import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sscarapp/helper/manuplator_functions.dart';
import 'package:sscarapp/services/firebase/database/license_plates/license_plates_services.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import 'package:sscarapp/widgets/pages_default_app_bar.dart';
import 'package:video_player/video_player.dart';
import '../../helper/push_notification_functions.dart';
import '../../shared/app_constants.dart';
import '../../widgets/model_bottom_sheet_register_plate.dart';

class AddNewLicensePlatePage extends StatefulWidget {
  final String userUid;
  final String? plateNumber;
  const AddNewLicensePlatePage({Key? key, required this.userUid, this.plateNumber}) : super(key: key);

  @override
  State<AddNewLicensePlatePage> createState() => _AddNewLicensePlatePageState();
}

class _AddNewLicensePlatePageState extends State<AddNewLicensePlatePage> {
  TextEditingController plateTextController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;
  bool showVideoDescriptionText = false;
  bool _isUploadOnProgress = false;
  File? uploadimage;
  bool? isPlateAdded;
  List<String> forbiddenPlates = ["07VN442", "07SS111"];

  @override
  void initState() {
    super.initState();
    configureVideoPlayerSampleVideo();
    plateTextController.text = widget.plateNumber ?? "";
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void configureVideoPlayerSampleVideo(){
    _videoPlayerController = VideoPlayerController.network("https://mubayazilim.com/kanit-video2.mp4");
    _initializeVideoPlayerFuture = _videoPlayerController?.initialize().then((value){
      setState(() {
        showVideoDescriptionText = true;
      });
    });
    _videoPlayerController?.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isUploadOnProgress,
      child: Scaffold(
        appBar: PagesDefaultAppBar(title: 'Plaka Ekle', leftIcon: Icons.arrow_back_ios_new, dataEditedShouldReload: isPlateAdded,),
        body:  ProgressHUD(
          child: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: AppConstants().primaryColor, width: 3),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  color: AppConstants().primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Image.asset(
                                      "assets/porsche-car-icon.png",
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.white,
                                    height: 50,
                                    child: TextFormField(
                                        controller: plateTextController,
                                        keyboardType: TextInputType.text,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 43),
                                        decoration: const InputDecoration.collapsed(
                                            hintText: "07 SS 111",
                                            fillColor: Colors.white,
                                            filled: true
                                        ),
                                        onChanged: (val) {
                                          plateTextController.text = StringPlateExtensions.makePlateVisualString(val);
                                          plateTextController.selection = TextSelection.collapsed(offset: plateTextController.text.length);

                                          /*
                                      if (returnKeyboardType(val) == _providedKeyboardType) {
                                        _providedKeyboardType = returnKeyboardType(val);
                                      }  else{
                                      setState(() {
                                          log("23f2f");
                                          _plateTextFieldFocusNode.unfocus();
                                          _providedKeyboardType = InformatorFunctions().returnKeyboardType(val);
                                          Future.delayed(const Duration(milliseconds: 50)).then((value) {
                                            _plateTextFieldFocusNode.requestFocus();
                                          });
                                        });*/
                                        }

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40,),
                        Expanded(
                          child: Transform.scale(
                            scale: 1.17,
                            child: Container(
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: FutureBuilder(
                                      future: _initializeVideoPlayerFuture,
                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                                        if(snapshot.connectionState == ConnectionState.done){
                                          _videoPlayerController?.play();
                                          return AspectRatio(
                                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                                            child: VideoPlayer(_videoPlayerController!),
                                          );
                                        }else{
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Transform.scale(
                                                  scale: 0.7,
                                                  child:circularProgressIndicator()
                                              ),
                                              const Text("Video yükleniyor...", style: TextStyle(color: Colors.grey, fontSize: 12),)
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  showVideoDescriptionText ? Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 36),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                "Plakayı sahiplenebilmen için araca erişebilir olduğunu bize göstermen gerekiyor.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Divider(height: 15, color: Colors.black54, thickness: 0.5,),
                                              Text(
                                                "Tek yapman gereken aracının plakasını ve şöför koltuğuna oturduğunu görebileceğimiz bir video yollamak. \n",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  " - Plakanın gözüktüğünden emin ol \n - Arabayı açıp direksiyona otur",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      )
                                  ) : Container(),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              "Örnek Video",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            // padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            if (!StringPlateExtensions.isRepresentingSignPlate(plateTextController.text)) {
                              showSnackbar(
                                  context: context,
                                  color: Colors.redAccent,
                                  message: "Bunun geçerli bir plaka olduğuna emin misin?"
                              );
                              return;
                            }
                            if (forbiddenPlates.contains(StringPlateExtensions.makePlateNumberSafe(plateTextController.text))) {
                              showSnackbar(
                                  context: context,
                                  color: Colors.redAccent,
                                  message: "Bu plakanın sana ait olduğuna emin misin?"
                              );
                              return;
                            }
                            showModalBottomSheet<void>(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return ModalBottomSheetRegisterPlateWidget(
                                  openCameraFunction: openCameraFunction,
                                  fromAlbumFunction: pickFromGallery,
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: const Border(),
                              borderRadius: BorderRadius.circular(5),
                              color: AppConstants().primaryColor,
                            ),
                            alignment: Alignment.center,
                            height: 50,
                            width: 200,
                            child: const Text(
                              "Video yükle",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          ),
        ),
      ),
    );
  }


  Future uploadVideoProcesses(String videoUrl) async {
    String plateNum = StringPlateExtensions.makePlateNumberSafe(plateTextController.text);
    //delete spaces here when u got plaka form textf
    if (StringPlateExtensions.isRepresentingSignPlate(plateNum)) {
      LicensePlatesServices(safePlateNumber: plateNum)
          .registerLicensePlateWaitings(email: widget.userUid, userUid: widget.userUid, ipAddress: "ipAddress", deviceId: "deviceId", videoUrl: videoUrl).then((value) {
        if (value) {
          setState(() {
            isPlateAdded = true;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showSnackbar(
            context: context,
            color: Colors.green,
            message: "Video yüklendi, plakanız yakın zamanda aktifleşecektir.",
          );
          PushNotificationsFunctions().sendNotificationToAllModerators(notificationKind: ModeratorReportCases.plateSubmission, additionalInfo: plateNum);
        }else{
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showSnackbar(
              context: context,
              color: Colors.redAccent,
              message: "İşleminizi şuan gerçekleştiremiyoruz"
          );
        }
      });
    }else{
      showSnackbar(context: context, color: Colors.redAccent, message: "'$plateNum' geçerli bir plaka değildir!");
    }
  }

  Future pickPlateValidationVideo(ImageSource source) async {
    try{
      final image = await ImagePicker().pickVideo(source: source, maxDuration: const Duration(seconds: 15));
      if (image == null) {
        log("ImagePicker().pickVideo returns null 12e1_ed12");
        return;
      }
      showSnackbar(
        context: context,
        color: AppConstants().primaryColor,
        isInfinite: true,
        showProgressCircle: true,
        message: "Video yükleniyor lütfen bekleyin",
      );
      final imageTemparory = File(image.path);
      uploadimage = imageTemparory;
      setState(() {
        _isUploadOnProgress = true;
      });
      // await uploadVideo(imageTemparory);

      final videoUrl = await uploadVideo();
      if (videoUrl != null) {
        await uploadVideoProcesses(videoUrl);
      }else{
        log("gog_wv video url null");
      }
      setState(() {
        _isUploadOnProgress = false;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _isUploadOnProgress = false;
      log("$e 5333d2");

    }
  }

  Future<String?> uploadVideo() async {
    String plateNum = StringPlateExtensions.makePlateNumberSafe(plateTextController.text);
    log("df23f_f32 video upload");
    String uploadurl = "http://mubayazilim.com/sscar/api/upload_video_kanit.php";
    final asd = Uri.parse(uploadurl);
      if (uploadimage?.path == null) {
        showSnackbar(
            context: context,
            color: Colors.redAccent,
            message: "Lütfen tekrar video seçiniz."
        );
        return null;
      }

      final compressedVideoFile = await ManuplatorFunctions().videoFileCompressor(uploadimage!);

      if (compressedVideoFile == null) {
        log("23f_ll compress failed");
        return null;
      }
      final baseVideoFile = await ManuplatorFunctions().fileToBase64StringConverter(compressedVideoFile);

      //convert file image to Base64 encoding
      var response = await http.post(
          asd,
          body: {
            'video': baseVideoFile,
            'token': "fkj39dortp2f3n20djf3",
            'plate': plateNum,
          }
      );

      if(response.statusCode == 200) {
        var jsondata = json.decode(response.body); //decode json data
        if(jsondata["error"]){
          //check error sent from server
          log(jsondata["message"]);
          return null;
          //if error return from server, show message from server
        }else{
          log(jsondata["message"]);
          return jsondata["message"];
        }
      }else{
        log("df23f_f32 Error during connection to server");
        return null;
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
  }

  void openCameraFunction(){
    pickPlateValidationVideo(ImageSource.camera);
  }
  void pickFromGallery(){
    pickPlateValidationVideo(ImageSource.gallery);
  }

}
