import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/support_screen/chat_support_controller.dart';

class ChatSupportScreen extends GetView<ChatSupportController> {
  const ChatSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Chat Support',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CommonButton(
              label: 'End Chat',
              onTap: controller.onEndChat,
              fullWidth: false,
              height: 36,
              borderRadius: 20,
              backgroundColor: Colors.white,
              foregroundColor: AppColor.brownAccentPrimary,
              boxShadow: const [],
              textStyle: AppTextStyle.buttonSmall,
              paddingHorizontal: 14,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Agent info card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: const AssetImage('assets/images/person_image.png'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Support Agent',
                        style: AppTextStyle.titleSmallSemiBold
                            .copyWith(color: AppColor.blackShade1)),
                    Row(
                      children: [
                        Text('Marcus', style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText)),
                        const SizedBox(width: 4),
                        const Text('•', style: TextStyle(color: AppColor.coolGrayText)),
                        const SizedBox(width: 4),
                        Text('Online',
                            style: AppTextStyle.bodySmallMedium
                                .copyWith(color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.messages.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Today, 10:24 AM',
                          style: AppTextStyle.bodySmallRegular
                              .copyWith(color: AppColor.coolGrayText)),
                    ),
                  );
                }
                if (index == controller.messages.length + 1) {
                  return Obx(() => controller.isAgentTyping.value
                      ? _TypingBubble()
                      : const SizedBox.shrink());
                }
                final msg = controller.messages[index - 1];
                return _MessageBubble(message: msg);
              },
            )),
          ),

          // Quick actions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...['Track Refund', 'Talk to Expert', 'Billing FAQ'].map((label) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColor.lightGreyColor),
                        ),
                        child: Text(label,
                            style: AppTextStyle.bodySmallMedium
                                .copyWith(color: AppColor.blackShade1)),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          // Counter Offer Section

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: const Icon(Icons.add, size: 20, color: AppColor.coolGrayText),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyle.bodyMediumRegular
                          .copyWith(color: AppColor.coolGrayText),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.image_outlined, color: AppColor.coolGrayText, size: 22),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.sendMessage,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.brownAccentPrimary,
              child: Text('1A',
                  style: AppTextStyle.labelSmallMedium.copyWith(
                      color: Colors.white, fontSize: 9)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColor.brownAccentPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser ? null : Border.all(color: AppColor.lightGreyColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: isUser ? Colors.white : AppColor.blackShade1,
                          height: 1.5,
                        ),
                      ),
                      if (message.imagePath != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(message.imagePath!,
                              width: 180, fit: BoxFit.cover),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(message.time,
                    style: AppTextStyle.bodySmallRegular
                        .copyWith(color: AppColor.coolGrayText, fontSize: 11)),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColor.brownAccentPrimary,
            child: Text('1A',
                style: AppTextStyle.labelSmallMedium
                    .copyWith(color: Colors.white, fontSize: 9)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColor.lightGreyColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                    color: AppColor.coolGrayText,
                    shape: BoxShape.circle,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
