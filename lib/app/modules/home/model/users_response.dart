import 'package:api_task/app/data/user_model.dart';

class UsersResponse {
  final List<UserModel> users;

  UsersResponse({required this.users});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['users'] as List<dynamic>)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return UsersResponse(users: list);
  }
}
