import 'dart:convert';
import 'package:circleapp/controller/getx_controllers/messenger_controller.dart';
import 'package:circleapp/controller/utils/global_variables.dart';
import 'package:circleapp/controller/utils/style/customTextStyle.dart';
import 'package:circleapp/models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controller/getx_controllers/chat_socket_controller.dart';
import '../../../controller/utils/app_colors.dart';
import '../../../controller/utils/common_methods.dart';
import '../../../controller/utils/shared_preferences.dart';
import '../../custom_widget/customwidgets.dart';
import '../choose_image.dart';
import 'message_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with WidgetsBindingObserver {
  late MessengerController messengerController;
  late ChatSocketService chatSocketService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    messengerController = Get.put(MessengerController(context));
    messengerController.getConversations(load: true);
    chatSocketService = Get.put(ChatSocketService());
    chatSocketService.emitChatScreenOpen();
    startListeningForMessages();
  }

  void startListeningForMessages() {
    chatSocketService.listenForNewMessagesInList(
      (circleId, message) {
        if (messengerController.conversationModel.value != null) {
          for (var conversation in messengerController.conversationModel.value!.data) {
            if (conversation.circleId == circleId && message.senderId != currentUserId) {
              conversation.latestMessage.text = message.text != "" ? message.text : "Media";
              conversation.latestMessage.sentAt = message.sentAt;
              conversation.unreadCount++;
              messengerController.conversationModel.refresh();
              MySharedPreferences.setInt(circleId, conversation.unreadCount);
            }
          }
        }
        print('Received message in circle $circleId: ${json.encode(message.toJson())}');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    chatSocketService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColors.mainColorBackground,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.h),
            child: Column(
              children: [
                getVerticalSpace(7.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Circles", style: CustomTextStyle.mediumTextExplore),
                    GestureDetector(
                      onTap: () => Get.to(() => const ChooseImage()),
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 2.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.mainColorYellow),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add_sharp, color: AppColors.mainColorYellow),
                            getHorizentalSpace(0.5.w),
                            Text("New Group", style: CustomTextStyle.mediumTextYellow),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                getVerticalSpace(2.h),
                Expanded(
                  child: messengerController.conversationModel.value == null
                      ? Shimmer.fromColors(
                          baseColor: AppColors.shimmerColor1,
                          highlightColor: AppColors.shimmerColor2,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.bottomCenter,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                height: 10.h,
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius.circular(10.px),
                                ),
                              );
                            },
                          ),
                        )
                      : messengerController.conversationModel.value!.data.isEmpty
                          ? const Center(
                              child: Text(
                                "No Circles",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: messengerController.conversationModel.value!.data.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                Datum item = messengerController.conversationModel.value!.data[index];
                                item.unreadCount = MySharedPreferences.getInt(item.circleId);

                                return GestureDetector(
                                  onTap: () {
                                    chatSocketService.joinRoom(item.circleId);
                                    item.unreadCount = 0; // Reset unread count on tap
                                    messengerController.conversationModel.refresh(); // Refresh the model
                                    MySharedPreferences.setInt(item.circleId, 0);
                                    isMainChat = false;
                                    Get.to(
                                      () => MessageDetailScreen(
                                        itemId: item.circleId,
                                        chatCircleImage: item.circleImage,
                                        chatCircleName: item.circleName,
                                      ),
                                    )?.then(
                                      (value) {
                                        chatSocketService.removeMessageListeners();
                                        startListeningForMessages();
                                        messengerController.getConversations(load: true);
                                      },
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 1.5.h),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.textFieldColor,
                                    ),
                                    child: ListTile(
                                      title: Text(item.circleName, style: CustomTextStyle.mediumTextTitle, overflow: TextOverflow.ellipsis),
                                      subtitle: item.latestMessage.text.isNotEmpty || (item.unreadCount > 0)
                                          ? Text(
                                              item.latestMessage.text.isNotEmpty
                                                  ? item.latestMessage.text
                                                  : item.unreadCount > 0
                                                      ? "Media"
                                                      : "",
                                              style: CustomTextStyle.mediumTextSubtitle,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : const SizedBox.shrink(), // Won't take any space when text is empty
                                      leading: ClipOval(
                                        child: Image.network(
                                          item.circleImage,
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.network(
                                              circleImagePlaceholder,
                                              fit: BoxFit.cover,
                                              width: 60,
                                              height: 60,
                                            );
                                          },
                                        ),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (item.latestMessage.text.isNotEmpty) // Only show if text is not empty
                                            Text(TimeAgoSinceDate(item.latestMessage.sentAt), style: CustomTextStyle.mediumTextTime),
                                          getVerticalSpace(1.w),
                                          if (item.unreadCount > 0)
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: AppColors.mainColorYellow,
                                                borderRadius: BorderRadius.circular(30),
                                                border: Border.all(color: AppColors.mainColorYellow),
                                              ),
                                              child: Center(
                                                child: Text(item.unreadCount.toString(), style: CustomTextStyle.mediumTextNumber),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ));
  }
}
