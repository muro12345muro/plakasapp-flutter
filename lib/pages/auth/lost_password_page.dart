import 'package:flutter/material.dart';
import 'package:sscarapp/helper/informator_functions.dart';
import 'package:sscarapp/services/firebase/database/auth/database_auth.dart';
import 'package:sscarapp/widgets/custom_widgets.dart';
import '../../shared/app_constants.dart';

class LostPasswordPage extends StatefulWidget {
  const LostPasswordPage({Key? key}) : super(key: key);

  @override
  State<LostPasswordPage> createState() => _LostPasswordPageState();
}

class _LostPasswordPageState extends State<LostPasswordPage> {
  TextEditingController emailTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
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
                height: availableHeight,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          iconSize: 35,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.disabled_by_default_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 85,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50,),
                          const Text(
                            "Şifremi unuttum",
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
                            child: TextField(
                              controller: emailTextFieldController,
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              textInputAction: TextInputAction.send,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: "E-mail",
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
                                  child: TextButton( /// nico supply demo cc. token
                                    onPressed: () async {
                                      final emailInput = emailTextFieldController.text;
                                      if(!InformatorFunctions().isValidEmail(emailInput)){
                                        showSnackbar(context: context, color: Colors.red, message: "Lütfen geçerli bir e-mail adresi giriniz!");
                                      }
                                      final res = await DatabaseAuth().resetPasswordByEmail(email: emailInput);
                                      if (res) {
                                        showSnackbar(context: context, color: Colors.green, message: "Şifre sıfırlama linki için e-mailinizi (gereksiz/spam) kontrol ediniz");
                                      } else{
                                        showSnackbar(context: context, color: Colors.red, message: "Belirtilen e-mail sisteme kayıtlı değil gibi gözüküyor?");

                                      }
                                    },
                                    child: const Text(
                                      "Şifreyi sıfırla",
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

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );;
  }
}
