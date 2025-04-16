import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:circleapp/controller/utils/preference_keys.dart';
import 'package:circleapp/controller/utils/shared_preferences.dart';
import 'package:circleapp/models/all_users_model.dart';
import 'package:circleapp/models/current_user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view/custom_widget/customwidgets.dart';
import '../api/auth_apis.dart';

class AuthController extends GetxController {
  late final BuildContext context;

  // TextEditingControllers
  final TextEditingController forgotPasswordTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController userNameTextController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final TextEditingController otpCodeTextController = TextEditingController();

  // RxBool Observables
  RxBool isLoading = false.obs;
  RxBool loginLoading = false.obs;
  RxBool uploadImageLoading = false.obs;
  RxBool loading = false.obs;
  Rxn<CurrentUserModel> currentUserModel = Rxn<CurrentUserModel>();
  Rxn<AllUsersModel> allUsersModel = Rxn<AllUsersModel>();

  AuthController(this.context);

  // Forgot Password API
  Future<void> forgotPasswordApi(String email) async {
    isLoading.value = true;
    try {
      await AuthApis(context).forgotPasswordApi(email);
    } catch (e) {
      print('Error during forgot password: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'Forgot password failed. Please try again.');
      }
    }
    isLoading.value = false;
  }

  // Login API
  Future<void> loginApi(String email, String password) async {
    loginLoading.value = true;
    try {
      await AuthApis(context).loginApi(email, password);
    } catch (e) {
      print('Error during login: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'Login failed. Please try again.');
      }
    } finally {
      loginLoading.value = false;
    }
  }

  // Profile Picture Upload API
  Future<void> uploadProfilePicture(File imageFile) async {
    print('Starting uploadProfilePicture...');
    uploadImageLoading.value = true;
    try {
      print('Calling updateProfilePicture API...');
      String? profileImage = await AuthApis(context).uploadProfilePicture(imageFile);
      print('API call completed. Profile image URL: $profileImage');

      if (profileImage != null) {
        print('Profile image is not null. Updating currentUserModel...');
        var currentUserJson = MySharedPreferences.getString(currentUserKey);
        print('Current user JSON from SharedPreferences: $currentUserJson');

        currentUserModel.value = CurrentUserModel.fromJson(jsonDecode(currentUserJson));
        print('Current user model: ${currentUserModel.value}');

        currentUserModel.value!.data.profilePicture = profileImage;
        print('Updated profile picture in currentUserModel: ${currentUserModel.value!.data.profilePicture}');

        MySharedPreferences.setString(currentUserKey, jsonEncode(currentUserModel.toJson()));
        print('Updated currentUserModel saved to SharedPreferences');
      } else {
        print('Profile image URL is null.');
      }
    } catch (e) {
      print('Error during profile picture upload: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'Upload failed. Please try again.');
      }
    } finally {
      uploadImageLoading.value = false;
      print('Finished uploadProfilePicture.');
    }
  }

  // Resend OTP API
  Future<void> resendOtpApi(String phoneNumber) async {
    loginLoading.value = true;
    try {
      await AuthApis(context).resendOtpApi(phoneNumber);
    } catch (e) {
      print('Error during OTP resend: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'OTP resend failed. Please try again.');
      }
    }
    loginLoading.value = false;
  }

  // Reset Password API
  Future<void> resetPasswordApi(String phoneNumber, String otpCode, String password) async {
    isLoading.value = true;
    try {
      await AuthApis(context).resetPasswordApi(phoneNumber, otpCode, password);
    } catch (e) {
      print('Error during reset password: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'Reset password failed. Please try again.');
      }
    }
    isLoading.value = false;
  }

  // Signup API
  Future<void> signup({
    required bool load,
    required String userName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (load) {
      isLoading.value = true;
    }
    await AuthApis(context).signupApi(
      userName: userName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    isLoading.value = false;
  }

  // Verify OTP API
  Future<void> verifyOtpApi(String phoneNumber, String code) async {
    isLoading.value = true;
    try {
      await AuthApis(context).verifyOtpApi(phoneNumber, code);
    } catch (e) {
      print('Error during OTP verification: $e');
      if (context.mounted) {
        customScaffoldMessenger( 'OTP verification failed. Please try again.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCurrentUser() async {
    Future.microtask(() {
      loading.value = MySharedPreferences.getString(currentUserKey) == "";
    },);
    if (MySharedPreferences.getString(currentUserKey) != "") {
      currentUserModel.value = CurrentUserModel.fromJson(jsonDecode(MySharedPreferences.getString(currentUserKey)));
    }
    currentUserModel.value = await AuthApis(context).getCurrentUser();
    loading.value = false;
  }

  Future<void> getAllUsers() async {
    loading.value = true;
    allUsersModel.value = await AuthApis(context).getAllUsers();
    loading.value = false;
  }
}
