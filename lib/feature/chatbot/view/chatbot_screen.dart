import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/chatbot/controller/chatbot_controller.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/utils/dimensions.dart';
import 'package:demandium/utils/styles.dart';

class ChatbotBottomSheet extends StatefulWidget {
  const ChatbotBottomSheet({Key? key}) : super(key: key);

  @override
  State<ChatbotBottomSheet> createState() => _ChatbotBottomSheetState();
}

class _ChatbotBottomSheetState extends State<ChatbotBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ChatbotController>()) {
      Get.put(ChatbotController());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, // ensure we scroll past typing indicator
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(Images.logo, width: 25), // use app logo
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dirt2Tidy Expert",
                        style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                      ),
                      Text(
                        "Online",
                        style: robotoRegular.copyWith(color: Colors.white70, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          
          // Chat List
          Expanded(
            child: GetX<ChatbotController>(
              builder: (controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.messages.length) {
                      return _buildTypingIndicator();
                    }
                    
                    var msg = controller.messages[index];
                    return _buildMessageBubble(msg, context);
                  },
                );
              },
            ),
          ),

          // Quick Replies
          GetX<ChatbotController>(
            builder: (controller) {
              if (controller.quickReplies.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: controller.quickReplies.map((reply) {
                    return ActionChip(
                      label: Text(reply, style: robotoRegular.copyWith(fontSize: 13, color: Theme.of(context).primaryColor)),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      onPressed: () => controller.handleUserInput(reply),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 10),

          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Get.find<ChatbotController>().handleUserInput(val.trim());
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      Get.find<ChatbotController>().handleUserInput(_messageController.text.trim());
                      _messageController.clear();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, BuildContext context) {
    bool isUser = msg.isUser;
    
    // Check if it's a link message from bot
    bool isLink = msg.text.startsWith("LINK:");
    String displayText = msg.text;
    String? linkUrl;
    String? linkLabel;
    
    if (isLink && !isUser) {
      var parts = msg.text.substring(5).split('|');
      if (parts.length == 2) {
        linkUrl = parts[0];
        linkLabel = parts[1];
        displayText = linkLabel;
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: isLink 
            ? InkWell(
                onTap: () {
                  if (linkUrl != null) {
                    Get.back(); // close chatbot
                    // Handle routing
                    // Example: /category-service-form?categoryId=...
                    Uri uri = Uri.parse(linkUrl);
                    String? catId = uri.queryParameters['categoryId'];
                    if (catId != null) {
                       Get.toNamed(RouteHelper.getCategoryServiceFormRoute(catId, 'Service', ''));
                    }
                  }
                },
                child: Text(
                  displayText,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                ),
              )
            : Text(
                displayText.replaceAll('**', ''), // A simple way to strip ** formatting for now
                style: robotoRegular.copyWith(color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Text("Typing...", style: robotoRegular.copyWith(color: Colors.grey, fontStyle: FontStyle.italic)),
      ),
    );
  }
}
