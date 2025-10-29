import 'package:api_task/app/modules/home/views/widgets/custom_icon.dart';
import 'package:api_task/app/modules/login/controllers/auth_service.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_button.dart';
import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.green[100],
        title: CustomText(text: "Home", color: Colors.white, fontSize: 25),
        centerTitle: true,
        actionsPadding: EdgeInsets.all(10),
        leading: CustomIcon(
          icon: Icons.add_comment,
          onTap: () {
            Get.bottomSheet(
              Container(
                height: 600,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'Add Post',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    CustomText(
                      text: controller.posts[0].user.username,
                      alignment: Alignment.topLeft,
                      fontSize: 16,
                    ),
                    Divider(),
                    SizedBox(height: 20),

                    TextField(
                      maxLines: 5,

                      decoration: InputDecoration(
                        hintText: 'Write details here ..',
                        border: InputBorder.none,
                      ),
                    ),

                    SizedBox(height: 200),

                    CustomButton(
                      text: "Add",
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          CustomIcon(
            icon: Icons.logout,
            onTap: () async {
              final authService = Get.find<AuthService>();
              await authService.logout();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.posts.isEmpty) {
          return Center(child: Text('No posts available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(post.user.imageUrl),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post.user.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.content,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
