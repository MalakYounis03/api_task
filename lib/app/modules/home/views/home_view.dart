import 'package:api_task/app/data/post_model.dart';
import 'package:api_task/app/modules/home/views/widgets/create_post_sheet.dart';
import 'package:api_task/app/service/auth_service.dart';
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
        title: TextButton(
          onPressed: () {
            Get.toNamed(Routes.users);
          },
          child: Text("Show All Users"),
        ),
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
            Get.bottomSheet(CreatePostSheet());
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
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final items = controller.posts;

          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.posts.isEmpty) {
            return Center(child: Text('No posts available'));
          }

          return RefreshIndicator(
            onRefresh: controller.fetchPosts,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: controller.posts.length,
              itemBuilder: (context, index) {
                final PostModel post = items[index];

                return Dismissible(
                  key: Key(post.id),
                  child: createPost(post),
                  onDismissed: (direction) async {
                    await controller.deletePost(post.id);
                  },
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 12),
            ),
          );
        }),
      ),
    );
  }

  Widget createPost(PostModel post) {
    return Container(
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
                    backgroundImage: NetworkImage(post.user.imageUrl),
                  ),
                  SizedBox(width: 12),
                  Text(
                    post.user.username,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: TextStyle(fontSize: 14, color: Color(0xFF828282)),
          ),
        ],
      ),
    );
  }
}
