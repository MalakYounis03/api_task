import 'package:api_task/app/data/user_model.dart';

class RegisterResponse {
  final UserModel user;
  final String token;

  RegisterResponse({required this.user, required this.token});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      user: UserModel.fromJson(json['user']),
      token: json['access_token'],
    );
  }
}
