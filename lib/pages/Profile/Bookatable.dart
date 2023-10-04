// ignore_for_file: file_names, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_local_variable,   override_on_non_overriding_member, use_build_context_synchronously, prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:singlerestaurant/Model/settings%20model/bookatablemodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:singlerestaurant/validation/validator.dart/validator.dart';
import 'package:sizer/sizer.dart';

class Bookatable extends StatefulWidget {
  const Bookatable({Key? key}) : super(key: key);

  @override
  State<Bookatable> createState() => _BookatableState();
}

class _BookatableState extends State<Bookatable> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var maxLines = 15;
  final Name = TextEditingController();
  final Email = TextEditingController();
  final Mobile = TextEditingController();
  final Noofguest = TextEditingController();
  final Date = TextEditingController();
  final Time = TextEditingController();
  final Reservation = TextEditingController();
  final Specialrequest = TextEditingController();
  DateTime selectedDate = DateTime.now();
  var currenttime = TimeOfDay.now();
  booktablemodel? booktabledata;

  Future<void> displayTimeDialog(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: currenttime,
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: color.primarycolor,
              ),
            ),
            child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        String _hour = picked.hour.toString();
        String _minute = picked.minute.toString();
        String _AMPM = picked.periodOffset.toString();
        String bookingtime = "$_hour:$_minute";

        Time.value = TextEditingValue(text: getFormatedTime(bookingtime));
      });
    }
  }

  getFormatedDate(_date) {
    var inputFormat = DateFormat('dd-MM-yyyy');
    var inputDate = inputFormat.parse(_date);
    var outputFormat = DateFormat('dd-MM-yyyy');
    return outputFormat.format(inputDate);
  }

  getFormatedTime(_time) {
    var inputFormat = DateFormat('HH:mm');
    var inputDate = inputFormat.parse(_time);
    var outputFormat = DateFormat('hh:mm a');
    return outputFormat.format(inputDate);
  }

  @override
  bookatableAPI() async {
    try {
      loader.showLoading();
      var map = {
        "name": Name.value.text,
        "email": Email.text.toString(),
        "mobile": Mobile.text.toString(),
        "guests": Noofguest.text.toString(),
        "date": Date.text.toString(),
        "time": Time.text.toString(),
        "reservation_type": Reservation.text.toString(),
        "special_request": Specialrequest.text.toString()
      };

      var response = await Dio().post(
        DefaultApi.appUrl + PostAPI.Bookatable,
        data: map,
      );
      var finallist = response.data;
      booktabledata = booktablemodel.fromJson(finallist);
      loader.hideLoading();

      if (booktabledata!.status == 1) {
        Navigator.of(context).pop();

        loader.showErroDialog(description: "Booking Success");
      } else {
        loader.showErroDialog(description: booktabledata!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Book_A_Table'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        centerTitle: true,
        leadingWidth: 40,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Container(
            margin: EdgeInsets.only(left: 4.w, right: 4.w),
            child: Column(
              children: [
                SizedBox(
                  child: TextFormField(
                    validator: (value) => Validators.validatefirstName(value!),
                    controller: Name,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        hintText: 'Full_name'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  child: TextFormField(
                    validator: (value) => Validators.validateEmail(value!),
                    controller: Email,
                    decoration: InputDecoration(
                        hintText: 'Email'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  child: TextFormField(
                    validator: (value) =>
                        Validators.validateRequired(value!, "Mobile"),
                    keyboardType: TextInputType.number,
                    controller: Mobile,
                    cursorColor: Colors.grey,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                        hintText: 'Mobile'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  child: TextFormField(
                    validator: (value) =>
                        Validators.validateRequired(value!, "No"),
                    keyboardType: TextInputType.number,
                    controller: Noofguest,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        hintText: 'No_of_guest'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: const BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 44.w,
                      child: GestureDetector(
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: color.primarycolor,
                                    ),
                                  ),
                                  child: child!);
                            },
                          ).then((date) {
                            setState(() {
                              String _day = date!.day.toString();
                              String _month = date.month.toString();
                              String _year = date.year.toString();
                              String bookingdate = "$_day-$_month-$_year";

                              Date.value = TextEditingValue(
                                  text: getFormatedDate(bookingdate));
                            });
                          });
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            validator: (value) => Validators.validateRequired(
                              value!,
                              'Date'.tr,
                            ),
                            keyboardType: TextInputType.datetime,
                            controller: Date,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                                hintText: 'Date'.tr,
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11.sp,
                                    fontFamily: "Poppins"),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.5),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 43.w,
                      child: GestureDetector(
                        onTap: () {
                          displayTimeDialog(context);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            validator: (value) => Validators.validateRequired(
                              value!,
                              'Time'.tr,
                            ),
                            keyboardType: TextInputType.datetime,
                            controller: Time,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                                hintText: 'Time'.tr,
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11.sp,
                                    fontFamily: "Poppins"),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.5),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.5),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  child: TextFormField(
                    validator: (value) => Validators.validateRequired(
                      value!,
                      'Reservation_Type'.tr,
                    ),
                    controller: Reservation,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        hintText: 'Reservationtype'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                SizedBox(
                  child: TextFormField(
                    controller: Specialrequest,
                    maxLines: 6,
                    cursorColor: Colors.grey,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                        hintText: 'Specialrequest'.tr,
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.5.sp,
                            fontFamily: "Poppins"),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.5),
                          borderSide: BorderSide(color: Colors.grey),
                        )),
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                InkWell(
                  onTap: () {
                    if (_formkey.currentState!.validate()) {
                      bookatableAPI();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 1.h,
                    ),
                    height: 6.8.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: color.red,
                    ),
                    child: Center(
                      child: Text(
                        'Submit'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppins_semiBold',
                            color: Colors.white,
                            fontSize: fontsize.Buttonfontsize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
