import 'package:javacard_library/model/user.dart';

class Api {
  static User user = User(
      id: 0,
      name: '',
      address: '',
      status: 0,
      avatar: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      role: '');

  static Future<User> getUser() async {
    return user;
  }

  static Future<bool> setUser(User user) async {
    try {
      Api.user = user;
      return true;
    } catch (e) {
      return false;
    }
  }
}
