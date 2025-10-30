import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/data/post_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;

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
      print('Loaded ${posts.length}');
    } catch (e) {
      print('Controller Error: $e');
      Get.snackbar('Error', 'Failed to load posts: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
