// ignore_for_file: must_be_immutable, file_names, camel_case_types, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, non_constant_identifier_names, use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/favoritepage/addtocartmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/Ordersummary.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:singlerestaurant/validation/validator.dart/validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../Theme/ThemeModel.dart';
import 'addaddress.dart';

class Confirm_location extends StatefulWidget {
  String? Area;
  String? Address;
  double? latitude;
  double? longitude;
  String? addressid;
  String? oldarea;
  String? oldhouseno;
  String? oldaddress;
  String? addresstype;
  String? isedit;

  @override
  State<Confirm_location> createState() => _Confirm_locationState();
  Confirm_location([
    this.Area,
    this.Address,
    this.latitude,
    this.longitude,
    this.addressid,
    this.oldarea,
    this.oldhouseno,
    this.oldaddress,
    this.addresstype,
    this.isedit,
  ]);
}

class _Confirm_locationState extends State<Confirm_location> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController Address = TextEditingController();
  TextEditingController houseno = TextEditingController();
  TextEditingController Area = TextEditingController();
  int addresstype = 0;
  String? userid;
  addtocartmodel? addressdata;
  QTYupdatemodel? checkzone;
  @override
  void initState() {
    super.initState();
    print("assdsdsd");
    get();
    if (widget.isedit == "1") {
      Address.value = TextEditingValue(text: widget.oldaddress ?? "");
      Area.value = TextEditingValue(text: widget.oldarea ?? "");
      houseno.value = TextEditingValue(text: widget.oldhouseno ?? "");
      addresstype = int.parse(widget.addresstype.toString());
    } else if (DefaultApi.environment == "sendbox") {
      widget.Area = "New York";
      widget.Address = "20 Cooper Square, New York, NY 10003, USA";
      widget.latitude = 40.727949;
      widget.longitude = -73.991533;
      Address.value =
          TextEditingValue(text: "20 Cooper Square, New York, NY 10003, USA");
      Area.value = TextEditingValue(text: "New York");
      houseno.value = TextEditingValue(text: "20");
      addresstype = 1;
    }
  }

  get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    print("userid == $userid");
  }

  checkdeliveryzoneAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      loader.showLoading();
      var map = {
        "lat": widget.latitude,
        "lang": widget.longitude,
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.checkdeliveryzone, data: map);
      checkzone = QTYupdatemodel.fromJson(response.data);
      loader.hideLoading();
      if (checkzone!.status == 1) {
        prefs.setString(Delivery_charge, checkzone!.deliveryCharge.toString());
        print("dfndgvjkv ${checkzone!.deliveryCharge}");
        Navigator.popUntil(context, ModalRoute.withName('/Ordersummary'));
      } else {
        loader.showErroDialog(description: checkzone!.message);
      }
    } catch (e) {
      rethrow;
    }
  }
  addaddressAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    loader.showLoading();
    try {
      var map = {
        "user_id": userid,
        "address_type": addresstype.toString(),
        "address": Address.text.toString(),
        "lat": widget.latitude,
        "lang": widget.longitude,
        "house_no": houseno.text.toString(),
        "area": Area.text.toString()
      };

      print(map);

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.addaddress, data: map);
      var finallist = response.data;
      addressdata = addtocartmodel.fromJson(finallist);
      loader.hideLoading();
      int count = 0;
      if (addressdata!.status == 1) {
        if (DefaultApi.environment == "sendbox") {
          Get.back();
        } else {
          Navigator.popUntil(
            context,
            (route) {
              return count++ == 2;
            },
          );
        }
      } else {
        loader.showErroDialog(description: addressdata!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  editaddressAPI() async {
    loader.showLoading();
    try {
      var map = {
        "address_id": widget.addressid,
        "address_type": addresstype,
        "address": Address.text.toString(),
        "lat": widget.latitude,
        "lang": widget.longitude,
        "house_no": houseno.text.toString(),
        "area": Area.text.toString()
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Updateaddress, data: map);
      var finalist = await response.data;
      addressdata = addtocartmodel.fromJson(finalist);
      if (addressdata!.status == 1) {
        int count = 0;
        loader.hideLoading();
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      } else {
        loader.hideLoading();
        loader.showErroDialog(description: addressdata!.message);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themenofier, child) {
      return SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 40,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => Add_address()),
                );
              },
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
                size: 20,
              )),
          title: Text(
            'Confirm_Address'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins_semibold',
              fontSize: 12.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 4.5.w,
                  right: 4.5.w,
                  top: 1.2.h,
                ),
                child: Row(children: [
                  const ImageIcon(
                    AssetImage('Assets/Icons/address.png'),
                    size: 26,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 2.w,
                      right: 2.w,
                    ),
                    child: Text(
                      widget.Area.toString(),
                      style: TextStyle(
                          fontFamily: 'Poppins_semibold', fontSize: 12.sp),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 4.5.w,
                  right: 4.5.w,
                  top: 1.h,
                ),
                child: Text(
                  widget.Address.toString(),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 8.8.sp),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 1.h,
                  right: 1.h,
                  top: 0.6.h,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.black12),
                margin: EdgeInsets.only(
                  left: 4.5.w,
                  right: 4.5.w,
                  top: 1.5.h,
                ),
                width: double.infinity,
                height: 7.h,
                child: Center(
                    child: Text(
                  LocaleKeys
                          .A_detailed_address_will_help_our_delivery_parnter_reach_your_doorstep_easily
                      .tr,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 8.8.sp),
                )),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 4.5.w,
                  right: 4.5.w,
                  top: 1.5.h,
                ),
                child: Center(
                  child: TextFormField(
                    validator: (value) => Validators.validateRequired(
                      value!,
                      'Please_enter_all_details'.tr,
                    ),
                    cursorColor: Colors.grey,
                    controller: Address,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Compaddress'.tr,
                        hintStyle:
                            TextStyle(fontFamily: 'Poppins', fontSize: 10.sp),
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
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 1.5.h,
                ),
                child: Center(
                  child: TextFormField(
                    validator: (value) => Validators.validateRequired(
                      value!,
                      'Please_enter_all_details'.tr,
                    ),
                    cursorColor: Colors.black,
                    controller: houseno,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Houseflate'.tr,
                        hintStyle:
                            TextStyle(fontFamily: 'Poppins', fontSize: 10.sp),
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
              ),
              Container(
                margin: EdgeInsets.only(left: 4.w, top: 1.5.h, right: 4.w),
                child: Center(
                  child: TextFormField(
                    cursorColor: Colors.grey,
                    controller: Area,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Apartmentroad'.tr,
                        hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey,
                            fontSize: 10.sp),
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
              ),
              Container(
                  margin: EdgeInsets.only(
                    left: 4.5.w,
                    right: 4.5.w,
                    top: 1.8.h,
                    bottom: 2.h,
                  ),
                  child: Text(
                    'saveas'.tr,
                    style:
                        TextStyle(fontFamily: 'Poppins_semibold', fontSize: 14),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        setState(() => addresstype = 1);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: themenofier.isdark
                                  ? addresstype == 1
                                      ? Colors.white
                                      : Colors.grey
                                  : addresstype == 1
                                      ? color.black
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: addresstype == 1
                                      ? Colors.white
                                      : color.black)),
                          height: 9.w,
                          width: 25.w,
                          child: Center(
                              child: Text(
                            "HOME",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: themenofier.isdark
                                    ? addresstype == 1
                                        ? Colors.black
                                        : Colors.white
                                    : addresstype == 1
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 10.5.sp),
                          )))),
                  GestureDetector(
                      onTap: () {
                        setState(() => addresstype = 2);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: themenofier.isdark
                                  ? addresstype == 2
                                      ? Colors.white
                                      : Colors.grey
                                  : addresstype == 2
                                      ? color.black
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: addresstype == 2
                                      ? Colors.white
                                      : color.black)),
                          height: 9.w,
                          width: 25.w,
                          child: Center(
                              child: Text(
                            "OFFICE",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: themenofier.isdark
                                    ? addresstype == 2
                                        ? Colors.black
                                        : Colors.white
                                    : addresstype == 2
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 10.5.sp),
                          )))),
                  GestureDetector(
                      onTap: () {
                        setState(() => addresstype = 3);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: themenofier.isdark
                                  ? addresstype == 3
                                      ? Colors.white
                                      : Colors.grey
                                  : addresstype == 3
                                      ? color.black
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: addresstype == 3
                                      ? color.black
                                      : color.black)),
                          height: 9.w,
                          width: 25.w,
                          child: Center(
                              child: Text(
                            "OTHER",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: themenofier.isdark
                                    ? addresstype == 3
                                        ? Colors.black
                                        : Colors.white
                                    : addresstype == 3
                                        ? Colors.white
                                        : Colors.black,
                                // color: addresstype == 3
                                //     ? Colors.white
                                //     : color.black,
                                fontSize: 10.5.sp),
                          )))),
                ],
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: 0.8.h, left: 4.w, right: 4.w),
                height: MediaQuery.of(context).size.height / 16,
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    if(userid == null || userid == ""){
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setString(latitude, widget.latitude.toString());
                      pref.setString(longitude, widget.longitude.toString());
                      pref.setString(confirmAddress, Address.text.toString());
                      pref.setString(confirmhouse_no, houseno.text.toString());
                      pref.setString(confirmArea, Area.text.toString());
                      pref.setString(Addresstype, addresstype.toString());
                      pref.getString(Ordertype);
                      print("ordertype : ${pref.getString(Ordertype)}");
                      checkdeliveryzoneAPI();
                    }else{
                      if (_formkey.currentState!.validate()) {
                        if (addresstype == 0) {
                          loader.showErroDialog(
                            description: 'Please_enter_all_details'.tr,
                          );
                        } else if (widget.isedit == "1") {
                          editaddressAPI();
                        } else {
                          addaddressAPI();
                        }
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: color.black,
                  ),
                  child: Text(
                    'Saveaddressdetails'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins_semibold',
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    });
  }
}
