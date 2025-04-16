import 'package:circleapp/controller/getx_controllers/picker_controller.dart';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/common_methods.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../controller/getx_controllers/itinerary_controller.dart';
import '../../../custom_widget/customwidgets.dart';

class CreateItinerary extends StatefulWidget {
  const CreateItinerary({super.key});

  @override
  State<CreateItinerary> createState() => _CreateItineraryState();
}

class _CreateItineraryState extends State<CreateItinerary> {
  final TextEditingController itineraryNameController = TextEditingController();

  final TextEditingController aboutItineraryController = TextEditingController();
  String date = "";
  String time = "";

  final RxString errorMessage = ''.obs;
  late ItineraryController itineraryController;

  @override
  void initState() {
    itineraryController = Get.put(ItineraryController(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PickerController paymentController = Get.put(PickerController());

    return Scaffold(
      backgroundColor: AppColors.mainColorBackground,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.3.h),
        child: SingleChildScrollView(
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
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 2.h,
                    ),
                  ),
                  getHorizentalSpace(1.5.h),
                  Text(
                    'Create Itinerary',
                    style: CustomTextStyle.headingStyle,
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              getVerticalSpace(2.9.h),
              Text(
                'Itinerary name*',
                style: CustomTextStyle.buttonText.copyWith(fontSize: 10.px),
              ),
              getVerticalSpace(.5.h),
              customTextFormField(
                itineraryNameController,
                'Breakfast in SOHO',
                isObsecure: false,
              ),
              getVerticalSpace(1.h),
              Obx(() => Text(
                errorMessage.value.contains('name') ? errorMessage.value : '',
                style: TextStyle(color: Colors.red, fontSize: 10.px),
              )),
              getVerticalSpace(2.h),
              Text(
                'About itinerary*',
                style: CustomTextStyle.buttonText.copyWith(fontSize: 10.px),
              ),
              getVerticalSpace(.5.h),
              customTextFormField(
                aboutItineraryController,
                borderRadius: BorderRadius.circular(20.px),
                maxLine: 3,
                'Type the note here...',
                isObsecure: false,
              ),
              getVerticalSpace(1.h),
              Obx(() => Text(
                errorMessage.value.contains('About') ? errorMessage.value : '',
                style: TextStyle(color: Colors.red, fontSize: 10.px),
              )),
              getVerticalSpace(2.h),
              Obx(
                    () => TextField(
                  onTap: () async {
                    date = getFormattedDate(await paymentController.selectDate(context, DateTime.now()));
                  },
                  readOnly: true,
                  style: CustomTextStyle.hintText.copyWith(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: 1.h,
                      ),
                      child: Icon(
                        Icons.date_range_rounded,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 1.h, top: 2.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.px),
                    ),
                    fillColor: AppColors.textFieldColor,
                    filled: true,
                    hintStyle: CustomTextStyle.hintText,
                    hintText: '${paymentController.formatedDate}',
                    isCollapsed: true,
                  ),
                ),
              ),
              getVerticalSpace(1.h),
              Obx(() => Text(
                errorMessage.value.contains('Date') ? errorMessage.value : '',
                style: TextStyle(color: Colors.red, fontSize: 10.px),
              )),
              getVerticalSpace(2.h),
              Obx(
                    () => TextField(
                  onTap: () async {
                    time = getFormattedTime(await paymentController.selectTime(context));
                  },
                  readOnly: true,
                  style: CustomTextStyle.hintText.copyWith(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: 1.h,
                      ),
                      child: Icon(
                        Icons.date_range_rounded,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 1.h, top: 2.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.px),
                    ),
                    fillColor: AppColors.textFieldColor,
                    filled: true,
                    hintStyle: CustomTextStyle.hintText,
                    hintText: '${paymentController.formatedTime}',
                    isCollapsed: true,
                  ),
                ),
              ),
              getVerticalSpace(1.h),
              Obx(() => Text(
                errorMessage.value.contains('Time') ? errorMessage.value : '',
                style: TextStyle(color: Colors.red, fontSize: 10.px),
              )),
              getVerticalSpace(5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.3.h),
                child: customLoadingButton(
                    onTap: () {
                      if (itineraryNameController.text.isEmpty) {
                        errorMessage.value = 'Itinerary name is required';
                      } else if (aboutItineraryController.text.isEmpty) {
                        errorMessage.value = 'About itinerary is required';
                      } else if (date == "") {
                        errorMessage.value = 'Date is required';
                      } else if (time == "") {
                        errorMessage.value = 'Time is required';
                      } else {
                        errorMessage.value = '';
                        itineraryController
                            .createItinerary(
                            load: true, name: itineraryNameController.text, about: aboutItineraryController.text, date: date, time: time)
                            .then(
                              (value) {
                            if (value) {
                              Get.back();
                            }
                          },
                        );
                      }
                    },
                    backgroundColor: AppColors.secondaryColor,
                    borderColor: AppColors.primaryColor,
                    title: 'Create Itinerary',
                    titleColor: Colors.black,
                    height: 4.5.h,
                    loading: itineraryController.loading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}