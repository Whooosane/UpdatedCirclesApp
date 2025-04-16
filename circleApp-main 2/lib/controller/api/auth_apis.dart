import 'dart:convert';
import 'dart:io';

import 'package:circleapp/controller/utils/shared_preferences.dart';
import 'package:circleapp/models/all_users_model.dart';
import 'package:circleapp/models/current_user_model.dart';
import 'package:circleapp/view/check_invitation.dart';
import 'package:circleapp/view/screens/athentications/login_screen.dart';
import 'package:circleapp/view/screens/bottom_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, MultipartFile;
import 'package:http/http.dart';

import '../../view/custom_widget/customwidgets.dart';
import '../../view/screens/athentications/resetpassword_screen.dart';
import '../../view/screens/athentications/verIfymobilescreen.dart';
import '../../view/screens/choose_image.dart';
import '../utils/api_constants.dart';
import '../utils/global_variables.dart';
import '../utils/preference_keys.dart';

class AuthApis {
  final BuildContext context;
  AuthApis(this.context);

  Future<void> signupApi({required String userName, required String email, required String password, required String phoneNumber}) async {
    String apiName = "Sign Up";
    final url = Uri.parse("$baseURL/$signUpEP");
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'name': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    });

    Response response = await post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      print("API Success: $apiName\n${response.body}");
      Get.to(() => VerifyMobileScreen(), arguments: {
        'phoneNumber': phoneNumber,
      });
      return;
    }
    if (context.mounted) {
      print("API Failed: $apiName\n ${response.body}");
      customScaffoldMessenger( jsonDecode(response.body)['error'] ?? 'Signup failed');
      return;
    }
  }

  Future<void> loginApi(String email, String password) async {
    final url = Uri.parse("$baseURL/api/auth/login");

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('API request details: $email, $password');

      if (response.statusCode == 200) {
        print("API Success: Login");
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];

        // Handle successful login
        // customScaffoldMessenger( responseBody['message']);
        MySharedPreferences.setBool(isLoggedInKey, true);
        MySharedPreferences.setString(userTokenKey, token);
        Get.offAll(() => const BottomNavigationScreen());
      } else {
        print("API Failed: Login");
        print(response.body);
        if (context.mounted) {
          String errorMessage;
          try {
            errorMessage = jsonDecode(response.body)['error'] ?? 'Login failed';
          } catch (e) {
            errorMessage = 'Login failed';
          }
          customScaffoldMessenger( errorMessage);
        }
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        customScaffoldMessenger( 'An error occurred. Please try again.');
      }
    }
  }

  Future<void> resendOtpApi(String phoneNumber) async {
    final url = Uri.parse("$baseURL/api/auth/resend-code");

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      print('API request details: $phoneNumber');

      if (response.statusCode == 200) {
        print("API Success: Resend OTP");
        customScaffoldMessenger( 'Verification code sent successfully');
      } else {
        print("API Failed: Resend OTP");
        print(response.body);
        if (context.mounted) {
          String errorMessage;
          try {
            errorMessage = jsonDecode(response.body)['error'] ?? 'Failed to resend OTP';
          } catch (e) {
            errorMessage = 'Failed to resend OTP';
          }
          customScaffoldMessenger( errorMessage);
        }
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  Future<void> verifyOtpApi(String phoneNumber, String code) async {
    final url = Uri.parse("$baseURL/api/auth/verify");

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code': code,
        }),
      );

      print('API request details: $phoneNumber, $code');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          print("API Success: OTP Verified");
          userToken = responseBody['token'];
          MySharedPreferences.setBool(isSignedUpKey, true);
          MySharedPreferences.setString(userTokenKey, responseBody['token']);
          Get.offAll(() => const CheckInvitationScreen());
          customScaffoldMessenger( responseBody['message']);
        } else {
          print("API Failed: OTP Verification");
          customScaffoldMessenger( responseBody['message']);
        }
      } else {
        print("API Failed: OTP Verification");
        print(response.body);
        if (context.mounted) {
          String errorMessage;
          try {
            errorMessage = jsonDecode(response.body)['message'] ?? 'OTP verification failed';
          } catch (e) {
            errorMessage = 'OTP verification failed';
          }
          customScaffoldMessenger( errorMessage);
        }
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        customScaffoldMessenger( 'An error occurred. Please try again.');
      }
    }
  }

  Future<void> forgotPasswordApi(String phoneNumber) async {
    final url = Uri.parse("$baseURL/api/auth/forgot-password");

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      print('API request details: $phoneNumber');

      if (response.statusCode == 200) {
        print("API Success: Resend OTP");
        customScaffoldMessenger( 'Verification code sent successfully');
        Get.off(() => const ResetPasswordScreen(), arguments: {'phoneNumber': phoneNumber});
      } else {
        print("API Failed: Resend OTP");
        print(response.body);
        if (context.mounted) {
          String errorMessage;
          try {
            errorMessage = jsonDecode(response.body)['error'] ?? 'Failed to resend OTP';
          } catch (e) {
            errorMessage = 'Failed to resend OTP';
          }
          customScaffoldMessenger( errorMessage);
        }
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        customScaffoldMessenger( 'An error occurred. Please try again.');
      }
    }
  }

  Future<void> resetPasswordApi(String phoneNumber, String otpCode, String password) async {
    final url = Uri.parse("$baseURL/api/auth/reset-password");

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'code': otpCode,
          'password': password,
        }),
      );

      print('API request details: $phoneNumber');

      if (response.statusCode == 200) {
        print("API Success: Resend OTP");
        customScaffoldMessenger( 'Password reset successfully');
        Get.offAll(() => const LoginScreen());
      } else {
        print("API Failed: Resend OTP");
        print(response.body);
        if (context.mounted) {
          String errorMessage;
          try {
            errorMessage = jsonDecode(response.body)['error'] ?? 'Failed to resend OTP';
          } catch (e) {
            errorMessage = 'Failed to resend OTP';
          }
          customScaffoldMessenger( errorMessage);
        }
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        customScaffoldMessenger( 'An error occurred. Please try again.');
      }
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    final url = Uri.parse("$baseURL/$updateProfilePicEP");
    print("Upload Profile Picture API URL: $url");

    try {
      final request = MultipartRequest('POST', url)
        ..headers.addAll({
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $userToken',
        });

      print("Headers set: ${request.headers}");

      final file = await MultipartFile.fromPath('profilePicture', imageFile.path);
      print("File to upload: ${file.filename}");

      request.files.add(file);

      print("Sending request...");
      final response = await request.send();
      print("Response status code: ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      print("Response body: $responseBody");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(responseBody);
        print("Decoded response: $decodedResponse");

        if (decodedResponse['success']) {
          print("Upload successful, image URL: ${decodedResponse['data']['url']}");
          return decodedResponse['data']['url'];
        } else {
          print("Upload failed: ${decodedResponse['message']}");
          return null;
        }
      } else {
        print("Error: Received non-200 status code.");
        return null;
      }
    } catch (error) {
      print("Exception occurred: $error");
      if (context.mounted) {
        customScaffoldMessenger( 'An error occurred. Please try again.');
      }
      return null;
    }
  }

  Future<CurrentUserModel?> getCurrentUser() async {
    String apiName = "Get Current User";
    final url = Uri.parse("$baseURL/$getCurrentUserEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      MySharedPreferences.setString(currentUserKey, response.body);
      MySharedPreferences.setString(currentUserIdKey, CurrentUserModel.fromJson(jsonDecode(response.body)).data.id);
      return CurrentUserModel.fromJson(jsonDecode(response.body));
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  Future<AllUsersModel?> getAllUsers() async {
    String apiName = "Get All User";
    final url = Uri.parse("$baseURL/$getAllUsersEP");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
    print("$url\n$userToken");
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      print("API Success: $apiName\n${response.body}");
      return AllUsersModel.fromJson(jsonDecode(response.body));
    }
    print("API Failed: $apiName\n ${response.body}");
    return null;
  }

  // Future<bool> createEvent({required String eventName, required String color}) async {
  //   String apiName = "Update Profile";
  //
  //   final url = Uri.parse("$baseURL/$createEventEP");
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $userToken',
  //   };
  //
  //   final body = {
  //     "name": eventName,
  //     "color": color,
  //   };
  //
  //   Response response = await post(url, headers: headers, body: jsonEncode(body));
  //   Map<String, dynamic> responseBody = json.decode(response.body);
  //   customScaffoldMessenger( responseBody["message"]);
  //
  //   if (response.statusCode == 201) {
  //     print("API Success: $apiName\n${response.body}");
  //     return true;
  //   }
  //   print("API Failed: $apiName\n ${response.body}");
  //   return false;
  // }
}
