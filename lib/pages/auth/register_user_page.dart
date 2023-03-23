import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sscarapp/pages/auth/login_page.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/services/mysql/custom_api_requests.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/database/auth/database_auth.dart';
import '../../shared/app_constants.dart';
import '../../tabBarPages/main_controller.dart';
import '../../widgets/custom_widgets.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({Key? key}) : super(key: key);

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailTextFieldController = TextEditingController();
  TextEditingController passwordTextFieldController = TextEditingController();
  TextEditingController rePasswordTextFieldController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  bool _agreementCheckBox = false;

  @override
  Widget build(BuildContext context) {

    final mediaQueryData = MediaQuery.of(context);
    final availableHeight = mediaQueryData.size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final bottomSafeAreaHeight =      mediaQueryData.padding.bottom;

    log("d3_f32_aa $bottomSafeAreaHeight");
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(160),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const LoginPage();
                }));
              },
              child: const Text(
                "Zaten üye misin? Hemen giriş yap! ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          Container(
            height: bottomSafeAreaHeight > 10 ? bottomSafeAreaHeight-10 : 0,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(70),
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          decoration: BoxDecoration(
            //color: Colors.red,
              image: DecorationImage(
                  image: Image.asset("assets/traffic-road-bg.jpg").image,
                  fit: BoxFit.cover
              )//
          ),
          child: SafeArea(//
            child: SingleChildScrollView(
////
              child: Container(//
                height: availableHeight-30,//
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Form(//
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            iconSize: 35,
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              const SizedBox(height: 30,),//
                              const Text(
                                "Kayıt Ol",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(height: 20,),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  controller: emailTextFieldController,
                                  keyboardType: TextInputType.emailAddress,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: "E-Mail",
                                      fillColor: Colors.white,
                                      filled: true
                                  ),
                                  validator: (val) {
                                    if (val == null) return "Please enter a valid email";
                                    return RegExp(
                                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val)
                                        ? null
                                        : "Please enter a valid email";
                                  },
                                ),
                              ),
                              const SizedBox(height: 15,),
                              Container(
                                padding: const EdgeInsets.fromLTRB(5, 2.5, 5, 0),
                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  obscureText: !_passwordVisible,
                                  controller: passwordTextFieldController,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: "Şifre",
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    focusColor: AppConstants().primaryColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  /*validator: (val) {
                                    if (val!.length < 6) {
                                      return "Password must be at least 6 characters";
                                    } else {
                                      return null;
                                    }
                                  },*/
                                ),
                              ),
                              const SizedBox(height: 15,),
                              Container(
                                //padding: const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.all(4.0),

                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                child: TextFormField(
                                  obscureText: !_passwordVisible,
                                  controller: rePasswordTextFieldController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: "Şifre Tekrar",
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    focusColor: AppConstants().primaryColor,
                                  ),
                                  /*validator: (val) {
                                    if (val!.length < 6) {
                                      return "Password must be at least 6 characters";
                                    } else {
                                      return null;
                                    }
                                  },*/
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                        shape: const CircleBorder(),
                                        activeColor: AppConstants().primaryColor,
                                        fillColor: MaterialStateProperty.all(Colors.orange),
                                        checkColor: Colors.white,
                                        value: _agreementCheckBox,
                                        onChanged: (val){
                                          if (val == null) return;
                                          setState(() {
                                            _agreementCheckBox = val;
                                          });
                                        }),
                                  ),
                                  /*const Expanded(
                                    child: Text(
                                      "Kullanıcı sözleşmesi ni okudum,\n kabul ediyorum.",
                                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
                                    ),
                                  ),*/
                                  GestureDetector(
                                    onTap: () async {
                                      final uri = Uri.parse(AppConstants.conditionsAgreementURL);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          // backgroundColor: Colors.red
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Kullanıcı Sözleşmesi'",
                                            style: TextStyle(
                                              decoration: TextDecoration.underline,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic,

                                            ),
                                          ),
                                          TextSpan(
                                            text: "ni okudum,\n kabul ediyorum.",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                                        onPressed: (){
                                          register();
                                        },
                                        child: const Text(
                                          "Aramıza Katıl",
                                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
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
                      // const Spacer(),
                      /* Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(160),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return const LoginPage();
                              }));
                            },
                            child: const Text(
                              "Zaten üye misin? Hemen giriş yap! ",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ),*/
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
  register() async {
    if (!mounted) return;
    final password = passwordTextFieldController.text;
    final rePassword = rePasswordTextFieldController.text;
    final email = emailTextFieldController.text.trim();

    if (_agreementCheckBox) {
      if (password.length > 5) {
        if (password == rePassword) {
          if (formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });
            await DatabaseAuth()
                .registerWithEmailAndPassword(email, password)
                .then((value) async {
              if (value == null) {
                print("fail 3215 value");
                showSnackbar(context: context, color: Colors.red, message: "uuid alinamadi");
                setState(() {
                  _isLoading = false;
                });
                return;
              }
              // QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
              // saving the values to our shared preferences
              final isDBSaved = await UserDatabaseService(userUid: value!).registerUserToUsers(email, password, "deviceId");
              if(isDBSaved){
                await UserDefaultsFunctions.setUserLoggedInStatus(true);
                await UserDefaultsFunctions.saveUserUidSF(value!);
                showSnackbar(context: context, color: Colors.green, message: AppConstants.successRegisterText);
                print("success 3215 $value");
                await CustomAPIRequests().registrationMysqlWorks(email, password) ? print("23595 true") : print("23595 false");
                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (_) {
                  return MainControllerTabBar(isSignedIn: true);
                }), (Route<dynamic> route) => false, );
                // nextScreenReplace(context, const HomePage());

              }else{
                showSnackbar(context: context, color: Colors.red, message: AppConstants.errorSystemErrorText);
              }
            })
                .catchError((onError) {
              print("$onError");
              showSnackbar(context: context, color: Colors.red, message: onError);
              setState(() {
                _isLoading = false;
              });
            });
          }
        }else{
          showSnackbar(context: context, color: Colors.red, message: AppConstants.errorRegisterPasswordsMatchText,);
        }
      }else{
        showSnackbar(context: context, color: Colors.red, message: AppConstants.errorRegisterPasswordTooShortText);
      }
    } else{
      showSnackbar(context: context, color: Colors.red, message: AppConstants.errorRegisterAgreementCheckboxText);
    }
  }

}
