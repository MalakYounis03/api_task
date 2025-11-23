import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/modules/home/views/widgets/create_post_sheet.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDrawer extends GetView<HomeController> {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    final savedUser = authService.user.value;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 10),
      color: Color(0xFF443C42),
      width: 228,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(savedUser!.imageUrl),
              ),
              SizedBox(width: 12),
              Text(
                savedUser.username,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 15),
          ListTile(
            leading: Icon(Icons.add_comment, size: 20, color: Colors.white),
            title: Text('Add Post'.tr, style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.bottomSheet(CreatePostSheet());
            },
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.chat, size: 20, color: Colors.white),
            title: Text('Chats'.tr, style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.chats);
            },
          ),
          ListTile(
            leading: Icon(Icons.people, size: 20, color: Colors.white),
            title: Text('All Users'.tr, style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.users);
            },
          ),
          Spacer(),
          InkWell(
            onTap: () async {
              final authService = Get.find<AuthService>();
              await authService.logout();
              Get.offAllNamed(Routes.login);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
