import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../shared/app_constants.dart';


class BottomNavigationTabBar extends StatelessWidget {
  const BottomNavigationTabBar({
    Key? key,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  final int index;
  final Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GNav(
          backgroundColor: Colors.grey.shade200,
          gap: 8,
          selectedIndex: 1,
          padding: EdgeInsets.all(16),
          tabBackgroundColor: AppConstants().secondaryColor,
          activeColor: Colors.white,
          onTabChange: onTap,
          tabs: [
            GButton(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.grey.shade600,
              text: "Bildirimler",
              padding: const EdgeInsets.all(10),
              iconActiveColor: AppConstants().primaryColor,
              onPressed: () {

              },
            ),
            GButton(
              icon: Icons.car_crash_outlined,
              iconColor: Colors.grey.shade600,
              text: "Plaka ara",
              padding: const EdgeInsets.all(10),
              iconActiveColor: AppConstants().primaryColor,
              onPressed: () {
              },
            ),
            GButton(
              icon: Icons.person_outline_outlined,
              iconColor: Colors.grey.shade600,
              text: "Profilim",
              padding: const EdgeInsets.all(10),
              iconActiveColor: AppConstants().primaryColor,
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}
