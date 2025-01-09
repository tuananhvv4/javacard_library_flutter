import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pcsc/flutter_pcsc.dart';
import 'package:javacard_library/api/Api.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/SmartCardHelper.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/user.dart';
import 'package:javacard_library/stateManager/getXState.dart';

import 'package:javacard_library/view/Navigator.dart';
import 'package:get/get.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final StateManager getXState = Get.put(StateManager());

  bool isConnected = false;
  bool isNewCard = true;
  int countFail = 3;
  /* establish PCSC context */

  // text controller

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showAddInfoDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text("Nhập thông tin"),
          ),
          contentPadding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tên:',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Nhập tên",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Địa chỉ:',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        hintText: "Nhập địa chỉ",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mật khẩu:',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Nhập mật khẩu",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              addressController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Vui lòng nhập đầy đủ thông tin!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            saveData();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Lưu",
                            style: TextStyle(color: Colors.white, fontSize: 15),
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
      },
    );
  }

  saveData() async {
    int lastId = await getLastestUserID();

    if (lastId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy ID người dùng!'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        int id = lastId + 1;
        String name = nameController.text.toString();
        String address = addressController.text.toString();
        String password = passwordController.text.toString();

        // gửi thông tin đến thẻ
        SmartCardHelper.sendAPDUcommandAndData(
            SmartCardHelper.setPasswordApduCommand,
            convertStringToByteList(password));
        SmartCardHelper.sendAPDUcommandAndData(SmartCardHelper.setIdApduCommand,
            convertStringToByteList(id.toString()));
        SmartCardHelper.sendAPDUcommandAndData(
            SmartCardHelper.setNameApduCommand, convertStringToByteList(name));
        SmartCardHelper.sendAPDUcommandAndData(
            SmartCardHelper.setAddressApduCommand,
            convertStringToByteList(address));
        SmartCardHelper.sendAPDUcommandAndData(
            SmartCardHelper.setStatusApduCommand, convertStringToByteList('1'));

        // lưu thông tin người dùng lên CSDL
        bool result = await createUser(name, password, address, '');
        if (!result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể lưu thông tin người dùng!'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          Api.user = await getUserByID(id);

          bool isAdmin = checkIsAdmin(await Api.getUser());

          getXState.setIsAdmin(isAdmin);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false);
        }
      } catch (e) {
        print(e.toString());
      }
    }
  }

  checkCard() async {
    var response =
        await SmartCardHelper.sendAPDUcommand(SmartCardHelper.getIdApduCommand);
    if (response.isNotEmpty) {
      showLoginDialog();
    } else {
      showAddInfoDialog();
    }
  }

  void showLoginDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 255, 218, 185),
              title: const Center(
                child: Text("Đăng nhập"),
              ),
              contentPadding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: TextField(
                          enabled: countFail > 0 ? true : false,
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: 'Nhập mật khẩu',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        countFail > 0
                            ? "Thẻ sẽ bị khóa sau ${countFail} lần nhập sai!"
                            : "Thẻ đã bị khóa! Liên hệ ADMIN để được hỗ trợ!",
                        style: TextStyle(
                          color: countFail > 0 ? Colors.orange : Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: countFail > 0
                        ? () async {
                            String password = passwordController.text.trim();
                            if (password.isNotEmpty) {
                              String responsePassword = byteListToString(
                                await SmartCardHelper.sendAPDUcommand(
                                  SmartCardHelper.getPasswordApduCommand,
                                ),
                              );
                              print(responsePassword);

                              if (countFail == 0) {
                                // Khóa thẻ
                                await SmartCardHelper.sendAPDUcommandAndData(
                                    SmartCardHelper.setStatusApduCommand,
                                    convertStringToByteList('0'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thẻ đã bị khóa!'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                Navigator.pop(context);
                              } else if (byteListToString(
                                      await SmartCardHelper.sendAPDUcommand(
                                          SmartCardHelper
                                              .getStatusApdApduCommand)) ==
                                  "0") {
                                setState(() {
                                  countFail = 0;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Thẻ đã bị khóa!'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (responsePassword == password) {
                                //Kiểm tra có phải admin không
                                int id = int.parse(byteListToString(
                                    await SmartCardHelper.sendAPDUcommand(
                                        SmartCardHelper.getIdApduCommand)));
                                Api.user = await getUserByID(id);
                                bool isAdmin =
                                    checkIsAdmin(await Api.getUser());
                                getXState.setIsAdmin(isAdmin);

                                // Đăng nhập thành công
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đăng nhập thành công!'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                // Sai mật khẩu
                                setState(() {
                                  countFail--;
                                  passwordController.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mật khẩu không đúng!'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        : () {
                            setState(() {
                              countFail = 3;
                              passwordController.clear();
                            });
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: countFail > 0
                          ? const Color.fromARGB(255, 211, 119, 38)
                          : Colors.red,
                    ),
                    child: Text(
                      countFail > 0 ? "Đăng nhập" : "Đóng",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("K Ế T    N Ố I"),
      ),
      // backgroundColor: const Color.fromARGB(255, 251, 180, 119),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 211, 119, 38),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                "THẺ THƯ VIỆN",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Google Sans"),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            ElevatedButton(
              onPressed: isConnected
                  ? () async {
                      SmartCardHelper.disconnect();
                      setState(() {
                        isConnected = false;
                      });
                    }
                  : () async {
                      if (await SmartCardHelper.connectApplet(context)) {
                        setState(() {
                          isConnected = true;
                        });
                        checkCard();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? Colors.red
                    : const Color.fromARGB(255, 211, 119, 38),
              ),
              child: isConnected
                  ? const Text(
                      "Ngắt kết nối",
                      style: TextStyle(color: Colors.white),
                    )
                  : const Text("Kết nối thẻ",
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
