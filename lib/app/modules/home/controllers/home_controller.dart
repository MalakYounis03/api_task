import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/api_service/end_points.dart';
import 'package:api_task/app/data/post_model.dart';
import 'package:api_task/app/modules/home/model/add_post_response.dart';
import 'package:api_task/app/modules/home/model/delete_post_response.dart';
import 'package:api_task/app/modules/home/model/home_response.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;
  TextEditingController postController = TextEditingController();
  final apiService = Get.find<ApiServices>();

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  Future<void> fetchPosts() async {
    isLoading.value = true;

    try {
      final response = await apiService.get(
        endPoint: EndPoints.getPosts,
        fromJson: HomeResponse.fromJson,
      );
      posts.value = response.posts;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posts: $e');
    }
    isLoading.value = false;
  }

  Future<void> addPost() async {
    final content = postController.text.trim();

    if (content.isEmpty) {
      Get.snackbar('Error', 'Post content cannot be empty');
      return;
    }
    try {
      final response = await apiService.post(
        endPoint: EndPoints.addPost,
        body: {'content': content},
        fromJson: AddPostResponse.fromJson,
      );

      posts.insert(0, response.post);
      posts.refresh();

      postController.clear();

      Get.back();

      Get.snackbar('Success', 'Post added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await apiService.delete(
        endPoint: EndPoints.deletePost,
        postId: postId,
        fromJson: DeletePostResponse.fromJson,
      );

      posts.removeWhere((post) => post.id == postId);
      posts.refresh();

      Get.snackbar('Success', 'Post deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post: $e');
    }
  }

  @override
  void onClose() {
    postController.dispose();
    super.onClose();
  }
}
