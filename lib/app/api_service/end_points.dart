import 'package:api_task/app/api_service/api_services.dart';

enum EndPoints {
  login,
  getPosts,
  addPost,
  getUsers,
  deletePost;

  String get path {
    return switch (this) {
      EndPoints.login => 'auth/login',
      EndPoints.getPosts => 'post',
      EndPoints.addPost => 'post',
      EndPoints.getUsers => 'user',
      EndPoints.deletePost => 'post',
    };
  }

  Uri get url {
    return Uri.parse('${ApiServices.baseUrl}/$path');
  }
}
