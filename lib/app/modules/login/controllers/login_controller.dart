import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading = true.obs;
        print("****************loading started ");
        final apiService = Get.find<ApiServices>();

        final String token = await apiService.login(
          email: emailController.text,
          password: passwordController.text,
        );
        final authService = Get.find<AuthService>();
        await authService.saveToken(token);
        isLoading = false.obs;
        print("*****************loading finished");
        Get.offAllNamed(Routes.HOME);
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }
}
