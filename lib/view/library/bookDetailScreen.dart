import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/helper/SmartCardHelper.dart';
import 'package:javacard_library/helper/helper.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/genre.dart';

class BookDetailScreen extends StatefulWidget {
  final List<Genre> genres;
  final Book book;

  const BookDetailScreen({super.key, required this.book, required this.genres});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  TextEditingController _borrowDay = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MƯỢN SÁCH"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              bookDetail(),
              SizedBox(height: 20),
              BookBorrow(),
            ],
          ),
        ));
  }

  Widget bookDetail() {
    return Row(children: [
      Container(
        clipBehavior: Clip.hardEdge,
        width: 225,
        height: 350,
        decoration: BoxDecoration(
          color: Color(0xfff3ecd4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.book.imgUrl.toString(),
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return const Center(child: CircularProgressIndicator());
          },
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      SizedBox(width: 30),
      Container(
        clipBehavior: Clip.hardEdge,
        width: MediaQuery.of(context).size.width - 355,
        height: 350,
        decoration: BoxDecoration(
          color: Color(0xfff3ecd4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: MediaQuery.of(context).size.width - 355,
              alignment: Alignment.center,
              child: Text(
                "${widget.book.name}",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff754820)),
              ),
            ),
            SizedBox(height: 10),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "Tác giả: ",
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
              TextSpan(
                  text: "${widget.book.author}",
                  style: TextStyle(fontSize: 15, color: Colors.black)),
            ])),
            SizedBox(height: 10),
            Text(widget.book.desc!,
                style: TextStyle(
                    fontSize: 15, color: Colors.black, letterSpacing: 1.2),
                maxLines: 10,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      )
    ]);
  }

  BookBorrow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text("Số ngày mượn: ", style: TextStyle(fontSize: 25)),
          SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: TextField(
              controller: _borrowDay,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          )
        ]),
        SizedBox(height: 40),
        ElevatedButton(
            onPressed: () async {
              if (_borrowDay.text.isNotEmpty) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                      title: Text("XÁC NHẬN"),
                      content: Text(
                          "Bạn có chắc chắn muốn mượn sách ${widget.book.name.toString()}?"),
                      actions: [
                        CupertinoDialogAction(
                          child: Text("ĐỒNG Ý"),
                          onPressed: () async {
                            bool result = await createBookBorrow(
                                int.parse(byteListToString(
                                    await SmartCardHelper.sendAPDUcommand(
                                        SmartCardHelper.getIdApduCommand))),
                                widget.book.id!,
                                int.parse(_borrowDay.text));
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Mượn sách thành công!'),
                                      backgroundColor: Colors.green));
                              _borrowDay.clear();
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Mượn sách thất bại!'),
                                      backgroundColor: Colors.red));
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text("HỦY"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vui lòng nhập số ngày mượn!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50), backgroundColor: Color(0xff754820)),
            child: Text("MƯỢN",
                style: TextStyle(fontSize: 18, color: Colors.white)))
      ],
    );
  }
}
