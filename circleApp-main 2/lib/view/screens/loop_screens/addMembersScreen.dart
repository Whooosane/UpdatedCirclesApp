import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/getx_controllers/circle_controller.dart';
import '../../../models/contact_model.dart';
import '../../custom_widget/custom_loading_button.dart';
import '../../custom_widget/customwidgets.dart';

class AddMembers extends StatefulWidget {
  const AddMembers({super.key});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  RxList<ContactSelection> contactsSelection = <ContactSelection>[].obs;
  late CircleController createCircleController;

  @override
  void initState() {
    super.initState();
    createCircleController = Get.put(CircleController(context));
    getContacts();
  }

  Future<void> getContacts() async {
    try {
      var value = await createCircleController.getContacts();
      if (!mounted) return; // Check if the widget is still mounted
      if (value != null) {
        setState(() {
          contactsSelection = value;
        });
      } else {
        customScaffoldMessenger("You have no contacts in phone");
      }
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      customScaffoldMessenger("An error occurred: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of any resources if needed
    Get.delete<CircleController>(); // Dispose of the controller properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Obx(() {
        return SizedBox(
          height: Device.height,
          width: Device.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getVerticalSpace(6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    getHorizentalSpace(1.5.h),
                    Text(
                      'Add Members',
                      style: CustomTextStyle.headingStyle,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1.h, bottom: 2.5.h),
                  child: Text(
                    'Select circle members from your contacts',
                    style: CustomTextStyle.hintText.copyWith(color: const Color(0xffF8F8F8)),
                  ),
                ),
                createCircleController.contactsLoading.value
                    ? Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 15,
                          itemBuilder: (BuildContext context, int index) {
                            return Shimmer.fromColors(
                              baseColor: AppColors.shimmerColor1,
                              highlightColor: AppColors.shimmerColor2,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                height: 5.h,
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  borderRadius: BorderRadius.circular(30.px),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: contactsSelection.length,
                          itemBuilder: (context, index) {
                            return Obx(() => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        contactsSelection[index].isSelected = !contactsSelection[index].isSelected;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 1.5.h, vertical: .5.h),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30.px),
                                        color: const Color(0xff313131),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 2.5.h,
                                            backgroundColor: AppColors.textFieldColor,
                                            backgroundImage: const AssetImage('assets/png/members.png'),
                                          ),
                                          getHorizentalSpace(1.h),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                contactsSelection[index].contact.displayName,
                                                style: CustomTextStyle.headingStyle.copyWith(fontSize: 12.px),
                                              ),
                                              Text(
                                                contactsSelection[index].contact.phones.isNotEmpty
                                                    ? contactsSelection[index].contact.phones.first.number
                                                    : '(none)',
                                                style: CustomTextStyle.hintText.copyWith(color: Colors.white.withOpacity(0.49)),
                                              )
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              if (!contactsSelection[index].isUser)
                                                Text(
                                                  "Invite",
                                                  style: CustomTextStyle.hintText.copyWith(color: Colors.white.withOpacity(0.49)),
                                                ),
                                              getHorizentalSpace(4.w),
                                              Container(
                                                height: 2.h,
                                                width: 2.h,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: contactsSelection[index].isSelected ? AppColors.textFieldColor : AppColors.secondaryColor,
                                                  ),
                                                ),
                                                child: contactsSelection[index].isSelected
                                                    ? SvgPicture.asset('assets/svg/selected.svg', fit: BoxFit.cover)
                                                    : SvgPicture.asset(
                                                        'assets/svg/unselected.svg',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                getVerticalSpace(2.h),
                CustomLoadingButton(
                  onPressed: () {
                    if (!createCircleController.createCircleLoading.value) {
                      createCircleController.createCircle(
                        load: true,
                        circleName: Get.arguments["text"],
                        circleImage: Get.arguments["imageUrl"],
                        description: Get.arguments["description"],
                        type: Get.arguments["type"],
                        circleInterests: Get.arguments["circle_interests"],
                        contactsSelection: contactsSelection,
                      );
                    }
                  },
                  loading: createCircleController.createCircleLoading,
                  buttonText: 'Done',
                ),
                getVerticalSpace(2.5.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
