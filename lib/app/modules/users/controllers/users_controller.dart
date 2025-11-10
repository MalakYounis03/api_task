import 'package:api_task/app/api_service/api_services.dart';
import 'package:api_task/app/api_service/end_points.dart';
import 'package:api_task/app/data/user_model.dart';
import 'package:api_task/app/modules/home/model/users_response.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  var isLoading = true.obs;
  var users = <UserModel>[].obs;
  final apiService = Get.find<ApiServices>();

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;

    try {
      print('Fetching users...');
      final response = await apiService.get(
        endPoint: EndPoints.getUsers,
        fromJson: UsersResponse.fromJson,
      );
      print('Users fetched successfully: ${response.users}');
      users.value = response.users;
    } catch (e) {
      print('Error fetching users: $e');
      Get.snackbar('Error', 'Failed to load users: $e');
    }
    isLoading.value = false;
  }
}
