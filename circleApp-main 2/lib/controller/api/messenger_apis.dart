import 'dart:convert';

import 'package:circleapp/models/conversation_model.dart';
import 'package:circleapp/models/message_models/post_message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import '../../models/message_models/get_message_model.dart';
import '../../view/custom_widget/customwidgets.dart';
import '../utils/api_constants.dart';
import '../utils/global_variables.dart';

class MessengerApis {
  final BuildContext context;

  MessengerApis(this.context);

  Future<bool> sendMessage({
    required PostMessageModel postMessageModel,
  }) async {
    String apiName = "Send Message";

    final url = Uri.parse("$baseURL/$sendMessageEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    final body = postMessageModel.toJson();
    Response response = await post(url, headers: headers, body: jsonEncode(body));
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    print(responseBody.toString());
    customScaffoldMessenger(responseBody["message"]);
    print("Response Code: ${response.statusCode}");
    if (response.statusCode == 201) {
      print("API Success: $apiName\n${response.body}");
      return true;
    } else {
      print("API Failed: $apiName\n ${response.body}");
      return false;
    }
  }

  Future<GetMessageModel?> getMessages({required String circleId}) async {
    String apiName = "Get Messages";
    final url = Uri.parse("$baseURL/$getMessagesEP/$circleId");
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

  Future<ConversationModel?> getConversations() async {
    String apiName = "Get Conversations";
    final url = Uri.parse("$baseURL/$getConversationsEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    Response response = await get(url, headers: headers);
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success']) {
      print("API Success: $apiName\n${response.body}");
      return ConversationModel.fromJson(jsonDecode(response.body));
    }

    print("API Failed: $apiName\n ${response.body}");
    return null;
  }
}
