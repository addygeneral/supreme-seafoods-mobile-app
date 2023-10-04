// ignore_for_file: prefer_const_constructors, file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/common class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:singlerestaurant/validation/validator.dart/validator.dart';
import 'package:sizer/sizer.dart';

import 'Payment.dart';

class Addmoney extends StatefulWidget {
  const Addmoney({Key? key}) : super(key: key);

  @override
  State<Addmoney> createState() => _AddmoneyState();
}

class _AddmoneyState extends State<Addmoney> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController Enteramount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            )),
        title: Text(
          'Add_Money'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        leadingWidth: 40,
        centerTitle: true,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 2.h,
                left: 3.w,
                right: 4.w,
              ),
              child: Image.asset(
                'Assets/Icons/whitelogo.png',
                height: 8.h,
                color: color.primarycolor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 1.1.h,
                ),
                Text(
                  'Wallet_Money'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins_semibold',
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(
                  height: 1.2.sp,
                ),
                Row(
                  children: [
                    Text(
                      'Total_Balance_'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      "0.00",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8.7.sp,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 4.h, left: 3.w, right: 4.w),
          child: Text(
            'Enteramount'.tr,
            style: TextStyle(
                fontFamily: 'Poppins', fontSize: 10.5.sp, color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 3.w, right: 4.w, top: 1.5.h),
          child: Center(
            child: Form(
              key: _formkey,
              child: TextFormField(
                validator: (value) =>
                    Validators.validateRequired(value!, "amount"),
                cursorColor: Colors.grey,
                controller: Enteramount,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    size: 12.5.sp,
                  ),
                  prefixStyle: TextStyle(
                    fontFamily: 'Poppins_bold',
                    fontSize: 12.5.sp,
                  ),
                  hintText: 'Zero'.tr,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.h, left: 3.w, right: 4.w),
          height: 6.h,
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              if (_formkey.currentState!.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Payment(Enteramount.value.text)),
                );
              }
            },
            style: TextButton.styleFrom(backgroundColor: Color(0xFFE82428)),
            child: Text(
              'Procaddmoney'.tr,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 4.h, left: 3.w, right: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTES'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 7.8.sp,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  LocaleKeys
                      .Wallet_Money_cannot_be_transferred_to_your_bank_account
                      .tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 7.8.sp,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'You_can_use_Wallet_Money_only_on_orders'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 7.8.sp,
                  ),
                ),
              ],
            )),
        Spacer(),
        Center(
          child: Container(
            margin: EdgeInsets.only(
              bottom: 1.5.h,
            ),
            child: Text(
              'Devbygravityinfo'.tr,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontsize.Buttonfontsize,
                  color: Colors.black),
            ),
          ),
        ),
      ]),
    );
  }
}
