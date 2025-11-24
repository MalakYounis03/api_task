class ChatMessage {
  final String id;
  final String message;
  final int messageTime;
  final String senderId;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.message,
    required this.messageTime,
    required this.senderId,
    this.isDeleted = false,
  });

  factory ChatMessage.fromMap(String id, Map data) {
    return ChatMessage(
      id: id,
      message: data["message"],
      messageTime: data["messageTime"],
      senderId: data["senderId"],
      isDeleted: data["isDeleted"] ?? false,
    );
  }
}
