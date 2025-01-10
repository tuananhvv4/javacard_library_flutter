import 'package:javacard_library/helper/helper.dart';

const List<int> appCommand = [0x00, 0x01, 0x00, 0x00];
main() {
  String id = '1';
  print(convertStringToByteList(id));
}
