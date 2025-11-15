import 'package:api_task/app/modules/chats/controllers/chats_controller.dart';
import 'package:api_task/app/routes/app_pages.dart';
import 'package:api_task/app/service/auth_service.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatsView extends GetView<ChatsController> {
  const ChatsView({super.key});
  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    final savedUser = authService.user.value;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF443C42),
        title: Text('Chats'.tr, style: TextStyle(fontSize: 18)),
      ),
      body: FutureBuilder(
        future: controller.fetchChats(savedUser!.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final String lastAuthorId = chat["lastMessageAuthor"];
              final String otherName = chat["name"];
              final String currentUserId = savedUser.id;
              String senderName;

              if (lastAuthorId == currentUserId) {
                senderName = "You";
              } else {
                senderName = otherName;
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFEBEBEB).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () {
                    Get.toNamed(
                      Routes.chatDetails,
                      arguments: {
                        "otherUserId": chat["otherUserId"],
                        "name": chat["name"],
                      },
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat["imageUrl"]),
                  ),
                  title: Text(chat["name"]),
                  subtitle: Row(
                    children: [
                      Text("$senderName : "),
                      Text(chat["lastMessage"]),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            chat["lastMessageTime"] * 1000,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            chat["lastMessageTime"] * 1000,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
