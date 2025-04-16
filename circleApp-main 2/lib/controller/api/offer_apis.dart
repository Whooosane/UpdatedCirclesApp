import 'dart:convert';
import 'package:circleapp/models/offer_models/offers_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../controller/utils/global_variables.dart';
import '../../models/loop_models/event_model.dart';
import '../../view/custom_widget/customwidgets.dart';
import '../utils/api_constants.dart';

class OfferApis {
  final BuildContext context;

  OfferApis(this.context);

  Future<OffersModel?> getOffers(String interest) async {
    String apiName = "Get Event Types";
    final url = Uri.parse("$baseURL/$getOffersEP/$interest");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return offersModelFromJson(response.body);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  Future<Offer?> sendOffer(String offerId, String circleId) async {
    String apiName = "Get Event Types";
    final url = Uri.parse("$baseURL/$sendOfferEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    final body = {
      "circleId": offerId,
      "offerId": circleId,
    };
    print("$url\n$userToken");
    Response response = await post(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return Offer.fromJson(jsonDecode(response.body)["data"]);
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }


}
