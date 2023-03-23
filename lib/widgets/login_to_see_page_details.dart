import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sscarapp/pages/auth/register_user_page.dart';
import 'package:sscarapp/shared/app_constants.dart';

import '../pages/auth/login_page.dart';

class LoginToSeePageDetails extends StatelessWidget {
  const LoginToSeePageDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppConstants().primaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal:15 ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: Container(
                    child: Lottie.network(
                      'https://assets7.lottiefiles.com/packages/lf20_0VDqUYk6MS.json',
                      onLoaded: (_){
                        print("asdasd");
                      }
                    ),
                  ),
                ),
                const Text(
                  "Bu alanı kullanabilmek için hesap oluşturmalısın",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: 120,
                  height: 34,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppConstants().secondaryColor
                  ),
                  child: TextButton(
                    onPressed: () async {
                      dynamic pushLogin = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_){
                                return const RegisterUserPage();
                              }
                          )
                      );
                    },
                    child: const Text(
                      "Kayıt Ol",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,),
                    ),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}
