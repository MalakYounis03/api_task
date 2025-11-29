import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/users_controller.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});
  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final savedUser = authService.user.value;
    final currentUserId = savedUser!.id;
    return Scaffold(
      appBar: AppBar(title: const Text('All Users'), centerTitle: true, backgroundColor: Color(0xFF443C42)),
      body: SafeArea(
        child: Obx(() {
          final items = controller.users;

          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.users.isEmpty) {
            return Center(child: Text('No users available'));
          }

          return RefreshIndicator(
            onRefresh: controller.fetchUsers,

            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final user = items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () {
                      if (user.id == currentUserId) {
                        Get.snackbar('Info', 'You cannot chat with yourself');
                        return;
                      }
                      Get.toNamed(Routes.chatDetails, arguments: {"chat": ChatDetails.newChat(user)});
                    },
                    leading: CircleAvatar(backgroundImage: NetworkImage(user.imageUrl)),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 12),
            ),
          );
        }),
      ),
    );
  }
}
