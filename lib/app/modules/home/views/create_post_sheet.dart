import 'package:api_task/app/components/async_button.dart';
import 'package:api_task/app/data/user_model.dart';
import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('auth');
    final UserModel user = box.get('user');

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
              text: 'Add Post',
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
                  CustomText(
                    text: controller.posts[0].user.username,
                    alignment: Alignment.topLeft,
                    fontSize: 16,
                  ),
                  SizedBox(height: 16),
                  Divider(height: 0),
                  SizedBox(height: 16),
                  TextField(
                    maxLines: 7,
                    decoration: InputDecoration(
                      hintText: 'Write details here ..',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            AsyncButton(
              text: "Add",
              onPressed: () async {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
