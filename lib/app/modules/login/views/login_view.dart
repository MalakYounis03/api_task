import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text_form_filed.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/components/async_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 128),
            CustomText(
              text: "login".tr,
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10),
            CustomText(
              text: "Please Enter Your Email And Password ".tr,
              fontSize: 14,
            ),
            SizedBox(height: 30),
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormFiled(
                    text: "Email".tr,
                    hintText: "Email here".tr,
                    icon: Icons.email,
                    controller: controller.emailController,
                  ),
                  SizedBox(height: 15),
                  CustomTextFormFiled(
                    text: "Password".tr,
                    hintText: "Password here".tr,
                    icon: Icons.password,
                    controller: controller.passwordController,
                  ),
                  SizedBox(height: 50),
                  AsyncButton(
                    text: "Login".tr,
                    onPressed: () => controller.login(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "Don't have an account? ".tr,
                        fontSize: 14,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offNamed(Routes.register);
                        },
                        child: CustomText(
                          text: "Register".tr,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
