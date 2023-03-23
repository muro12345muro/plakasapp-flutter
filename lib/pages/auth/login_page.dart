import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sscarapp/services/firebase/database/auth/database_auth.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';
import 'package:sscarapp/shared/app_constants.dart';
import 'package:sscarapp/tabBarPages/main_controller.dart';
import '../../helper/request_functions.dart';
import '../../helper/user_defaults_functions.dart';
import '../../services/firebase/firestore/notifications_services.dart';
import '../../widgets/custom_widgets.dart';
import 'lost_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // GlobalKey formKey = GlobalKey();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailTextFieldController = TextEditingController();
  TextEditingController passwordTextFieldController = TextEditingController();
  String email = "";
  String password = "";
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final availableHeight = mediaQueryData.size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final bottomSafeAreaHeight =      mediaQueryData.padding.bottom;


    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(70),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Üyeliğin yok mu? Hemen kayıt ol!",//
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                              "Giriş Yap",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
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
                                controller: emailTextFieldController,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 16),
                                validator: (val) {
                                  return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                      ? null
                                      : "Please enter a valid email";
                                },
                                decoration: InputDecoration(
                                  hintText: "E-mail",
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: InputBorder.none,
                                  focusColor: AppConstants().primaryColor,
                                ),
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
                                textInputAction: TextInputAction.go,
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
                                validator: (val) {
                                  if (val!.length < 6) {
                                    return "Password must be at least 6 characters";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return const LostPasswordPage();
                                    }));
                                  },
                                  child: const Text(
                                    "Şifreni mi unuttun?",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white,),
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
                                      onPressed: _isLoading ? null : login,
                                      child: !_isLoading ? const Text(
                                        "Giriş Yap",
                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
                                      ) : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "Giriş yapılıyor",
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
    );
  }
  login() async {
    if (true) {
      setState(() {
        _isLoading = true;
      });
      final _emailField = emailTextFieldController.text.trim();
      final _passwordField = passwordTextFieldController.text.trim();

      await DatabaseAuth()
          .loginWithEmailAndPassword(_emailField, _passwordField)
          .then((value) async {
        if (value == null) {
          showSnackbar(context: context, color: Colors.red, message: "Bir sorun meydana geldi.");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final isDisabled = await UserDatabaseService(userUid: value).getUsersAccountIsDisabled();
        if (isDisabled) {
          showSnackbar(context: context, color: Colors.red, message: "Bir sorun meydana geldi.");
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
        // saving the values to our shared preferences
        await UserDefaultsFunctions.setUserLoggedInStatus(true);
        await UserDefaultsFunctions.saveUserUidSF(value!);
        setPushToken(value!);
        //UserDatabaseService(userUid: value).setUserDefaultsLogin();
        Navigator.of(context)
            .pushAndRemoveUntil(MaterialPageRoute(builder: (_) {
          return MainControllerTabBar(isSignedIn: true);
        }), (Route<dynamic> route) => false, );
        // nextScreenReplace(context, const HomePage());

      })
          .catchError((onError) {
        log("$onError");
        showSnackbar(context: context, color: Colors.red, message: onError);
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  setPushToken(String uUid) async {
    RequestFunctions().getPushToken().then((value) async {
      if(value == null) return;
      NotificationsServices().setPushTokenDevice(token: value, userUid: uUid);
    });
  }
}

