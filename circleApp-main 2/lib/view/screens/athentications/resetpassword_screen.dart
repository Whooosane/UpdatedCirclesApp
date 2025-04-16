import 'dart:developer';

import 'package:circleapp/controller/api/auth_apis.dart';
import 'package:circleapp/controller/getx_controllers/auth_controller.dart';
import 'package:circleapp/controller/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controller/utils/app_colors.dart';
import '../../../controller/utils/customTextStyle.dart';
import '../../custom_widget/custom_loading_button.dart';
import '../../custom_widget/custom_text_field.dart';
import '../../custom_widget/customwidgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ResetPasswordScreen> {
  late AuthController authController;
  late AuthApis authApis;
  TextEditingController emailTextController = TextEditingController();
  TextEditingController newPasswordTextController = TextEditingController();
  TextEditingController confirmPasswordTextController = TextEditingController();
  TextEditingController otpTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController = Get.put(AuthController(context));
    authApis = AuthApis(context);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = Get.arguments;
    String phoneNumber = arguments['phoneNumber'];
    print('resetNumber: $phoneNumber');
    return Scaffold(
      backgroundColor: AppColors.mainColorBackground,
      body: Padding(
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
                "assets/png/forgetScreen.png",
                height: 272.px,
                width: 272.px,
              )),
              SizedBox(
                height: 5.h,
              ),
              Text(
                "Reset Password",
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
                child: Text("Otp", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "medium", fontSize: 10.px)),
              ),
              SizedBox(
                height: 0.4.h,
              ),
              PinCodeTextField(
                onCompleted: (v) {
                  otpTextController.text = v;
                },
                length: 6,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                cursorColor: Colors.white,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 52,
                  fieldWidth: 52,
                  inactiveColor: AppColors.mainColor,
                  selectedColor: AppColors.mainColor,
                  activeColor: AppColors.mainColor,
                  borderWidth: 0,
                  activeBorderWidth: 0,
                  disabledBorderWidth: 0,
                  inactiveBorderWidth: 0,
                  selectedBorderWidth: 0,
                ),
                animationDuration: const Duration(milliseconds: 200),
                onChanged: (value) {
                  log(value.toString());
                },
                beforeTextPaste: (text) {
                  log("Allowing to paste $text");
                  return true;
                },
                appContext: context,
                textStyle: const TextStyle(color: Colors.white),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Add this line
              ),
              SizedBox(
                height: 2.h,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("New Password", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "medium", fontSize: 10.px)),
              ),
              SizedBox(
                height: 0.4.h,
              ),
              CustomTextField(
                controller: newPasswordTextController,
                hintText: "Litahan12@gmail.com",
                prefixIcon: SvgPicture.asset("assets/svg/lock.svg"),
              ),
              SizedBox(
                height: 2.h,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Confirm Password", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "medium", fontSize: 10.px)),
              ),
              SizedBox(
                height: 0.4.h,
              ),
              CustomTextField(
                controller: confirmPasswordTextController,
                hintText: "Litahan12@gmail.com",
                prefixIcon: SvgPicture.asset("assets/svg/lock.svg"),
              ),
              SizedBox(
                height: 4.h,
              ),
              CustomLoadingButton(
                buttonText: "Done",
                buttonColor: AppColors.mainColorYellow,
                onPressed: () {
                  if(!authController.isLoading.value)
                  {
                    if (Validations.handleResetPasswordScreenError(
                      otp: otpTextController,
                      password: newPasswordTextController,
                      confirmPassword: confirmPasswordTextController,
                    ).isNotEmpty) {
                      customScaffoldMessenger(
                          Validations.handleResetPasswordScreenError(
                            otp: otpTextController,
                            password: newPasswordTextController,
                            confirmPassword: confirmPasswordTextController,
                          ));
                    } else {
                      authController.resetPasswordApi(
                        phoneNumber,
                        otpTextController.text,
                        confirmPasswordTextController.text,
                      );
                    }
                  }
                  // Get.to(() => VerifyMobileScreen());
                },
                loading: authController.isLoading,
              ),
              SizedBox(
                height: 4.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
