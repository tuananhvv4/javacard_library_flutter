import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:javacard_library/api/apiServices.dart';
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/genre.dart';
import 'package:javacard_library/view/library/bookDetailScreen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> bookList = [];
  List<Genre> genres = [];
  List<Book> searchResult = [];
  late Future future;
  int selectedGenre = 0;

  TextEditingController searchController = TextEditingController();

  Future fetchData() async {
    genres = await getGenres();
    bookList = await getBooks();
  }

  void searchBook(String query) async {
    searchResult = bookList
        .where((book) =>
            book.name!.toLowerCase().contains(query.toLowerCase()) ||
            book.author!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: MediaQuery.of(context).size.width - 250,
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text("Thư viện sách",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    searchBar(),
                    const SizedBox(
                      height: 20,
                    ),
                    genresItem(),
                    const SizedBox(
                      height: 20,
                    ),
                    searchController.text.isNotEmpty
                        ? gridViewBookListBySearch(searchResult)
                        : selectedGenre != 0
                            ? gridViewBookListByGenre()
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 280,
                                child: SingleChildScrollView(
                                    child: Column(children: [
                                  ...genres.map((bookCategory) {
                                    return bookCategoryList(bookCategory);
                                  }).toList()
                                ]))),
                  ],
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
    );
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
                  selectedGenre = 0;
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
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bookCategoryList(Genre genre) {
    List<Book> books = [];
    Future getBooksData() async {
      books = await getBooksByGenre(genre.id!);
    }

    late Future _getBooksFuture = getBooksData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            genre.name.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
                future: _getBooksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookDetailScreen(
                                            book: book,
                                            genres: genres,
                                          )));
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
                                              child:
                                                  CircularProgressIndicator());
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
                      },
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

  Widget genresItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final category = genres[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: InkWell(
                onTap: () {
                  if (selectedGenre == category.id) {
                    setState(() {
                      selectedGenre = 0;
                    });
                  } else {
                    setState(() {
                      searchController.clear();
                      selectedGenre = category.id!;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedGenre == category.id
                        ? Colors.black
                        : const Color(0xff754820),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    genres[index].name.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget gridViewBookListByGenre() {
    List<Book> books = [];
    Future getBooksData() async {
      books = await getBooksByGenre(selectedGenre);
    }

    late Future getBooksFuture = getBooksData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      width: MediaQuery.of(context).size.width - 250,
      height: MediaQuery.of(context).size.height - 280,
      child: FutureBuilder(
          future: getBooksFuture,
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookDetailScreen(
                                        genres: genres,
                                        book: book,
                                      )));
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
          }),
    );
  }

  Widget gridViewBookListBySearch(List<Book> books) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        width: MediaQuery.of(context).size.width - 250,
        height: MediaQuery.of(context).size.height - 280,
        child: books.isNotEmpty
            ? SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 20,
                  runSpacing: 20,
                  children: books.map((book) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookDetailScreen(
                                        book: book,
                                        genres: genres,
                                      )));
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
              )
            : const Center(
                child: Text('Không có kết quả nào!'),
              ));
  }
}
