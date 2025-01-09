import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:javacard_library/api/Api.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/SmartCardHelper.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/bookBorrows.dart';

class BookShelfScreen extends StatefulWidget {
  const BookShelfScreen({super.key});

  @override
  State<BookShelfScreen> createState() => _BookShelfScreenState();
}

class _BookShelfScreenState extends State<BookShelfScreen> {
  showDetailDialog(Book book, BookBorrows borrowData) {
    bool isExpired = borrowData.isExpired();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xfff3ecd4),
          content: Container(
            height: 300,
            width: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xfff3ecd4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CachedNetworkImage(
                          imageUrl: book.imgUrl.toString(),
                          errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                              ),
                          placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ))),
                  SizedBox(width: 30),
                  Container(
                    height: 200,
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          book.name.toString(),
                          style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const TextSpan(
                              text: 'Tác giả: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          TextSpan(
                              text: book.author.toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black))
                        ])),
                        const SizedBox(height: 10),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const TextSpan(
                              text: 'Ngày mượn: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          TextSpan(
                              text: getFormattedDateTime(borrowData.createdAt),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black))
                        ])),
                        const SizedBox(height: 10),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const TextSpan(
                              text: 'Hạn trả: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          TextSpan(
                              text: getFormattedDateTime(
                                  borrowData.getExpirationDate()),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                          TextSpan(
                              text: isExpired ? ' (Đã quá hạn)' : '',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red))
                        ])),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                ])
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              child: Text('Trả sách',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                      title: Text("XÁC NHẬN"),
                      content: Text(
                          "Bạn có chắc chắn muốn trả sách ${book.name.toString()}?"),
                      actions: [
                        CupertinoDialogAction(
                          child: Text("Trả sách"),
                          onPressed: () async {
                            bool result = await returnBook(
                                borrowData.userId!, borrowData.bookId!);
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Trả sách thành công!'),
                                      backgroundColor: Colors.green));
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Trả sách thất bại!'),
                                      backgroundColor: Colors.red));
                            }
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text("Hủy"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]),
                );
              },
            ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width - 250,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text("Tủ sách của tôi",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 30,
                ),
                bookList(),
              ]),
        ),
      ),
    );
  }

  Widget bookList() {
    List<BookBorrows> bookBorrows = [];

    Future getBooksList() async {
      bookBorrows = await getBorrowBooksByID(Api.user.id!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sách đang mượn',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
                future: getBooksList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    int total = 0;
                    for (var i in bookBorrows) {
                      if ((i.returnDate == null)) {
                        total++;
                      }
                    }
                    print(total);
                    if (total == 0) {
                      return const Center(
                        child: Text('Danh sách trống!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      );
                    }

                    return SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 20,
                        runSpacing: 20,
                        children: bookBorrows
                            .map((e) => bookItem(e))
                            .toList()
                            .cast<Widget>(),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget bookItem(BookBorrows item) {
    Book bookData = Book();
    Future getBookData() async {
      bookData = await getBookByID(item.bookId!);
    }

    bool isExpired = item.isExpired();
    if (item.returnDate != null) {
      return Container();
    }
    return FutureBuilder(
        future: getBookData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {
                  showDetailDialog(bookData, item);
                },
                child: Container(
                  alignment: Alignment.center,
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
                            imageUrl: bookData.imgUrl.toString(),
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
                        bookData.name.toString(),
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
                            text: bookData.author.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600))
                      ])),
                      const SizedBox(height: 5),
                      RichText(
                          text: TextSpan(children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        TextSpan(
                            text: 'Hạn trả: ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600)),
                        TextSpan(
                            text:
                                getFormattedDateTime(item.getExpirationDate()),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: isExpired
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isExpired
                                    ? Colors.red
                                    : Colors.grey.shade600))
                      ]))
                    ],
                  ),
                ),
              ),
            );
          }
          return Container(
            width: 170,
            height: 250,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
