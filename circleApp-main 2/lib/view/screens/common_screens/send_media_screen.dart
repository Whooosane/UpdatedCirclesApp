import 'dart:io';
import 'package:circleapp/controller/getx_controllers/chat_socket_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import '../../../controller/getx_controllers/messenger_controller.dart';
import '../../../controller/getx_controllers/picker_controller.dart';
import '../../../controller/utils/app_colors.dart';
import '../../../controller/utils/common_methods.dart';
import '../../../controller/utils/customTextStyle.dart';
import '../../../controller/utils/preference_keys.dart';
import '../../../controller/utils/shared_preferences.dart';
import '../../../models/message_models/get_message_model.dart';
import '../../../models/message_models/post_message_model.dart';
import '../../custom_widget/customwidgets.dart';

class SendMediaScreen extends StatefulWidget {
  final String itemId;

  const SendMediaScreen({super.key, required this.itemId});

  @override
  State<SendMediaScreen> createState() => _SendMediaScreenState();
}

class _SendMediaScreenState extends State<SendMediaScreen> {
  final TextEditingController messageController = TextEditingController();

  late MessengerController messengerController;
  late ChatSocketService chatSocketService;
  late String currentUserId;
  VideoPlayerController? _controller;

  Rx<bool> isPlaying = false.obs;
  Rx<bool> isBuffering = false.obs;
  Rx<bool> isCompleted = false.obs;
  Rx<double> progress = (0.0).obs;

  @override
  void initState() {
    messengerController = Get.put(MessengerController(context));
    chatSocketService = Get.put(ChatSocketService());
    currentUserId = MySharedPreferences.getString(currentUserIdKey);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PickerController imagePickerController = Get.put(PickerController());
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          imagePickerController.pickedImage.value = null;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.7),
          ),
          body: Column(
            children: [
              if (isImageFile(imagePickerController.pickedImage.value)) ...[
                Expanded(
                    child: PhotoView(
                  imageProvider: FileImage(
                    File(imagePickerController.pickedImage.value!.path),
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 1.8,
                  initialScale: PhotoViewComputedScale.contained,
                )),
              ] else ...[
                Expanded(
                  child: buildVideoPlayer(File(imagePickerController.pickedImage.value!.path)),
                ),
                buildVideoControls(),
              ],
              Container(
                margin: EdgeInsets.only(right: 10.px, bottom: 10.px, left: 10.px),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.textFieldColor)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.px), borderSide: const BorderSide(color: AppColors.textFieldColor)),
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 1.6.h),
                                  fillColor: AppColors.textFieldColor,
                                  hintText: 'Write your message',
                                  hintStyle: CustomTextStyle.hintText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    getHorizentalSpace(1.h),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 10.px),
                        child: GestureDetector(
                          onTap: () {
                            messengerController.uploadFile(load: true, file: File(imagePickerController.pickedImage.value!.path)).then(
                              (value) {
                                if (value != null) {
                                  final file = imagePickerController.pickedImage.value;
                                  String type = isImageFile(file) ? "image" : "video";

                                  if (type == "video" && (_controller == null || !_controller!.value.isInitialized)) {
                                    customScaffoldMessenger("Video not ready");
                                    return;
                                  }

                                  // Common code for both image and video
                                  var media = Media(
                                    type: type,
                                    url: value,
                                    mimetype: "$type/${getFileExtension(file)}",
                                  );
                                  imagePickerController.pickedImage.value = null;
                                  messengerController.sendMessage(
                                    load: false,
                                    postMessageModel: PostMessageModel(
                                      circleId: widget.itemId,
                                      message: messageController.text,
                                      media: [
                                        PostMedia(
                                          type: type,
                                          url: value,
                                          mimetype: "$type/${getFileExtension(file)}",
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  customScaffoldMessenger("Failed to Send");
                                }
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(13.px),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.mainColorYellow),
                            child: messengerController.loading.value
                                ? SizedBox(
                                    height: 15.px,
                                    width: 15.px,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.px,
                                    )),
                                  )
                                : Icon(
                                    Icons.send,
                                    size: 15.px,
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildVideoPlayer(File videoFile) {
    _controller = VideoPlayerController.file(videoFile);
    _controller!.initialize().then((_) {
      _controller!.addListener(updateVideoState);
      _controller!.play();
    });

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget buildVideoControls() {
    return Container(
      color: Colors.black,
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black.withOpacity(0.5),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  isPlaying.value ? pause() : play();
                },
              ),
              Text(
                _formatDuration(_controller?.value.position ?? const Duration(days: 0)),
                style: const TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: progress.value,
                  min: 0,
                  max: _controller!.value.duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller!.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_controller!.value.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateVideoState() {
    progress.value = _controller!.value.position.inMilliseconds.toDouble();
    isBuffering.value = _controller!.value.isBuffering;
    isCompleted.value = _controller!.value.isCompleted;
    isPlaying.value = _controller!.value.isPlaying;
  }

  void play() {
    isPlaying.value = true;
    _controller!.play();
  }

  void pause() {
    isPlaying.value = false;
    _controller!.pause();
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
