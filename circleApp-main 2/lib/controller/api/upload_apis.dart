import 'dart:convert';
import 'dart:io';

import 'package:circleapp/controller/utils/global_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../utils/api_constants.dart';

class UploadApis {
  final BuildContext context;

  UploadApis(this.context);

  Future<List<String>?> uploadFile(File file) async {
    String apiName = "Upload File";
    final StreamedResponse response;
    var responseString = "";
    final url = Uri.parse("$baseURL/$uploadFileEP");
    final request = MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $userToken'
      ..headers['Content-Type'] = 'multipart/form-data';

    final fileData = await MultipartFile.fromPath(
      'images',
      file.path,
    );

    request.files.add(fileData);
    response = await request.send();
    if (response.statusCode == 200) {
      responseString = await response.stream.bytesToString();
      print("API Success: $apiName\n$responseString");
      List<dynamic> decodedJson = json.decode(responseString)["imageUrls"];
      List<String> imageUrls = decodedJson.cast<String>();
      return imageUrls;
    }
    print("API Failed: $apiName\n $responseString");
    return null;
  }
}
