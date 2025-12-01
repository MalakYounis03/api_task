import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class ChatsController extends GetxController with StateMixin<List<Chat>> {
  final db = FirebaseDatabase.instance.ref();

  final authService = Get.find<AuthService>();
  late final savedUser = authService.user.value;

  final chats = <Chat>[];

  StreamSubscription<DatabaseEvent>? _ref;
  StreamSubscription<DatabaseEvent>? _changedSub;
  StreamSubscription<DatabaseEvent>? _removedSub;

  @override
  void onInit() {
    super.onInit();
    getChats();
  }

  getChats() async {
    change(null, status: RxStatus.loading());
    final event = await db
        .child("list-of-chats/${savedUser!.id}")
        .orderByChild('lastMessageTime')
        .once(DatabaseEventType.value);

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
      change(List<Chat>.from(chats), status: RxStatus.success());
    }
    listenForUpdates();
  }

  listenForUpdates() {
    _ref?.cancel();
    final ref = db
        .child("list-of-chats/${savedUser!.id}")
        .orderByChild('lastMessageTime');
    _ref = ref
        .startAfter(key: 'lastMessageTime', chats.firstOrNull?.lastMessageTime)
        .onChildAdded
        .listen((event) {
          //

          print('onChildAdded');

          final key = event.snapshot.key ?? '';
          final json = event.snapshot.value as Map<dynamic, dynamic>;
          final chat = Chat.fromJson(key, json);

          chats.removeWhere(
            (element) => element.otherUserId == chat.otherUserId,
          );

          chats.insert(0, chat);
          change(List<Chat>.from(chats), status: RxStatus.success());

          listenForUpdates();
        });

    _changedSub = ref.onChildChanged.listen((event) {
      final key = event.snapshot.key ?? '';
      final data = event.snapshot.value;
      if (data == null) return;

      final json = data as Map<dynamic, dynamic>;
      final updatedChat = Chat.fromJson(key, json);
      final index = chats.indexWhere(
        (c) => c.otherUserId == updatedChat.otherUserId,
      );
      if (index != -1) {
        chats[index] = updatedChat;
      } else {
        chats.add(updatedChat);
      }

      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      change(List<Chat>.from(chats), status: RxStatus.success());
    });

    _removedSub = ref.onChildRemoved.listen((event) {
      final key = event.snapshot.key ?? '';
      chats.removeWhere((c) => c.otherUserId == key);

      if (chats.isEmpty) {
        change(<Chat>[], status: RxStatus.empty());
      } else {
        change(List<Chat>.from(chats), status: RxStatus.success());
      }
    });
  }

  @override
  void onClose() {
    _ref?.cancel();
    _changedSub?.cancel();
    _removedSub?.cancel();
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
