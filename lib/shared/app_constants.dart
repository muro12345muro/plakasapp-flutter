import 'dart:ui';
import 'package:flutter/material.dart';

class AppConstants{
  static String appId = "";
  static String apiKey = "";
  static String messagingSenderId = "";
  static String projectId = "";
  static int initialTokenCount = 15;
  static int dailyFreeTokenCount = 20;
  static int watchAdsEarnToken = 1;
  static int substractTokenPlateSearched = 1;
  final primaryColor = const Color(0xffEEBC51);
  final secondaryColor = const Color(0xff263238);
  final errorInputBorderColor = const Color(0xffb73139);
  final approvedInputBorderColor = const Color(0xff4a790d);
  final enabledInputBorderColor = const Color(0xff516a51);
  final pppic = "https://static.wikia.nocookie.net/yildizsavaslari/images/6/6f/Anakin_Skywalker_RotS.png/revision/latest?cb=20180522061709&path-prefix=tr";
  static String  successLoginText = "Giriş başarılı!";
  static String  successRegisterText = "Kayıt başarılı!";
  static String  errorRegisterPasswordsMatchText = "Şifreler uyuşmuyor!";
  static String  errorRegisterEmailAlreadyExistText = "Bu E-Mail zaten kullanılıyor!";
  static String  errorRegisterPasswordTooShortText = "Şifre 6 karakterden az olamaz!";
  static String  errorSystemErrorText = "Sistem hatası meyada geldi!";
  static String  errorRegisterAgreementCheckboxText = "Lütfen sözleşmeyi kabul edin!";
  static String  privacyAgreementURL = "https://www.mubayazilim.com/sscar/gizlilik.html";
  static String  conditionsAgreementURL = "https://www.mubayazilim.com/sscar/sartlar.html";
}

const premiumEntitleId = "100_token";
const appleApiKey = "appl_MMzzKFTLFRiNPGFyuwqFXrVMbRq";
const googleApiKey = "goog_OFIJCAxIjOKjzJRYrbuOyvOqTei";
const amazonApiKey = "premiumAcc";

const cityByPlateCodeDic = {"01": "Adana", "28": "Giresun",
  "55": "Samsun", "02": "Adıyaman",
  "29": "Gümüşhane", "56": "Siirt",
  "03": "Afyonkarahisar", "30": "Hakkari",
  "57": "Sinop", "04": "Ağrı",
  "31": "Hatay", "58": "Sivas",
  "05": "Amasya",  "32": "Isparta",
  "59":"Tekirdağ", "06": "Ankara",
  "33": "Mersin", "60": "Tokat",
  "07":"Antalya", "34": "İstanbul",
  "08": "Artvin", "35": "İzmir",
  "09": "Aydın", "36": "Kars",
  "63": "Şanlıurfa", "62": "Tunceli",
  "10": "Balıkesir", "37": "Kastamonu",
  "64": "Uşak", "61": "Trabzon",
  "11": "Bilecik",   "38": "Kayseri", "65": "Van",
  "12": "Bingöl", "39": "Kırklareli", "66": "Yozgat",
  "13": "Bitlis", "40": "Kırşehir", "67": "Zonguldak",
  "14": "Bolu", "41": "Kocaeli", "68": "Aksaray",
  "15": "Burdur", "42": "Konya", "69": "Bayburt",
  "16": "Bursa", "43": "Kütahya", "70": "Karaman",
  "17": "Çanakkale",   "44": "Malatya", "71": "Kırıkkale",
  "18": "Çankırı" ,  "45": "Manisa", "72": "Batman",
  "19": "Çorum", "46": "Kahramanmaraş", "73": "Şırnak",
  "20": "Denizli", "47": "Mardin", "74": "Bartın",
  "21": "Diyarbakır", "48": "Muğla", "75": "Ardahan",
  "22": "Edirne", "49": "Muş", "76": "Iğdır",
  "23": "Elazığ", "50": "Nevşehir", "77": "Yalova",
  "24": "Erzincan", "51": "Niğde", "78": "Karabük",
  "25": "Erzurum", "52": "Ordu", "79": "Kilis",
  "26": "Eskişehir" , "53": "Rize", "80": "Osmaniye",
  "27": "Gaziantep", "54":  "Sakarya", "81": "Düzce"};

const List<String> speacialUsersUids = [
  "LPouPC2SVCZKmkQsYUVx7hqfC4B3",
  "swYGcsJqvLOgaeVVLVdJP22sS1C3",
  "C2vrMAOT23cRXmN4IGbNFUg1nYC2",
];