import 'package:circleapp/controller/getx_controllers/auth_controller.dart';
import 'package:circleapp/view/screens/loop_screens/add_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../controller/getx_controllers/convos_controller.dart';
import '../../../../controller/getx_controllers/stories_controller.dart';
import '../../../../controller/utils/app_colors.dart';
import '../../../../controller/utils/common_methods.dart';
import '../../../../controller/utils/customTextStyle.dart';
import '../../../../controller/utils/global_variables.dart';
import '../../../custom_widget/customwidgets.dart';
import '../../../custom_widget/media_widget.dart';
import '../convos/story_screen.dart';

Widget convosWidget(
    {required BuildContext mContext,
    StoryController? storyController,
    String? userImageUrl,
    required String circleId,
    required ConvosController convosController}) {
  return Obx(() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 12.h,
            child: storyController?.loading.value == true
                ? Shimmer.fromColors(
                    baseColor: AppColors.shimmerColor1,
                    highlightColor: AppColors.shimmerColor2,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 8,
                      itemExtent: 10.h,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: .8.h),
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                          ),
                        );
                      },
                    ))
                : Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: .8.h),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(() => CreateStoryScreen(circleId: circleId)),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryColor), shape: BoxShape.circle),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          Get.put(AuthController(mContext)).currentUserModel.value?.data.profilePicture ?? userimagePlaceholder),
                                      radius: 30,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 1.px,
                                    right: 0,
                                    child: Container(
                                      height: 25.px,
                                      width: 25.px,
                                      decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                                      child: Icon(Icons.add, size: 15.px, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.px),
                            const Text('Your Story', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                      if (storyController?.storiesModel.value?.data.isNotEmpty ?? false)
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: storyController?.storiesModel.value?.data.length,
                            itemBuilder: (context, index) {
                              final story = storyController!.storiesModel.value!.data[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: .8.h),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Get.to(() => StoryScreen(stories: Stories(imageUrl: storyController.storiesModel.value?.data[index].user.profilePicture?? "", userName: storyController.storiesModel.value?.data[index].user.name?? "", stories: storyController.storiesModel.value?.data[index].stories ?? []),)),
                                      child: Container(
                                        height: 62.px,
                                        width: 62.px,
                                        decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryColor), shape: BoxShape.circle),
                                        child: CircleAvatar(
                                          radius: 5.6.h,
                                          backgroundColor: AppColors.mainColor,
                                          backgroundImage: NetworkImage(story.user.profilePicture ?? ""),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 3.px),
                                    Text(
                                      story.user.name ?? "",
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          convosController.loading.value
              ? Expanded(
                  child: Shimmer.fromColors(
                    baseColor: AppColors.shimmerColor1,
                    highlightColor: AppColors.shimmerColor2,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: 10,
                            itemBuilder: (context, index) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.3.h),
                              alignment: Alignment.bottomCenter,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              height: 10.h,
                              decoration: BoxDecoration(color: AppColors.mainColor, borderRadius: BorderRadius.circular(10.px)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : convosController.messagesModel.value?.data.isEmpty ?? [].isEmpty
                  ? const Text("No Convos Added",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: convosController.messagesModel.value?.data.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final convos = convosController.messagesModel.value!.data[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.3.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    convos.senderProfilePicture,
                                    fit: BoxFit.cover,
                                    width: 35,
                                    height: 35,
                                    errorBuilder: (context, error, stackTrace) => Image.network(
                                      circleImagePlaceholder,
                                      fit: BoxFit.cover,
                                      width: 35,
                                      height: 35,
                                    ),
                                  ),
                                ),
                                getHorizentalSpace(3.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (convos.media.isNotEmpty)
                                      Container(
                                        width: 60.w,
                                        padding: EdgeInsets.all(5.px),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.textFieldColor,
                                          borderRadius: BorderRadius.circular(10.px),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            mediaWidget(convos.media, context: mContext, messengerController: convosController, isCurrentUser: false),
                                            if (convos.media.first.type != "audio" && convos.text.isNotEmpty)
                                              Container(
                                                margin: EdgeInsets.symmetric(vertical: 15.px),
                                                child: Text(convos.text, style: CustomTextStyle.messageDetailText, overflow: TextOverflow.visible),
                                              ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 60.w,
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.textFieldColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(convos.text, style: CustomTextStyle.messageDetailText),
                                      ),
                                    Container(
                                      margin: EdgeInsets.only(top: 5.px, bottom: 15.px),
                                      child: Text(
                                        getCurrentTimeIn12HourFormat(convos.sentAt),
                                        style: CustomTextStyle.messageDetailDate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  });
}
