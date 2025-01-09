import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:javacard_library/api/Api.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/SmartCardHelper.dart';
import 'package:javacard_library/helper/helper.dart';

import 'package:javacard_library/view/connectScreen.dart';

class UserinfoScreen extends StatefulWidget {
  const UserinfoScreen({super.key});

  @override
  State<UserinfoScreen> createState() => _UserinfoScreenState();
}

class _UserinfoScreenState extends State<UserinfoScreen> {
  String? id;
  String? name;
  String? address;

  bool isHaveAvatar = false;
  bool readOnly = true;

  File? selectedImage;
  List<int>? avatar;

  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  saveData() {
    try {
      String name = nameController.text.toString();
      String address = addressController.text.toString();

      SmartCardHelper.sendAPDUcommandAndData(
          SmartCardHelper.setNameApduCommand, convertStringToByteList(name));
      SmartCardHelper.sendAPDUcommandAndData(
          SmartCardHelper.setAddressApduCommand,
          convertStringToByteList(address));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cập nhật thông tin thành công"),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cập nhật thông tin thất bại"),
          backgroundColor: Colors.red));
    }
  }

  loadData() async {
    id = byteListToString(await SmartCardHelper.sendAPDUcommand(
        SmartCardHelper.getIdApduCommand));
    name = byteListToString(await SmartCardHelper.sendAPDUcommand(
        SmartCardHelper.getNameApduCommand));
    address = byteListToString(await SmartCardHelper.sendAPDUcommand(
        SmartCardHelper.getAddressApduCommand));

    idController.text = id!;
    nameController.text = name!;
    addressController.text = address!;

    try {
      avatar = await SmartCardHelper.sendAPDUcommand(
          SmartCardHelper.getAvatarApduCommand);

      if (avatar!.length > 0) {
        setState(() {
          log('có avatar');
          isHaveAvatar = true;
        });
      }
    } catch (e) {
      log("lỗi");

      log(e.toString());
    }

    setState(() {});
  }

  changeAvatar() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        final Uint8List byteList =
            await File(result.files.single.path!).readAsBytes();
        avatar = byteList;
        print(avatar.toString());

        if (await SmartCardHelper.sendAPDUcommandAndData(
            SmartCardHelper.setAvatarApduCommand, avatar!)) {
          setState(() {
            isHaveAvatar = true;
          });
        }
      }
      editUser(Api.user.id!, '', '', '', avatar.toString(), '', 1, '');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cập nhật ảnh đại diện thành công"),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cập nhật ảnh đại diện thất bại"),
          backgroundColor: Colors.red));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: 50,
        ),
        Text("Thông tin tài khoản",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            )),
        SizedBox(
          height: 50,
        ),
        GestureDetector(
            onTap: () async {
              changeAvatar();
            },
            child: Stack(children: [
              isHaveAvatar
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          Image.memory(Uint8List.fromList(avatar!)).image,
                    )
                  : const Icon(
                      Icons.account_circle,
                      size: 100,
                    ),
              const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                  ))
            ])),
        Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 500,
            decoration: BoxDecoration(),
            child: Column(children: [
              textFieldBox("ID", id ?? "", idController, true),
              textFieldBox("Tên", name ?? "", nameController, readOnly),
              textFieldBox(
                  "Địa chỉ", address ?? "", addressController, readOnly),
            ])),
        ElevatedButton(
          onPressed: () {
            if (readOnly) {
              setState(() {
                readOnly = false;
              });
            } else {
              saveData();
              setState(() {
                readOnly = true;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 211, 119, 38),
          ),
          child: Text(
            readOnly ? "Sửa thông tin" : "Lưu",
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              SmartCardHelper.disconnect();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConnectScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.white),
            ))
      ]),
    ));
  }
}
