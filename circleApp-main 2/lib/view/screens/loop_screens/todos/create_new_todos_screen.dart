import 'dart:io';

import 'package:circleapp/controller/api/upload_apis.dart';
import 'package:circleapp/controller/getx_controllers/circle_controller.dart';
import 'package:circleapp/controller/getx_controllers/picker_controller.dart';
import 'package:circleapp/controller/getx_controllers/todo_controller.dart';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/controller/utils/customTextStyle.dart';
import 'package:circleapp/models/add_todo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/add_bill_model.dart';
import '../../../../models/all_users_model.dart';
import '../../../custom_widget/customwidgets.dart';
import '../../plan_screens/all_members_screen.dart';
import 'add_bill_screen.dart';

class CreateNewToDo extends StatefulWidget {
  final String circleId;

  const CreateNewToDo({super.key, required this.circleId});

  @override
  State<CreateNewToDo> createState() => _CreateNewToDoState();
}

class _CreateNewToDoState extends State<CreateNewToDo> {
  RxList<Datum> selectedUsers = <Datum>[].obs;
  late PickerController pickerController;
  RxList<File?> todoImages = <File>[].obs;
  TextEditingController titleTextController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxBool billAdded = false.obs;
  Rxn<AddBillsModel> addBillModel = Rxn<AddBillsModel>();
  late TodosController todosController;

  @override
  void initState() {
    pickerController = Get.put(PickerController());
    todosController = Get.put(TodosController(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: SingleChildScrollView(
              child: Column(
            children: [
              getVerticalSpace(6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5.h),
                child: Row(
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
                      'Create new To-Dos',
                      style: CustomTextStyle.headingStyle,
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                        onTap: () async {
                          await Get.to(() => const AddBills())?.then(
                            (value) {
                              if (value != null) {
                                addBillModel.value = value;
                                billAdded.value = true;
                              }
                            },
                          );
                          ;
                        },
                        child: customTextButton1(title: 'Add Bill'))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getVerticalSpace(3.h),
                    Text(
                      'Title',
                      style: CustomTextStyle.smallText.copyWith(color: Colors.white),
                    ),
                    getVerticalSpace(.4.h),
                    customTextFormField(titleTextController, 'Winter trip Plan', isObsecure: false),
                    getVerticalSpace(3.h),
                    Text(
                      'Description',
                      style: CustomTextStyle.smallText.copyWith(color: Colors.white),
                    ),
                    getVerticalSpace(.4.h),
                    customTextFormField(descriptionController,
                        '''Lorem ipsum dolor sit amet consectetur. Eget aliquam suspendisse ultrices a mattis vitae. Adipiscing id vestibulum ultrices lorem. Nibh dignissim bibendum aAdipi.''',
                        isObsecure: false, maxLine: 4, borderRadius: BorderRadius.circular(15.px)),
                    getVerticalSpace(3.h),
                    Text('Upload Images', style: CustomTextStyle.headingStyle),
                    getVerticalSpace(.6.h),
                    Text('you can add multiple images.', style: CustomTextStyle.hintText),
                    getVerticalSpace(1.h),
                    GestureDetector(
                      onTap: () async {
                        todoImages.add(await pickerController.pickImage());
                      },
                      child: Image.asset("assets/png/chooseImage.png"),
                    ),
                    getVerticalSpace(1.5.h),
                    if (todoImages.isNotEmpty) ...[
                      SizedBox(
                        height: 8.2.h,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: todoImages.length,
                          itemExtent: 11.h,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: .3.h),
                                  child: Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.px), color: AppColors.textFieldColor),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15.px),
                                          child: Image.file(
                                            todoImages[index]!,
                                            fit: BoxFit.cover,
                                          )))),
                            );
                          },
                        ),
                      ),
                    ],
                    getVerticalSpace(4.h),
                    Text('Add person in group to split bill', style: CustomTextStyle.headingStyle),
                    getVerticalSpace(1.h),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 3.5.h,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedUsers.length,
                              itemExtent: 4.h,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: .3.h),
                                  decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryColor), shape: BoxShape.circle),
                                  child: CircleAvatar(
                                    radius: 5.6.h,
                                    backgroundColor: AppColors.mainColor,
                                    backgroundImage: selectedUsers[index].profilePicture != null
                                        ? NetworkImage(selectedUsers[index].profilePicture!)
                                        : const AssetImage('assets/png/userplacholder.png') as ImageProvider,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Get.to(() => AllMembersScreen(showAll: false, circleId: widget.circleId,))?.then(
                              (value) {
                                if (value != null) {
                                  selectedUsers.value = value;
                                }
                              },
                            );
                          },
                          child: customTextButton1(title: 'Add Member', horizentalPadding: 1.h, verticalPadding: .5.h, bgColor: Colors.transparent),
                        ),
                      ],
                    ),
                    getVerticalSpace(3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.h),
                      child: customButton(
                          onTap: () {
                            if (titleTextController.text.isEmpty) {
                              customScaffoldMessenger( "Add title");
                            } else if (descriptionController.text.isEmpty) {
                              customScaffoldMessenger( "Add description");
                            } else if (todoImages.isEmpty) {
                              customScaffoldMessenger( "Add at least one image description");
                            } else if (selectedUsers.isEmpty) {
                              customScaffoldMessenger( "Add at least one member");
                            }
                            // else if (!billAdded.value) {
                            //   customScaffoldMessenger( "Please add bill before submission");
                            // }
                            else {
                              showCustomDialog(context,
                                  title: titleTextController.text,
                                  description: descriptionController.text,
                                  selectedUsers: selectedUsers,
                                  addBillsModel:
                                      addBillModel.value != null ? addBillModel.value! : AddBillsModel(title: "", billAmount: "0", todoImages: []),
                                  todosController: todosController,
                                  circleId: widget.circleId,
                                  todoImages: todoImages);
                            }
                          },
                          backgroundColor: AppColors.secondaryColor,
                          borderColor: AppColors.primaryColor,
                          title: 'Done',
                          titleColor: Colors.black,
                          height: 4.5.h),
                    ),
                  ],
                ),
              )
            ],
          )));
    });
  }
}

void showCustomDialog(BuildContext context,
    {required String title,
    required String description,
    required RxList<Datum> selectedUsers,
    required AddBillsModel addBillsModel,
    required TodosController todosController,
    required String circleId,
    required List<File?> todoImages}) {
  final RxBool backButton = false.obs;
  final RxBool nextButton = true.obs;
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2.3.h),
            padding: EdgeInsets.symmetric(horizontal: 1.9.h, vertical: 1.3.h),
            height: 40.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.px), color: AppColors.textFieldColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 2.5.h,
                      ),
                    )
                  ],
                ),
                getVerticalSpace(2.h),
                Row(
                  children: [
                    Text(
                      'To-Dos Details',
                      style: CustomTextStyle.headingStyle,
                    ),
                    const Expanded(child: SizedBox()),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(text: 'Total Bill: ', style: CustomTextStyle.smallText.copyWith(color: const Color(0xffFFFFFF).withOpacity(0.48))),
                      TextSpan(text: '\$${addBillsModel.billAmount}', style: CustomTextStyle.smallText),
                    ])),
                  ],
                ),
                getVerticalSpace(1.3.h),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: 'Title: ', style: CustomTextStyle.smallText.copyWith(color: const Color(0xffDADADA))),
                  TextSpan(text: title, style: CustomTextStyle.smallText.copyWith(color: const Color(0xffDADADA))),
                ])),
                getVerticalSpace(1.3.h),
                Text(
                  "Description: $description",
                  style: CustomTextStyle.hintText,
                ),
                getVerticalSpace(1.3.h),
                Row(
                  children: [
                    Text(
                      "Splitting Bill",
                      style: CustomTextStyle.hintText.copyWith(color: const Color(0xffFFFFFF).withOpacity(0.69)),
                    ),
                    const Expanded(child: SizedBox()),
                    Text('Bill receipts',
                        style: CustomTextStyle.hintText.copyWith(
                          color: const Color(0xffFFFFFF).withOpacity(0.69),
                        ))
                  ],
                ),
                getVerticalSpace(1.3.h),
                Row(
                  children: [
                    SizedBox(
                      height: 4.h,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedUsers.length,
                        itemExtent: 4.h,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: .3.h),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryColor), shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 5.6.h,
                              backgroundColor: AppColors.mainColor,
                              backgroundImage: selectedUsers[index].profilePicture != null
                                  ? NetworkImage(selectedUsers[index].profilePicture!)
                                  : const AssetImage('assets/png/userplacholder.png') as ImageProvider,
                            ),
                          );
                        },
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      height: 4.h,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: addBillsModel.todoImages.length,
                        itemExtent: 5.h,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: .3.h),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.px),
                                  image: DecorationImage(image: FileImage(addBillsModel.todoImages[index]!))),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                getVerticalSpace(3.4.h),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      getHorizentalSpace(4.h),
                      Expanded(
                        child: customButton(
                            onTap: () {
                              Get.back();
                            },
                            backgroundColor: backButton.value == true ? AppColors.secondaryColor : AppColors.primaryColor,
                            borderColor: backButton.value == true ? AppColors.primaryColor : AppColors.secondaryColor,
                            title: 'Back',
                            titleColor: backButton.value == true ? Colors.black : Colors.white,
                            width: 12.h,
                            height: 4.5.h),
                      ),
                      getHorizentalSpace(1.h),
                      Expanded(
                        child: customLoadingButton(
                            onTap: () async {
                              List<String> todoImagesString = [];
                              List<String> receiptImagesString = [];
                              for (var image in todoImages) {
                                todosController.newTodoLoading.value = true;
                                await UploadApis(context).uploadFile(image!).then(
                                  (value) {
                                    if (value != null) {
                                      todoImagesString.add(value.first);
                                    }
                                  },
                                );
                              }
                              for (var image in addBillsModel.todoImages) {
                                await UploadApis(context).uploadFile(image!).then(
                                  (value) {
                                    if (value != null) {
                                      receiptImagesString.add(value.first);
                                    }
                                  },
                                );
                              }

                              todosController.createNewTodo(
                                  load: true,
                                  addNewToDoModel: AddNewTodoModel(
                                      title: title,
                                      description: description,
                                      memberIds: selectedUsers.map((datum) => datum.id).toList(),
                                      circleId: circleId,
                                      images: todoImagesString,
                                      bill: Bill(
                                          total: double.parse(addBillsModel.billAmount),
                                          title: title,
                                          images: receiptImagesString,
                                          members: selectedUsers.map((datum) => datum.id).toList())));
                            },
                            backgroundColor: nextButton.value == true ? AppColors.secondaryColor : AppColors.primaryColor,
                            borderColor: nextButton.value == true ? AppColors.primaryColor : AppColors.secondaryColor,
                            title: 'Done',
                            titleColor: nextButton.value == true ? Colors.black : Colors.white,
                            width: 12.h,
                            height: 4.5.h,
                            loading: todosController.newTodoLoading),
                      ),
                      getHorizentalSpace(4.h)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
      } else {
        tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
      }

      return SlideTransition(
        position: tween.animate(anim),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}
