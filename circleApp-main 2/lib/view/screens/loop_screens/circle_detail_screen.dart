import 'package:circleapp/controller/getx_controllers/circle_controller.dart';
import 'package:circleapp/controller/getx_controllers/convos_controller.dart';
import 'package:circleapp/controller/getx_controllers/todo_controller.dart';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:circleapp/view/screens/loop_screens/todos/create_new_todos_screen.dart';
import 'package:circleapp/view/screens/loop_screens/todos/to_dos_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../controller/getx_controllers/stories_controller.dart';
import '../../custom_widget/customwidgets.dart';
import 'convos/convos_widget.dart';

class CircleDetails extends StatefulWidget {
  final String circleId, userProfileImage, circleName;

  const CircleDetails({super.key, required this.circleId, required this.userProfileImage, required this.circleName});

  @override
  State<CircleDetails> createState() => _CircleDetailsState();
}

class _CircleDetailsState extends State<CircleDetails> {
  late StoryController storyController;
  late TodosController todosController;
  late ConvosController convosController;
  RxInt selectedIndex = 0.obs;

  @override
  void initState() {
    storyController = Get.put(StoryController(context));
    todosController = Get.put(TodosController(context));
    convosController = Get.put(ConvosController(context));
    storyController.getStories(
        circleId: widget.circleId,
        load: storyController.storiesModel.value == null || convosController.messagesModel.value?.circleId != widget.circleId);
    convosController.getConvos(
        load: convosController.messagesModel.value == null || convosController.messagesModel.value?.circleId != widget.circleId,
        circleId: widget.circleId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('id======${widget.circleId}');
    RxList<String> name = <String>['Convos', 'To-Dos', 'Experiences'].obs;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Column(
            children: [
              getVerticalSpace(55.px),
              Row(
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
                    widget.circleName,
                    style: CustomTextStyle.headingStyle,
                  ),
                  const Spacer(),
                  selectedIndex.value == 1
                      ? GestureDetector(
                          onTap: () {
                            if (selectedIndex.value == 1) {
                              Get.to(CreateNewToDo(circleId: widget.circleId));
                            }
                            if (selectedIndex.value == 2) {}
                          },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 2.h),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.mainColorYellow)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Add+",
                                  style: CustomTextStyle.mediumTextYellow,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              getVerticalSpace(15.px),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        selectedIndex.value = 0;
                        storyController.getStories(circleId: widget.circleId, load: storyController.storiesModel.value == null);
                        convosController.getConvos(
                            load: convosController.messagesModel.value == null || convosController.messagesModel.value?.circleId != widget.circleId,
                            circleId: widget.circleId);
                      },
                      child: Container(
                        height: 40.px,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedIndex.value == 0 ? AppColors.secondaryColor : AppColors.textFieldColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.px),
                            bottomLeft: Radius.circular(20.px),
                          ),
                        ),
                        child: Text(
                          name[0],
                          style: CustomTextStyle.smallText.copyWith(
                            fontSize: 12.px,
                            color: selectedIndex.value == 0 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  getHorizentalSpace(5.px),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        selectedIndex.value = 1;
                        todosController.getTodosTodos(load: todosController.allTodosModel.value == null, circleId: widget.circleId);
                      },
                      child: Container(
                        height: 40.px,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedIndex.value == 1 ? AppColors.secondaryColor : AppColors.textFieldColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.px),
                            bottomRight: Radius.circular(20.px),
                          ),
                        ),
                        child: Text(
                          name[1],
                          style: CustomTextStyle.smallText.copyWith(
                            fontSize: 12.px,
                            color: selectedIndex.value == 1 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  getHorizentalSpace(5.px),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       selectedIndex.value = 2;
                  //     },
                  //     child: Container(
                  //       height: 40.px,
                  //       alignment: Alignment.center,
                  //       decoration: BoxDecoration(
                  //         color: selectedIndex.value == 2 ? AppColors.secondaryColor : AppColors.textFieldColor,
                  //         borderRadius: BorderRadius.only(
                  //           topRight: Radius.circular(20.px),
                  //           bottomRight: Radius.circular(20.px),
                  //         ),
                  //       ),
                  //       child: Text(
                  //         name[2],
                  //         style: CustomTextStyle.smallText.copyWith(
                  //           fontSize: 12.px,
                  //           color: selectedIndex.value == 2 ? Colors.black : Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              getVerticalSpace(1.3.h),
              selectedIndex.value == 0
                  ? convosWidget(storyController: storyController, circleId: widget.circleId, convosController: convosController, mContext: context)
                  : selectedIndex.value == 1
                      ? toDosWidget(todosController: todosController, circleId: widget.circleId)
                      : getVerticalSpace(3.h),
            ],
          ),
        ),
      ),
    );
  }
}
