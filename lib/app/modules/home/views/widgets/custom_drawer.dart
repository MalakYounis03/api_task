import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/modules/home/views/widgets/create_post_sheet.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends GetView<HomeController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 70),

      child: Column(
        children: [
          SizedBox(height: 8),
          IconButton(
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              minimumSize: Size(32, 32),
              fixedSize: Size(32, 32),
            ),
            icon: Icon(Icons.add_comment, size: 20, color: Color(0xff71B24D)),
            onPressed: () {
              Get.back();
              Get.bottomSheet(CreatePostSheet());
            },
          ),
          IconButton(
            icon: Image.asset('assets/message_icon.png'),
            style: IconButton.styleFrom(
              backgroundColor: Color(0xff71B24D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(0),
              minimumSize: Size(32, 32),
              fixedSize: Size(32, 32),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.chats);
            },
          ),
        ],
      ),
    );
  }
}
