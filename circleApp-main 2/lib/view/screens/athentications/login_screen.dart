import 'package:circleapp/controller/utils/validation.dart';
import 'package:circleapp/view/custom_widget/custom_loading_button.dart';
import 'package:circleapp/view/screens/athentications/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controller/api/auth_apis.dart';
import '../../../controller/getx_controllers/auth_controller.dart';
import '../../../controller/utils/app_colors.dart';
import '../../../controller/utils/customTextStyle.dart';
import '../../custom_widget/custom_text_field.dart';
import '../../custom_widget/customwidgets.dart';
import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthController authController;
  late AuthApis authApis;
  RxBool hidePassword = false.obs;

  @override
  void initState() {
    super.initState();
    authController = Get.put(
      AuthController(context),
    );
    authApis = AuthApis(context);
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
                SizedBox(
                  height: 9.h,
                ),
                Center(
                    child: Image.asset(
                  "assets/png/loginScreen.png",
                  height: 272.px,
                  width: 272.px,
                )),
                SizedBox(
                  height: 5.h,
                ),
                Text(
                  "Welcome Back!",
                  style: CustomTextStyle.mediumTextL,
                ),
                SizedBox(
                  height: 0.8.h,
                ),
                Text(
                  "Please enter the required details",
                  style: CustomTextStyle.mediumTextS1,
                ),
                SizedBox(
                  height: 4.h,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "medium", fontSize: 10.px)),
                ),
                SizedBox(
                  height: 0.4.h,
                ),
                CustomTextField(
                  controller: authController.emailTextController,
                  hintText: "Litahan12@gmail.com",
                  prefixIcon: SvgPicture.asset("assets/svg/email.svg"),
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10.px, fontFamily: "medium")),
                ),
                SizedBox(
                  height: 0.4.h,
                ),
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
                SizedBox(
                  height: 0.5.h,
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: () {
                          Get.to(() => const ForgetScreen());
                        },
                        child: Text(
                          "Forgot Password?",
                          style: CustomTextStyle.mediumTextS1,
                        ))),
                SizedBox(
                  height: 2.h,
                ),
                Center(
                  child: CustomLoadingButton(
                    buttonText: "Log In",
                    buttonColor: AppColors.mainColorYellow,
                    onPressed: () {
                      if(!authController.loginLoading.value)
                        {
                          if (Validations.handleLoginScreenError(
                              emailTextController: authController.emailTextController, passwordTextController: authController.passwordTextController)
                              .isNotEmpty) {
                            customScaffoldMessenger(
                              Validations.handleLoginScreenError(
                                  emailTextController: authController.emailTextController, passwordTextController: authController.passwordTextController),
                            );
                          } else {
                            authController.loginApi(
                              authController.emailTextController.text,
                              authController.passwordTextController.text,
                            );
                            // Get.to(() => const ChooseImage());
                          }
                        }
                    },
                    loading: authController.loginLoading,
                  ),
                ),
                SizedBox(
                  height: 1.4.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: CustomTextStyle.mediumTextBS),
                    SizedBox(
                      width: 0.5.h,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => SignUpScreen());
                      },
                      child: Text("Create Account", style: CustomTextStyle.mediumTextS1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
