import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/pages/introduction_screens/introduction_page_1.dart';
import 'package:sscarapp/pages/introduction_screens/introduction_page_2.dart';

import '../../helper/request_functions.dart';
import '../../shared/app_constants.dart';
import 'introduction_page_3.dart';
import 'introduction_page_4.dart';

class InitialIntroductionPage extends StatefulWidget {
  const InitialIntroductionPage({Key? key}) : super(key: key);

  @override
  State<InitialIntroductionPage> createState() => _InitialIntroductionPageState();
}

class _InitialIntroductionPageState extends State<InitialIntroductionPage> {
  final PageController _pageViewController = PageController();

  final listOfIntroPages = [
    const IntroductionPage1(),
    const IntroductionPage2(),
    const IntroductionPage3(),
    const IntroductionPage4(),
  ];

  int currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageViewController,
                physics: currIndex == 3 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                onPageChanged: (int indx) {
                  setState(() {});
                  currIndex = indx;
                  log("32f23f $indx");
                },
                itemBuilder: (BuildContext context, int index) {
                  return listOfIntroPages[index];
                },
              ),
            ),
            Container(
              //alignment: const Alignment(0, 0.80),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  currIndex != 0 ?
                  GestureDetector(
                    onTap: (){
                      _pageViewController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                    },
                    child: Text(
                      "Önceki",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppConstants().secondaryColor
                      ),
                    ),
                  ) : Container(width: 40.5,),
                  SmoothPageIndicator(
                    controller: _pageViewController,
                    count: 4,
                    effect: JumpingDotEffect(
                      dotHeight: 16,
                      dotWidth: 16,
                      jumpScale: 0.7,
                      verticalOffset: 15,
                      activeDotColor: AppConstants().primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if( currIndex != 3){
                        _pageViewController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                      }else{
                        UserDefaultsFunctions.saveIntroductionViewed();
                        Navigator.pop(context);
                        RequestFunctions().requestNotificationsPermission();
                      }
                    },
                    child: Text(
                      currIndex != 3 ? "Sonraki" : " Bitti     ",
                      style: TextStyle(
                          color: AppConstants().secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
