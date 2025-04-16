import 'package:circleapp/controller/getx_controllers/events_controller.dart';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/getx_controllers/plan_controller.dart';
import '../../../controller/utils/common_methods.dart';
import '../../../models/loop_models/event_model.dart';
import '../../../models/plan_model.dart';
import '../../custom_widget/customwidgets.dart';
import '../explore_section/share_group.dart';
import 'addNewPlanScreen.dart';

class PlansDetails extends StatefulWidget {
  final DateTime dateTime;

  const PlansDetails({super.key, required this.dateTime});

  @override
  State<PlansDetails> createState() => _PlansDetailsState();
}

class _PlansDetailsState extends State<PlansDetails> {
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(DateTime.now());
  late EventController eventController;
  late PlanController planController;

  @override
  void initState() {
    planController = Get.put(PlanController(context));
    eventController = Get.put(EventController(context));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPlansAndEvents();
    });
    super.initState();
  }

  Future<void> getPlansAndEvents() async {
    await Future.wait([
      planController.getPlans(load: planController.plans.isEmpty, dateTime: widget.dateTime),
      eventController.getEvents(load: eventController.events.isEmpty),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = ["assets/png/png4.png", "assets/png/png3.png", "assets/png/png2.png", "assets/png/png1.png"];

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.mainColorBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.3.h),
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
                    'Plan details',
                    style: CustomTextStyle.headingStyle,
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              getVerticalSpace(3.5.h),
              Text(
                'Events',
                style: CustomTextStyle.headingStyle,
              ),
              getVerticalSpace(.4.h),
              SizedBox(
                height: 4.h,
                width: MediaQuery.of(context).size.width - 2.3.h,
                child: eventController.loading.value
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: AppColors.shimmerColor1,
                            highlightColor: AppColors.shimmerColor2,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.symmetric(horizontal: 5.px),
                              width: 120.px,
                              height: 50.px,
                              decoration: BoxDecoration(
                                color: AppColors.mainColor,
                                borderRadius: BorderRadius.circular(10.px),
                              ),
                            ),
                          );
                        })
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: eventController.events.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Event event = eventController.events[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.px),
                      padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.px),
                        color: const Color(0xffFFFFFF).withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: .6.h,
                            backgroundColor: Color(colorCodeToInt(eventColors[event.color] ?? "blue")),
                          ),
                          getHorizentalSpace(.8.h),
                          Text(
                            event.name,
                            style: CustomTextStyle.buttonText.copyWith(
                              fontSize: 10.px,
                              color: Color(colorCodeToInt(colorNameToCode(event.color))),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              getVerticalSpace(2.5.h),
              Expanded(
                child: planController.loading.value
                    ? ListView.builder(
                        itemCount: 8,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: AppColors.shimmerColor1,
                            highlightColor: AppColors.shimmerColor2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              alignment: Alignment.bottomCenter,
                              height: 180.px,
                              decoration: BoxDecoration(
                                color: AppColors.mainColor,
                                borderRadius: BorderRadius.circular(20.px),
                              ),
                            ),
                          );
                        })
                    : planController.plans.isEmpty
                        ? Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("No Plans found on",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    )),
                                Text(
                                    "${_selectedDate.value.day} ${[
                                      "Jan",
                                      "Feb",
                                      "Mar",
                                      "Apr",
                                      "May",
                                      "Jun",
                                      "Jul",
                                      "Aug",
                                      "Sep",
                                      "Oct",
                                      "Nov",
                                      "Dec"
                                    ][_selectedDate.value.month - 1]} ${_selectedDate.value.year}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ))
                              ],
                            ),
                          )
                        : ListView.builder(
                  itemCount: planController.plans.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    Plan plan = planController.plans[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Dismissible(
                        key: ValueKey(plan.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.mainColorYellow,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          planController.deletePlan(plan.id, load: false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.2.h, vertical: 2.h),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.textFieldColor,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan.name,
                                    style: CustomTextStyle.mediumTextM14,
                                  ),
                                  const Expanded(child: SizedBox()),
                                  Text(
                                    getFormattedDate(plan.date),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 11.px,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "medium",
                                    ),
                                  ),
                                ],
                              ),
                              getVerticalSpace(.5.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  plan.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10.px,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "medium",
                                  ),
                                ),
                              ),
                              getVerticalSpace(1.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/svg/Location.svg"),
                                  getHorizentalSpace(1.w),
                                  Expanded(
                                    child: Text(
                                      plan.location,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 8.px,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "medium",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              getVerticalSpace(1.2.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Added members",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11.px,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "medium",
                                  ),
                                ),
                              ),
                              getVerticalSpace(1.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        height: 27,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageUrls.length,
                                          itemBuilder: (BuildContext, index) {
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 2),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(50.0),
                                                child: Image.asset(
                                                  fit: BoxFit.fill,
                                                  imageUrls[index],
                                                  width: 27,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      getHorizentalSpace(1.w),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => const ShareGroupScreen());
                                        },
                                        child: SvgPicture.asset("assets/svg/shareButton.svg"),
                                      ),
                                      getHorizentalSpace(2.w),
                                      Container(
                                        height: 3.h,
                                        width: 22.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.mainColorYellow,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: AppColors.mainColorYellow),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Booked",
                                            style: CustomTextStyle.buttonDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
