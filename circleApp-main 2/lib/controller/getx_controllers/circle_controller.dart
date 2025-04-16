import 'dart:io';

import 'package:circleapp/controller/api/circle_apis.dart';
import 'package:circleapp/models/all_todo_model.dart';
import 'package:circleapp/models/circle_models/circle_details_model.dart';
import 'package:circleapp/models/circle_models/circle_members_model.dart';
import 'package:circleapp/models/circle_models/post_circle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/add_todo_model.dart';
import '../../models/circle_models/GetUserInterestsModel.dart';
import '../../models/circle_models/get_circle_model.dart';
import '../../models/contact_model.dart';
import '../../models/is_user_model.dart';
import '../../view/custom_widget/customwidgets.dart';
import '../utils/common_methods.dart';

class CircleController extends GetxController {
  late final BuildContext context;

  CircleController(this.context);

  //Variables
  RxBool loading = false.obs;
  RxBool contactsLoading = false.obs;
  RxBool createCircleLoading = false.obs;
  RxBool messagesLoading = false.obs;
  RxBool newTodoLoading = false.obs;
  RxBool addMembersLoading = false.obs;
  Rxn<PostCircleModel> postCircleModel = Rxn<PostCircleModel>();
  Rxn<GetCircleModel> getCircleModel = Rxn<GetCircleModel>();
  Rxn<CircleDetailsModel> circleDetailsModel = Rxn<CircleDetailsModel>();
  Rxn<CircleMembersModel> circleMembersModel = Rxn<CircleMembersModel>();
  TextEditingController circleNameTextController = TextEditingController();
  TextEditingController circleDescriptionTextController = TextEditingController();
  Rxn<GetUserInterestsModel> userInterestsModel = Rxn<GetUserInterestsModel>();

  //API Methods
  Future<void> createCircle({
    required bool load,
    required String circleName,
    required String circleImage,
    required String description,
    required String type,
    required List<String> circleInterests, // Updated to accept multiple circle interests
    required List<ContactSelection> contactsSelection,
  }) async {
    if (load) {
      createCircleLoading.value = true;
    }

    postCircleModel.value = await CircleApis(context).createCircleApi(
      circleName: circleName,
      circleImage: circleImage,
      description: description,
      type: type,
      circleInterests: circleInterests,
      // Pass the updated circle interests
      memberIds: getContactsFromModel(true, contactsSelection),
      phoneNumbers: getContactsFromModel(false, contactsSelection),
    );

    createCircleLoading.value = false;
  }

  Future<void> getCircles({required bool load}) async {
    if (load) {
      loading.value = true;
    }

    getCircleModel.value = await CircleApis(context).getCircles();
    loading.value = false;
  }

  Future<void> getCircleMembers({required bool load, required String circleId}) async {
    if (load) {
      loading.value = true;
    }

    circleMembersModel.value = await CircleApis(context).getCircleMembers(circleId: circleId);
    loading.value = false;
  }

  Future<void> getCircleById({required bool load, required String circleId}) async {
    if (load) {
      loading.value = true;
    }

    circleDetailsModel.value = await CircleApis(context).getCircleById(circleId);
    loading.value = false;
  }

  Future<String?> uploadCircleImage(File imageFile) async {
    loading.value = true;
    try {
      return await CircleApis(context).uploadCircleImage(imageFile);
    } catch (e) {
      if (context.mounted) {
        customScaffoldMessenger('Upload failed. Please try again.');
      }
    } finally {
      loading.value = false;
    }
    return null;
  }

  Future<bool> updateCircle({required bool load, required String circleId, required String circleName, required String circleImage}) async {
    bool done = false;
    if (load) {
      loading.value = true;
    }

    await CircleApis(context).updateCircle(circleId: circleId, circleName: circleName, circleImage: circleImage).then(
      (value) {
        loading.value = false;
        done = value;
      },
    );
    return done;
  }

  Future<bool> addMembersToCircle({required bool load, required String circleId, required List<String> memberIds}) async {
    bool done = false;
    if (load) {
      addMembersLoading.value = true;
    }

    await CircleApis(context).addMembersToCircle(circleId: circleId, memberIds: memberIds).then(
      (value) {
        addMembersLoading.value = false;
        done = value;
      },
    );
    return done;
  }

  //Supporting Methods
  Future<RxList<ContactSelection>?> getContacts() async {
    contactsLoading.value = true;
    print("Contacts loading started");

    // Requesting contact permission
    await FlutterContacts.requestPermission(readonly: true);
    // final status = await Permission.contacts.request();
    // if (status.isDenied || status.isPermanentlyDenied) {
    //   final message = status.isPermanentlyDenied
    //       ? "Please enable contact permission from settings"
    //       : "Please allow contacts permission to proceed";
    //   customScaffoldMessenger( message);
    //   contactsLoading.value = false;
    //   return null;
    // }

    final contactsFromPhone = await FlutterContacts.getContacts(withPhoto: true, withProperties: true);
    if (contactsFromPhone.isEmpty) {
      print("No contacts found");
      contactsLoading.value = false;
      return null;
    }

    // Filtering contacts and extracting numbers
    final filteredContacts = filterContacts(contactsFromPhone);
    final numbers = filteredContacts.where((contact) => contact.phones.isNotEmpty).map((contact) => contact.phones.first.number).toList();
    if (numbers.isEmpty) {
      print("No phone numbers available in contacts");
      contactsLoading.value = false;
      return null;
    }

    // Checking which contacts are users
    final isUserResponse = await CircleApis(context).getIsUser(numbers: numbers);
    if (isUserResponse == null) {
      print("No users found in API response");
      contactsLoading.value = false;
      return null;
    }

    final myContacts = <ContactSelection>[].obs; // Initialize an empty list

    for (int i = 0; i < isUserResponse.length; i++) {
      // Check if isUser is true and userId is not null before assigning
      if (isUserResponse[i].isUser) {
        filteredContacts[i].id = isUserResponse[i].userId;
      }

      // Add ContactSelection to the list
      myContacts.add(
        ContactSelection(
          contact: filteredContacts[i],
          isUser: isUserResponse[i].isUser,
        ),
      );
    }

    print("Contacts processing completed");
    contactsLoading.value = false;
    return myContacts;
  }

  List<String> getContactsFromModel(bool areUser, List<ContactSelection> contactsSelection) {
    List<String> contactNumbers = [];
    for (var contact in contactsSelection) {
      if (contact.isUser == areUser && contact.isSelected) {
        {
          if (areUser) {
            contactNumbers.add(contact.contact.id);
            print("Is user: ${contact.contact.id}");
          } else {
            contactNumbers.add(contact.contact.phones.first.number);
            print("Is user: ${contact.contact.phones.first.number}");
          }
        }
      }
    }
    return contactNumbers;
  }

  Future<void> fetchUserInterests({required bool load}) async {
    if (load) {
      loading.value = true;
    }

    userInterestsModel.value = await CircleApis(context).getUserInterests();

    loading.value = false;
  }
}
