class GeneralResponse {
  final String message;
  GeneralResponse({required this.message});
  factory GeneralResponse.fromJson(Map<String, dynamic> json) {
    final String message;
    if (json['message'] is String) {
      message = json['message'];
    } else {
      final array = (json['message'] as List).map((e) => e as List).toList();
      message = array.join('\n');
    }
    return GeneralResponse(message: message);
  }
}
