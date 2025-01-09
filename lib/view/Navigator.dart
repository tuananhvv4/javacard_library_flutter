import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:javacard_library/helper/SmartCardHelper.dart';
import 'package:javacard_library/stateManager/getXState.dart';
import 'package:javacard_library/view/admin/dashboard.dart';
import 'package:javacard_library/view/connectScreen.dart';
import 'package:javacard_library/view/library/historyScreen.dart';
import 'package:javacard_library/view/library/libraryScreen.dart';
import 'package:javacard_library/view/library/bookshelf.dart';

import 'package:javacard_library/view/user/userInfoScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StateManager stateManager = Get.find();

  List<Widget> listWidget = [
    const LibraryScreen(),
    const BookShelfScreen(),
    const Historyscreen(),
    const UserinfoScreen(),
    const DashboardScreen(),
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // backgroundColor: Colors.white,
        body: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          color: const Color(0xffb78d6b),
          width: 250,
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 250,
                height: 250,
              ),
              customElevatedButton("Thư viện", Icons.menu_book, 0),
              customElevatedButton("Tủ sách", Icons.book, 1),
              customElevatedButton("Lich sử", Icons.history, 2),
              customElevatedButton("Người dùng", Icons.person, 3),
              Obx(() => Visibility(
                    child: customElevatedButton(
                        "ADMIN", Icons.admin_panel_settings, 4),
                    visible: stateManager.getIsAdmin(),
                  ))
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width - 250,
          color: Colors.black,
          child: listWidget[currentIndex],
        )
      ],
    ));
  }

  customElevatedButton(String text, IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentIndex = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                currentIndex == index ? Colors.white : const Color(0xff754820),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon,
                  color: currentIndex == index ? Colors.black : Colors.white),
              const SizedBox(
                width: 10,
              ),
              Text(text,
                  style: TextStyle(
                    color: currentIndex == index ? Colors.black : Colors.white,
                    fontSize: 17,
                  ))
            ],
          )),
    );
  }
}
