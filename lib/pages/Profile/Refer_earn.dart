// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names,   avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

class Refer_earn extends StatefulWidget {
  const Refer_earn({Key? key}) : super(key: key);

  @override
  State<Refer_earn> createState() => _Refer_earnState();
}

class _Refer_earnState extends State<Refer_earn> {
  String? userid;
  String? user_refer_code;
  String? currency;
  String? currencyposition;
  String? _reffer_amount;
  String? Androidapplink;
  String? IosApplink;

  @override
  void initState() {
    super.initState();
    refer_data();
  }

  refer_data() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userid = (prefs.getString(UD_user_id) ?? "null");
      user_refer_code = (prefs.getString(UD_user_refer_code) ?? "null");
      currency = (prefs.getString(APPcurrency) ?? "null");
      currencyposition = (prefs.getString(APPcurrency_position) ?? "null");
      _reffer_amount = (prefs.getString(referral_amount) ?? "null");
      Androidapplink = (prefs.getString(Androidlink) ?? "null");
      IosApplink = (prefs.getString(Ioslink) ?? "null");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            )),
        title: Text(
          'Refer_Earn'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        centerTitle: true,
        leadingWidth: 40,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 4.w, right: 4.w),
              height: 35.h,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Image.asset('Assets/Icons/referearn.png', height: 200),
            ),
            Center(
              child: Text(
                'Refer_Earn'.tr,
                style: TextStyle(fontFamily: 'Poppins_bold', fontSize: 14.5.sp),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 0.8.h, left: 4.w, right: 4.w),
              height: 11.h,
              width: 80.w,
              child: Text(
                currencyposition == "1"
                    ? "${'refer_code1'.tr} $currency$_reffer_amount ${'refer_code2'.tr}"
                    : "${'refer_code1'.tr} $_reffer_amount$currency ${'refer_code2'.tr}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey)),
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                height: 7.h,
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 1.9,
                      child: Text(
                        user_refer_code.toString(),
                        style:
                            TextStyle(fontFamily: 'Poppins_bold', fontSize: 18),
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 7.h,
                      width: 25.w,
                      color: color.black,
                      child: TextButton(
                        child: Text(
                          'Share'.tr,
                          style: TextStyle(
                              fontFamily: 'Poppins_semibold',
                              color: Colors.white,
                              fontSize: 11.sp),
                        ),
                        onPressed: () {
                          Share.share(
                            currencyposition == "1"
                                ? '${'Use_this_code'.tr} $user_refer_code ${'to_register_with'.tr} ${'Supreme_Seafood'.tr} ${'get_bonus_amount'.tr} $currency$_reffer_amount \n $Androidapplink \n $IosApplink   '
                                : '${'Use_this_code'.tr} $user_refer_code ${'to_register_with'.tr} ${'Supreme_Seafood'.tr} ${'get_bonus_amount'.tr} $_reffer_amount$currency \n $Androidapplink \n $IosApplink  ',
                          );
                        },
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
