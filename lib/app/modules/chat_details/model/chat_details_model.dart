class ChatMessage {
  final String id;
  final String message;
  final int messageTime;
  final String senderId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.messageTime,
    required this.senderId,
  });

  factory ChatMessage.fromMap(String id, Map data) {
    return ChatMessage(
      id: id,
      message: data["message"],
      messageTime: data["messageTime"],
      senderId: data["senderId"],
    );
  }
}
