import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';

class ChatDetailsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final authService = Get.find<AuthService>();

  final messageController = TextEditingController();

  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  StreamSubscription<DatabaseEvent>? _childRemovedSub;

  late final user = authService.user.value!;
  late final String chatId;

  final ChatDetails chat = Get.arguments['chat'];

  final messages = <ChatMessage>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();

    chatId = buildChatId(user.id, chat.otherUserId);

    await _fetchMessages();
    _listenToNewMessages();
  }

  Future<void> _fetchMessages() async {
    isLoading.value = true;

    try {
      final event = await db
          .child("chat-details/$chatId/messages")
          .orderByChild('messageTime')
          .once(DatabaseEventType.value);

      final childs = event.snapshot.children.toList();

      for (var child in childs) {
        final message = ChatMessage.fromMap(
          child.key ?? '',
          child.value as Map<dynamic, dynamic>,
        );
        messages.add(message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToNewMessages() {
    _messagesSubscription = db
        .child("chat-details/$chatId/messages")
        .orderByChild('messageTime')
        .startAfter(key: 'messageTime', messages.lastOrNull?.messageTime)
        .onChildAdded
        .listen((event) {
          final msgData = event.snapshot.value as Map<dynamic, dynamic>;

          final newMessage = ChatMessage.fromMap(
            event.snapshot.key ?? '',
            msgData,
          );

          messages.add(newMessage);
        });
    _childRemovedSub = db
        .child("chat-details/$chatId/messages")
        .orderByChild('messageTime')
        .onChildRemoved
        .listen((event) {
          final msgId = event.snapshot.key;
          if (msgId == null) return;

          messages.removeWhere((m) => m.id == msgId);
        });
  }

  Future<void> sendMessages() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final newMessageRef = db.child("chat-details/$chatId/messages").push();
    final newMessageTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    messageController.clear();

    await newMessageRef.set({
      "senderId": user.id,
      "message": text,
      "messageTime": newMessageTime,
    });

    await db.child("list-of-chats/${user.id}/${chat.otherUserId}").update({
      "name": chat.otherUserName,
      "imageUrl": chat.otherUserImageUrl,
      "lastMessage": text,
      "lastMessageTime": newMessageTime,
      "lastMessageAuthor": user.id,
    });

    await db.child("list-of-chats/${chat.otherUserId}/${user.id}").update({
      "name": user.username,
      "imageUrl": user.imageUrl,
      "lastMessage": text,
      "lastMessageTime": newMessageTime,
      "lastMessageAuthor": user.id,
    });
  }

  //

  String buildChatId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    final reversed = ids.reversed.toList();
    return reversed.join('____');
  }

  Future<void> deleteMessageForEveryone(ChatMessage msg) async {
    final messageRef = db.child("chat-details/$chatId/messages/${msg.id}");

    await messageRef.remove();
    await _updateLastMessageAfterDelete(msg);
  }

  Future<void> _updateLastMessageAfterDelete(ChatMessage deletedMsg) async {
    final myId = user.id;
    final otherId = chat.otherUserId;

    final myChatRef = db.child("list-of-chats/$myId/$otherId");
    final otherChatRef = db.child("list-of-chats/$otherId/$myId");

    final messagesRef = db.child("chat-details/$chatId/messages");

    final lastMsgEvent = await messagesRef
        .orderByChild('messageTime')
        .limitToLast(1)
        .once(DatabaseEventType.value);

    if (!lastMsgEvent.snapshot.exists) {
      await myChatRef.remove();
      await otherChatRef.remove();
      return;
    }
    final lastSnap = lastMsgEvent.snapshot;

    final DataSnapshot msgSnap = lastSnap.children.first;

    final lastMsgData = msgSnap.value as Map<dynamic, dynamic>;

    final updateData = {
      'lastMessage': lastMsgData['message'] ?? '',
      'lastMessageAuthor': lastMsgData['senderId'] ?? '',
      'lastMessageTime': lastMsgData['messageTime'] ?? 0,
    };

    await myChatRef.update(updateData);
    await otherChatRef.update(updateData);
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    _childRemovedSub?.cancel();
    super.onClose();
  }
}
