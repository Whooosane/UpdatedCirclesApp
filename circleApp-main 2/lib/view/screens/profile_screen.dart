import 'dart:io';

import 'package:circleapp/controller/utils/global_variables.dart';
import 'package:circleapp/controller/utils/style/customTextStyle.dart';
import 'package:circleapp/view/custom_widget/common_shimmer.dart';
import 'package:circleapp/view/custom_widget/customwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/getx_controllers/auth_controller.dart';
import '../../controller/getx_controllers/picker_controller.dart';
import '../../controller/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthController authController;
  final PickerController imagePickerController = Get.put(PickerController());

  @override
  void initState() {
    authController = Get.put(AuthController(context));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      authController.getCurrentUser();
    });
    super.initState();
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
              children: [
                getVerticalSpace(8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 2.h,
                        ),
                      ),
                    ),
                    Text(
                      "Profile",
                      style: CustomTextStyle.mediumTextL,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context, // Make sure to pass the correct context
                          builder: (BuildContext context) {
                            return logoutDialog(); // Return your dialog widget
                          },
                        );
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w400, fontFamily: 'medium', color: Colors.red),
                      ),
                    ),
                  ],
                ),
                getVerticalSpace(3.h),
                GestureDetector(
                  onTap: () {
                    imagePickerController.pickImage().then((value) {
                      if (value != null) {
                        authController.uploadProfilePicture(value);
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      authController.uploadImageLoading.value || authController.loading.value
                          ? Shimmer.fromColors(
                              baseColor: AppColors.shimmerColor1,
                              highlightColor: AppColors.shimmerColor2,
                              child: Container(
                                width: 120,
                                height: 120,
                                alignment: Alignment.bottomCenter,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                              ))
                          : imagePickerController.pickedImage.value != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(File(imagePickerController.pickedImage.value!.path)),
                                  radius: 60,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(authController.currentUserModel.value?.data.profilePicture ?? userimagePlaceholder),
                                  radius: 60,
                                ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.mainColorBackground),
                          child: Transform.scale(
                              scale: 0.6,
                              child: SvgPicture.asset(
                                "assets/svg/profileCamera.svg",
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                getVerticalSpace(4.h),
                if (authController.loading.value) ...[
                  commonShimmer(height: 7.h, width: 100.w),
                ] else ...[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Name",
                        style: CustomTextStyle.mediumTextSubtitle,
                      )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      authController.currentUserModel.value?.data.name ?? "",
                      style: TextStyle(fontSize: 14.px, fontWeight: FontWeight.w400, fontFamily: 'medium', color: Colors.white),
                    ),
                  ),
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ],
                getVerticalSpace(2.h),
                if (authController.loading.value) ...[
                  commonShimmer(height: 7.h, width: 100.w),
                ] else ...[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email",
                        style: CustomTextStyle.mediumTextSubtitle,
                      )),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      authController.currentUserModel.value?.data.email ?? "",
                      style: TextStyle(fontSize: 14.px, fontWeight: FontWeight.w400, fontFamily: 'medium', color: Colors.white),
                    ),
                  ),
                  Divider(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
