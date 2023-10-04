// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class Ordersucesspage extends StatefulWidget {
  const Ordersucesspage({Key? key}) : super(key: key);

  @override
  State<Ordersucesspage> createState() => _OrdersucesspageState();
}

class _OrdersucesspageState extends State<Ordersucesspage> {
  cartcount count = Get.put(cartcount());
  String? userid;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: SafeArea(
          child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
              // width: double.infinity,
              height: 48.h,
              child: Image.asset(
                "Assets/Image/ordersucess.png",
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'Success'.tr,
              style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 15.sp),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.h),
              child: Text(
                LocaleKeys
                        .Your_order_has_been_placed_successfully_will_be_process_by_system
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5.sp),
              ),
            )
          ],
        ),
        bottomSheet: Container(
          margin: EdgeInsets.only(
            bottom: 1.h,
            left: 3.5.w,
            right: 3.5.w,
          ),
          height: 6.h,
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              count.cartcountnumber.value = 0;
              SharedPreferences pref = await SharedPreferences.getInstance();
              userid = pref.getString(UD_user_id);
                Get.offAll(() => Homepage(0));
                },
            style: TextButton.styleFrom(backgroundColor: color.primarycolor),
            child: Text(
              'Continue_Shopping'.tr,
              style: TextStyle(
                  fontFamily: 'Poppins_semibold',
                  color: Colors.white,
                  fontSize: fontsize.Buttonfontsize),
            ),
          ),
        ),
      )),
    );
  }
}
