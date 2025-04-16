import 'dart:async';
import 'dart:io';
import 'package:circleapp/controller/getx_controllers/chat_socket_controller.dart';
import 'package:circleapp/controller/getx_controllers/circle_controller.dart';
import 'package:circleapp/controller/getx_controllers/convos_controller.dart';
import 'package:circleapp/controller/getx_controllers/messenger_controller.dart';
import 'package:circleapp/controller/utils/shared_preferences.dart';
import 'package:circleapp/models/message_models/get_message_model.dart';
import 'package:circleapp/models/message_models/post_message_model.dart';
import 'package:circleapp/view/custom_widget/common_shimmer.dart';
import 'package:circleapp/view/screens/explore_section/early_bird_offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/getx_controllers/picker_controller.dart';
import '../../../controller/utils/app_colors.dart';
import '../../../controller/utils/common_methods.dart';
import '../../../controller/utils/global_variables.dart';
import '../../../controller/utils/preference_keys.dart';
import '../../../controller/utils/style/customTextStyle.dart';
import '../../../models/circle_models/circle_members_model.dart';
import '../../custom_widget/customwidgets.dart';
import '../../custom_widget/media_widget.dart';
import '../common_screens/audio_player.dart';
import '../common_screens/send_media_screen.dart';
import 'circle_profile_screen.dart';

class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({super.key, this.title, required this.itemId, required this.chatCircleImage, required this.chatCircleName});

  final String? title;
  final String itemId;
  final String chatCircleImage;
  final String chatCircleName;

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  late MessengerController messengerController;
  late CircleController circleController;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late ConvosController convosController;
  late String currentUserId;
  RxList<int> pinList = <int>[].obs;
  RxInt selectedIndex = 0.obs;
  final PickerController imagePickerController = Get.put(PickerController());
  RxString messageLength = ''.obs;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;
  RxString recordTimer = "00:00".obs;
  Timer? timer;
  String? audioFilePath;
  late ChatSocketService chatSocketService;
  List<String> circleMemberNames = [];

  @override
  void initState() {
    messengerController = Get.put(MessengerController(context));
    circleController = Get.put(CircleController(context));
    convosController = Get.put(ConvosController(context));
    messengerController
        .getMessages(
            load: messengerController.messagesModel.value == null || messengerController.messagesModel.value?.circleId != widget.itemId,
            circleId: widget.itemId)
        .then(
      (value) {
        messengerController.messagesModel.value?.data.refresh();
        scrollToEnd();
      },
    );
    currentUserId = MySharedPreferences.getString(currentUserIdKey);
    getCircleMembers();
    chatSocketService = Get.put(ChatSocketService());
    chatSocketService.removeMessageListeners();
    chatSocketService.listenForNewMessagesInChat(
      (circleId, message) {
        bool isMessageExist = messengerController.messagesModel.value!.data
            .any((existingMessage) => existingMessage.text == message.text && existingMessage.sentAt == message.sentAt);
        if (!isMessageExist) {
          scrollToEnd();
          messengerController.messagesModel.value!.data.add(message);
          messengerController.messagesModel.value!.data.refresh();
        } else {
          print('Duplicate message detected, skipping addition.');
        }
      },
    );

    super.initState();
  }

  Future<void> getCircleMembers() async {
    await circleController.getCircleMembers(load: circleController.circleMembersModel.value == null, circleId: widget.itemId);
    if (circleController.circleMembersModel.value != null) {
      circleMemberNames.clear();
      for (Member member in circleController.circleMembersModel.value!.members) {
        circleMemberNames.add(member.name);
      }
    }
  }

  void scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        if (scrollController.position.maxScrollExtent > 0) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    });
  }

  Future<void> _startRecording() async {
    isRecording.value = true;
  }

  Future<void> startRecording() async {
    isRecording.value = true;
    startTimer();
    Directory tempDir = await getTemporaryDirectory();
    audioFilePath = '${tempDir.path}/audio_record.aac';

    await _recorder.startRecorder(
      toFile: audioFilePath,
      codec: Codec.aacADTS,
    );
  }

  Future<void> stopRecording() async {
    isRecording.value = false;
    stopTimer();
    await _recorder.stopRecorder();
    isRecording.value = false;
    messengerController.setUpPlayerFile(audioFilePath!);
  }

  void startTimer() {
    int i = 0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      i++;
      recordTimer.value = '${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}';
    });
  }

  void stopTimer() {
    timer?.cancel();
    recordTimer.value = "00:00";
  }

  @override
  void dispose() {
    isMainChat = true;
    chatSocketService.leaveRoom(widget.itemId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Obx(
        () {
          return imagePickerController.pickedImage.value != null
              ? SendMediaScreen(
                  itemId: widget.itemId,
                )
              : Column(
                  children: [
                    getVerticalSpace(6.h),
                    Container(
                      height: 50.px,
                      padding: EdgeInsets.symmetric(horizontal: 1.5.h, vertical: 5.px),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (pinList.isNotEmpty) {
                                pinList.clear();
                              } else {
                                Get.back();
                              }
                            },
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 2.5.h,
                            ),
                          ),
                          getHorizentalSpace(2.h),
                          if (pinList.isNotEmpty) ...[
                            Text(
                              "${pinList.length}",
                              style: CustomTextStyle.buttonText.copyWith(color: Colors.white),
                            ),
                            Expanded(
                                child: SvgPicture.asset(
                              'assets/svg/pin.svg',
                              alignment: Alignment.centerRight,
                            )),
                            getHorizentalSpace(1.h),
                            Text('Pin', style: CustomTextStyle.headingStyle),
                            getHorizentalSpace(2.h),
                            GestureDetector(
                              onTap: () {
                                // Get.to(() => const CircleDetails());
                              },
                              child: convosController.loading.value
                                  ? LoadingAnimationWidget.progressiveDots(color: AppColors.mainColorYellow, size: 30.px)
                                  : GestureDetector(
                                      onTap: () {
                                        for (var pinned in pinList) {
                                          convosController
                                              .addToConvos(load: true, messageId: messengerController.messagesModel.value?.data[pinned].id ?? "")
                                              .then(
                                            (value) {
                                              pinList.clear();
                                              pinList.refresh();
                                            },
                                          );
                                        }
                                      },
                                      child: Text('Add to convos', style: CustomTextStyle.mediumTextTab)),
                            ),
                            getHorizentalSpace(1.h),
                          ] else ...[
                            messengerController.loading.value
                                ? Shimmer.fromColors(
                                    baseColor: AppColors.shimmerColor1,
                                    highlightColor: AppColors.shimmerColor2,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Get.to(() => CircleProfileScreen(circleId: widget.itemId));
                                    },
                                    child: widget.chatCircleImage == ""
                                        ? CircleAvatar(
                                            radius: 20.px,
                                            backgroundColor: AppColors.textFieldColor,
                                            backgroundImage: const AssetImage('assets/png/members.png'),
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              widget.chatCircleImage,
                                              fit: BoxFit.cover,
                                              width: 40,
                                              height: 40,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.network(
                                                  circleImagePlaceholder,
                                                  fit: BoxFit.cover,
                                                  width: 40,
                                                  height: 40,
                                                );
                                              },
                                            ),
                                          ),
                                  ),
                            getHorizentalSpace(1.5.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => CircleProfileScreen(circleId: widget.itemId));
                                  },
                                  child: messengerController.loading.value || circleController.loading.value
                                      ? commonShimmer(height: 30.px, width: 100.px)
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.chatCircleName,
                                              style: CustomTextStyle.headingStyle.copyWith(fontSize: 12.px),
                                            ),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 200,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  circleMemberNames.join(', '),
                                                  style: TextStyle(
                                                    fontSize: 10.px,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'medium',
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                            // SvgPicture.asset('assets/svg/audiocallicon.svg'),
                            // getHorizentalSpace(1.h),
                            // SvgPicture.asset('assets/svg/videocallicon.svg'),
                            // getHorizentalSpace(1.h),
                            // if (widget.title != 'loop')
                            //   GestureDetector(
                            //     onTap: () {},
                            //     child: SvgPicture.asset('assets/svg/loopicon.svg'),
                            //   ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Column(
                          children: [
                            Expanded(
                              child: Obx(
                                () => messengerController.loading.value
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
                                        ))
                                    : ListView.builder(
                                        controller: scrollController,
                                        itemCount: messengerController.messagesModel.value?.data.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          Datum message = messengerController.messagesModel.value!.data[index];
                                          print("Sender Id: ${message.senderId}");
                                          print("Current User Id: $currentUserId");
                                          bool isCurrentUser = message.senderId == currentUserId;
                                          return GestureDetector(
                                            onTap: () {
                                              if (pinList.isNotEmpty) {
                                                pinList.contains(index) ? pinList.remove(index) : pinList.add(index);
                                              }
                                            },
                                            onLongPress: () {
                                              if (!pinList.contains(index)) {
                                                pinList.add(index);
                                              }
                                            },
                                            child: Stack(children: [
                                              pinList.contains(index)
                                                  ? Container(
                                                      padding: EdgeInsets.only(right: 4.h),
                                                      margin: EdgeInsets.only(bottom: 1.h),
                                                      alignment: isCurrentUser ? Alignment.centerLeft : Alignment.centerRight,
                                                      height: 7.7.h,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: SvgPicture.asset('assets/svg/selected.svg'),
                                                    )
                                                  : const SizedBox.shrink(),
                                              Row(
                                                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  //Sender profile picture for any type of message if not current user
                                                  if (!isCurrentUser) ...[
                                                    ClipOval(
                                                      child: Image.network(
                                                        message.senderProfilePicture,
                                                        fit: BoxFit.cover,
                                                        width: 35,
                                                        height: 35,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Image.network(
                                                            circleImagePlaceholder,
                                                            fit: BoxFit.cover,
                                                            width: 35,
                                                            height: 35,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                  getHorizentalSpace(3.w),
                                                  Column(
                                                    crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                    children: [
                                                      //Plan Type message
                                                      if (message.type == "plan") ...[
                                                        Text(
                                                          "Here will be offer or plan",
                                                          style: CustomTextStyle.messageDetailDate,
                                                        ),
                                                      ]
                                                      //Offer type message
                                                      else if (message.type == "offer") ...[
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() => OfferDetails(offer: message.offerDetails!));
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 2.2.h, vertical: 2.h),
                                                            width: MediaQuery.of(context).size.width * 0.75,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(20),
                                                              color: AppColors.textFieldColor,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text("Offer", style: CustomTextStyle.headingStyle,),
                                                                getVerticalSpace(10.px),
                                                                offerCard(
                                                                  title: message.offerDetails!.title,
                                                                  description: message.offerDetails!.description,
                                                                  interest: message.offerDetails!.interest,
                                                                  price: message.offerDetails!.price,
                                                                  startingDate: message.offerDetails!.startingDate,
                                                                  numberOfPeople: message.offerDetails!.numberOfPeople,
                                                                  imageUrls: message.offerDetails!.imageUrls,
                                                                  showShare: false,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                      //Text message type
                                                      else ...[
                                                        //Text if type is not text
                                                        if (message.media.isNotEmpty) ...[
                                                          Container(
                                                            width: 60.w,
                                                            padding: EdgeInsets.only(top: 5.px, left: 5.px, right: 5.px),
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              color: isCurrentUser ? AppColors.mainColorYellow : AppColors.textFieldColor,
                                                              borderRadius: BorderRadius.only(
                                                                bottomLeft: Radius.circular(10.px),
                                                                bottomRight: Radius.circular(10.px),
                                                                topRight: isCurrentUser ? Radius.circular(0.px) : Radius.circular(10.px),
                                                                topLeft: isCurrentUser ? Radius.circular(10.px) : Radius.circular(0.px),
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                mediaWidget(message.media,
                                                                    context: context,
                                                                    messengerController: messengerController,
                                                                    isCurrentUser: isCurrentUser),
                                                                if (message.media.first.type != "audio" && message.text != "") ...[
                                                                  Container(
                                                                    margin: EdgeInsets.symmetric(vertical: 15.px),
                                                                    child: Text(
                                                                      message.text,
                                                                      style: isCurrentUser
                                                                          ? CustomTextStyle.currentUserMessageDetailText
                                                                          : CustomTextStyle.messageDetailText,
                                                                      overflow: TextOverflow.visible,
                                                                    ),
                                                                  )
                                                                ] else ...[
                                                                  getVerticalSpace(5.px),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                        ]
                                                        //Text it type is text
                                                        else ...[
                                                          Container(
                                                            width: 60.w,
                                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              color: isCurrentUser ? AppColors.mainColorYellow : AppColors.textFieldColor,
                                                              borderRadius: BorderRadius.only(
                                                                bottomLeft: const Radius.circular(10),
                                                                bottomRight: const Radius.circular(10),
                                                                topRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(10),
                                                                topLeft: isCurrentUser ? const Radius.circular(10) : const Radius.circular(0),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              message.text,
                                                              style: isCurrentUser
                                                                  ? CustomTextStyle.currentUserMessageDetailText
                                                                  : CustomTextStyle.messageDetailText,
                                                            ),
                                                          )
                                                        ],
                                                      ],
                                                      //Date time
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          top: 5.px,
                                                          bottom: 15.px,
                                                        ),
                                                        child: Text(
                                                          getCurrentTimeIn12HourFormat(message.sentAt),
                                                          style: CustomTextStyle.messageDetailDate,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ]),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (audioFilePath != null && !isRecording.value) ...[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 10.px),
                                      padding: EdgeInsets.symmetric(horizontal: .8.h),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.px), color: AppColors.mainColorYellow),
                                      child: audioPlayerItem(
                                        context: context,
                                        controller: messengerController,
                                        isCurrentUser: true,
                                        buttonpress: () {
                                          messengerController.playPause2();
                                        },
                                        onChange: (value) {
                                          messengerController.player2.seek(
                                            Duration(
                                              milliseconds: value.toInt(),
                                            ),
                                          );
                                        },
                                        player: messengerController.player2,
                                      ),
                                    ),
                                  )
                                ] else ...[
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 10.px),
                                      padding: EdgeInsets.symmetric(horizontal: .8.h),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.px), color: AppColors.mainColor),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/svg/icons.svg'),
                                          getHorizentalSpace(.8.h),
                                          Expanded(
                                            child: TextFormField(
                                              controller: messageController,
                                              onChanged: (value) {
                                                messageLength.value = value;
                                              },
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              cursorHeight: 2.h,
                                              style: CustomTextStyle.hintText,
                                              cursorColor: Colors.white,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.px),
                                                  borderSide: const BorderSide(
                                                    color: AppColors.textFieldColor,
                                                  ),
                                                ),
                                                focusedBorder: const OutlineInputBorder(
                                                  borderSide: BorderSide(color: AppColors.textFieldColor),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.px),
                                                  borderSide: const BorderSide(color: AppColors.textFieldColor),
                                                ),
                                                isCollapsed: true,
                                                contentPadding: EdgeInsets.symmetric(vertical: 1.6.h),
                                                fillColor: AppColors.textFieldColor,
                                                hintText: 'Write your message',
                                                hintStyle: CustomTextStyle.hintText,
                                              ),
                                            ),
                                          ),
                                          getHorizentalSpace(.8.h),
                                          GestureDetector(
                                            onTap: () {
                                              imagePickerController.pickImageOrVideo();
                                            },
                                            child: SvgPicture.asset('assets/svg/camera.svg'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isRecording.value) ...[
                                    getHorizentalSpace(1.h),
                                    Tooltip(
                                      message: '',
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Text(recordTimer.value,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.6),
                                          )),
                                    ),
                                  ],
                                ],
                                getHorizentalSpace(1.h),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.px),
                                  child: Obx(
                                    () => messageLength.value.isEmpty && imagePickerController.pickedImage.value == null
                                        ? GestureDetector(
                                            onTap: () {
                                              isRecording.value ? stopRecording() : startRecording();
                                            },
                                            child: SvgPicture.asset(
                                                isRecording.value ? 'assets/svg/voice_recorder_red.svg' : 'assets/svg/voicerecorder.svg'))
                                        : GestureDetector(
                                            onTap: () {
                                              if (messageLength.value.isNotEmpty) {
                                                String message = messageLength.value;
                                                messageLength.value = "";
                                                messageController.clear();
                                                messengerController
                                                    .sendMessage(
                                                  load: false,
                                                  postMessageModel: PostMessageModel(
                                                    circleId: widget.itemId,
                                                    message: message,
                                                    media: [],
                                                  ),
                                                )
                                                    .then(
                                                  (value) {
                                                    scrollToEnd();
                                                  },
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(13.px),
                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.mainColorYellow),
                                              child: Icon(
                                                Icons.send,
                                                size: 2.h,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
