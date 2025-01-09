import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/genre.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  TextEditingController bookNameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool readOnly = true;

  List<Book> books = [];
  List<Genre> genres = [];
  List<Book> searchResult = [];

  Future<void> getBookList() async {
    books = await getBooks();
  }

  Future<void> getGenresList() async {
    genres = await getGenres();
  }

  bookDetailDialog(BuildContext context, Book book) {
    bookNameController.text = book.name.toString();
    authorController.text = book.author.toString();
    imageUrlController.text = book.imgUrl.toString();
    descController.text = book.desc.toString();
    int dropdownValue = book.genreId!;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Center(
                    child: AlertDialog(
                      title: Center(child: Text('Chi tiết sách')),
                      backgroundColor: Color(0xfff3ecd4),
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
                                  imageUrl: book.imgUrl.toString(),
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
                                        child: textFieldBox(
                                            "",
                                            book.name.toString(),
                                            bookNameController,
                                            readOnly))
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
                                        child: textFieldBox(
                                            "",
                                            book.name.toString(),
                                            authorController,
                                            readOnly)),
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
                                        child: textFieldBox(
                                            "",
                                            book.name.toString(),
                                            imageUrlController,
                                            readOnly))
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
                                            "",
                                            book.name.toString(),
                                            descController,
                                            readOnly))
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
                                          onChanged: readOnly
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    dropdownValue =
                                                        value as int;
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: readOnly
                                    ? Colors.black
                                    : Colors.green.shade400),
                            onPressed: () async {
                              if (readOnly) {
                                setState(() {
                                  readOnly = false;
                                });
                              } else {
                                bool result = await editBook(
                                    book.id!,
                                    bookNameController.text,
                                    authorController.text,
                                    descController.text,
                                    imageUrlController.text,
                                    dropdownValue);

                                if (result) {
                                  readOnly = true;
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã sửa thành công!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => BookListScreen(),
                                    ),
                                  );
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
                              }
                            },
                            child: Text(readOnly ? 'Chỉnh sửa' : 'Lưu',
                                style: TextStyle(
                                  color: Colors.white,
                                ))),
                        OutlinedButton(
                            onPressed: () {
                              if (readOnly == false) {
                                setState(() {
                                  readOnly = true;
                                });
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text('Đóng',
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ],
                    ),
                  ));
        });
  }

  void searchBook(String query) async {
    searchResult = books
        .where((book) =>
            book.name!.toLowerCase().contains(query.toLowerCase()) ||
            book.author!.toLowerCase().contains(query.toLowerCase()))
        .toList();
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
        appBar: AppBar(
          centerTitle: true,
          title: Text('TẤT CẢ SÁCH'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              searchBar(),
              SizedBox(
                height: 20,
              ),
              searchController.text.isEmpty
                  ? bookList()
                  : searchList(searchResult),
            ],
          ),
        ));
  }

  Widget bookList() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: MediaQuery.of(context).size.height - 170,
        child: FutureBuilder(
            future: getBookList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 20,
                    runSpacing: 20,
                    children: books.map((book) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: InkWell(
                          onTap: () {
                            bookDetailDialog(context, book);
                          },
                          child: SizedBox(
                            width: 170,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 170,
                                  height: 250,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: CachedNetworkImage(
                                      imageUrl: book.imgUrl.toString(),
                                      placeholder: (context, url) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  book.name.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.person,
                                      size: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                      text: book.author.toString(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black))
                                ])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
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
                if (value.isNotEmpty) {
                  searchBook(value);
                  setState(() {});
                } else {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sách...',
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

  Widget searchList(List<Book> searchResult) {
    if (searchResult.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy sách',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: MediaQuery.of(context).size.height - 170,
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 20,
            runSpacing: 20,
            children: searchResult.map((book) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: () {
                    bookDetailDialog(context, book);
                  },
                  child: SizedBox(
                    width: 170,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 170,
                          height: 250,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                          ),
                          child: CachedNetworkImage(
                              imageUrl: book.imgUrl.toString(),
                              placeholder: (context, url) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book.name.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextSpan(
                              text: book.author.toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black))
                        ])),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}
