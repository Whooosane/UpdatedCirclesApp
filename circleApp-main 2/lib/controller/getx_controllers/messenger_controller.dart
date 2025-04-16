import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:circleapp/controller/api/messenger_apis.dart';
import 'package:circleapp/controller/api/upload_apis.dart';
import 'package:circleapp/controller/getx_controllers/auth_controller.dart';
import 'package:circleapp/controller/getx_controllers/chat_socket_controller.dart';
import 'package:circleapp/controller/utils/global_variables.dart';
import 'package:circleapp/models/conversation_model.dart';
import 'package:circleapp/models/current_user_model.dart';
import 'package:circleapp/models/message_models/post_message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/message_models/get_message_model.dart' as CompleteDatum;
import '../../models/message_models/get_message_model.dart';
import '../../view/custom_widget/customwidgets.dart';
import '../utils/preference_keys.dart';
import '../utils/shared_preferences.dart';

class MessengerController extends GetxController {
  late final BuildContext context;

  MessengerController(this.context);

  //Variables
  RxBool _loading = false.obs;
  Rxn<ConversationModel> conversationModel = Rxn<ConversationModel>();
  Rxn<GetMessageModel?> messagesModel = Rxn<GetMessageModel>();
  TextEditingController circleNameTextController = TextEditingController();
  TextEditingController circleDescriptionTextController = TextEditingController();
  CurrentUserModel currentUserModel = CurrentUserModel.fromJson(jsonDecode(MySharedPreferences.getString(currentUserKey)));
  late AudioPlayer player, player2;
  Rx<Duration> duration = const Duration(seconds: 0).obs;
  Rx<Duration> position = const Duration(seconds: 0).obs;
  Rx<bool> isAudioInitialized = false.obs;
  Rx<bool> isPlaying = false.obs;
  Rx<bool> isCompleted = false.obs;
  Rx<double> progress = (0.0).obs;

  RxList<int> unreadCount = <int>[].obs;

  //Getters and Setters
  RxBool get loading => _loading;

  set loading(RxBool value) {
    _loading = value;
  }

  //API Methods
  Future<void> sendMessage({
    required bool load,
    required PostMessageModel postMessageModel,
  }) async {
    if (load) {
      loading.value = true;
    }
    bool isSent = await MessengerApis(context).sendMessage(postMessageModel: postMessageModel);

    if (isSent) {
      Get.put(ChatSocketService()).sendMessage(
        postMessageModel.circleId,
        CompleteDatum.Datum(
          id: "",
          senderId: currentUserModel.data.id,
          text: postMessageModel.message,
          senderName: currentUserModel.data.name,
          senderProfilePicture: currentUserModel.data.profilePicture,
          sentAt: DateTime.now(),
          media: postMessageModel.media
              .map((media) =>
              CompleteDatum.Media(
                type: media.type,
                url: media.url,
                mimetype: media.mimetype,
              ))
              .toList(), pinned: false, type: "text", offerDetails: null, planDetails: null,
        ),
      );
      messagesModel.value?.data.add(CompleteDatum.Datum(
        id: "",
        senderId: currentUserModel.data.id,
        text: postMessageModel.message,
        senderName: currentUserModel.data.name,
        senderProfilePicture: currentUserModel.data.profilePicture,
        sentAt: DateTime.now(),
        media: postMessageModel.media
            .map((media) =>
            CompleteDatum.Media(
              type: media.type,
              url: media.url,
              mimetype: media.mimetype,
            ))
            .toList(), pinned: false, type: "text", offerDetails: null, planDetails: null,
      ));
      messagesModel.value?.data.refresh();
    } else {
      customScaffoldMessenger("Failed to Send");
    }
    loading.value = false;
  }

  Future<String?> uploadFile({required bool load, required File file}) async {
    if (load) {
      loading.value = true;
    }

    List<String>? response = await UploadApis(context).uploadFile(file);
    loading.value = false;
    if (response != null) {
      return response.first;
    } else {
      return null;
    }
  }

  Future<void> getMessages({required bool load, required String circleId}) async {
    if (load) {
      loading.value = true;
    }

    messagesModel.value = await MessengerApis(context).getMessages(circleId: circleId);
    loading.value = false;
  }

  Future<void> getConversations({required bool load}) async {
    if (load) {
      loading.value = true;
    }

    conversationModel.value = await MessengerApis(context).getConversations();
    loading.value = false;
  }

  Future<void> setUpPlayer(voiceUrl) async {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    player.setSourceUrl(voiceUrl).then(
          (value) async {
        duration.value = (await player.getDuration().then((value) {
          isAudioInitialized.value = true;
          player.onDurationChanged.listen((d) {
            duration.value = d;
          });

          player.onPositionChanged.listen((p) {
            progress.value = p.inMilliseconds.toDouble();
            position.value = p;
          });

          player.onPlayerComplete.listen((event) {
            isCompleted.value = true;
            isPlaying.value = false;
          });

          player.onPlayerStateChanged.listen((state) {});
          return value ?? const Duration();
        }));
        position.value = duration.value;
        print("Duration: ${duration.value.inMilliseconds.toString()}");
      },
    );
  }

  Future<void> setUpPlayerFile(file) async {
    player2 = AudioPlayer();
    player2.setReleaseMode(ReleaseMode.stop);
    player2.setSourceDeviceFile(file).then(
          (value) async {
        duration.value = (await player2.getDuration().then((value) {
          isAudioInitialized.value = true;
          player2.onDurationChanged.listen((d) {
            duration.value = d;
          });

          player2.onPositionChanged.listen((p) {
            progress.value = p.inMilliseconds.toDouble();
            position.value = p;
          });

          player2.onPlayerComplete.listen((event) {
            isCompleted.value = true;
            isPlaying.value = false;
          });

          player2.onPlayerStateChanged.listen((state) {});
          return value ?? const Duration();
        }));
        position.value = duration.value;
        print("Duration: ${duration.value.inMilliseconds.toString()}");
      },
    );
  }

  void playPause() {
    if (isPlaying.value) {
      player.pause();
    } else {
      player.resume();
    }
    isPlaying.value = !isPlaying.value;
  }

  void playPause2() {
    if (isPlaying.value) {
      player2.pause();
    } else {
      player2.resume();
    }
    isPlaying.value = !isPlaying.value;
  }
}
