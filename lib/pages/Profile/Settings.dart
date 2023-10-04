// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../Theme/ThemeModel.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themenofier, child) {
      return SafeArea(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.all(2.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Darkmode'.tr,
                      style: TextStyle(
                          fontSize: 12.sp, fontFamily: 'Poppins_semibold'),
                    ),
                    Spacer(),
                    Switch.adaptive(
                        inactiveTrackColor: Colors.grey,
                        activeColor: Colors.white,
                        inactiveThumbColor: Colors.black,
                        value: themenofier.isdark ? true : false,
                        onChanged: (value) {
                          themenofier.isdark
                              ? themenofier.isDark = false
                              : themenofier.isDark = true;
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
