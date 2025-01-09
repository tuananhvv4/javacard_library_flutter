void main() {
  // Chuỗi gốc
  String input = '[137, 96, 130]';

  // Loại bỏ dấu ngoặc vuông và khoảng trắng
  input = input.replaceAll('[', '').replaceAll(']', '').trim();

  // Tách chuỗi thành danh sách các số dạng String
  List<String> stringNumbers = input.split(',');

  // Chuyển từng phần tử thành số nguyên (int)
  List<int> numbers = stringNumbers.map((e) => int.parse(e.trim())).toList();

  // In kết quả
  print(numbers.runtimeType);
}
