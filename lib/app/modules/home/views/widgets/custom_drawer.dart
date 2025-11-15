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
      color: Color(0xFF2F2A2D),
      width: 200,
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
            title: Text('Create Post', style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.bottomSheet(CreatePostSheet());
            },
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.chat, size: 20, color: Colors.white),
            title: Text('Chats', style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.chats);
            },
          ),
          ListTile(
            leading: Icon(Icons.people, size: 20, color: Colors.white),
            title: Text('All users', style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.users);
            },
          ),
        ],
      ),
    );
  }
}
