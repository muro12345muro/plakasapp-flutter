import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sscarapp/services/firebase/database/auth/database_auth.dart';
import 'package:sscarapp/services/firebase/database/common_services.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/tabBarPages/main_controller.dart';
import '../../helper/request_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/firestore/notifications_services.dart';
import '../../services/firebase/storage/user_storage_services.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/modal_bottom_sheet_edit_profile.dart';
import 'lost_password_page.dart';

class SetNicknamePage extends StatefulWidget {
  final String? profilePictureUrl;
  final String userUid;

  const SetNicknamePage({
    Key? key,
    this.profilePictureUrl,
    required this.userUid,
  }) : super(key: key);

  @override
  State<SetNicknamePage> createState() => _SetNicknamePageState();
}

class _SetNicknamePageState extends State<SetNicknamePage> {
  // GlobalKey formKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nicknameTextFieldController = TextEditingController();
  bool _isLoading = false;
  String? existingProfilePictureUrl;
  String? newProfilePictureURL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExistingProfilePic();
  }

  void getExistingProfilePic() async {
    existingProfilePictureUrl = await CommonServices().getUsersSingleDataNode(
        userUid: widget.userUid,
        data: SingleDataOps.profilePicture
    );
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {

    final mediaQueryData = MediaQuery.of(context);
    final availableHeight = mediaQueryData.size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              //color: Colors.red,
                image: DecorationImage(
                    image: Image.asset("assets/traffic-road-bg.jpg").image,
                    fit: BoxFit.cover
                )
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  height: availableHeight-30,//
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(bottom: 60,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            //color: Colors.red,
                            color: Colors.black54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30,),
                              const Text(
                                "Son adım...",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(height: 20,),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ModalBottomSheetEditProfileWidget(openCameraFunction: openCameraFunction, fromAlbumFunction: pickFromGallery, removePhotoFunction: removePhotoFunction,);
                                    },
                                  );
                                },
                                child: Center(
                                  child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppConstants().primaryColor,
                                          radius: 80 + 3,
                                          child: NonEmptyCircleAvatar(
                                            profilePictureURL: existingProfilePictureUrl ?? newProfilePictureURL,
                                            radius: 80,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          margin: const EdgeInsets.only(right: 5, bottom: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(20)
                                          ),
                                          child: const Icon(Icons.edit, color: Colors.white, size: 20,),
                                        ),
                                      ]
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: nicknameTextFieldController,
                                  keyboardType: TextInputType.emailAddress,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: "Kullanıcı adı*",
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    focusColor: AppConstants().primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      //color: Colors.red,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppConstants().primaryColor
                                      ),
                                      child: TextButton(
                                        onPressed: _isLoading ? null : login,
                                        child: !_isLoading ? const Text(
                                          "Kaydet",
                                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
                                        ) : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "Kaydediliyor",
                                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
                                            ),
                                            SizedBox(width: 5,),
                                            SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2, ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
    await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) {
      return null;
    }
    return File(croppedImage.path);
  }

  Future uploadPPImage(File imageFile) async {
    try{
      newProfilePictureURL =
      await UserStorageService(userUid: widget.userUid).uploadProfilePicture(imageFile);
      if (newProfilePictureURL == null) return;
      UserDatabaseService(userUid: widget.userUid).saveNewProfilePicture(newProfilePictureURL!);
      log("uplod complete $newProfilePictureURL");
      setState(() {

      });
    } catch (e) {
      log("49213 $e");
    }

  }

  Future pickProfilePhoto(ImageSource source) async {
    try{
      log("object");
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        log("message return dondu image 253");
        return;
      }
      final imageTemparory = File(image.path);
      final imageFile = await cropImage(imageFile: imageTemparory);
      if (imageFile == null) return;
      if(!mounted) return;
      showSnackbar(context: context, color: AppConstants().primaryColor, message: "Fotoğraf yükleniyor", showProgressCircle: true);
      await uploadPPImage(imageFile);
      setState(() {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    } on PlatformException catch (e) {
      log("$e 511");
    } catch (e) {
      log("$e 532");

    }
  }

  void openCameraFunction(){
    pickProfilePhoto(ImageSource.camera);
  }
  void pickFromGallery(){
    pickProfilePhoto(ImageSource.gallery);
  }

  void removePhotoFunction(){
    // pickProfilePhoto(ImageSource.camera);
  }

  login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final nickname = nicknameTextFieldController.text.trim();

    if (nickname.length < 6) {
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı en az 6 karakter olmalıdır."
      );
      return;
    }

    if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(nickname)) {
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı özel karakter içeremez"
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final doesExist = await DatabaseAuth().isUsernameAlreadyExisting(nickname);
    if (doesExist) {
      if (!mounted) return;
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı alınmış."
      );
    } else{
      await CommonServices().updateUsersSingleNode(
          userUid: widget.userUid,
          data: nickname,
          node: SingleDataOps.nickname
      );
      if (newProfilePictureURL != null) {
        UserDefaultsFunctions.saveUserProfilePictureURLSF(newProfilePictureURL!);
      }
      UserDefaultsFunctions.saveUserUsernameSF(nickname);

      if(!mounted) return;
      Navigator.pop(context);
    }
    setState(() {
      _isLoading = false;
    });

  }


}

