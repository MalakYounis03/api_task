class DeleteModel {
  String message;
  DeleteModel({required this.message});
  factory DeleteModel.fromJson(Map<String, dynamic> json) {
    return DeleteModel(message: json['message']);
  }
}
