import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class ChatsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> fetchChats(String userId) async {
    final snapshot = await db.child("list-of-chats/$userId").get();

    List<Map<String, dynamic>> chats = [];

    if (snapshot.exists) {
      final list = snapshot.value as Map;

      list.forEach((otherUserId, chatData) {
        chats.add({
          "otherUserId": otherUserId,
          "name": chatData["name"],
          "imageUrl": chatData["imageUrl"],
          "lastMessage": chatData["lastMessage"],
          "lastMessageTime": chatData["lastMessageTime"],
          "lastMessageAuthor": chatData["lastMessageAuthor"],
        });
      });
    }

    return chats;
  }
}
