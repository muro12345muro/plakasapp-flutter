import 'package:flutter/material.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';
import 'package:sscarapp/services/firebase/database/user/user_database_service.dart';

/*List dataList = [
  {
    "name": "Sales",
    "icon": Icons.payment,
    "subMenu": [
      {"name": "Orders"},
      {"name": "Invoices"}
    ]
  },
  {
    "name": "Marketing",
    "icon": Icons.volume_up,
    "subMenu": [
      {
        "name": "Promotions",
        "subMenu": [
          {"name": "Catalog Price Rule"},
          {"name": "Cart Price Rules"}
        ]
      },
      {
        "name": "Communications",
        "subMenu": [
          {"name": "Newsletter Subscribers"}
        ]
      },
      {
        "name": "SEO & Search",
        "subMenu": [
          {"name": "Search Terms"},
          {"name": "Search Synonyms"}
        ]
      },
      {
        "name": "User Content",
        "subMenu": [
          {"name": "All Reviews"},
          {"name": "Pending Reviews"}
        ]
      }
    ]
  }
];*/

class PredefinedMessagesModellingList{
   final String? phoneNumber;

   PredefinedMessagesModellingList({ required this.phoneNumber });

   Future<List> getPredefinedMessagesList() async {


     final List predefinedMessagesList = [
       {
         "name": "Bilgilendirme",
         "icon": Icons.info_outline,
         "subMenu": [
           {"name": "Aracınıza yanlışlıkla çarptım, lütfen bana mesajla veya numaramdan ulaşın."},
           {"name": "Aracınızın başında şüpheli şahıs/şahıslar mevcut, bilginize."},
           {"name": "Aracınızı beğendim, satmayı düşünüyorsanız bana ulaşabilir misiniz?"},
           {"name": "Araç motoruna bir canlı girmiş olabilir, çalıştırmadan önce lütfen kontrol edin."},
           {"name": "Aracınıza polis ekipleri tarafından cezai işlem uygulanmaktadır, bilginize."},
           {"name": "Aracınızın park edildiği yerde işçiler çalışma yapacaktır. Lütfen aracınızı çekiniz."},
         ]
       },
       {
         "name": "Uyarı",
         "icon": Icons.warning_amber,
         "subMenu": [
           {"name": "Aracınız yanlış yere park edilmiş. Lütfen aracinizi bulunduğu yerden alınız."},
           {"name": "Aracınız yol geçişini engelliyor, lütfen aracınızı buradan çekiniz."},
           {"name": "Aracınızın kapı ve camlarını kontrol ediniz."},
           {"name": "Aracınızın lastikleri zarar görmüş gibi görünüyor, dikkat edin."},
           {"name": "Aracınızın iç veya dış ışıklandırma sistemi açık unutulmuş, bilginize."},
           {"name": "Seyir halindeki araç farlarınız açık değil, lütfen kontrol ediniz."},
           {"name": "Otoparkı yalnızca site sakinleri kullanabilmektedir, lütfen aracınızı buraya park etmeyin."},
         ]
       },
       {
         "name": "Yanıtlar",
         "icon": Icons.reply_all,
         "subMenu": [
           {"name": "Kusura bakmayın, hemen ilgileniyorum."},
           {"name": "Bilgilendirme için teşekkürler."},
           {"name": "Maalesef şu an müsait değilim."},
           {"name": "Beni ara, numaram: $phoneNumber"},
         ]
       }
     ];

     return predefinedMessagesList;
   }

}
class Menu {
  late final String name;
  late final IconData? icon;
  final List<Menu> subMenu = [];

  Menu({required this.name, this.icon});

  Menu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    if (json['subMenu'] != null) {
      subMenu.clear();
      json['subMenu'].forEach((v) {
        subMenu?.add(Menu.fromJson(v));
      });

    }
  }
}