import 'dart:convert';
import 'dart:io';

import 'package:circleapp/controller/utils/common_methods.dart';
import 'package:circleapp/controller/utils/shared_preferences.dart';
import 'package:circleapp/models/circle_models/circle_details_model.dart';
import 'package:circleapp/models/circle_models/circle_members_model.dart';
import 'package:circleapp/models/circle_models/post_circle_model.dart';
import 'package:circleapp/models/is_user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';

import '../../models/circle_models/GetUserInterestsModel.dart';
import '../../models/circle_models/get_circle_model.dart';
import '../../view/custom_widget/customwidgets.dart';
import '../../view/screens/bottom_navigation_screen.dart';
import '../utils/api_constants.dart';
import '../utils/global_variables.dart';
import '../utils/preference_keys.dart';

class CircleApis {
  final BuildContext context;
  CircleApis(this.context);

  Future<PostCircleModel?> createCircleApi({
    required String circleName,
    required String circleImage,
    required String description,
    required String type,
    required List<String> circleInterests, // Accept multiple interests for the circle
    required List<String> memberIds,
    required List<String> phoneNumbers,
  }) async {
    String apiName = "Create Circle";

    final url = Uri.parse("$baseURL/api/circle/create");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    // Get user interests from shared preferences
    List<String> userInterests = MySharedPreferences.getListString('user_interests') ?? [];

    final body = {
      'circleName': circleName,
      'circleImage': circleImage,
      'description': description,
      'type': toCamelCase(type),
      'circle_interests': circleInterests,  // Updated to accept multiple interests for the circle
      'memberIds': memberIds,
      'phoneNumbers': phoneNumbers,
      'interests': userInterests  // User interests to be stored in user schema
    };

    print(jsonEncode(body));
    Response response = await post(url, headers: headers, body: jsonEncode(body));
    Map<String, dynamic> responseBody = json.decode(response.body);
    print(response.body);

    if (responseBody["success"] == true) {
      print("API Success: $apiName\n${response.body}");
      Get.offAll(const BottomNavigationScreen());
      MySharedPreferences.setBool(isLoggedInKey, true);
      customScaffoldMessenger(responseBody["message"]);
      return PostCircleModel.fromJson(responseBody["circle"]);
    }
    print("API Failed: $apiName\n ${response.body}");
    customScaffoldMessenger(responseBody["error"]);
    return null;
  }

  Future<List<IsUserModel>?> getIsUser({required List<String> numbers}) async {
    String apiName = "Get is User";
    final url = Uri.parse("$baseURL/api/auth/check-users");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    final body = {"phoneNumbers": numbers};

    Response response = await post(url, headers: headers, body: jsonEncode(body));
    print(response.body);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return isUserModelFromJson(response.body);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  Future<GetCircleModel?> getCircles() async {
    String apiName = "Get Circles";
    final url = Uri.parse("$baseURL/$getCirclesEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return GetCircleModel.fromJson(jsonDecode(response.body));
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

   Future<CircleMembersModel?> getCircleMembers({required String circleId}) async {
    String apiName = "Get Circle Members";
    final url = Uri.parse("$baseURL/$getCircleMembersEP/$circleId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return circleMembersModelFromJson(response.body);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  Future<String?> uploadCircleImage(File file) async {
    String apiName = "Upload Circle Image";
    final StreamedResponse response;
    var responseString = "";
    final url = Uri.parse("$baseURL/$uploadCircleImageEP");
    final request = MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $userToken'
      ..headers['Content-Type'] = 'multipart/form-data';

    final fileData = await MultipartFile.fromPath(
      'circle-image', // Ensure this field name matches what your server expects
      file.path,
    );

    request.files.add(fileData);
    response = await request.send();

    if (response.statusCode == 200) {
      responseString = await response.stream.bytesToString();
      print("API Success: $apiName\n$responseString");

      // Decode JSON response and extract URL
      final decodedJson = json.decode(responseString);
      if (decodedJson['success']) {
        return decodedJson['data']['url'];
      } else {
        print("API Failed1: $apiName\n${decodedJson['message']}");
        return null;
      }
    } else {
      print("API Failed2: $apiName\n$responseString");
      return null;
    }
  }

  Future<bool> updateCircle({required String circleId, required String circleName, required String circleImage}) async {
    String apiName = "Update Circle";

    final url = Uri.parse("$baseURL/$editCircleEP/$circleId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    final body = {
      "circleName": circleName,
      "circleImage": circleImage,
    };

    Response response = await put(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return true;
    }
    print("API Failed: $apiName\n ${response.body}");
    return false;
  }

  Future<CircleDetailsModel?> getCircleById(String circleId) async {
    String apiName = "Get Circle By Id";

    final url = Uri.parse("$baseURL/$getCircleByIdEP/$circleId");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return circleDetailsModelFromJson(response.body);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  Future<bool> addMembersToCircle({required String circleId, required List<String> memberIds}) async {
    String apiName = "Add Members to Circle";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    bool allSuccessful = true;

    for (String memberId in memberIds) {
      final url = Uri.parse("$baseURL/$addMemberToCircleEP/$circleId");
      final body = {
        "memberId": memberId,
      };

      Response response = await post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        print("API Success: $apiName\n${response.body}");
      } else {
        print("API Failed: $apiName\n ${response.body}");
        customScaffoldMessenger(jsonDecode(response.body)["error"]);
        allSuccessful = false;
      }
    }

    return allSuccessful;
  }

  Future<GetUserInterestsModel?> getUserInterests() async {
    String apiName = "Get User Interests";
    final url = Uri.parse("$baseURL/api/auth/user-intrests");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    Response response = await get(url, headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return getUserInterestsModelFromJson(response.body);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }
}
