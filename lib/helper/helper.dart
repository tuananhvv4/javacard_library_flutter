import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:javacard_library/model/user.dart';

List<int> convertStringToByteList(String input) {
  // Chuyển mỗi ký tự thành mã ASCII và lưu vào danh sách
  return input.codeUnits;
}

List<int> intToByteList(
  int number,
) {
  // Tạo ByteData để lưu trữ số với số byte được chỉ định
  ByteData byteData = ByteData(2);

  // Ghi số vào ByteData (big-endian)
  for (int i = 0; i < 2; i++) {
    int shift = (2 - 1 - i) * 8;
    byteData.setUint8(i, (number >> shift) & 0xFF);
  }

  // Chuyển ByteData thành danh sách byte
  return byteData.buffer.asUint8List();
}

String byteListToString(List<int> byteList) {
  return String.fromCharCodes(byteList);
}

String stringToHex(String input) {
  // Chuyển đổi từng ký tự trong chuỗi thành mã hex
  return input.runes.map((int charCode) {
    return charCode
        .toRadixString(16)
        .padLeft(2, '0'); // Chuyển sang hex và đảm bảo đủ 2 ký tự
  }).join(); // Nối các mã hex thành một chuỗi
}

String decToHex(int decimal) {
  return decimal.toRadixString(16).toUpperCase().padLeft(4, '0');
}

String convertToSlug(String input) {
  // Bảng chuyển đổi các ký tự có dấu sang không dấu
  const Map<String, String> charMap = {
    'á': 'a',
    'à': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'ă': 'a',
    'ắ': 'a',
    'ằ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'â': 'a',
    'ấ': 'a',
    'ầ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'đ': 'd',
    'é': 'e',
    'è': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ế': 'e',
    'ề': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'í': 'i',
    'ì': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'ó': 'o',
    'ò': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ố': 'o',
    'ồ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ớ': 'o',
    'ờ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ứ': 'u',
    'ừ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'ý': 'y',
    'ỳ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y'
  };

  // Đổi các ký tự sang chữ thường
  input = input.toLowerCase();

  // Thay thế các ký tự có dấu bằng ký tự không dấu
  input = input.split('').map((char) {
    return charMap[char] ??
        char; // Nếu không tìm thấy ký tự trong bảng, giữ nguyên
  }).join();

  // Thay khoảng trắng và các ký tự đặc biệt bằng dấu gạch ngang
  input = input.replaceAll(RegExp(r'[^a-z0-9\s]'), ''); // Xóa ký tự đặc biệt
  input = input.replaceAll(
      RegExp(r'\s+'), '-'); // Thay khoảng trắng bằng gạch ngang

  return input;
}

textFieldBox(String label, String value, TextEditingController controller,
    bool readOnly) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      readOnly: readOnly,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 196, 196, 196),
        contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      ),
      controller: controller,
    ),
  );
}

bool checkIsAdmin(User user) {
  String role = user.role!;
  if (role == 'admin') {
    return true;
  }
  return false;
}

String getFormattedDateTime(DateTime? input) {
  if (input != null) {
    return DateFormat('dd/MM/yyyy').format(input); // Ví dụ: 06/01/2025
  }
  return 'Chưa trả sách!'; // Nếu không có giá trị
}

List<int> convertAvatarStringToListInt(String avatar) {
  String input = avatar.replaceAll('[', '').replaceAll(']', '').trim();

  // Tách chuỗi thành danh sách các số dạng String
  List<String> stringNumbers = input.split(',');

  // Chuyển từng phần tử thành số nguyên (int)
  return stringNumbers.map((e) => int.parse(e.trim())).toList();
}
