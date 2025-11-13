import 'package:api_task/app/modules/home/controllers/home_controller.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ChatDetailsView extends GetView<HomeController> {
  const ChatDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    final msgs = <_Msg>[
      _Msg('1 هنا يوضع نص الرسالة', isMe: false, date: '15-7-2023'),
      _Msg('2 هنا يوضع نص الرسالة', isMe: true, date: '15-7-2023'),
      _Msg('3 هنا يوضع نص الرسالة', isMe: false, date: '15-7-2023'),
      _Msg('4 هنا يوضع نص الرسالة', isMe: false, date: '15-7-2023'),
      _Msg('5 هنا يوضع نص الرسالة', isMe: true, date: '15-7-2023'),
      _Msg('6 هنا يوضع نص الرسالة', isMe: false, date: '15-7-2023'),
    ];

    final authService = Get.find<AuthService>();

    final savedUser = authService.user.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF443C42),

        title: Text(
          savedUser!.username,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) =>
                  ChatBubble(msg: msgs.reversed.toList()[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemCount: msgs.length,
            ),
          ),

          const _InputBar(),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final _Msg msg;
  const ChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = msg.isMe
        ? const Color(0xFFEFEFEF)
        : const Color(0xFFE6F2E6);
    final align = msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Column(
      crossAxisAlignment: msg.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: align,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(msg.text, style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(msg.date, style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send, size: 22),
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Write your message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  final String date;
  _Msg(this.text, {required this.isMe, required this.date});
}
