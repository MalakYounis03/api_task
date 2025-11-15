import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:api_task/components/async_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePostSheet extends GetView<HomeController> {
  const CreatePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    final savedUser = authService.user.value;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              text: 'Add Post'.tr,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEBEBEB).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundImage: NetworkImage(savedUser!.imageUrl),
                      ),
                      SizedBox(width: 12),
                      CustomText(
                        text: savedUser.username,
                        alignment: Alignment.topLeft,
                        fontSize: 16,
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  Divider(height: 0),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.postController,
                    maxLines: 7,
                    decoration: InputDecoration(
                      hintText: 'Write details here'.tr,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            AsyncButton(
              text: "Add".tr,
              onPressed: () async {
                await controller.addPost();
              },
            ),
          ],
        ),
      ),
    );
  }
}
