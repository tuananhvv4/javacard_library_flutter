import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class StateManager extends GetxController {
  RxBool isLogin = false.obs;

  getIsLogin() {
    return isLogin.value;
  }

  setIsLogin(bool value) {
    isLogin.value = value;
  }

  RxBool isAdmin = false.obs;

  getIsAdmin() {
    return isAdmin.value;
  }

  setIsAdmin(bool value) {
    isAdmin.value = value;
  }
}
