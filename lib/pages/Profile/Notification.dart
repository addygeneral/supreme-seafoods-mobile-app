// ignore_for_file: file_names,   prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/settings%20model/isnotificationmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:provider/provider.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import '../../Theme/ThemeModel.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({Key? key}) : super(key: key);

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  bool status1 = false;
  String? userid;
  String? isnotification;
  String? ismail;
  isnotificationModel? notificationdata;

  isisnotificationAPI(notification, mail) async {
    loader.showLoading();
    var map = {
      "user_id": userid,
      "notification_status": notification,
      "mail_status": mail,
    };

    var response =
        await Dio().post(DefaultApi.appUrl + PostAPI.Isnotification, data: map);
    var finallist = await response.data;
    notificationdata = isnotificationModel.fromJson(finallist);
    if (notificationdata!.status == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(UD_user_isnotification,
          notificationdata!.notificationStatus.toString());
      prefs.setString(UD_user_ismail, notificationdata!.mailStatus.toString());
    }
    loader.hideLoading();
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString(UD_user_id);
      isnotification = prefs.getString(UD_user_isnotification);
      ismail = prefs.getString(UD_user_ismail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themenofier, child) {
      return SafeArea(
          child: Scaffold(
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
            'Notification_Settings'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
          ),
          leadingWidth: 40,
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 1.7.h, left: 4.w, right: 4.w),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Push_Notifications'.tr,
                    style: TextStyle(
                        fontFamily: 'Poppins_semibold', fontSize: 12.sp),
                  ),
                  Spacer(),
                  FlutterSwitch(
                    inactiveColor: Colors.grey,
                    activeColor: color.red,
                    width: 12.8.w,
                    height: 3.9.h,
                    value: isnotification == "1" ? true : false,
                    borderRadius: 30.0,
                    padding: 4.0,
                    showOnOff: false,
                    onToggle: (val) {
                      if (DefaultApi.environment == "sendbox") {
                        loader.showErroDialog(
                          description: LocaleKeys
                              .This_operation_was_not_performed_due_to_demo_mode
                              .tr,
                        );
                      } else if (isnotification == "1") {
                        setState(() {
                          isnotification = "2";
                        });

                        isisnotificationAPI(isnotification, ismail);
                      } else {
                        setState(() {
                          isnotification = "1";
                        });
                        isisnotificationAPI(isnotification, ismail);
                      }
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: 1.1.h),
                height: 0.8.sp,
                color: color.grey,
              ),
              Row(
                children: [
                  Text(
                    'keepthisonnoti'.tr,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10.sp),
                  ),
                ],
              ),
              SizedBox(
                height: 6.h,
              ),
              Row(
                children: [
                  Text(
                    'Emails',
                    style: TextStyle(
                        fontFamily: 'Poppins_semibold', fontSize: 12.sp),
                  ),
                  Spacer(),
                  FlutterSwitch(
                    inactiveColor: Colors.grey,
                    activeColor: color.red,
                    width: 12.8.w,
                    height: 3.9.h,
                    value: ismail == "1" ? true : false,
                    borderRadius: 30.0,
                    padding: 4.0,
                    showOnOff: false,
                    onToggle: (val1) {
                      if (DefaultApi.environment == "sendbox") {
                        loader.showErroDialog(
                          description: LocaleKeys
                              .This_operation_was_not_performed_due_to_demo_mode
                              .tr,
                        );
                      } else if (ismail == "1") {
                        setState(() {
                          ismail = "2";
                        });
                        isisnotificationAPI(isnotification, ismail);
                      } else {
                        setState(() {
                          ismail = "1";
                        });
                        isisnotificationAPI(isnotification, ismail);
                      }
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 1.h, bottom: 1.1.h),
                height: 0.8.sp,
                color: Colors.black26,
              ),
              Row(
                children: [
                  Text(
                    'Keep_this_on_to_receive_emails_from_system'.tr,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ));
    });
  }
}
