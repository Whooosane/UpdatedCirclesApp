import 'package:circleapp/controller/getx_controllers/circle_controller.dart';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../controller/utils/shared_preferences.dart';
import '../../../models/contact_model.dart';
import '../../custom_widget/customwidgets.dart';
import 'addMembersScreen.dart';

class CircleInterest extends StatefulWidget {
  const CircleInterest({super.key});

  @override
  State<CircleInterest> createState() => _CircleInterestState();
}

class _CircleInterestState extends State<CircleInterest> {
  RxList<ContactSelection> myContacts = <ContactSelection>[].obs;
  late CircleController createCircleController;
  RxList<int> selectedIndexes = <int>[].obs; // Changed to store multiple selected indexes
  RxList<String> interests = <String>[].obs;
  RxList<String> userInterests = <String>[].obs;

  @override
  void initState() {
    super.initState();
    createCircleController = Get.put(CircleController(context));
    interests.addAll([
      'Photography',
      'Shopping',
      'Music',
      'Movies',
      'Fitness',
      'Travelling',
      'Sports',
      'Video Games',
      'Night Out',
      'Art'
    ]);
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            createCircleController.fetchUserInterests(load: true).then((_) {
              if (createCircleController.userInterestsModel.value != null) {
                interests.addAll(createCircleController.userInterestsModel.value!.interests);
                interests.refresh();
              }
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryColor,
      body: Obx(() {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 1.5.h),
          child: Column(
            children: [
              getVerticalSpace(6.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  getHorizentalSpace(1.5.h),
                  Text(
                    'Circle interests',
                    style: CustomTextStyle.headingStyle,
                  ),
                ],
              ),
              getVerticalSpace(1.h),
              Text(
                '''share what your group is interested in and activities you participate in to receive exclusive offers for your circle!''',
                style: CustomTextStyle.hintText.copyWith(color: const Color(0xffF8F8F8)),
              ),
              getVerticalSpace(3.h),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: interests.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.h,
                          mainAxisSpacing: 1.4.h,
                          childAspectRatio: 4,
                        ),
                        itemBuilder: (context, index) {
                          return Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (selectedIndexes.contains(index)) {
                                  selectedIndexes.remove(index); // Deselect if already selected
                                } else {
                                  selectedIndexes.add(index); // Select if not already selected
                                }
                              },
                              child: customRadioButton(
                                title: interests[index],
                                borderColor: selectedIndexes.contains(index) ? AppColors.textFieldColor : AppColors.secondaryColor,
                                assetsImage: selectedIndexes.contains(index)
                                    ? SvgPicture.asset('assets/svg/selected.svg')
                                    : SvgPicture.asset('assets/svg/unselected.svg'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    getVerticalSpace(2.h),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return interestsDialog(onLogout: (newInterest) {
                              if (newInterest.isNotEmpty) {
                                interests.add(newInterest);
                                userInterests.add(newInterest);

                                // Store the updated interests in SharedPreferences
                                MySharedPreferences.setListString('user_interests', userInterests);
                              }
                            });
                          },
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 5.h,
                        decoration: BoxDecoration(color: AppColors.textFieldColor, borderRadius: BorderRadius.circular(30.px)),
                        child: Row(
                          children: [
                            getHorizentalSpace(2.h),
                            const Icon(Icons.add, color: Colors.white),
                            getHorizentalSpace(2.h),
                            Text(
                              "Add Interest",
                              style: CustomTextStyle.smallText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    getVerticalSpace(2.h),
                    customButton(
                      onTap: () async {
                        if (selectedIndexes.isNotEmpty) {
                          // Pass the selected interests to the next screen
                          List<String> selectedInterests = selectedIndexes.map((index) => interests[index]).toList();

                          Get.to(
                                () => const AddMembers(),
                            arguments: {
                              'text': Get.arguments['text'],
                              'description': Get.arguments['description'],
                              'type': Get.arguments['type'],
                              'imageUrl': Get.arguments['imageUrl'],
                              'circle_interests': selectedInterests,
                            },
                          );
                        } else {
                          customScaffoldMessenger("Please select at least one interest");
                        }
                      },
                      backgroundColor: AppColors.secondaryColor,
                      borderColor: AppColors.primaryColor,
                      title: 'Continue',
                      titleColor: Colors.black,
                      height: 5.h,
                    ),
                    getVerticalSpace(3.h),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
