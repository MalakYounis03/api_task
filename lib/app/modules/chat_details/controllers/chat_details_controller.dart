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

  @override
  void onInit() async {
    super.onInit();

    chatId = buildChatId(user.id, chat.otherUserId);

    _listenToMessages();
  }

  void _listenToMessages() {
    change(null, status: RxStatus.loading());
    final messagesRef = db
        .child("chat-details/$chatId/messages")
        .orderByChild('messageTime')
        .limitToLast(20);

    // 1) أولاً: تحقق مرة واحدة هل في رسائل قديمة
    messagesRef
        .once(DatabaseEventType.value)
        .then((event) {
          // لو ما في ولا رسالة، snapshot.exists = false
          if (!event.snapshot.exists) {
            // ما في رسائل قديمة -> نطفي اللودينغ

            change(<ChatMessage>[], status: RxStatus.empty());
          }
          // لو في رسائل، ما منعمل شي هون، لأن onChildAdded رح يضبط الأمور
        })
        .catchError((error) {
          if (status == RxStatus.loading()) {
            change(null, status: RxStatus.error(error.toString()));
          }
        });

    // 2) ثانياً: اسمع لكل الرسائل (القديمة + الجديدة)
    _messagesSubscription = messagesRef.onChildAdded.listen(
      (event) {
        // هنا event.snapshot.exists دائماً true لأن في child حقيقي
        final msgData = event.snapshot.value as Map<dynamic, dynamic>;
        final message = ChatMessage.fromMap(event.snapshot.key ?? '', msgData);

        messages.add(message);
        change(List<ChatMessage>.from(messages), status: RxStatus.success());
      },
      onError: (error) {
        change(null, status: RxStatus.error(error.toString()));
      },
    );
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

  @override
  void onClose() {
    messageController.dispose();
    _messagesSubscription?.cancel();
    super.onClose();
  }
}
