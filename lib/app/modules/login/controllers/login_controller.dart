import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/api_service/end_points.dart';
import 'package:api_task/app/modules/login/model/login_response.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  final authService = Get.find<AuthService>();
  final apiService = Get.find<ApiServices>();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final response = await apiService.post(
        endPoint: EndPoints.login,
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
        fromJson: LoginResponse.fromJson,
      );
      await authService.saveLoginData(response.token, response.user);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      print(e);

      Get.snackbar('Error', e.toString());
    }
  }
}
