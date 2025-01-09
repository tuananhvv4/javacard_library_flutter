import 'package:flutter/material.dart';
import 'package:javacard_library/api/Api.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/bookBorrows.dart';

class Historyscreen extends StatefulWidget {
  const Historyscreen({super.key});

  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
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
                const Text("Lịch sử mượn sách",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                  height: 30,
                ),
                historyList()
              ]),
        ),
      ),
    );
  }

  Widget historyList() {
    List<BookBorrows> bookBorrows = [];

    Future getBooksList() async {
      bookBorrows = await getBorrowBooksByID(Api.user.id!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height - 200,
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
                            1: FlexColumnWidth(2), // Cột Tên sách chiếm 2 phần
                            2: FlexColumnWidth(1), // Cột Ngày mượn chiếm 1 phần
                            3: FlexColumnWidth(1), // Cột Hạn trả chiếm 1 phần
                            4: FlexColumnWidth(1), // Cột Ngày trả chiếm 1 phần
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
                                  child: const Text(
                                'Ngày trả',
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
                                      child: Text(getFormattedDateTime(
                                          item.returnDate))),
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
}
