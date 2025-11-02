import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/data/post_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;
  TextEditingController postController = TextEditingController();

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final apiService = Get.find<ApiServices>();

      final List<PostModel> fetchedPosts = await apiService.getPosts();
      posts.assignAll(fetchedPosts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPost() async {
    final content = postController.text.trim();

    if (content.isEmpty) {
      Get.snackbar('Error', 'Post content cannot be empty');
      return;
    }
    try {
      final apiServices = Get.find<ApiServices>();
      print('DEBUG addPost: sending content: "$content"');

      final PostModel created = await apiServices.createPost(content: content);

      print('DEBUG addPost: created successfully - id: ${created.id}');

      final PostModel postWithUser = PostModel(
        id: created.id,
        content: created.content,
        createdAt: created.createdAt,
      );

      print('DEBUG addPost: created successfully - id: ${created.id}');

      posts.add(postWithUser);
      posts.refresh();

      postController.clear();

      Get.back();

      Get.snackbar('Success', 'Post added successfully');
    } catch (e) {
      print('DEBUG addPost ERROR: $e');
      Get.snackbar('Error', 'Failed to add post: $e');
    }
  }

  @override
  void onClose() {
    postController.dispose();
    super.onClose();
  }
}
