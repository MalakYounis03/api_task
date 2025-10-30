import 'package:api_task/app/data/user_model.dart';

class PostModel {
  final String id;
  final String content;
  final DateTime createdAt;
  UserModel user;

  PostModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      user: UserModel.fromJson(json['user']),
    );
  }
}
