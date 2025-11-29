import 'package:api_task/app/modules/chat_details/controllers/chat_details_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatDetailsView extends GetView<ChatDetailsController> {
  const ChatDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF443C42),
        title: Text(
          controller.chat.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: controller.obx(
        (msgs) {
          final messages = msgs ?? [];

          return Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];

                    final isMe =
                        msg.senderId == controller.authService.user.value?.id;
                    final bubbleColor = isMe
                        ? const Color(0xFFEFEFEF)
                        : const Color(0xFFE6F2E6);
                    final align = isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start;

                    return Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: align,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onLongPressStart: isMe
                                    ? (details) async {
                                        final tapPosition =
                                            details.globalPosition;

                                        final value = await showMenu<String>(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                            tapPosition.dx - 130,
                                            tapPosition.dy,
                                            tapPosition.dx,
                                            tapPosition.dy - 40,
                                          ),
                                          items: const [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('حذف الرسالة'),
                                            ),
                                          ],
                                        );

                                        if (value == 'delete') {
                                          controller.deleteMessageForEveryone(
                                            msg,
                                          );
                                        }
                                      }
                                    : null,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    msg.message,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              msg.messageTime,
                            ),
                          ),
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: messages.length,
                ),
              ),
              _InputBar(),
            ],
          );
        },
        onLoading: const Center(child: CircularProgressIndicator()),

        onEmpty: Column(
          children: const [
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            _InputBar(),
          ],
        ),
        onError: (err) => Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Error loading chat',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            const _InputBar(),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends GetView<ChatDetailsController> {
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
              onPressed: () {
                controller.sendMessages();
              },
              icon: const Icon(Icons.send, size: 22),
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'Write your message'.tr,
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
