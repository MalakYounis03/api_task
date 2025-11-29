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
  StreamSubscription<DatabaseEvent>? _childRemovedSub;

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
        .orderByChild('messageTime');

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
    _childRemovedSub = messagesQuery.onChildRemoved.listen((event) {
      final msgId = event.snapshot.key;
      if (msgId == null) return;

      messages.removeWhere((m) => m.id == msgId);

      if (messages.isEmpty) {
        change(<ChatMessage>[], status: RxStatus.empty());
      } else {
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
    final messageRef = db.child("chat-details/$chatId/messages/${msg.id}");

    await messageRef.remove();
    await _updateLastMessageAfterDelete(msg);
  }

  Future<void> _updateLastMessageAfterDelete(ChatMessage deletedMsg) async {
    final myId = user.id;
    final otherId = chat.otherUserId;

    final myChatRef = db.child("list-of-chats/$myId/$otherId");
    final otherChatRef = db.child("list-of-chats/$otherId/$myId");

    final headerSnap = await myChatRef.get();
    if (!headerSnap.exists) return;

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

    final raw = lastMsgEvent.snapshot.value as Map<dynamic, dynamic>;
    final lastEntry = raw.entries.first;
    final lastMsgData = lastEntry.value as Map<dynamic, dynamic>;

    final String lastText = lastMsgData['message'] as String? ?? '';
    final String lastSenderId = lastMsgData['senderId'] as String? ?? '';
    final int lastTime = lastMsgData['messageTime'] as int? ?? 0;

    final updateData = {
      'lastMessage': lastText,
      'lastMessageAuthor': lastSenderId,
      'lastMessageTime': lastTime,
    };

    await myChatRef.update(updateData);
    await otherChatRef.update(updateData);
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    _childChangedSub?.cancel();
    _childRemovedSub?.cancel();

    super.onClose();
  }
}
