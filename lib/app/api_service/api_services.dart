import 'package:api_task/app/api_service/end_points.dart';
import 'package:api_task/app/api_service/general_response.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServices {
  static const String baseUrl = 'http://13.60.40.160';
  final authService = Get.find<AuthService>();

  Future<T> get<T>({
    required EndPoints endPoint,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await http.get(
      endPoint.url,
      headers: {'Authorization': "Bearer ${authService.token}"},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(data);
    }
    throw handleError(data);
  }

  Future<T> post<T>({
    required EndPoints endPoint,
    required Object? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await http.post(
      endPoint.url,
      headers: {'Authorization': "Bearer ${authService.token}"},
      body: body,
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(data);
    }
    throw handleError(data);
  }

  Future<T> delete<T>({
    required EndPoints endPoint,
    required String postId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await http.delete(
      endPoint.url.replace(queryParameters: {'post_id': postId}),
      headers: {'Authorization': "Bearer ${authService.token}"},
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(data);
    }
    throw handleError(data);
  }

  String handleError(Map<String, dynamic> data) {
    final generalResponse = GeneralResponse.fromJson(data);

    return generalResponse.message;
  }
}
