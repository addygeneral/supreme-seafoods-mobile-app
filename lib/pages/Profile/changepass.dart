// ignore_for_file: unused_field, non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:singlerestaurant/Model/settings%20model/changepasswordmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../config/API/API.dart';

class Changepass extends StatefulWidget {
  const Changepass({Key? key}) : super(key: key);

  @override
  State<Changepass> createState() => _ChangepassState();
}

class _ChangepassState extends State<Changepass> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  TextEditingController oldpass = TextEditingController();
  TextEditingController newpass = TextEditingController();
  TextEditingController confirmpass = TextEditingController();
  changepasswordmodel? changepassworddata;
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _obscureText3 = true;

  _Changepassword() async {
    try {
      loader.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getString(UD_user_id);

      var map = {
        "user_id": prefs.getString(UD_user_id),
        "new_password": newpass.text.toString(),
        "old_password": oldpass.text.toString(),
      };

      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.ChangePassword, data: map);

      // print(response.data);
      var finallist = await response.data;
      changepassworddata = changepasswordmodel.fromJson(finallist);
      loader.hideLoading();

      if (changepassworddata!.status == 0) {
        loader.showErroDialog(
            description: changepassworddata!.message.toString());
      } else if (changepassworddata!.status == 1) {
        oldpass.clear();
        newpass.clear();
        confirmpass.clear();
        Navigator.of(context).pop();
        loader.showErroDialog(description: "update password");
      }
    } catch (e) {
      loader.showErroDialog(description: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          'Change_Password'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins_semibold',
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leadingWidth: 40,
      ),
      body: Form(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 4.5.w,
                right: 4.5.w,
                top: MediaQuery.of(context).size.height / 80,
              ),
              width: double.infinity,
              child: Center(
                child: TextField(
                  cursorColor: Colors.grey,
                  controller: oldpass,
                  obscureText: _obscureText1,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText1 = !_obscureText1;
                            });
                          },
                          icon: Icon(
                            _obscureText1
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          )),
                      hintText: 'Old_password'.tr,
                      hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 10.5.sp),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      )),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 4.5.w,
                right: 4.5.w,
                top: MediaQuery.of(context).size.height / 80,
              ),
              width: double.infinity,
              child: Center(
                child: TextFormField(
                  cursorColor: Colors.black,
                  obscureText: _obscureText2,
                  controller: newpass,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText2 = !_obscureText2;
                            });
                          },
                          icon: Icon(
                            _obscureText2
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          )),
                      hintText: 'New_password'.tr,
                      hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 10.5.sp),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      )),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 4.5.w,
                right: 4.5.w,
                top: MediaQuery.of(context).size.height / 80,
              ),
              width: double.infinity,
              child: Center(
                child: TextFormField(
                  obscureText: _obscureText3,
                  validator: (val) {
                    if (val!.isEmpty) return 'Empty';
                    if (val != newpass.text) return 'Not Match';
                    return null;
                  },
                  cursorColor: Colors.black,
                  controller: confirmpass,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText3 = !_obscureText3;
                            });
                          },
                          icon: Icon(
                            _obscureText3
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          )),
                      hintText: 'Confirm_password'.tr,
                      hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                          fontSize: 10.5.sp),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                      )),
                ),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(
                right: 4.w,
                left: 4.w,
                bottom: 0.8.h,
              ),
              height: 6.5.h,
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  if (DefaultApi.environment == "sendbox") {
                    loader.showErroDialog(
                        description: LocaleKeys
                            .This_operation_was_not_performed_due_to_demo_mode
                            .tr);
                  } else {
                    if (oldpass.text.isEmpty) {
                      loader.showErroDialog(
                          description: 'Please_enter_all_details'.tr);
                    } else if (newpass.text.isEmpty) {
                      loader.showErroDialog(
                          description: 'Please_enter_all_details'.tr);
                    } else if (confirmpass.text.isEmpty) {
                      loader.showErroDialog(
                          description: 'Please_enter_all_details'.tr);
                    } else if (newpass.text == confirmpass.text) {
                      _Changepassword();
                    } else {
                      loader.showErroDialog(
                          description: LocaleKeys
                              .New_password_Confirm_password_must_be_same.tr);
                    }
                  }
                },
                style: TextButton.styleFrom(backgroundColor: Color(0xFFE82428)),
                child: Text(
                  'Reset'.tr,
                  style: TextStyle(
                      fontFamily: 'Poppins_semibold',
                      color: Colors.white,
                      fontSize: fontsize.Buttonfontsize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
