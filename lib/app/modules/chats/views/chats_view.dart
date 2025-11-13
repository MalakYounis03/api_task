import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ChatsView extends GetView<HomeController> {
  const ChatsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF443C42),

        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(12),

          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.CHAT_DETAILS);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFEBEBEB).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                controller.posts[index].user.imageUrl,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              controller.posts[index].user.username,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${controller.posts[index].createdAt.day}/${controller.posts[index].createdAt.month}/${controller.posts[index].createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.posts[index].content,
                      style: TextStyle(fontSize: 14, color: Color(0xFF828282)),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 15),
          itemCount: controller.posts.length,
        ),
      ),
    );
  }
}
