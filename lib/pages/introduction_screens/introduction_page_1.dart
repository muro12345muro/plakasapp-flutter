import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage1 extends StatefulWidget {
  const IntroductionPage1({Key? key}) : super(key: key);

  @override
  State<IntroductionPage1> createState() => _IntroductionPage1State();
}

class _IntroductionPage1State extends State<IntroductionPage1> {

  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: const Text(
                    "ssCar'a Hoş Geldin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: Container(
                height: availableHeight-400,
                child: Lottie.network(
                    'https://assets7.lottiefiles.com/packages/lf20_If2U2O.json',
                    onLoaded: (_){
                      print("asdasd");
                    }
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: const Text(
                      "Artık arabanın önüne telefon numarası yazma devri bitti! ssCar ile yalnızca plaka numarandan aracın hakkında bilgilendirme alabileceksin. \n\n Trafiği daha güvenli ve sosyal hale getirmenin en güzel yolu!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
