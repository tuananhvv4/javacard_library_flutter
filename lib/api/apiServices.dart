import 'dart:convert'; // Để xử lý JSON
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:javacard_library/model/book.dart';
import 'package:javacard_library/model/bookBorrows.dart';
import 'package:javacard_library/model/genre.dart';
import 'package:javacard_library/model/user.dart';

Future<int> getLastestUserID() async {
  const apiUrl = 'https://nguyenanh.fun/public/api/get-lastest-id'; // URL API
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));
    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      return result['data'];
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return 0;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return 0;
  }
}

Future<bool> createUser(String name, String pin, String address, String img,
    String publicKey) async {
  const apiUrl = 'https://nguyenanh.fun/public/api/create-user'; // URL API

  // Tham số cần gửi
  final requestData = {
    'name': name,
    'pin': pin,
    'address': address,
    'avatar': img,
    'role': 'user',
    'public_key': publicKey,
  };

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      print('Tạo user thành công: $requestData');
      return true;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<bool> editUser(int userID, String name, String pin, String address,
    String avatar, String role, int status, String publicKey) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/user/${userID}/edit'; // URL API

  // Tham số cần gửi
  final requestData = {
    'name': name,
    'pin': pin,
    'address': address,
    'avatar': avatar,
    'role': role,
    'status': status,
    'public_key': publicKey,
  };

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      if (result['status'] == true) {
        print(requestData);
        print('Sửa thông tin người dùng thành công: $result');
        return true;
      }
      print('Lỗi khi sửa thông tin người dùng!');
      return false;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<List<User>> getUsers() async {
  const apiUrl = 'https://nguyenanh.fun/public/api/get-all-users'; // URL API
  List<User> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(User.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<User> getUserByID(int id) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/user/' + id.toString(); // URL API

  var response = await http.get(Uri.parse(apiUrl));
  User user;
  try {
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      user = User.fromJson(result['data'][0]);
      return user;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return User(
          id: 0,
          name: '',
          address: '',
          status: 0,
          avatar: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          role: '');
    }
  } catch (error) {
    print('Đã xảy ra lỗi khi lấy thông tin người dùng: $error');
    return User(
        id: 0,
        name: '',
        address: '',
        status: 0,
        avatar: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        role: '');
  }
}

Future<bool> createBook(
    String name, String author, String desc, String imgUrl, int genre) async {
  const apiUrl = 'https://nguyenanh.fun/public/api/create-book'; // URL API

  // Tham số cần gửi
  final requestData = {
    'name': name,
    'author': author,
    'desc': desc,
    'img_url': imgUrl,
    'genre_id': genre
  };

  print(requestData);

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      print('Tạo sách thành công: $result');
      return true;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<bool> editBook(int id, String name, String author, String desc,
    String imgUrl, int genre_id) async {
  String apiUrl = 'https://nguyenanh.fun/public/api/book/' +
      id.toString() +
      '/edit'; // URL API

  // Tham số cần gửi
  final requestData = {
    'name': name,
    'author': author,
    'desc': desc,
    'img_url': imgUrl,
    'genre_id': genre_id
  };

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      print('Sửa sách thành công: $result');
      return true;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<Book> getBookByID(int id) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/book/' + id.toString(); // URL API

  var response = await http.get(Uri.parse(apiUrl));
  Book book;
  try {
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      book = Book.fromJson(result['data'][0]);
      return book;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return Book(
          id: 0, name: '', author: '', desc: '', imgUrl: '', genreId: 0);
    }
  } catch (error) {
    print('Đã xảy ra lỗi khi lấy thông tin sách: $error');
    return Book(id: 0, name: '', author: '', desc: '', imgUrl: '', genreId: 0);
  }
}

Future<List<Book>> getBooks() async {
  const apiUrl = 'https://nguyenanh.fun/public/api/get-all-books'; // URL API
  List<Book> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(Book.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<List<Book>> getBooksByGenre(int id) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/genre/' + id.toString(); // URL API
  List<Book> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(Book.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<List<Genre>> getGenres() async {
  const apiUrl = 'https://nguyenanh.fun/public/api/genre'; // URL API
  List<Genre> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(Genre.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<bool> createGenre(String name, String shortName) async {
  const apiUrl = 'https://nguyenanh.fun/public/api/create-genre'; // URL API

  // Tham số cần gửi
  final requestData = {'name': name, 'short_name': shortName};

  print(requestData);

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      print('Tạo thể loại thành công: $result');
      return true;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<bool> editGenre(int genreId, String name, String shortName) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/genre/${genreId}/edit'; // URL API

  // Tham số cần gửi
  final requestData = {'name': name, 'short_name': shortName};

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      if (result['status'] == true) {
        print('Sửa thể loại thành công: $requestData');
        return true;
      }
      print('Lỗi khi sửa thể loại!');
      return false;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<bool> deleteGenre(int id) async {
  String apiUrl = 'https://nguyenanh.fun/public/api/genre/' +
      id.toString() +
      '/delete'; // URL API

  try {
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('Xóa thể loại thành công: $result');
      return true;
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<bool> createBookBorrow(int userID, int bookID, int duration) async {
  const apiUrl = 'https://nguyenanh.fun/public/api/add-borrow'; // URL API

  // Tham số cần gửi
  final requestData = {
    'user_id': userID,
    'book_id': bookID,
    'duration': duration,
  };

  try {
    // Gửi yêu cầu POST
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json', // Định dạng JSON
      },
      body: jsonEncode(requestData), // Gửi tham số dưới dạng JSON
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      if (result['status'] == true) {
        print('Mượn sách thành công: $requestData');
        return true;
      }
      print(result['message']);
      return false;
    } else {
      final result = jsonDecode(response.body);
      print(result['msg']);
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text(result['msg']),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1)));
      return false;
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return false;
  }
}

Future<List<BookBorrows>> getBorrowBooksByID(int id) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/history/' + id.toString(); // URL API
  List<BookBorrows> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(BookBorrows.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<List<BookBorrows>> getBorrowBooks() async {
  String apiUrl = 'https://nguyenanh.fun/public/api/borrowed-books'; // URL API
  List<BookBorrows> data = [];
  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      for (var item in result['data']) {
        data.add(BookBorrows.fromJson(item));
      }
    }

    return data;
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
    return data;
  }
}

Future<bool> returnBook(int userID, int bookID) async {
  String apiUrl =
      'https://nguyenanh.fun/public/api/user/${userID}/return/${bookID}'; // URL API
  var response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);

    if (result['status'] == true) {
      print('Trả sách thành công!');
      return true;
    } else {
      print('Trả sách thất bại!');
      return false;
    }
  } else {
    print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
    return false;
  }
}
