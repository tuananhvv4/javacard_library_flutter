import 'package:http/http.dart' as http;
import 'dart:convert';

const List<int> selectAppletCommand = [
  0x00,
  0xA4,
  0x04,
  0x00,
  0x06,
  0x11,
  0x22,
  0x33,
  0x44,
  0x55,
  0x11,
];

Future<void> getData() async {
  const apiUrl =
      'https://nguyenanh.site/api/InfoResource.php?username=anh&password=112233&id=1'; // URL API

  try {
    // Gửi yêu cầu GET
    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body); // Parse JSON
      print('$result');
    } else {
      print('Lỗi: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Đã xảy ra lỗi: $error');
  }
}

const List<int> appCommand = [0x00, 0x01, 0x00, 0x00];
void main(List<String> args) async {
  await getData();
}
