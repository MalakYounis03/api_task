import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/api_service/end_points.dart';
import 'package:api_task/app/modules/register/model/register_response.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;
  final apiService = Get.find<ApiServices>();
  final authService = Get.find<AuthService>();
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final response = await apiService.post(
        endPoint: EndPoints.register,
        body: {
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
        fromJson: RegisterResponse.fromJson,
      );
      await authService.saveLoginData(response.token, response.user);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
