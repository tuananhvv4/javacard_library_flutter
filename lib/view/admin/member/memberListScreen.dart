import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/helper.dart';

import 'package:javacard_library/model/bookBorrows.dart';
import 'package:javacard_library/model/user.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  List<User> user = [];
  List<User> searchUser = [];

  late Future _future;

  TextEditingController searchController = TextEditingController();

  List<String> status = ["Khóa", "Hoạt động"];
  List<String> roles = ["user", "admin"];
  int selectedStatus = 1;
  String selectedRole = 'user';

  getUserList() async {
    user = await getUsers();
  }

  searchUserList(String query) {
    searchUser = user
        .where((element) =>
            element.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  editUserDialog(User user) {
    nameController.text = user.name!;
    addressController.text = user.address!;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Thông tin thành viên'),
              content: SizedBox(
                  height: 300,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tên: ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                            height: 50,
                            width: 220,
                            child: textFieldBox(
                                "", user.name!, nameController, false)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Địa chỉ: ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                            height: 50,
                            width: 220,
                            child: textFieldBox(
                                "", user.address!, addressController, false)),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Trạng thái: ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          height: 50,
                          width: 150,
                          child: DropdownButtonFormField(
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder()),
                            value: status[user.status!],
                            items: status
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = status.indexOf(value!);
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Role: ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          height: 50,
                          width: 150,
                          child: DropdownButtonFormField(
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder()),
                            value: user.role.toString(),
                            items: roles
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value as String;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ])),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () async {
                      bool result = await editUser(
                          user.id!,
                          nameController.text,
                          '',
                          addressController.text,
                          '',
                          selectedRole,
                          selectedStatus,
                          '');

                      if (result) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã sửa thành công!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const MemberListScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã xảy ra lỗi!',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('Lưu',
                        style: TextStyle(
                          color: Colors.white,
                        ))),
                OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Đóng',
                        style: TextStyle(
                          color: Colors.black,
                        ))),
              ],
            );
          });
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('TẤT CẢ THÀNH VIÊN'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              searchBar(),
              SizedBox(
                height: 20,
              ),
              searchUser.isEmpty ? allUserBox() : searchUserBox(),
            ],
          ),
        ));
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                searchUserList(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                suffixIcon: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.search)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  allUserBox() {
    return Container(
      height: MediaQuery.of(context).size.height - 170,
      child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.white70, width: 0.5),
                  columnWidths: const {
                    0: FixedColumnWidth(
                        100), // Cột STT với chiều rộng cố định là 50(),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(children: [
                      TableCell(
                          child: SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('STT',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      )),
                      TableCell(
                          child: SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('Thành viên',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      )),
                      TableCell(
                          child: SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('Thư viện',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      )),
                      TableCell(
                          child: SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('Thao tác',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ))
                    ]),
                    ...user.map((e) {
                      int countTotal = 0;
                      int countBorrowing = 0;
                      int countExpired = 0;

                      List<BookBorrows> bookBorrows = [];

                      Future getBooksList(int userID) async {
                        bookBorrows = await getBorrowBooksByID(userID);
                      }

                      print(e.avatar);

                      return TableRow(children: [
                        TableCell(
                            child: Container(
                          child: Center(
                              child: Text((user.indexOf(e) + 1).toString())),
                        )),
                        TableCell(
                            child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                          child: Row(
                            children: [
                              e.avatar != null
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: CircleAvatar(
                                        backgroundImage: Image.memory(
                                                Uint8List.fromList(
                                                    convertAvatarStringToListInt(
                                                        e.avatar!)))
                                            .image,
                                      ),
                                    )
                                  : const Icon(Icons.account_circle, size: 50),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    const TextSpan(
                                        text: "ID: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: e.id.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                  RichText(
                                      text: TextSpan(children: [
                                    const TextSpan(
                                        text: "Tên: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: e.name!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                  RichText(
                                      text: TextSpan(children: [
                                    const TextSpan(
                                        text: "Địa chỉ: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: e.address!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Trạng thái: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: e.status == 1
                                            ? "Hoạt động"
                                            : "Khóa",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: e.status == 1
                                                ? Colors.green
                                                : Colors.red))
                                  ])),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Role: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: e.role!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                ],
                              ),
                            ],
                          ),
                        )),
                        TableCell(
                            child: FutureBuilder(
                                future: getBooksList(e.id!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    for (var i in bookBorrows) {
                                      if (i.returnDate == null) {
                                        countBorrowing++;
                                      }
                                      if (i.isExpired()) {
                                        countExpired++;
                                      }
                                      countTotal++;
                                    }
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 10, 10, 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                text: "Tổng số sách đã mượn: ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            TextSpan(
                                                text: countTotal.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Colors.black))
                                          ])),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                text: "Số sách đang mượn: ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            TextSpan(
                                                text: countBorrowing.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Colors.black))
                                          ])),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RichText(
                                              text: TextSpan(children: [
                                            const TextSpan(
                                                text: "Số sách đang quá hạn: ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            TextSpan(
                                                text: countExpired.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: countExpired > 0
                                                        ? Colors.red
                                                        : Colors.black))
                                          ])),
                                        ],
                                      ),
                                    );
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                })),
                        TableCell(
                            child: Container(
                          height: 50,
                          child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    editUserDialog(e);
                                  },
                                  icon: const Icon(Icons.edit))),
                        ))
                      ]);
                    })
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  searchUserBox() {
    return Container(
      height: MediaQuery.of(context).size.height - 170,
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.white70, width: 0.5),
          columnWidths: const {
            0: FixedColumnWidth(100), // Cột STT với chiều rộng cố định là 50(),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(children: [
              TableCell(
                  child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('STT',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )),
              TableCell(
                  child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('Thành viên',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )),
              TableCell(
                  child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('Thư viện',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                ),
              )),
              TableCell(
                  child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('Thao tác',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ))
            ]),
            ...searchUser.map((e) {
              int countTotal = 0;
              int countBorrowing = 0;
              int countExpired = 0;

              List<BookBorrows> bookBorrows = [];

              Future getBooksList(int userID) async {
                bookBorrows = await getBorrowBooksByID(userID);
              }

              return TableRow(children: [
                TableCell(
                    child: Container(
                  child: Center(
                      child: Text((searchUser.indexOf(e) + 1).toString())),
                )),
                TableCell(
                    child: Container(
                  padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                            text: "ID: ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                            text: e.id.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black))
                      ])),
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                            text: "Tên: ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                            text: e.name!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black))
                      ])),
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                            text: "Địa chỉ: ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                            text: e.address!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black))
                      ])),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Trạng thái: ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                            text: e.status == 1 ? "Hoạt động" : "Khóa",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color:
                                    e.status == 1 ? Colors.green : Colors.red))
                      ])),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Role: ",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        TextSpan(
                            text: e.role!,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black))
                      ])),
                    ],
                  ),
                )),
                TableCell(
                    child: FutureBuilder(
                        future: getBooksList(e.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            for (var i in bookBorrows) {
                              if (i.returnDate == null) {
                                countBorrowing++;
                              }
                              if (i.isExpired()) {
                                countExpired++;
                              }
                              countTotal++;
                            }
                            return Container(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 10, 10, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Tổng số sách đã mượn: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: countTotal.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: "Số sách đang mượn: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: countBorrowing.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black))
                                  ])),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RichText(
                                      text: TextSpan(children: [
                                    const TextSpan(
                                        text: "Số sách đang quá hạn: ",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    TextSpan(
                                        text: countExpired.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: countExpired > 0
                                                ? Colors.red
                                                : Colors.black))
                                  ])),
                                ],
                              ),
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        })),
                TableCell(
                    child: Container(
                  height: 50,
                  child: Center(
                      child: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.edit))),
                ))
              ]);
            })
          ],
        ),
      ),
    );
  }

  dropDownStatusBox(
    int currentStatus,
  ) {
    return DropdownButton<String>(
      value: status[selectedStatus],
      items: status
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedStatus = status.indexOf(value!);
        });
        print(selectedStatus);
      },
    );
  }
}
