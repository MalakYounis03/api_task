import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'dart:async';

class ChatsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final authService = Get.find<AuthService>();

  final chats = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  StreamSubscription<DatabaseEvent>? _chatsSub;

  @override
  void onInit() {
    super.onInit();
    final savedUser = authService.user.value;
    if (savedUser != null) {
      _listenToChats(savedUser.id);
    }
  }

  void _listenToChats(String userId) {
    isLoading.value = true;

    _chatsSub = db.child("list-of-chats/$userId").onValue.listen((event) {
      final temp = <Map<String, dynamic>>[];

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((otherUserId, chatData) {
          final map = chatData as Map<dynamic, dynamic>;
          temp.add({
            "otherUserId": otherUserId,
            "name": map["name"],
            "imageUrl": map["imageUrl"],
            "lastMessage": map["lastMessage"],
            "lastMessageTime": map["lastMessageTime"],
            "lastMessageAuthor": map["lastMessageAuthor"],
          });
        });

        temp.sort((a, b) {
          final aTime = a["lastMessageTime"] as int? ?? 0;
          final bTime = b["lastMessageTime"] as int? ?? 0;
          return bTime.compareTo(aTime);
        });
      }

      chats.assignAll(temp);
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _chatsSub?.cancel();
    super.onClose();
  }
}
