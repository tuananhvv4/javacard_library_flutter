import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:javacard_library/helper/customScrollHelper.dart';
import 'package:javacard_library/view/connectScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        scrollBehavior: CustomScrollHelper(),
        debugShowCheckedModeBanner: false,
        title: 'Library',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 226, 201),
          useMaterial3: true,
          fontFamily: "Faustina",
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xffb78d6b),
          ),
        ),
        home: const ConnectScreen());
  }
}
