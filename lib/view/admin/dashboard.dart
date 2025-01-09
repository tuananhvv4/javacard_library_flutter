import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/genre.dart';
import 'package:javacard_library/view/admin/book/bookBorrowsList.dart';
import 'package:javacard_library/view/admin/book/bookListScreen.dart';
import 'package:javacard_library/view/admin/member/memberListScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController bookNameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController genreController = TextEditingController();

  bool readOnly = false;

  List<Genre> genres = [];

  Future<void> getGenresList() async {
    genres = await getGenres();
  }

  addBookDialog(BuildContext context) {
    int dropdownValue = genres[0].id!;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => Center(
                    child: AlertDialog(
                      title: const Center(child: Text('Thêm sách')),
                      backgroundColor: const Color(0xfff3ecd4),
                      content: Container(
                        height: 350,
                        width: 500,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 200,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade100,
                              ),
                              child: CachedNetworkImage(
                                  imageUrl: imageUrlController.text,
                                  placeholder: (context, url) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Tên sách:",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 50,
                                        width: 220,
                                        child: textFieldBox("", '',
                                            bookNameController, readOnly))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Tên tác giả:",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 50,
                                        width: 220,
                                        child: textFieldBox("", '',
                                            authorController, readOnly)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Link ảnh bìa:",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 50,
                                        width: 220,
                                        child: textFieldBox("", '',
                                            imageUrlController, readOnly))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Mô tả:",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                        height: 100,
                                        width: 220,
                                        child: textFieldBox(
                                            "", '', descController, readOnly))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Thể loại:",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      width: 220,
                                      child: DropdownButton(
                                          isExpanded: true,
                                          items: genres
                                              .map((e) => DropdownMenuItem(
                                                  value: e.id,
                                                  child:
                                                      Text(e.name.toString())))
                                              .toList(),
                                          value: dropdownValue,
                                          onChanged: (value) {
                                            setState(() {
                                              dropdownValue = value!;
                                              print(value);
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(
                          child: const Text('Thêm',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () async {
                            bool result = await createBook(
                                bookNameController.text.trim(),
                                authorController.text.trim(),
                                descController.text.trim(),
                                imageUrlController.text.trim(),
                                dropdownValue);
                            if (result) {
                              Navigator.of(context).pop();
                              bookNameController.clear();
                              authorController.clear();
                              descController.clear();
                              imageUrlController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm sách thành công'),
                                      backgroundColor: Colors.green));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm sách thất bại'),
                                      backgroundColor: Colors.red));
                            }
                          },
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  showGenreListDialog(BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => Center(
                    child: AlertDialog(
                      title: const Center(child: Text('Danh sách thể loại')),
                      backgroundColor: const Color(0xfff3ecd4),
                      content: Container(
                          width: 400,
                          height: 300,
                          child: FutureBuilder(
                              future: getGenresList(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Table(
                                      columnWidths: const {
                                        0: FixedColumnWidth(50),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        const TableRow(children: [
                                          TableCell(
                                              child: Text(
                                            'STT',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          TableCell(
                                              child: Text(
                                            'Tên thể loại',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          TableCell(
                                              child: Text(
                                            'Thao tác',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                        ]),
                                        ...genres.map((e) =>
                                            TableRow(children: [
                                              TableCell(
                                                  child: Text(
                                                (genres.indexOf(e) + 1)
                                                    .toString(),
                                              )),
                                              TableCell(
                                                  child: Text(
                                                e.name.toString(),
                                              )),
                                              TableCell(
                                                  child: Row(
                                                children: [
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.edit),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        editGenreDialog(e);
                                                      }),
                                                  IconButton(
                                                      icon: const Icon(
                                                          Icons.delete),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        deleteGenreDialog(e);
                                                      }),
                                                ],
                                              ))
                                            ]))
                                      ]);
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              })),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(
                          child: const Text('Thêm thể loại',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () {
                            Navigator.of(context).pop();
                            addGenreDialog();
                          },
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  addGenreDialog() {
    genreController.clear();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => Center(
                    child: AlertDialog(
                      title: const Center(child: Text('Thêm thể loại')),
                      backgroundColor: const Color(0xfff3ecd4),
                      content: Container(
                        height: 100,
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Tên thể loại:",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: 50,
                                width: 220,
                                child: textFieldBox(
                                    "", '', genreController, readOnly)),
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(
                          child: const Text('Thêm',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () async {
                            bool result = await createGenre(
                                genreController.text.trim(),
                                convertToSlug(genreController.text.trim()));
                            if (result) {
                              getGenresList();
                              Navigator.of(context).pop();
                              genreController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm thể loại thành công'),
                                      backgroundColor: Colors.green));
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm thể loại thất bại'),
                                      backgroundColor: Colors.red));
                            }
                          },
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  editGenreDialog(Genre genre) {
    genreController.text = genre.name!;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => Center(
                    child: AlertDialog(
                      title: const Center(child: Text('Sửa thể loại')),
                      backgroundColor: const Color(0xfff3ecd4),
                      content: Container(
                        height: 100,
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Tên thể loại:",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height: 50,
                                width: 220,
                                child: textFieldBox(
                                    "", '', genreController, readOnly)),
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(
                          child: const Text('Lưu',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () async {
                            bool result = await editGenre(
                                genre.id!,
                                genreController.text.trim(),
                                convertToSlug(genreController.text.trim()));
                            if (result) {
                              getGenresList();
                              Navigator.of(context).pop();
                              genreController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Sửa thể loại thành công'),
                                      backgroundColor: Colors.green));
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Sửa thể loại thất bại'),
                                      backgroundColor: Colors.red));
                            }
                          },
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  deleteGenreDialog(Genre genre) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => Center(
                    child: AlertDialog(
                      title: const Center(child: Text('Xóa thể loại')),
                      backgroundColor: const Color(0xfff3ecd4),
                      content: Container(
                        height: 100,
                        width: 300,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Bạn có chắc chắn muốn xóa thể loại nây?",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(
                          child: const Text('Xóa',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          onPressed: () async {
                            bool result = await deleteGenre(genre.id!);
                            if (result) {
                              getGenresList();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Xóa thể loại thành công'),
                                      backgroundColor: Colors.green));
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Xóa thể loại thất bại'),
                                    backgroundColor: Colors.red));
                          },
                        ),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGenresList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width - 250,
            child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(
                  height: 50,
                ),
                const Text("DASHBOARD",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 50,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [userBox(), libraryBox(), toolBox()])
              ]),
            ),
          )),
    );
  }

  userBox() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("NGƯỜI DÙNG",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemberListScreen(),
                        ));
                  },
                  child: Container(
                    width: 200,
                    height: 100,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("Thành viên",
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  libraryBox() {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("THƯ VIỆN",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const BookListScreen();
                }));
              },
              child: Container(
                width: 200,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Text("Tất cả sách", style: TextStyle(fontSize: 20)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const BookBorrowsListScreen();
                }));
              },
              child: Container(
                width: 200,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("Sách đang được mượn",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)),
              ),
            ),
            InkWell(
              onTap: () {
                showGenreListDialog(context);
              },
              child: Container(
                width: 200,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("Thể loại", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget toolBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("CÔNG CỤ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  addBookDialog(context);
                },
                child: Container(
                  width: 200,
                  height: 100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Text("Thêm sách", style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
