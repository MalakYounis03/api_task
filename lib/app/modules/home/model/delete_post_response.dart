import 'package:api_task/app/data/delete_model.dart';

class DeletePostResponse {
  final DeleteModel delete;

  DeletePostResponse({required this.delete});

  factory DeletePostResponse.fromJson(Map<String, dynamic> json) {
    return DeletePostResponse(delete: DeleteModel.fromJson(json));
  }
}
