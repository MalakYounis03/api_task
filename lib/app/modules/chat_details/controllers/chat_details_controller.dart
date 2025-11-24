import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/modules/chats/controllers/chats_controller.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'dart:async';

class ChatDetailsController extends GetxController
    with StateMixin<List<ChatMessage>> {
  final db = FirebaseDatabase.instance.ref();
  final authService = Get.find<AuthService>();

  final messageController = TextEditingController();

  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  late final user = authService.user.value!;
  late final String chatId;

  final Chat chat = Get.arguments['chat'];

  final List<ChatMessage> messages = [];
  StreamSubscription<DatabaseEvent>? _childChangedSub;

  @override
  void onInit() {
    super.onInit();

    chatId = buildChatId(user.id, chat.otherUserId);

    _listenToMessages();
  }

  void _listenToMessages() {
    change(null, status: RxStatus.loading());

    final messagesQuery = db
        .child("chat-details/$chatId/messages")
        .orderByChild('messageTime')
        .limitToLast(20);

    messagesQuery
        .once(DatabaseEventType.value)
        .then((event) {
          if (!event.snapshot.exists) {
            change(<ChatMessage>[], status: RxStatus.empty());
          }
        })
        .catchError((error) {
          if (status == RxStatus.loading()) {
            change(null, status: RxStatus.error(error.toString()));
          }
        });

    _messagesSubscription = messagesQuery.onChildAdded.listen(
      (event) {
        final msgData = event.snapshot.value as Map<dynamic, dynamic>;
        final message = ChatMessage.fromMap(event.snapshot.key ?? '', msgData);

        messages.add(message);
        change(List<ChatMessage>.from(messages), status: RxStatus.success());
      },
      onError: (error) {
        change(null, status: RxStatus.error(error.toString()));
      },
    );
    _childChangedSub = messagesQuery.onChildChanged.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final updatedMsg = ChatMessage.fromMap(event.snapshot.key ?? '', data);

      final index = messages.indexWhere((m) => m.id == updatedMsg.id);
      if (index != -1) {
        messages[index] = updatedMsg;
        change(List<ChatMessage>.from(messages), status: RxStatus.success());
      }
    });
  }

  Future<void> sendMessages() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final newMessageRef = db.child("chat-details/$chatId/messages").push();
    final newMessageTime = DateTime.now().millisecondsSinceEpoch;

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

  String buildChatId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    final reversed = ids.reversed.toList();
    return reversed.join('____');
  }

  Future<void> deleteMessageForEveryone(ChatMessage msg) async {
    try {
      await db.child("chat-details/$chatId/messages").child(msg.id).update({
        'isDeleted': true,
        'message': '',
      });

      await _updateLastMessageIfNeeded(msg);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الرسالة');
    }
  }

  Future<void> _updateLastMessageIfNeeded(ChatMessage msg) async {
    final myId = user.id;
    final otherId = chat.otherUserId;

    final myChatRef = db.child("list-of-chats/$myId/$otherId");
    final otherChatRef = db.child("list-of-chats/$otherId/$myId");

    final snap = await myChatRef.get();
    if (!snap.exists) return;

    final data = snap.value as Map<dynamic, dynamic>;
    final lastTime = data['lastMessageTime'] as int? ?? 0;

    if (lastTime != msg.messageTime) return;

    await myChatRef.update({'lastMessage': 'تم حذف هذه الرسالة'});

    await otherChatRef.update({'lastMessage': 'تم حذف هذه الرسالة'});
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    _childChangedSub?.cancel();

    super.onClose();
  }
}
