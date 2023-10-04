// ignore_for_file: unnecessary_null_comparison, file_names, must_be_immutable, camel_case_types, use_key_in_widget_constructors,   non_constant_identifier_names, avoid_unnecessary_containers, use_build_context_synchronously, unused_local_variable, prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/settings%20model/deleteaddressmodel.dart';
import 'package:singlerestaurant/Model/settings%20model/getaddressmodel.dart';
import 'package:singlerestaurant/Theme/ThemeModel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Profile/confirm%20location.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:singlerestaurant/common%20class/EngString.dart';
import '../../config/location/location.dart';
import 'addaddress.dart';

enum DataStatus { none, compleated, error }

class Manage_Addresses extends StatefulWidget {
  int? isorder;
  // const Manage_Addresses({Key? key}) : super(key: key);

  @override
  State<Manage_Addresses> createState() => _Manage_AddressesState();
  Manage_Addresses([this.isorder]);
}

class _Manage_AddressesState extends State<Manage_Addresses> {
  String? userid;
  getaddressmodel? addressdata;
  deleteaddressmodel? deleteaddressdata;
  QTYupdatemodel? checkzone;

  @override
  void initState() {
    super.initState();
  }

  Future getaddressAPI(i) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    i == 1 ? loader.showLoading() : null;
    try {
      var map = {
        "user_id": userid,
      };
      print(map);
      var response = await Dio().post(
        DefaultApi.appUrl + PostAPI.Getaddress,
        data: map,
      );
      print(response);
      var finallist = response.data;
      print(finallist);
      addressdata = getaddressmodel.fromJson(finallist);
      i == 1 ? loader.hideLoading() : null;
      return addressdata!.data.toString();
    } catch (e) {
      rethrow;
    }
  }

  Deleteaddress(id, index) async {
    try {
      loader.showLoading();
      var map = {"address_id": id};
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Deleteaddress, data: map);
      var finalist = await response.data;
      deleteaddressdata = deleteaddressmodel.fromJson(finalist);
      setState(() {
        addressdata!.data!.remove(index);
      });

      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }

  checkdeliveryzoneAPI(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      loader.showLoading();
      var map = {
        "lat": addressdata!.data![index].lat,
        "lang": addressdata!.data![index].lang,
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.checkdeliveryzone, data: map);
      checkzone = QTYupdatemodel.fromJson(response.data);
      loader.hideLoading();
      if (checkzone!.status == 1) {
        prefs.setString(Delivery_charge, checkzone!.deliveryCharge.toString());
        Navigator.pop(context, addressdata!.data![index]);
      } else {
        loader.showErroDialog(description: checkzone!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeModel themenofier, child) {
        return SafeArea(
          child: Scaffold(
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
                'Myadresses'.tr,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
              ),
              centerTitle: true,
              leadingWidth: 40,
            ),
            body: FutureBuilder(
              future: getaddressAPI(0),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (addressdata!.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No_data_found'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            color: Colors.grey),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        padding: EdgeInsets.only(bottom: 8.h),
                        itemCount: addressdata!.data!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (widget.isorder == 1) {
                                if (DefaultApi.environment == "sendbox") {
                                  Navigator.pop(
                                      context, addressdata!.data![index]);
                                } else {
                                  checkdeliveryzoneAPI(index);
                                }
                              }
                            },
                            child: Container(
                                margin: EdgeInsets.only(left: 4.w, right: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "1") ...[
                                          SvgPicture.asset(
                                            'Assets/Icons/Home.svg',
                                            color: themenofier.isdark
                                                ? Colors.white
                                                : null,
                                          ),
                                        ] else if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "2") ...[
                                          SvgPicture.asset(
                                            'Assets/svgicon/office.svg',
                                            color: themenofier.isdark
                                                ? Colors.white
                                                : null,
                                          ),
                                        ] else if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "3") ...[
                                          SvgPicture.asset(
                                            'Assets/svgicon/Address.svg',
                                            color: themenofier.isdark
                                                ? Colors.white
                                                : null,
                                          ),
                                        ],
                                        if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "1") ...[
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: 3.w,
                                              right: 3.w,
                                            ),
                                            child: Text(
                                              'Home'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        ] else if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "2") ...[
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: 3.w,
                                              right: 3.w,
                                            ),
                                            child: Text(
                                              'Office'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        ] else if (addressdata!
                                                .data![index].addressType
                                                .toString() ==
                                            "3") ...[
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: 3.w,
                                              right: 3.w,
                                            ),
                                            child: Text(
                                              'Other'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  fontSize: 12.sp),
                                            ),
                                          )
                                        ],
                                        const Spacer(),
                                        Container(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text('Alert'),
                                                          content: Text(
                                                            LocaleKeys
                                                                .Are_you_sure_to_delete_this_address
                                                                .tr,
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text(
                                                                'Yes'.tr,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Deleteaddress(
                                                                    addressdata!
                                                                        .data![
                                                                            index]
                                                                        .id
                                                                        .toString(),
                                                                    index);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                LocaleKeys
                                                                    .Cancel.tr,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                icon: SvgPicture.asset(
                                                  'Assets/svgicon/delete.svg',
                                                  color: themenofier.isdark
                                                      ? Colors.white
                                                      : null,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  if (DefaultApi.environment ==
                                                      "sendbox") {
                                                    loader.showErroDialog(
                                                      description: LocaleKeys
                                                          .This_operation_was_not_performed_due_to_demo_mode
                                                          .tr,
                                                    );
                                                  } else {
                                                    Get.to(() => Add_address(
                                                          "1",
                                                          addressdata!
                                                              .data![index].id
                                                              .toString(),
                                                          double.parse(
                                                              addressdata!
                                                                  .data![index]
                                                                  .lat),
                                                          double.parse(
                                                              addressdata!
                                                                  .data![index]
                                                                  .lang),
                                                          addressdata!
                                                              .data![index]
                                                              .area,
                                                          addressdata!
                                                              .data![index]
                                                              .houseNo,
                                                          addressdata!
                                                              .data![index]
                                                              .address,
                                                          addressdata!
                                                              .data![index]
                                                              .addressType
                                                              .toString(),
                                                        ));
                                                  }
                                                },
                                                icon: SvgPicture.asset(
                                                  'Assets/svgicon/Edit.svg',
                                                  color: themenofier.isdark
                                                      ? Colors.white
                                                      : null,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "${addressdata!.data![index].address.toString()}, ",
                                      style: TextStyle(
                                          fontSize: 8.8.sp,
                                          fontFamily: 'Poppins'),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: 3.w,
                                        ),
                                        height: 0.8.sp,
                                        width: double.infinity,
                                        color: Colors.grey),
                                  ],
                                )),
                          );
                        });
                  }
                }
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFFE82428)),
                );
              },
            ),
            bottomSheet: Container(
              margin: EdgeInsets.only(
                bottom: 0.8.h,
                left: 4.w,
                right: 4.w,
              ),
              height: 6.5.h,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (DefaultApi.environment == "sendbox") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Confirm_location(),
                      ),
                    ).then((value) {
                      getaddressAPI(1);
                      setState(() {});
                    });
                  } else if (Engstring.locationpermission == false) {
                    location_permission().parmission();
                  } else {
                    final value = Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Add_address()),
                    ).then((value) {
                      getaddressAPI(1);
                      setState(() {});
                    });
                    setState(() {});
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFE82428),
                ),
                child: Text(
                  'Add_New_Address'.tr,
                  style: TextStyle(
                      fontFamily: 'Poppins_semibold',
                      color: Colors.white,
                      fontSize: fontsize.Buttonfontsize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
