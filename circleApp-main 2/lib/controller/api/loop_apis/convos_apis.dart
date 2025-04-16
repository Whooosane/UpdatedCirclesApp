import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../../../models/message_models/get_message_model.dart';
import '../../../view/custom_widget/customwidgets.dart';
import '../../utils/api_constants.dart';
import '../../utils/global_variables.dart';

class ConvosApis {
  final BuildContext context;

  ConvosApis(this.context);

  Future<bool> addToConvos({
    required String messageId,
  }) async {
    String apiName = "Add To Convos";

    final url = Uri.parse("$baseURL/$addToConvosEP/$messageId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    Response response = await post(url, headers: headers);
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    print(responseBody.toString());
    customScaffoldMessenger(responseBody["message"]);
    print("Response Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return true;
    } else {
      print("API Failed: $apiName\n ${response.body}");
      return false;
    }
  }

  Future<GetMessageModel?> getConvos({required String circleId}) async {
    String apiName = "Get Messages";
    final url = Uri.parse("$baseURL/$getConvosEP/$circleId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return GetMessageModel.fromJson(jsonDecode(response.body));
    }
    print("API Failed: $apiName\n ${response.body}");
    return GetMessageModel(success: true, data: [], circleId: '');
  }
}
