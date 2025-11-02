import 'package:api_task/app/data/post_model.dart';
import 'package:api_task/app/data/user_model.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServices {
  static const String baseUrl = 'http://13.60.40.160';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      final token = data['access_token'] ?? data['token'];
      final userJson = data['user'];

      if (token != null && userJson != null) {
        final user = UserModel.fromJson(userJson);
        final auth = Get.find<AuthService>();
        await auth.saveLoginData(token, user);
        return token;
      } else {
        throw Exception('Invalid login response: missing token or user');
      }
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<List<PostModel>> getPosts() async {
    try {
      final authService = Get.find<AuthService>();
      final String token = authService.token.value;

      if (token.isEmpty) {
        throw Exception('No token available - User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/post'),
        headers: {'Authorization': "Bearer $token"},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['posts'] != null) {
          final List<dynamic> postsList = jsonResponse['posts'];
          return postsList
              .map((postJson) => PostModel.fromJson(postJson))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load posts ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<PostModel> createPost({required String content}) async {
    final authService = Get.find<AuthService>();
    final String token = authService.token.value;

    // تأكد من تنظيف الـ content
    final cleanedContent = content.trim();

    if (cleanedContent.isEmpty) {
      throw Exception('Content cannot be empty');
    }

    print('DEBUG: Creating post with content: "$cleanedContent"');

    final response = await http.post(
      Uri.parse('$baseUrl/post'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
      body: jsonEncode({'content': cleanedContent}),
    );

    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      // حسب الرد اللي بترسله، الـ post بيكون داخل كائن "post"
      if (jsonResponse.containsKey('post')) {
        return PostModel.fromJson(jsonResponse['post']);
      } else {
        // إذا ما فيش كائن "post"، جرب مباشرة
        return PostModel.fromJson(jsonResponse);
      }
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }
}
