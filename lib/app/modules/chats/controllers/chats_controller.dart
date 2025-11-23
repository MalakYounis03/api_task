import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class ChatsController extends GetxController with StateMixin<List<Chat>> {
  final db = FirebaseDatabase.instance.ref();

  final authService = Get.find<AuthService>();

  final chats = <Chat>[];

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
    change(null, status: RxStatus.loading());
    final ref = db
        .child("list-of-chats/$userId")
        .orderByChild('lastMessageTime');
    final event = await ref.once(DatabaseEventType.value);

    final childrens = event.snapshot.children.toList().reversed.toList();

    for (var snapshot in childrens) {
      final key = snapshot.key ?? '';
      final json = snapshot.value as Map<dynamic, dynamic>;
      final chat = Chat.fromJson(key, json);
      chats.add(chat);
    }

    if (chats.isEmpty) {
      change(<Chat>[], status: RxStatus.empty());
    } else {
      change(chats, status: RxStatus.success());
    }
    _ref1 = ref.onChildChanged.listen((event) {
      final key = event.snapshot.key ?? '';
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      final chat = Chat.fromJson(key, json);

      chats.removeWhere((element) => element.otherUserId == chat.otherUserId);

      chats.insert(0, chat);
      change(chats, status: RxStatus.success());
    });
    final lastTime = chats.firstOrNull?.lastMessageTime;
    Query query = ref;
    if (lastTime != null) {
      query = ref.startAt(lastTime + 1);
    }

    _ref2 = query.onChildAdded.listen((event) {
      final key = event.snapshot.key ?? '';
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      final chat = Chat.fromJson(key, json);

      chats.removeWhere((element) => element.otherUserId == chat.otherUserId);

      chats.insert(0, chat);
      change(chats, status: RxStatus.success());
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
    ).format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime));
  }

  String get formattedDate {
    return DateFormat(
      'MMM d',
    ).format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime));
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
