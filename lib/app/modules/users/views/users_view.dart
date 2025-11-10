import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/users_controller.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        centerTitle: true,
        backgroundColor: Color(0xFF443C42),
      ),
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
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text(user.email),
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
