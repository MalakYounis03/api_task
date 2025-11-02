import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final apiService = Get.find<ApiServices>();

      await apiService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
