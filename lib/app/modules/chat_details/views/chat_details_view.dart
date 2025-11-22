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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          controller.chat.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final msgs = controller.messages;

        return Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final msgs = controller.messages;

                  final isMe =
                      msgs[index].senderId ==
                      controller.authService.user.value?.id;
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
                                msgs[index].message,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            msgs[index].messageTime * 1000,
                          ),
                        ),
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: msgs.length,
              ),
            ),

            _InputBar(),
          ],
        );
      }),
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
