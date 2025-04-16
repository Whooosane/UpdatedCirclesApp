import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:circleapp/view/custom_widget/custom_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controller/getx_controllers/auth_controller.dart';
import '../../../controller/utils/validation.dart';
import '../../custom_widget/custom_text_field.dart';
import '../../custom_widget/customwidgets.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late AuthController authController;
  RxBool hidePassword = false.obs;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColorBackground,
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 9.h),
                Center(
                  child: Image.asset(
                    "assets/png/loginScreen.png",
                    height: 272.px,
                    width: 272.px,
                  ),
                ),
                SizedBox(height: 5.h),
                Text("Create Account", style: CustomTextStyle.mediumTextL),
                SizedBox(height: 0.8.h),
                Text(
                  "Please enter the required details",
                  style: CustomTextStyle.mediumTextS1,
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Name",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: "medium",
                      fontSize: 10.px,
                    ),
                  ),
                ),
                SizedBox(height: 0.4.h),
                CustomTextField(
                  controller: authController.userNameTextController,
                  hintText: "Lita han",
                  prefixIcon: SvgPicture.asset("assets/svg/profile.svg"),
                ),
                SizedBox(height: 2.5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: "medium",
                      fontSize: 10.px,
                    ),
                  ),
                ),
                SizedBox(height: 0.4.h),
                CustomTextField(
                  controller: authController.emailTextController,
                  hintText: "Litahan12@gmail.com",
                  prefixIcon: SvgPicture.asset("assets/svg/email.svg"),
                ),
                SizedBox(height: 2.5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mobile Number",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: "medium",
                      fontSize: 10.px,
                    ),
                  ),
                ),
                SizedBox(height: 0.4.h),
                CustomTextField(
                  controller: authController.phoneNumberController,
                  phoneKeyboard: true,
                  hintText: "+00 123321 456",
                  prefixIcon: SvgPicture.asset("assets/svg/Mobile.svg"),
                ),
                SizedBox(height: 2.5.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10.px,
                      fontFamily: "medium",
                    ),
                  ),
                ),
                SizedBox(height: 0.4.h),
                CustomTextField(
                  controller: authController.passwordTextController,
                  hintText: "**********",
                  obscureText: hidePassword.value,
                  prefixIcon: SvgPicture.asset("assets/svg/lock.svg"),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        hidePassword.value = !hidePassword.value;
                      },
                      child: SvgPicture.asset("assets/svg/closeEye.svg")),
                ),
                SizedBox(height: 4.h),
                CustomLoadingButton(
                  buttonText: "Sign Up",
                  buttonColor: AppColors.mainColorYellow,
                  onPressed: () {
                    if(!authController.isLoading.value)
                    {
                      if (Validations.handleSingUpScreenError(
                        userNameTextController:
                            authController.userNameTextController,
                        emailTextController: authController.emailTextController,
                        passwordTextController:
                            authController.passwordTextController,
                        mobileNumberTextController:
                            authController.phoneNumberController,
                      ).isNotEmpty) {
                        customScaffoldMessenger(
                          Validations.handleSingUpScreenError(
                            userNameTextController:
                                authController.userNameTextController,
                            emailTextController:
                                authController.emailTextController,
                            passwordTextController:
                                authController.passwordTextController,
                            mobileNumberTextController:
                                authController.phoneNumberController,
                          ),
                        );
                      } else {
                        authController.signup(
                            load: true,
                            userName:
                                authController.userNameTextController.text,
                            email: authController.emailTextController.text,
                            phoneNumber:
                                authController.phoneNumberController.text,
                            password:
                                authController.passwordTextController.text);
                      }
                    }
                  },
                  loading: authController.isLoading,
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: CustomTextStyle.mediumTextBS),
                    SizedBox(width: 0.5.h),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text("Log In", style: CustomTextStyle.mediumTextS1),
                    ),
                  ],
                ),
                SizedBox(height: 1.h, width: 1.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
