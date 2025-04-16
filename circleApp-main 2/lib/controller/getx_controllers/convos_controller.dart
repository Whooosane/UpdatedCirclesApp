import 'package:circleapp/controller/api/loop_apis/convos_apis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/message_models/get_message_model.dart';

class ConvosController extends GetxController {
  final BuildContext context;
  ConvosController(this.context);

  //Variables
  RxBool loading = false.obs;
  Rxn<GetMessageModel?> messagesModel = Rxn<GetMessageModel>();

  //API Methods
  Future<void> getConvos({required bool load, required String circleId}) async {
    if (load) {
      loading.value = true;
    }

    messagesModel.value = await ConvosApis(context).getConvos(circleId: circleId);
    loading.value = false;
  }

  Future<void> addToConvos({required bool load, required String messageId}) async {
    if (load) {
      loading.value = true;
    }

    await ConvosApis(context).addToConvos(messageId: messageId);
    loading.value = false;
  }
}
