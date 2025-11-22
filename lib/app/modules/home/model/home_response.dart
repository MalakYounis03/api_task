import 'package:api_task/app/data/post_model.dart';

class HomeResponse {
  List<PostModel> posts;
  HomeResponse({required this.posts});
  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> postsJson = json['posts'];
    final postsList = postsJson
        .map((postJson) => PostModel.fromJson(postJson))
        .toList();
    return HomeResponse(posts: postsList);
  }
}
