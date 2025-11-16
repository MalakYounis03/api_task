import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

class ChatDetailsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final authService = Get.find<AuthService>();
  final messageController = TextEditingController();
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  late final String chatId;
  late final String otherName;
  late final String otherUserId;
  late final String currentUserId;
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    otherUserId = args["otherUserId"];
    otherName = args["name"];
    final savedUser = authService.user.value;
    currentUserId = savedUser!.id;
    chatId = buildChatId(currentUserId, otherUserId);
    fetchMessages();
    _listenToNewMessages();
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String buildChatId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    final reversed = ids.reversed.toList();
    return reversed.join('____');
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;

    try {
      final snapshot = await db.child("chat-details/$chatId/messages").get();

      print("**********chatId********************");
      print(chatId);
      print("**********snapshot********************");
      print(snapshot.value);

      final temp = <ChatMessage>[];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((msgId, msgData) {
          final msgMap = msgData as Map<dynamic, dynamic>;
          temp.add(ChatMessage.fromMap(msgId as String, msgMap));
          print("**********id********************");
          print(msgId);
          print("**********data********************");

          print(msgMap);
        });

        temp.sort((a, b) => a.messageTime.compareTo(b.messageTime));
      }

      messages.assignAll(temp);
      scrollToBottom();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessages() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessageRef = db.child("chat-details/$chatId/messages").push();
    final newMessageTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await newMessageRef.set({
      "senderId": currentUserId,
      "message": text,
      "messageTime": newMessageTime,
    });
    await _updateChatSummary(
      lastMessage: text,
      lastMessageTime: newMessageTime,
      senderId: currentUserId,
    );
    messageController.clear();
    scrollToBottom();
  }

  Future<void> _updateChatSummary({
    required String lastMessage,
    required int lastMessageTime,
    required String senderId,
  }) async {
    await db.child("list-of-chats/$currentUserId/$otherUserId").update({
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "lastMessageAuthor": senderId,
    });

    await db.child("list-of-chats/$otherUserId/$currentUserId").update({
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "lastMessageAuthor": senderId,
    });
  }

  void _listenToNewMessages() {
    _messagesSubscription = db
        .child("chat-details/$chatId/messages")
        .onChildAdded
        .listen((event) {
          if (!event.snapshot.exists || event.snapshot.value == null) return;
          final msgId = event.snapshot.key;
          if (msgId == null) return;

          final msgData = event.snapshot.value as Map<dynamic, dynamic>;
          final alreadyExists = messages.any((msg) => msg.id == msgId);
          if (alreadyExists) return;

          final newMessage = ChatMessage.fromMap(msgId, msgData);

          messages.add(newMessage);
          messages.sort((a, b) => a.messageTime.compareTo(b.messageTime));
        });
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    super.onClose();
  }
}
