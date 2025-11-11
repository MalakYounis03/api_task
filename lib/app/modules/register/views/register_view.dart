import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text_form_filed.dart';
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
              text: "Register",
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10),
            CustomText(
              text: "Please Enter Your Email And Password ",
              fontSize: 14,
            ),
            SizedBox(height: 30),
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFormFiled(
                    text: "Name",
                    hintText: "Name here",
                    icon: Icons.person,
                    controller: controller.usernameController,
                  ),
                  CustomTextFormFiled(
                    text: "Email",
                    hintText: "Email here",
                    icon: Icons.email,
                    controller: controller.emailController,
                  ),
                  SizedBox(height: 15),
                  CustomTextFormFiled(
                    text: "Password",
                    hintText: "Password here",
                    icon: Icons.password,
                    controller: controller.passwordController,
                  ),
                  SizedBox(height: 50),
                  AsyncButton(
                    text: "Login",
                    onPressed: () => controller.register(),
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
