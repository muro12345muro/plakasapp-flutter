import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage3 extends StatefulWidget {
  const IntroductionPage3({Key? key}) : super(key: key);

  @override
  State<IntroductionPage3> createState() => _IntroductionPage3State();
}

class _IntroductionPage3State extends State<IntroductionPage3> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

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
            const SizedBox(height: 20,),
            Container(
              child: Image.asset(
                'assets/predefined-messages-sample-introduction.jpeg',
                height: availableHeight-400,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: const Text(
                      "Aracının başına bir şey gelse ne yapacaksın? Devir kötü; vurup kaçan mı dersin, aracına zarar vermek isteyen mi dersin maalesef bu durumlar gittikçe artmaya başladı. \n Bi araç otopark girişinin önüne mi park etmiş? Hatalı park mı var?\n\n Neyse ki artık bu durumların pratik bir yolu var!",
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
