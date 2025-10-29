import 'package:api_task/app/data/post_model.dart';
import 'package:api_task/app/modules/login/controllers/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:api_task/app/data/login_response_model.dart';

class ApiServices {
  static const String baseUrl = 'http://13.60.40.160';

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final loginResponse = LoginResponseModel.fromJson(jsonResponse);

        return loginResponse.accessToken;
      } else {
        throw Exception('Failed to login - Status: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Login failed!: $e');
    }
  }

  static Future<List<PostModel>> getPosts() async {
    try {
      final authService = Get.find<AuthService>();
      final String? token = authService.token.value;

      // التأكد من وجود التوكن
      if (token == null || token.isEmpty) {
        throw Exception('No token available - User not logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/post'),
        headers: {
          'Authorization': "Bearer $token", // استخدام التوكن الحي
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

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
}
