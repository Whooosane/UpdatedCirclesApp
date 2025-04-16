import 'package:circleapp/controller/getx_controllers/itinerary_controller.dart';
import 'package:circleapp/controller/getx_controllers/picker_controller.dart';
import 'package:circleapp/models/ItineraryModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../controller/utils/app_colors.dart';
import '../../../../controller/utils/customTextStyle.dart';
import '../../../custom_widget/customwidgets.dart';
import '../../explore_section/share_group.dart';
import 'create_itinirary.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(DateTime.now());
  late ItineraryController itineraryController;
  late PickerController pickerController;
  CalendarWeekController calendarWeekController = CalendarWeekController();
  String day = "";
  String month = "";

  @override
  void initState() {
    itineraryController = Get.put(ItineraryController(context));
    pickerController = Get.put(PickerController());
    calendarWeekController.selectedDate = DateTime.now();
    itineraryController.getItineraries(load: true, dateTime: DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColorBackground,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 10.px),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime? dateTime = await pickerController.selectDate(context, _selectedDate.value);
                    if (dateTime != null) {
                      _selectedDate.value = dateTime;
                      itineraryController.getItineraries(load: true, dateTime: _selectedDate.value);
                    }
                  },
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDate,
                        builder: (context, value, child) {
                          return Text(
                            "${value.day}",
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      getHorizentalSpace(10.px),
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _selectedDate,
                        builder: (context, value, child) {
                          day = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][value.weekday - 1];
                          month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][value.month - 1];
                          return Text(
                            "$day\n$month ${value.year}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                customButton(
                  onTap: () {
                    Get.to(() => CreateItinerary());
                  },
                  backgroundColor: AppColors.secondaryColor,
                  height: 30.px,
                  width: 120.px,
                  title: "Create Itinerary",
                  titleColor: Colors.black,
                  borderColor: Colors.transparent,
                ),
              ],
            ),
          ),
          weeklyCalender(
            calendarWeekController,
                (dateTime) {
              _selectedDate.value = dateTime;
              itineraryController.getItineraries(load: true, dateTime: _selectedDate.value);
            },
                (dateTime) {},
          ),
          Expanded(
            child: Obx(() {
              return itineraryController.loading.value
                  ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
                  shrinkWrap: true,
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: AppColors.shimmerColor1,
                      highlightColor: AppColors.shimmerColor2,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(10.px),
                        ),
                      ),
                    );
                  })
                  : itineraryController.itineraries.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Itineraries found on",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      )),
                  Text("${_selectedDate.value.day} $month ${_selectedDate.value.year}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ))
                ],
              )
                  : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
                  shrinkWrap: true,
                  itemCount: itineraryController.itineraries.length,
                  itemBuilder: (context, index) {
                    ItineraryModel itinerary = itineraryController.itineraries[index];
                    return Column(
                      children: [
                        if (index == 0) ...[
                          Divider(
                            color: AppColors.hintTextColor,
                          ),
                        ],
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const ShareGroupScreen());
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: .6.h,
                                      backgroundColor: Colors.white,
                                    ),
                                    getHorizentalSpace(.5.h),
                                    Text(
                                      itinerary.about,
                                      style: CustomTextStyle.buttonText.copyWith(color: Colors.white),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      itinerary.time,
                                      style: CustomTextStyle.buttonText.copyWith(color: Colors.white),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    getHorizentalSpace(2.h),
                                    Text(
                                      itinerary.name,
                                      style: CustomTextStyle.headingStyle.copyWith(color: AppColors.secondaryColor),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    GestureDetector(
                                        onTap: () {
                                          Get.to(() => const ShareGroupScreen());
                                        },
                                        child: SvgPicture.asset("assets/png/share.svg"))
                                  ],
                                ),
                                getVerticalSpace(.6.h),
                                Divider(
                                  color: AppColors.secondaryColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            }),
          )
        ],
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Conference', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }
    return meetingData;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}