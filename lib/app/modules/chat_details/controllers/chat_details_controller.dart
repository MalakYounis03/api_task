import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/modules/chats/controllers/chats_controller.dart';
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

  late final user = authService.user.value!;
  late final String chatId;

  final Chat chat = Get.arguments['chat'];

  final messages = <ChatMessage>[].obs;

  final isLoading = false.obs;

  final ScrollController scrollController = ScrollController();

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

          scrollToBottom();
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
      "lastMessage": text,
      "lastMessageTime": newMessageTime,
      "lastMessageAuthor": user.id,
      "name": chat.name,
      "imageUrl": chat.imageUrl,
    });

    await db.child("list-of-chats/${chat.otherUserId}/${user.id}").update({
      "lastMessage": text,
      "lastMessageTime": newMessageTime,
      "lastMessageAuthor": user.id,
      "name": user.username,
      "imageUrl": user.imageUrl,
    });
  }

  //

  String buildChatId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    final reversed = ids.reversed.toList();
    return reversed.join('____');
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final position = scrollController.position.maxScrollExtent;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
