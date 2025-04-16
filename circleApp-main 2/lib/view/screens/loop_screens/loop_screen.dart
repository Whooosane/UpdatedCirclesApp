import 'package:circleapp/controller/getx_controllers/auth_controller.dart';
import 'package:circleapp/controller/utils/global_variables.dart';
import 'package:circleapp/controller/utils/style/customTextStyle.dart';
import 'package:circleapp/view/screens/loop_screens/circle_detail_screen.dart';
import 'package:circleapp/view/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controller/getx_controllers/circle_controller.dart';
import '../../../controller/utils/app_colors.dart';
import '../../../models/circle_models/get_circle_model.dart';
import '../../custom_widget/customwidgets.dart';

class LoopScreen extends StatefulWidget {
  int selectedIndex;

  LoopScreen({super.key, required this.selectedIndex});

  @override
  State<LoopScreen> createState() => _LoopScreenState();
}

class _LoopScreenState extends State<LoopScreen> {
  late CircleController circleController;
  late AuthController authController;

  @override
  void initState() {
    circleController = Get.put(CircleController(context));
    authController = Get.put(AuthController(context));
    authController.getCurrentUser();
    circleController.getCircles(load: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.mainColorBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.h),
          child: Column(
            children: [
              getVerticalSpace(7.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome to Circle!",
                    style: CustomTextStyle.mediumTextExplore,
                  ),
                  authController.loading.value
                      ? Shimmer.fromColors(
                          baseColor: AppColors.shimmerColor1,
                          highlightColor: AppColors.shimmerColor2,
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.bottomCenter,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                          ))
                      : GestureDetector(
                          onTap: () {
                            Get.to(() => const ProfileScreen());
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(authController.currentUserModel.value?.data.profilePicture ?? userimagePlaceholder),
                            radius: 25,
                          ),
                        ),
                ],
              ),
              getVerticalSpace(2.h),
              Expanded(
                child: circleController.getCircleModel.value == null
                    ? Shimmer.fromColors(
                        baseColor: AppColors.shimmerColor1,
                        highlightColor: AppColors.shimmerColor2,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              alignment: Alignment.bottomCenter,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.mainColor,
                                borderRadius: BorderRadius.circular(10.px),
                              ),
                            );
                          },
                        ))
                    : circleController.getCircleModel.value!.circles.isEmpty
                        ? const Center(
                            child: Text(
                              "No Circles",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: circleController.getCircleModel.value!.circles.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext, index) {
                              Circle item = circleController.getCircleModel.value!.circles[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.to(() => CircleDetails(
                                        circleId: circleController.getCircleModel.value!.circles[index].id,
                                        userProfileImage: authController.currentUserModel.value?.data.profilePicture ?? "",
                                        circleName: circleController.getCircleModel.value!.circles[index].circleName,
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 1.5.h),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.textFieldColor,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      item.circleName,
                                      style: CustomTextStyle.mediumTextTitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      item.description,
                                      style: CustomTextStyle.mediumTextSubtitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: ClipOval(
                                      child: Image.network(
                                        item.circleImage,
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.network(
                                            circleImagePlaceholder,
                                            fit: BoxFit.cover,
                                            width: 60,
                                            height: 60,
                                          );
                                        },
                                      ),
                                    ),
                                    trailing: Text(
                                      "15m ago",
                                      style: CustomTextStyle.messageItemTime,
                                    ),
                                  ),
                                ),
                              );
                            }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
