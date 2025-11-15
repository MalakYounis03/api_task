import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text_form_filed.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/components/async_button.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 128),
            CustomText(
              text: "Register".tr,
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
              key: controller.formKeyRegister,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormFiled(
                    text: "Name".tr,
                    hintText: "Name here".tr,
                    icon: Icons.person,
                    controller: controller.usernameController,
                  ),
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
                    text: "Register".tr,
                    onPressed: () => controller.register(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "Already have an account? ".tr,
                        fontSize: 14,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offNamed(Routes.login);
                        },
                        child: CustomText(
                          text: "Login".tr,
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
