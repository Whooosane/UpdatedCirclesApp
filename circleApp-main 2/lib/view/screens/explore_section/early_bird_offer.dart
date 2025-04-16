import 'package:circleapp/controller/utils/common_methods.dart';
import 'package:circleapp/controller/utils/style/customTextStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import the cached_network_image package
import 'package:shimmer/shimmer.dart';

import '../../../controller/utils/app_colors.dart';
import '../../../models/offer_models/offers_model.dart';
import '../../custom_widget/customwidgets.dart';

class OfferDetails extends StatefulWidget {
  final Offer offer;

  const OfferDetails({super.key, required this.offer});

  @override
  State<OfferDetails> createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  RxInt selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColorBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainColorBackground,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 19.px,
                )),
            getHorizentalSpace(4.w),
            Text(
              widget.offer.title,
              style: CustomTextStyle.mediumTextExplore,
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: SvgPicture.asset(
              "assets/svg/save.svg",
              height: 25.px,
            ),
          ),
          getHorizentalSpace(2.w),
          SvgPicture.asset(
            "assets/svg/shareIcon.svg",
          ),
          getHorizentalSpace(2.w),
          Container(
            height: 22.px,
            width: 20.w,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.mainColorYellow),
            child: const Center(child: Text("Book")),
          ),
          SizedBox(
            height: 6.w,
            width: 6.w,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.h),
        child: SingleChildScrollView(
            child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 48.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Border radius for the image
                    child: CachedNetworkImage(
                      imageUrl: widget.offer.imageUrls[selectedIndex.value],
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Shimmer.fromColors(
                          baseColor: AppColors.shimmerColor1,
                          highlightColor: AppColors.shimmerColor2,
                          child: Container(
                            color: Colors.white,
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    ),
                  ),
                ),
              ),
              getVerticalSpace(1.h),
              SizedBox(
                height: 11.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.offer.imageUrls.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        selectedIndex.value = index;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8), // Border radius for small images
                          child: CachedNetworkImage(
                            imageUrl: widget.offer.imageUrls[index],
                            height: 82,
                            width: 22.w,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Shimmer.fromColors(
                                baseColor: AppColors.shimmerColor1,
                                highlightColor: AppColors.shimmerColor2,
                                child: Container(
                                  color: Colors.white,
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              getVerticalSpace(1.h),
              Text(
                widget.offer.description,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.px, fontWeight: FontWeight.w400, fontFamily: "medium"),
              ),
              getVerticalSpace(1.h),
              Row(
                children: [
                  Text(
                    "Offer for: ",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.px, fontWeight: FontWeight.w400, fontFamily: "medium"),
                  ),
                  getHorizentalSpace(0.5.w),
                  Text(
                    "${widget.offer.numberOfPeople} People",
                    style: CustomTextStyle.mediumTextM,
                  ),
                ],
              ),
              getVerticalSpace(1.h),
              Row(
                children: [
                  Text(
                    "Interest: ",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.px, fontWeight: FontWeight.w400, fontFamily: "medium"),
                  ),
                  getHorizentalSpace(0.5.w),
                  Text(
                    widget.offer.interest,
                    style: CustomTextStyle.mediumTextM,
                  ),
                ],
              ),
              getVerticalSpace(1.h),
              Row(
                children: [
                  Text(
                    "Total Price: ",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.px, fontWeight: FontWeight.w400, fontFamily: "medium"),
                  ),
                  getHorizentalSpace(0.5.w),
                  Text(
                    "\$${widget.offer.price}",
                    style: CustomTextStyle.mediumTextM,
                  ),
                  const Expanded(child: SizedBox()),
                  Text(
                    getFormattedDate(widget.offer.startingDate),
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.px, fontWeight: FontWeight.w400, fontFamily: "medium"),
                  )
                ],
              ),
              SizedBox(
                height: 2.h,
                width: 2.h,
              )
            ],
          ),
        )),
      ),
    );
  }
}
