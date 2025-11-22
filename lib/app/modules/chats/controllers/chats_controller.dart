import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class ChatsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();

  final authService = Get.find<AuthService>();

  final chats = <Chat>[].obs;

  final isLoading = false.obs;

  StreamSubscription<DatabaseEvent>? _ref1;
  StreamSubscription<DatabaseEvent>? _ref2;

  @override
  void onInit() {
    super.onInit();
    final savedUser = authService.user.value;

    if (savedUser != null) {
      _listenToChats(savedUser.id);
    }
  }

  void _listenToChats(String userId) async {
    isLoading.value = true;

    final event = await db
        .child("list-of-chats/$userId")
        .orderByChild('lastMessageTime')
        .once(DatabaseEventType.value);

    final childrens = event.snapshot.children.toList().reversed.toList();

    for (var snapshot in childrens) {
      final key = snapshot.key ?? '';
      final json = snapshot.value as Map<dynamic, dynamic>;
      final chat = Chat.fromJson(key, json);
      chats.add(chat);
    }

    isLoading.value = false;

    _ref1 = db
        .child("list-of-chats/$userId")
        .orderByChild('lastMessageTime')
        .onChildChanged
        .listen((event) {
          final key = event.snapshot.key ?? '';
          final json = event.snapshot.value as Map<dynamic, dynamic>;
          final chat = Chat.fromJson(key, json);

          chats.removeWhere(
            (element) => element.otherUserId == chat.otherUserId,
          );

          chats.insert(0, chat);
        });

    _ref2 = db
        .child("list-of-chats/$userId")
        .orderByChild('lastMessageTime')
        .startAfter(key: 'lastMessageTime', chats.firstOrNull?.lastMessageTime)
        .onChildAdded
        .listen((event) {
          final key = event.snapshot.key ?? '';
          final json = event.snapshot.value as Map<dynamic, dynamic>;
          final chat = Chat.fromJson(key, json);

          chats.removeWhere(
            (element) => element.otherUserId == chat.otherUserId,
          );

          chats.insert(0, chat);
        });
  }

  @override
  void onClose() {
    _ref1?.cancel();
    _ref2?.cancel();
    super.onClose();
  }
}

class Chat {
  String name;
  String imageUrl;
  String lastMessage;
  int lastMessageTime;
  String lastMessageAuthor;
  String otherUserId;

  String get formattedTime {
    return DateFormat(
      'hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime * 1000));
  }

  String get formattedDate {
    return DateFormat(
      'MMM d',
    ).format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime * 1000));
  }

  Chat({
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageAuthor,
    required this.otherUserId,
  });

  factory Chat.fromJson(String key, Map<dynamic, dynamic> json) {
    return Chat(
      name: json['name'],
      imageUrl: json['imageUrl'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      lastMessageAuthor: json['lastMessageAuthor'],
      otherUserId: key,
    );
  }
}
