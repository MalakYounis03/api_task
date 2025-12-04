import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class ChatsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();

  final authService = Get.find<AuthService>();

  late final savedUser = authService.user.value!;

  final chats = <Chat>[].obs;

  final isLoading = false.obs;

  StreamSubscription<DatabaseEvent>? _newMessageRef;
  StreamSubscription<DatabaseEvent>? _changedSub;
  StreamSubscription<DatabaseEvent>? _removedSub;

  late final ref = db.child("list-of-chats/${savedUser.id}").orderByChild('lastMessageTime');

  @override
  onInit() {
    super.onInit();
    getChats();
  }

  getChats() async {
    isLoading.value = true;

    final event = await db
        .child("list-of-chats/${savedUser.id}")
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

    listenForNew();
    listenForChanges();
  }

  listenForNew() {
    //

    _newMessageRef?.cancel();

    _newMessageRef = ref.startAfter(key: 'lastMessageTime', chats.firstOrNull?.lastMessageTime).onChildAdded.listen((
      event,
    ) {
      //

      print('onChildAdded');

      final key = event.snapshot.key ?? '';
      final json = event.snapshot.value as Map<dynamic, dynamic>;
      final chat = Chat.fromJson(key, json);

      chats.removeWhere((element) => element.otherUserId == chat.otherUserId);

      chats.insert(0, chat);

      listenForNew();
    });
  }

  listenForChanges() {
    _changedSub = ref.onChildChanged.listen((event) {
      final key = event.snapshot.key ?? '';
      final data = event.snapshot.value;
      if (data == null) return;

      final json = data as Map<dynamic, dynamic>;
      final updatedChat = Chat.fromJson(key, json);
      final index = chats.indexWhere((c) => c.otherUserId == updatedChat.otherUserId);

      if (index != -1) {
        chats[index] = updatedChat;
      } else {
        chats.add(updatedChat);
      }

      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });

    _removedSub = ref.onChildRemoved.listen((event) {
      final key = event.snapshot.key ?? '';
      chats.removeWhere((c) => c.otherUserId == key);
    });
  }

  @override
  void onClose() {
    _newMessageRef?.cancel();
    _changedSub?.cancel();
    _removedSub?.cancel();
    super.onClose();
  }
}

class Chat {
  String name;
  String imageUrl;
  String otherUserId;
  String lastMessage;
  String lastMessageAuthor;
  int lastMessageTime;

  String get formattedTime {
    return DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime * 1000));
  }

  String get formattedDate {
    return DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(lastMessageTime * 1000));
  }

  Chat({
    required this.name,
    required this.imageUrl,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageAuthor,
  });

  factory Chat.fromJson(String key, Map<dynamic, dynamic> json) {
    return Chat(
      name: json['name'],
      imageUrl: json['imageUrl'],
      otherUserId: key,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      lastMessageAuthor: json['lastMessageAuthor'],
    );
  }
}
