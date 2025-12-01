import 'package:api_task/app/data/user_model.dart';
import 'package:api_task/app/modules/chats/controllers/chats_controller.dart';

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

class ChatDetails {
  String otherUserId;
  String otherUserName;
  String otherUserImageUrl;

  ChatDetails({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImageUrl,
  });

  factory ChatDetails.newChat(UserModel user) {
    return ChatDetails(
      otherUserId: user.id,
      otherUserName: user.username,
      otherUserImageUrl: user.imageUrl,
    );
  }

  factory ChatDetails.existChat(Chat chat) {
    return ChatDetails(
      otherUserId: chat.otherUserId,
      otherUserName: chat.name,
      otherUserImageUrl: chat.imageUrl,
    );
  }
}
