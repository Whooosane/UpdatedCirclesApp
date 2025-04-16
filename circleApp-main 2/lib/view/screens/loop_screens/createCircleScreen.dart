import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controller/getx_controllers/circle_controller.dart';
import '../../custom_widget/customwidgets.dart';
import 'circleInterestScreen.dart';

class CreateCircle extends StatefulWidget {
  const CreateCircle({super.key});

  @override
  State<CreateCircle> createState() => _CreateCircleState();
}

class _CreateCircleState extends State<CreateCircle> {
  late CircleController createCircleController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createCircleController = Get.put(CircleController(context));
  }

  @override
  Widget build(BuildContext context) {
    RxInt selectedIndex = 0.obs;
    RxBool backButton = false.obs;
    RxBool nextButton = true.obs;
    RxList<String> circleName = <String>['Friend', 'Family', 'Organization', 'Mix'].obs;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Create Circle',
          style: CustomTextStyle.headingStyle,
        ),
        leading: Row(children: [
          getHorizentalSpace(1.5.h),
          GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 2.h,
          ),
        ),
          getHorizentalSpace(1.5.h),],),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Circle name',
              style: CustomTextStyle.smallText,
            ),
            getVerticalSpace(.8.h),
            customTextFormField(
              createCircleController.circleNameTextController,
              'Hiking Plan',
              isObsecure: false,
            ),
            getVerticalSpace(1.h),
            Text(
              'Description',
              style: CustomTextStyle.smallText,
            ),
            getVerticalSpace(.8.h),
            customTextFormField(createCircleController.circleDescriptionTextController,
                'Lorem ipsum dolor sit amet consectetur. Eget aliquam suspendisse ultrices a mattis vitae. Adipiscing id vestibulum ultrices lorem. Nibh dignissim bibendum aAdipiscing id vestibulum ultrices lorem. Nibh dignissim bibendum a..',
                isObsecure: false, maxLine: 5, borderRadius: BorderRadius.circular(30.px)),
            getVerticalSpace(2.5.h),
            Text(
              'Type of circle',
              style: CustomTextStyle.headingStyle,
            ),
            getVerticalSpace(.6.h),
            GridView.builder(
              itemCount: 4,
              shrinkWrap: true,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2.h, mainAxisSpacing: 1.4.h, childAspectRatio: 4),
              itemBuilder: (context, index) {
                return Obx(
                  () => GestureDetector(
                    onTap: () {
                      selectedIndex.value = index;
                    },
                    child: customRadioButton(
                        title: circleName[index],
                        borderColor: selectedIndex.value == index ? AppColors.textFieldColor : AppColors.secondaryColor,
                        assetsImage: selectedIndex.value == index
                            ? SvgPicture.asset('assets/svg/selected.svg')
                            : SvgPicture.asset('assets/svg/unselected.svg')),
                  ),
                );
              },
            ),
            getVerticalSpace(6.h),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  getHorizentalSpace(3.h),
                  Expanded(
                    child: customButton(
                        onTap: () {
                          if (backButton.value == false) {
                            backButton.value = true;
                            nextButton.value = false;
                          } else {
                            backButton.value = false;
                            nextButton.value = true;
                          }
                          Get.back();
                        },
                        backgroundColor: backButton.value == true ? AppColors.secondaryColor : AppColors.primaryColor,
                        borderColor: backButton.value == true ? AppColors.primaryColor : AppColors.secondaryColor,
                        title: 'Back',
                        titleColor: backButton.value == true ? Colors.black : Colors.white,
                        width: 16.2.h,
                        height: 4.5.h),
                  ),
                  getHorizentalSpace(1.h),
                  Expanded(
                    child: customButton(
                        onTap: () {
                          if (nextButton.value == false) {
                            nextButton.value = true;
                            backButton.value = false;
                          } else {
                            nextButton.value = false;
                            backButton.value = true;
                          }
                          if (createCircleController.circleNameTextController.text.isEmpty) {
                            customScaffoldMessenger( 'please enter the circle name ');
                          } else if (createCircleController.circleDescriptionTextController.text.isEmpty) {
                            customScaffoldMessenger( 'please enter the circle description');
                          } else {
                            Get.to(const CircleInterest(), arguments: {
                              'text': createCircleController.circleNameTextController.text,
                              'description': createCircleController.circleDescriptionTextController.text,
                              'type': circleName[selectedIndex.value],
                              'imageUrl': Get.arguments['imageUrl'],
                            });
                          }
                        },
                        backgroundColor: nextButton.value == true ? AppColors.secondaryColor : AppColors.primaryColor,
                        borderColor: nextButton.value == true ? AppColors.primaryColor : AppColors.secondaryColor,
                        title: 'Next',
                        titleColor: nextButton.value == true ? Colors.black : Colors.white,
                        width: 16.2.h,
                        height: 4.5.h),
                  ),
                  getHorizentalSpace(3.h)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
