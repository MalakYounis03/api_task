import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();

  final RxBool isLoggedIn = false.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initFromBox();
  }

  Future<void> _initFromBox() async {
    final box = Hive.box('auth');
    final savedToken = box.get('token', defaultValue: '') as String;
    if (savedToken.isNotEmpty) {
      token.value = savedToken;
      isLoggedIn.value = true;
    } else {
      token.value = '';
      isLoggedIn.value = false;
    }
  }

  Future<void> saveToken(String newToken) async {
    final box = Hive.box('auth');
    await box.put('token', newToken);
    token.value = newToken;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    final box = Hive.box('auth');
    await box.delete('token');
    token.value = '';
    isLoggedIn.value = false;
  }
}
