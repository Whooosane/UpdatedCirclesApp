import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../controller/utils/global_variables.dart';
import '../offer_models/offers_model.dart';

GetMessageModel getMessageModelFromJson(String str) => GetMessageModel.fromJson(json.decode(str));

String getMessageModelToJson(GetMessageModel data) => json.encode(data.toJson());

class GetMessageModel {
  bool success;
  RxList<Datum> data;
  String circleId;

  GetMessageModel({
    required this.success,
    required List<Datum> data,
    required this.circleId,
  }) : data = data.obs;

  factory GetMessageModel.fromJson(Map<String, dynamic> json) => GetMessageModel(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    circleId: json["circleId"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "circleId": circleId,
    "data": data.toList().reversed,
  };
}

class Datum {
  String id;
  String type;
  String senderId;
  String text;
  String senderName;
  String senderProfilePicture;
  DateTime sentAt;
  bool pinned;
  List<Media> media;
  Offer? offerDetails;
  PlanDetails? planDetails;

  Datum({
    required this.id,
    required this.type,
    required this.senderId,
    required this.text,
    required this.senderName,
    required this.senderProfilePicture,
    required this.sentAt,
    required this.pinned,
    required this.media,
    this.offerDetails,
    this.planDetails,
  });

  Datum copyWith({
    String? id,
    String? type,
    String? senderId,
    String? text,
    String? senderName,
    String? senderProfilePicture,
    DateTime? sentAt,
    bool? pinned,
    List<Media>? media,
    Offer? offerDetails,
    PlanDetails? planDetails,
  }) =>
      Datum(
        id: id ?? this.id,
        type: type ?? this.type,
        senderId: senderId ?? this.senderId,
        text: text ?? this.text,
        senderName: senderName ?? this.senderName,
        senderProfilePicture: senderProfilePicture ?? this.senderProfilePicture,
        sentAt: sentAt ?? this.sentAt,
        pinned: pinned ?? this.pinned,
        media: media ?? this.media,
        offerDetails: offerDetails ?? this.offerDetails,
        planDetails: planDetails ?? this.planDetails,
      );

  factory Datum.fromJson(Map<String, dynamic> json) {
    // Only parse offerDetails and planDetails if they are not null
    final offerDetailsJson = json["offerDetails"];
    final planDetailsJson = json["planDetails"];

    return Datum(
      id: json["id"],
      type: json["type"],
      senderId: json["senderId"],
      text: json["text"],
      senderName: json["senderName"],
      senderProfilePicture: json["senderProfilePicture"] ?? userimagePlaceholder,
      sentAt: DateTime.parse(json["sentAt"]),
      pinned: json["pinned"],
      media: List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
      offerDetails: offerDetailsJson != null && offerDetailsJson.isNotEmpty
          ? Offer.fromJson(offerDetailsJson)
          : null,
      planDetails: planDetailsJson != null && planDetailsJson.isNotEmpty
          ? PlanDetails.fromJson(planDetailsJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "senderId": senderId,
    "text": text,
    "senderName": senderName,
    "senderProfilePicture": senderProfilePicture,
    "sentAt": sentAt.toIso8601String(),
    "pinned": pinned,
    "media": List<dynamic>.from(media.map((x) => x.toJson())),
    "offerDetails": offerDetails?.toJson(),
    "planDetails": planDetails?.toJson(),
  };
}

class Media {
  String type;
  String url;
  String mimetype;

  Media({
    required this.type,
    required this.url,
    required this.mimetype,
  });

  Media copyWith({
    String? type,
    String? url,
    String? mimetype,
  }) =>
      Media(
        type: type ?? this.type,
        url: url ?? this.url,
        mimetype: mimetype ?? this.mimetype,
      );

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    type: json["type"],
    url: json["url"],
    mimetype: json["mimetype"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "url": url,
    "mimetype": mimetype,
  };
}


class PlanDetails {
  String planId;
  String planName;
  String planDescription;
  double price;
  String duration;
  List<CreatedBy> members;
  String eventType;
  int budget;
  CreatedBy createdBy;

  PlanDetails({
    required this.planId,
    required this.planName,
    required this.planDescription,
    required this.price,
    required this.duration,
    required this.members,
    required this.eventType,
    required this.budget,
    required this.createdBy,
  });

  PlanDetails copyWith({
    String? planId,
    String? planName,
    String? planDescription,
    double? price,
    String? duration,
    List<CreatedBy>? members,
    String? eventType,
    int? budget,
    CreatedBy? createdBy,
  }) =>
      PlanDetails(
        planId: planId ?? this.planId,
        planName: planName ?? this.planName,
        planDescription: planDescription ?? this.planDescription,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        members: members ?? this.members,
        eventType: eventType ?? this.eventType,
        budget: budget ?? this.budget,
        createdBy: createdBy ?? this.createdBy,
      );

  factory PlanDetails.fromJson(Map<String, dynamic> json) => PlanDetails(
    planId: json["planId"] ?? '',
    planName: json["planName"] ?? '',
    planDescription: json["planDescription"] ?? '',
    price: (json["price"] ?? 0).toDouble(),
    duration: json["duration"] ?? '',
    members: json["members"] != null
        ? List<CreatedBy>.from(json["members"].map((x) => CreatedBy.fromJson(x)))
        : [],
    eventType: json["eventType"] ?? '',
    budget: json["budget"] ?? 0,
    createdBy: json["createdBy"] != null
        ? CreatedBy.fromJson(json["createdBy"])
        : CreatedBy(
      name: '',
      email: '',
      profilePicture: '',
      id: '',
    ),
  );

  Map<String, dynamic> toJson() => {
    "planId": planId,
    "planName": planName,
    "planDescription": planDescription,
    "price": price,
    "duration": duration,
    "members": List<dynamic>.from(members.map((x) => x.toJson())),
    "eventType": eventType,
    "budget": budget,
    "createdBy": createdBy.toJson(),
  };
}

class CreatedBy {
  String name;
  String email;
  String profilePicture;
  String id;

  CreatedBy({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.id,
  });

  CreatedBy copyWith({
    String? name,
    String? email,
    String? profilePicture,
    String? id,
  }) =>
      CreatedBy(
        name: name ?? this.name,
        email: email ?? this.email,
        profilePicture: profilePicture ?? this.profilePicture,
        id: id ?? this.id,
      );

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    name: json["name"],
    email: json["email"],
    profilePicture: json["profilePicture"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "profilePicture": profilePicture,
    "_id": id,
  };
}

class Pagination {
  int total;
  int pages;
  int currentPage;

  Pagination({
    required this.total,
    required this.pages,
    required this.currentPage,
  });

  Pagination copyWith({
    int? total,
    int? pages,
    int? currentPage,
  }) =>
      Pagination(
        total: total ?? this.total,
        pages: pages ?? this.pages,
        currentPage: currentPage ?? this.currentPage,
      );

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    pages: json["pages"],
    currentPage: json["currentPage"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "pages": pages,
    "currentPage": currentPage,
  };
}
