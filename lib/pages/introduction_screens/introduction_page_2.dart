import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage2 extends StatefulWidget {
  const IntroductionPage2({Key? key}) : super(key: key);

  @override
  State<IntroductionPage2> createState() => _IntroductionPage2State();
}

class _IntroductionPage2State extends State<IntroductionPage2> {

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
            SizedBox(height: 20),
            Container(
              child: Image.asset(
                'assets/interactions-driver-introduction.jpeg',
                height: availableHeight - 350,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: const Text(
                      "Trafikte bir sürücünün hareketini beğendin mi? Yayaya saygili bir sürücü mü yoksa makas atarak mı gidiyor? Plakasından kişiye ulaş ve ifadeni yolla.  \n \n Trafikte tepkisiz kalma, trafik candir!",
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
