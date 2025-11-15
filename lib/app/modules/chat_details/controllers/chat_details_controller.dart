import 'package:api_task/app/modules/chat_details/model/chat_details_model.dart';
import 'package:api_task/app/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class ChatDetailsController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final authService = Get.find<AuthService>();

  late final String chatId;
  late final String otherName;
  late final String currentUserId;
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    final String otherUserId = args["otherUserId"];
    otherName = args["name"];
    final savedUser = authService.user.value;
    currentUserId = savedUser!.id;
    chatId = buildChatId(currentUserId, otherUserId);
    fetchMessages();
  }

  String buildChatId(String id1, String id2) {
    final ids = [id1, id2];
    ids.sort();
    final reversed = ids.reversed.toList();
    return reversed.join('____');
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;

    try {
      final snapshot = await db.child("chat-details/$chatId/messages").get();

      print("**********chatId********************");
      print(chatId);
      print("**********snapshot********************");
      print(snapshot.value);

      final temp = <ChatMessage>[];

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((msgId, msgData) {
          final msgMap = msgData as Map<dynamic, dynamic>;
          temp.add(ChatMessage.fromMap(msgId as String, msgMap));
          print("**********id********************");
          print(msgId);
          print("**********data********************");

          print(msgMap);
        });

        temp.sort((a, b) => a.messageTime.compareTo(b.messageTime));
      }

      messages.assignAll(temp);
    } finally {
      isLoading.value = false;
    }
  }
}
