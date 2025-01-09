import 'package:flutter/material.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/bookBorrows.dart';
import 'package:javacard_library/model/user.dart';

class BookBorrowsListScreen extends StatefulWidget {
  const BookBorrowsListScreen({super.key});

  @override
  State<BookBorrowsListScreen> createState() => _BookBorrowsListScreenState();
}

class _BookBorrowsListScreenState extends State<BookBorrowsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('SÁCH ĐANG ĐƯỢC MƯỢN'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              borrowList()
            ],
          ),
        ));
  }

  Widget borrowList() {
    List<BookBorrows> bookBorrows = [];

    Future getBooksList() async {
      bookBorrows = await getBorrowBooks();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height - 150,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
                future: getBooksList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(
                                70), // Cột STT với chiều rộng cố định là 50
                            1: FlexColumnWidth(
                                1), // Cột Tên người dùng chiếm 1 phần
                            2: FlexColumnWidth(2), // Cột Tên sách chiếm 2 phần
                            3: FlexColumnWidth(1), // Cột Ngày mượn chiếm 1 phần
                            4: FlexColumnWidth(1), // Cột Hạn trả chiếm 1 phần
                            5: FlexColumnWidth(
                                1), // Cột tình trạng chiếm 1 phần
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Container(
                                alignment: Alignment.centerLeft,
                                height: 50,
                                child: const Text(
                                  'STT',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              const TableCell(
                                  child: Text(
                                'Tên người mượn/ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              const TableCell(
                                  child: Text(
                                'Tên sách',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              const TableCell(
                                  child: Text(
                                'Ngày mượn',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              const TableCell(
                                  child: Text(
                                'Hạn trả',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              const TableCell(
                                  child: Text(
                                'Tình trạng',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ]),
                            ...bookBorrows.map((item) => TableRow(children: [
                                  TableCell(
                                      child: Container(
                                    alignment: Alignment.centerLeft,
                                    height: 50,
                                    child: Text(
                                      (bookBorrows.indexOf(item) + 1)
                                          .toString(),
                                    ),
                                  )),
                                  TableCell(child: getUserName(item.userId!)),
                                  TableCell(
                                    child: getBookName(item.bookId!),
                                  ),
                                  TableCell(
                                      child: Text(getFormattedDateTime(
                                          item.createdAt))),
                                  TableCell(
                                      child: Text(getFormattedDateTime(
                                          item.getExpirationDate()!))),
                                  TableCell(
                                    child: Text(
                                        item.isExpired()
                                            ? 'Đã quá hạn trả'
                                            : 'Còn hạn',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: item.isExpired()
                                                ? Colors.red
                                                : Colors.green)),
                                  ),
                                ])),
                          ]),
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

  getBookName(int id) {
    Book bookData = Book();
    Future getBookData() async {
      bookData = await getBookByID(id);
    }

    return FutureBuilder(
      future: getBookData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Text(bookData.name!);
        }
        return Center(
          child: Container(
              height: 20,
              width: 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              )),
        );
      },
    );
  }

  getUserName(int userID) {
    User userData = User();
    Future getUserData() async {
      userData = await getUserByID(userID);
    }

    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Text(userData.name! + ' / ' + userID.toString());
        }
        return Center(
          child: Container(
              height: 20,
              width: 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              )),
        );
      },
    );
  }
}
