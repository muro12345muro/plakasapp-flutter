import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionPage4 extends StatefulWidget {
  const IntroductionPage4({Key? key}) : super(key: key);

  @override
  State<IntroductionPage4> createState() => _IntroductionPage4State();
}

class _IntroductionPage4State extends State<IntroductionPage4> {

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
              child: Container(
                child: Image.asset(
                  'assets/profile-sample-introduction.jpeg',
                  height: availableHeight-350,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: const Text(
                      "Plakanı kayıt ettikten sonra trafikteki profilini oluştur, ulaşılabilir ol! \n\n Profilini dilediğin gibi düzenleyebilirsin! İster numaranı gir tek tuşa aranabilir ol, fotoğraf ekle ve kendini trafikte belli et! Gizli kalmayi seviyorsan hiçbir kigisel bilgini girme, zaten özel mesaj ile gerekli durumlarda iletişime geçilecektir! \n \n Plakadan aracın satılık oldugunu görebilir ve direk kontakt kurabilirsin.",
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
