import 'package:api_task/app/data/user_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString token = ''.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _initFromBox();
  }

  Future<void> _initFromBox() async {
    final box = Hive.box('auth');
    final savedToken = box.get('token') as String;
    final savedUser = box.get('user') as UserModel;
    if (savedToken.isNotEmpty) {
      token.value = savedToken;
      isLoggedIn.value = true;
    }
    user.value = savedUser;
  }

  Future<void> saveLoginData(String newToken, UserModel newUser) async {
    final box = Hive.box('auth');
    await box.put('token', newToken);
    await box.put('user', newUser);
    token.value = newToken;
    user.value = newUser;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    final box = Hive.box('auth');
    await box.delete('token');
    await box.delete('user');
    token.value = '';
    user.value = null;
    isLoggedIn.value = false;
  }
}
