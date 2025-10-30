import 'package:api_task/app/service/auth_service.dart';
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
        backgroundColor: Color(0xFF443C42),
        title: CustomText(text: "الرئيسية", color: Colors.white, fontSize: 25),
        centerTitle: true,
        actionsPadding: EdgeInsets.all(10),
        leading: IconButton(
          style: IconButton.styleFrom(
            padding: EdgeInsets.all(0),
            backgroundColor: Colors.white,
            minimumSize: Size(32, 32),
            fixedSize: Size(32, 32),
          ),
          icon: Icon(Icons.add_comment, size: 20, color: Color(0xff71B24D)),
          onPressed: () {
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
          IconButton(
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(0),
              backgroundColor: Colors.white,
              minimumSize: Size(32, 32),
              fixedSize: Size(32, 32),
            ),
            icon: Icon(Icons.logout, size: 20, color: Color(0xff71B24D)),
            onPressed: () async {
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(post.user.imageUrl),
                        ),
                        Text(
                          post.user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 140),

                        Text(
                          '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
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
            );
          },
        );
      }),
    );
  }
}
