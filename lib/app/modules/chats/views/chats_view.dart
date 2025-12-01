import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/modules/chats/controllers/chats_controller.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ChatsView extends GetView<ChatsController> {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    final savedUser = authService.user.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF443C42),
        title: Text('Chats'.tr, style: TextStyle(fontSize: 18)),
      ),
      body: controller.obx(
        (chat) {
          final chats = chat ?? [];

          return ListView.separated(
            itemCount: chats.length,
            padding: EdgeInsets.all(16),
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = chats[index];

              final String currentUserId = savedUser!.id;
              final String senderName;

              if (chat.lastMessageAuthor == currentUserId) {
                senderName = "You";
              } else {
                senderName = chat.name;
              }

              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Color(0xFFEBEBEB).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () => Get.toNamed(
                    Routes.chatDetails,
                    arguments: {"chat": ChatDetails.existChat(chat)},
                  ),

                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat.imageUrl),
                  ),
                  title: Text(chat.name),
                  subtitle: Text("$senderName: ${chat.lastMessage}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(chat.formattedTime),
                      Text(chat.formattedDate),
                    ],
                  ),
                ),
              );
            },
          );
        },
        onLoading: const Center(child: CircularProgressIndicator()),
        onEmpty: const Center(child: Text("No chats yet")),
        onError: (err) => Center(
          child: Text(
            "Error loading chats",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
