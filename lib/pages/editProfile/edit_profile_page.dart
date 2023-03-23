import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sscarapp/services/firebase/storage/user_storage_services.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import '../../models/models.dart';
import '../../services/firebase/database/auth/database_auth.dart';
import '../../services/firebase/database/user/user_database_service.dart';
import '../../widgets/modal_bottom_sheet_edit_profile.dart';
import '../../widgets/pages_default_app_bar.dart';

class EditProfilePage extends StatefulWidget {
  final String userUid;
  const EditProfilePage({
    Key? key,
    required this.userUid,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController  fullNameFormFieldController = TextEditingController();
  final TextEditingController  nicknameFormFieldController = TextEditingController();
  final TextEditingController  biographyFormFieldController = TextEditingController();
  final TextEditingController emailFormFieldController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? newProfilePictureURL;

  bool _isLoading = true;

  UserPersonalDataModel? userInfo;

  void getUserInfo() async {
    _isLoading = true;
    userInfo = await UserDatabaseService(userUid: widget.userUid).getUsersAllData()
        .catchError((onErr) {
      log(onErr);
    });
    fullNameFormFieldController.text = userInfo?.fullname ?? "";
    nicknameFormFieldController.text = userInfo?.nickname ?? "";
    biographyFormFieldController.text = userInfo?.biography ?? "";
    emailFormFieldController.text = userInfo?.email ?? "";

    setState(() {
      _isLoading = false;
    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();

  }

  void saveEdits() async {
    final nickname =  nicknameFormFieldController.text.toLowerCase();
    if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(nickname)) {
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı özel karakter içeremez"
      );
      return;
    }

    if (nickname.length < 6) {
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı en az 6 karakter olmalıdır."
      );
      return;
    }

    final doesExist = await DatabaseAuth().isUsernameAlreadyExisting(nickname);
    if (doesExist) {
      if (!mounted) return;
      showSnackbar(
          context: context,
          color: Colors.redAccent,
          message: "Kullanıcı adı alınmış."
      );
      return;
    }

    final UserEditProfileInfo editedInfo = UserEditProfileInfo(
      fullname: fullNameFormFieldController.text,
      nickname: nickname,
      biography: biographyFormFieldController.text,
      profilePicture: newProfilePictureURL ?? (userInfo?.profilePicture),
      //email: emailFormFieldController.text,
    );

    await UserDatabaseService(userUid: widget.userUid).updateUserProfileInfo(editedInfo);
    if (!mounted) return;
    Navigator.pop(context, editedInfo);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: PagesDefaultAppBar(
        title: "Profilimi Düzenle",
        leftIcon: Icons.arrow_back_ios_new,
        rightButtonText: "Kaydet",
        rightButtonActionFunction: saveEdits,
      ),
      body: _isLoading ?
      const Center(
          child: CircularProgressIndicator(
              color: Colors.orange,
              backgroundColor: Colors.red,
          ),
      )
          :
      GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
               // height: availableHeight-85,
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
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
                      child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppConstants().primaryColor,
                              radius: 63.0,
                              child: NonEmptyCircleAvatar(
                                profilePictureURL: newProfilePictureURL ?? userInfo?.profilePicture,
                                radius: 60,
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

                    const SizedBox(height: 10,),
                    const Divider(thickness: 1,),
                    //Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          const SizedBox(width: 100, child: Text("İsim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded(
                              child: TextFormField(
                                controller: fullNameFormFieldController,
                                onChanged: (val) {
                                  userInfo?.fullname = val;
                                },
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppConstants().primaryColor),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          const SizedBox(width: 100, child: Text("Kullanıcı adı", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded(
                              child: TextFormField(
                                controller: nicknameFormFieldController,
                                onChanged: (val) {
                                  userInfo?.nickname = val;
                                },
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppConstants().primaryColor),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 100, child: Text("Biografi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded(
                              child: TextFormField(
                                controller: biographyFormFieldController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  userInfo?.biography = val;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 10.0),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppConstants().primaryColor),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(thickness: 1,),
                    Container(
                      padding: const EdgeInsets.only(left: 10, top: 20),
                      alignment: Alignment.centerLeft,
                      child: const Text("Kullanıcı Ayarları", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          const SizedBox(width: 60, child: Text("E-Mail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                          Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: emailFormFieldController,
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppConstants().primaryColor),
                                  ),
                                ),
                              )
                          ),
                        ],
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


