// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, use_key_in_widget_constructors, unrelated_type_equality_checks, camel_case_types, must_be_immutable, file_names,   use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/cartpage/isopenmodel.dart';
import 'package:singlerestaurant/Model/cartpage/ordersummaryModel.dart';
import 'package:singlerestaurant/Model/cartpage/checkpromocodeModel.dart';
import 'package:singlerestaurant/Model/settings%20model/getaddressmodel.dart';
import 'package:singlerestaurant/Theme/ThemeModel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:provider/provider.dart';
import 'package:singlerestaurant/common%20class/icons.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/addonslist.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/pages/Profile/addaddress.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:singlerestaurant/validation/validator.dart/validator.dart';
import 'package:sizer/sizer.dart';
import '../Profile/manage address.dart';
import 'Promocode.dart';
import 'Payment option.dart';

class addresscontrol extends GetxController {
  RxList addressdata = [].obs;
}

class Ordersummary extends StatefulWidget {
  String? ordertype;

  @override
  State<Ordersummary> createState() => _OrdersummaryState();

  Ordersummary([this.ordertype]);
}

class _OrdersummaryState extends State<Ordersummary> {
  order_summary_model? summarydata;
  String? userid;
  String sessionid = "";
  String? currency;
  String? currency_position;
  String? minorder_amount;
  String? maxorder_amount;
  String ordersubtotal = "0";
  String deliveryfees = "0";
  String discountoffer = "0.00";
  String ordertotal = "0";
  String promocodedata = "0";
  bool? isfirstcome = true;
  addData? Addressdata;
  String? reslat;
  String? reslang;
  String? deliverycharge;
  String order_type = "";
  String lati_tude = "";
  String longi_tude = "";
  String confirm_Address = "";
  String confirm_house = "";
  String confirm_Area = "";
  String addresstype = "";

  checkpromocodemodel? applypromocode;

  SummaryAPI() async {
    try {
      var map;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getString(UD_user_id);
      currency = prefs.getString(APPcurrency);
      currency_position = prefs.getString(APPcurrency_position);
      reslat = prefs.getString(restaurantlat);
      reslang = prefs.getString(restaurantlang);
      deliverycharge = prefs.getString(deliverycharges)!;
      minorder_amount = prefs.getString(min_order_amount)!;
      maxorder_amount = prefs.getString(max_order_amount)!;
      sessionid = prefs.getString(UD_user_session_id)!;
      print(prefs.getString(UD_user_session_id));
      if (userid == null || userid == "") {
        map = {
          "session_id": sessionid,
        };
      } else {
        map = {
          "user_id": userid,
        };
      }

      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Summary, data: map);
      summarydata = order_summary_model.fromJson(response.data);
      ordersubtotal = summarydata!.summery!.orderTotal.toString();
      ordertotal =
          (summarydata!.summery!.orderTotal + summarydata!.summery!.tax)
              .toString();
      isfirstcome = false;
      return summarydata;
    } catch (e) {
      rethrow;
    }
  }

  checkpromocodeAPI() async {
    try {
      loader.showLoading();
      var map = {
        "offer_code": promocodedata,
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Checkpromocode, data: map);
      applypromocode = checkpromocodemodel.fromJson(response.data);
      loader.hideLoading();
      if (applypromocode!.status == 1) {
        if ((double.parse(ordersubtotal)) <=
            (double.parse(applypromocode!.data!.minAmount.toString()))) {
          loader.showErroDialog(
              description: 'You_are_not_eligeble_for_this_offer'.tr);
        } else {
          if (applypromocode!.data!.offerType == "2") {
            setState(() {
              discountoffer = (double.parse(ordersubtotal) *
                      double.parse(applypromocode!.data!.offerAmount!) /
                      100)
                  .toString();

              ordertotal = (double.parse(ordertotal) -
                      (double.parse(ordersubtotal) *
                          double.parse(applypromocode!.data!.offerAmount!) /
                          100))
                  .toString();
            });
          } else {
            setState(() {
              discountoffer = applypromocode!.data!.offerAmount!;
              ordertotal = (double.parse(ordertotal) -
                      double.parse(applypromocode!.data!.offerAmount!))
                  .toString();
            });
          }
        }
      } else {
        loader.showErroDialog(description: applypromocode!.message!);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    ordertype();
  }

  ordertype() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      order_type = (prefs.getString(Ordertype) ?? "");
      widget.ordertype = (prefs.getString(Ordertype) ?? "");
      lati_tude = (prefs.getString(latitude) ?? "");
      longi_tude = (prefs.getString(longitude) ?? "");
      confirm_Address = (prefs.getString(confirmAddress) ?? "");
      confirm_house = (prefs.getString(confirmhouse_no) ?? "");
      confirm_Area = (prefs.getString(confirmArea) ?? "");
      addresstype = (prefs.getString(Addresstype) ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    var maxLines = 15;
    final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
    TextEditingController Promocode = TextEditingController();
    TextEditingController Ordernote = TextEditingController();
    TextEditingController fullname = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController mobile_no = TextEditingController();
    print("type = ${widget.ordertype}");

    return Consumer(builder: (context, ThemeModel themenofier, child) {
      return SafeArea(
          child: FutureBuilder(
        future: isfirstcome == true ? SummaryAPI() : null,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: color.primarycolor),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 20,
                  )),
              leadingWidth: 40,
              title: Text(
                'Ordersummary'.tr,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
              ),
              centerTitle: true,
            ),
            body: Form(
              key: _formkey,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: 8.h,
                  top: 1.h,
                  left: 3.5.w,
                  right: 3.5.w,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productsummary'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppins_semibold', fontSize: 12.sp),
                      ),
                      Container(
                          // color: Colors.black12,
                          height: 15.6.h * summarydata!.data!.length,
                          margin: EdgeInsets.only(
                            top: 2.h,
                          ),
                          child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 14.5.h,
                                  decoration: BoxDecoration(
                                      color: color.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withOpacity(0.3), // Shadow color
                                          spreadRadius: 0, // Spread radius
                                          blurRadius: 5, // Blur radius
                                          offset: Offset(
                                              0, 2), // Offset of the shadow
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.1.sp,
                                      )),
                                  child: Row(children: [
                                    SizedBox(
                                      width: 28.w,
                                      height: 15.5.h,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image.network(
                                          summarydata!.data![index].itemImage
                                              .toString(),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: 2.w,
                                          left: 2.w,
                                          bottom: 0.8.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  if (summarydata!.data![index]
                                                          .itemType ==
                                                      "1") ...[
                                                    SizedBox(
                                                      height: 2.h,
                                                      // color: Colors.black,
                                                      child: Image.asset(
                                                        Defaulticon.vegicon,
                                                      ),
                                                    ),
                                                  ] else if (summarydata!
                                                          .data![index]
                                                          .itemType ==
                                                      "2") ...[
                                                    SizedBox(
                                                      height: 2.h,
                                                      // color: Colors.black,
                                                      child: Image.asset(
                                                        Defaulticon.nonvegicon,
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(
                                                    width: 2.w,
                                                  ),
                                                  SizedBox(
                                                    width: 42.w,
                                                    child: Text(
                                                      summarydata!
                                                          .data![index].itemName
                                                          .toString(),
                                                      maxLines: 1,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        fontFamily:
                                                            'Poppins_semibold',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (summarydata!
                                                    .data![index].variation ==
                                                "") ...[
                                              Expanded(
                                                child: Text(
                                                  "-",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    // color: Colors.grey,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              Expanded(
                                                child: Text(
                                                  summarydata!
                                                      .data![index].variation
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    color: Colors.grey,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (summarydata!
                                                    .data![index].addonsName ==
                                                "") ...[
                                              Expanded(
                                                child: Text(
                                                  "-",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    modelsheet(
                                                        context,
                                                        summarydata!
                                                            .data![index]
                                                            .addonsName,
                                                        summarydata!
                                                            .data![index]
                                                            .addonsPrice,
                                                        currency,
                                                        currency_position);
                                                  },
                                                  child: Text(
                                                    "${'Add_ons'.tr}>>",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 9.sp,
                                                      color: Colors.grey,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            Row(children: [
                                              Text(
                                                "${'Qty'.tr} ${summarydata!.data![index].qty.toString()}",
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontFamily: 'Poppins_medium',
                                                ),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                child: Text(
                                                  currency_position == "1"
                                                      ? "$currency${(numberFormat.format(double.parse(summarydata!.data![index].itemPrice!.toString()) + double.parse(summarydata!.data![index].addonsTotalPrice!.toString())))}"
                                                      : "${(numberFormat.format(double.parse(summarydata!.data![index].itemPrice!.toString()) + double.parse(summarydata!.data![index].addonsTotalPrice!.toString())))}$currency",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontFamily:
                                                        'Poppins_semibold',
                                                  ),
                                                ),
                                              ),
                                            ])
                                          ],
                                        ),
                                      ),
                                    )
                                  ]),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: 1.h,
                                );
                              },
                              itemCount: summarydata!.data!.length)),
                      Container(
                          margin: EdgeInsets.only(top: 1.2.h),
                          padding: EdgeInsets.only(
                            top: 2.5.h,
                            left: 1.2.w,
                            right: 1.2.w,
                          ),
                          width: double.infinity,
                          height: 14.5.h,
                          decoration: BoxDecoration(
                              color: color.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.3), // Shadow color
                                  spreadRadius: 0, // Spread radius
                                  blurRadius: 5, // Blur radius
                                  offset: Offset(0, 2), // Offset of the shadow
                                ),
                              ],
                              border: Border.all(
                                color: themenofier.isdark
                                    ? Colors.white
                                    : Colors.black,
                                width: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Promocode'.tr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: 'Poppins_semibold',
                                    )),
                                if (discountoffer == "0.00") ...[
                                  InkWell(
                                      onTap: () async {
                                        // Get.to(() => Selectpromocode());
                                        promocodedata = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Selectpromocode(),
                                          ),
                                        );
                                        if (promocodedata != "0") {
                                          setState(() {
                                            promocodedata;
                                            Promocode.value = TextEditingValue(
                                                text: promocodedata);
                                          });
                                          // widget.promocode
                                        }
                                      },
                                      child: Text('Selectpromo'.tr,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontFamily: 'Poppins',
                                              color: Color(0xFFE82428))))
                                ],
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding:
                                        EdgeInsets.only(left: 2.w, right: 2.w),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey)),
                                    // color: Colors.black12,
                                    height: 4.5.h,
                                    width: 63.w,
                                    child: Text(
                                      promocodedata == "0"
                                          ? 'haveapromocode'.tr
                                          : promocodedata,
                                      style: TextStyle(
                                          color: promocodedata == "0"
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 10.5.sp,
                                          fontFamily: "Poppins"),
                                    )),
                                if (discountoffer == "0.00") ...[
                                  SizedBox(
                                    height: 5.h,
                                    width: 25.w,
                                    child: TextButton(
                                      onPressed: () {
                                        if (promocodedata == "0") {
                                          loader.showErroDialog(
                                              description:
                                                  "please enter promocode");
                                        } else {
                                          checkpromocodeAPI();
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: color.primarycolor),
                                      child: Text(
                                        'Apply'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Poppins_semibold',
                                            color: Colors.white,
                                            fontSize: 10.5.sp),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  SizedBox(
                                    height: 5.h,
                                    width: 25.w,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          promocodedata = "0";
                                          discountoffer = "0.00";
                                          ordertotal = (summarydata!
                                                      .summery!.orderTotal +
                                                  summarydata!.summery!.tax)
                                              .toString();
                                        });
                                        // if (promocodedata == "1") {
                                        //   loader.showErroDialog(
                                        //       description:
                                        //           "please enter promocode");
                                        // } else {
                                        //   checkpromocodeAPI();
                                        // }
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: color.primarycolor),
                                      child: Text(
                                        'Remove'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Poppins_semibold',
                                            color: Colors.white,
                                            fontSize: 10.5.sp),
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            )
                          ])),
                      Container(
                        margin: EdgeInsets.only(
                          top: 2.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill_Details'.tr,
                              style: TextStyle(
                                  fontFamily: 'Poppins_semibold',
                                  fontSize: 13.sp),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SubTotal'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10.sp),
                                ),
                                Text(
                                  currency_position == "1"
                                      ? "$currency${numberFormat.format(double.parse(summarydata!.summery!.orderTotal.toString()))}"
                                      : "${numberFormat.format(double.parse(summarydata!.summery!.orderTotal.toString()))}$currency",
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      fontSize: 11.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tax'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10.sp),
                                ),
                                Text(
                                  currency_position == "1"
                                      ? "$currency${numberFormat.format(double.parse(summarydata!.summery!.tax.toString()))}"
                                      : "${numberFormat.format(double.parse(summarydata!.summery!.tax.toString()))}$currency",
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      fontSize: 11.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delivery_Fee'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10.sp),
                                ),
                                if (deliveryfees.isEmpty) ...[
                                  Text(
                                    currency_position == "1"
                                        ? "$currency${numberFormat.format(double.parse("0"))}"
                                        : "${numberFormat.format(double.parse("0"))}$currency",
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semiBold',
                                        fontSize: 11.sp),
                                  ),
                                ] else ...[
                                  Text(
                                    currency_position == "1"
                                        ? "$currency${numberFormat.format(double.parse(deliveryfees))}"
                                        : "${numberFormat.format(double.parse(deliveryfees))}$currency",
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semiBold',
                                        fontSize: 11.sp),
                                  ),
                                ]
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (discountoffer == "0.00") ...[
                                  Text(
                                    'Discount_Offer'.tr,
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 10.sp),
                                  ),
                                ] else ...[
                                  Text(
                                    "${LocaleKeys.Discount_Offer} (${promocodedata.toUpperCase()})",
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 10.sp),
                                  ),
                                ],
                                if (discountoffer == "0.00") ...[
                                  Text(
                                    currency_position == "1"
                                        ? "$currency${numberFormat.format(double.parse(discountoffer))}"
                                        : "${numberFormat.format(double.parse(discountoffer))}$currency",
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semiBold',
                                        fontSize: 11.sp),
                                  ),
                                ] else ...[
                                  Text(
                                    currency_position == "1"
                                        ? "-$currency${numberFormat.format(double.parse(discountoffer))}"
                                        : "-${numberFormat.format(double.parse(discountoffer))}$currency",
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semiBold',
                                        fontSize: 11.sp),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 2.w, right: 2.w),
                              height: 0.8.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total_pay'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semibold',
                                      color: color.red,
                                      fontSize: 12.5.sp),
                                ),
                                Text(
                                  currency_position == "1"
                                      ? "$currency${numberFormat.format(double.parse(ordertotal))}"
                                      : "${numberFormat.format(double.parse(ordertotal))}$currency",
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      color: color.red,
                                      fontSize: 12.5.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            if (userid == null || userid == "") ...[
                              if (order_type == "1") ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 0.5.h,
                                    bottom: 1.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Deliveryaddress'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Poppins_semibold',
                                            fontSize: 13.sp),
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return Add_address();
                                              },
                                            ));
                                            setState(() {
                                              order_type =
                                                  (prefs.getString(Ordertype) ??
                                                      "");
                                              widget.ordertype =
                                                  (prefs.getString(Ordertype) ??
                                                      "");
                                              lati_tude =
                                                  (prefs.getString(latitude) ??
                                                      "");
                                              longi_tude =
                                                  (prefs.getString(longitude) ??
                                                      "");
                                              confirm_Address =
                                                  (prefs.getString(
                                                          confirmAddress) ??
                                                      "");
                                              confirm_house = (prefs.getString(
                                                      confirmhouse_no) ??
                                                  "");
                                              confirm_Area = (prefs
                                                      .getString(confirmArea) ??
                                                  "");
                                              addresstype = (prefs
                                                      .getString(Addresstype) ??
                                                  "");
                                              deliveryfees = prefs
                                                  .getString(Delivery_charge)!;
                                              ordertotal = (double.parse(
                                                          ordersubtotal) +
                                                      (double.parse(summarydata!
                                                          .summery!.tax
                                                          .toString())) +
                                                      double.parse(deliveryfees
                                                          .toString()) -
                                                      double.parse(discountoffer
                                                          .toString()))
                                                  .toString();
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 3.5.h,
                                            width: 18.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey)),
                                            child: Text(
                                              'Select'.tr,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: color.red,
                                                  fontSize: 10.5.sp),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 0.5.h,
                                      ),
                                      child: SvgPicture.asset(
                                        'Assets/svgicon/Address.svg',
                                        color: color.primarycolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    if (lati_tude == "" ||
                                        longi_tude == "" ||
                                        confirm_Address == "" ||
                                        confirm_house == "" ||
                                        confirm_Area == "") ...[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 0.5.h,
                                        ),
                                        child: Text(
                                          LocaleKeys
                                              .Set_your_delivery_address.tr,
                                          style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontFamily: "Poppins_semibold"),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        height: 4.h,
                                        child: Text(
                                          "${confirm_house},${confirm_Address},${confirm_Area}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontFamily: "Poppins"),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                              ]
                            ] else ...[
                              if (widget.ordertype == "1") ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 0.5.h,
                                    bottom: 1.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Deliveryaddress'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Poppins_semibold',
                                            fontSize: 13.sp),
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            if (userid == null ||
                                                userid == "") {
                                              await Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return Add_address();
                                                },
                                              ));
                                            } else {
                                              Addressdata =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Manage_Addresses(1)),
                                              );
                                            }

                                            if (Addressdata != null) {
                                              double distance =
                                                  Geolocator.distanceBetween(
                                                        double.parse(reslat!),
                                                        double.parse(reslang!),
                                                        double.parse(
                                                            Addressdata!.lat),
                                                        double.parse(
                                                            Addressdata!.lang),
                                                      ) /
                                                      1000;
                                              // if (DefaultApi
                                              //     .environment ==
                                              //     "sendbox") {
                                              //   deliveryfees =
                                              //       double.parse(
                                              //           deliverycharge!)
                                              //           .toString();
                                              // } else {
                                              //   deliveryfees = (distance *
                                              //       double.parse(
                                              //           deliverycharge!))
                                              //       .toString();
                                              // }
                                              deliveryfees = prefs
                                                  .getString(Delivery_charge)!;
                                              ordertotal = (double.parse(
                                                          ordersubtotal) +
                                                      (double.parse(summarydata!
                                                          .summery!.tax
                                                          .toString())) +
                                                      double.parse(deliveryfees
                                                          .toString()) -
                                                      double.parse(discountoffer
                                                          .toString()))
                                                  .toString();
                                              print(
                                                  "order total , = $ordertotal");

                                              setState(() {
                                                Addressdata;
                                                print(
                                                    "Addressdata  == $Addressdata");
                                              });
                                            }
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 3.5.h,
                                            width: 18.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey)),
                                            child: Text(
                                              'Select'.tr,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: color.red,
                                                  fontSize: 10.5.sp),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 0.5.h,
                                      ),
                                      child: SvgPicture.asset(
                                        'Assets/svgicon/Address.svg',
                                        color: color.primarycolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    if (Addressdata == null) ...[
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 0.5.h,
                                        ),
                                        child: Text(
                                          LocaleKeys
                                              .Set_your_delivery_address.tr,
                                          style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontFamily: "Poppins_semibold"),
                                        ),
                                      ),
                                    ] else ...[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (Addressdata!.addressType ==
                                              "1") ...[
                                            Text(
                                              'Home'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  // color: color.green,
                                                  fontSize: 9.sp),
                                            ),
                                          ] else if (Addressdata!.addressType ==
                                              "2") ...[
                                            Text(
                                              'Office'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  // color: color.green,
                                                  fontSize: 9.sp),
                                            ),
                                          ] else if (Addressdata!.addressType ==
                                              "3") ...[
                                            Text(
                                              'Other'.tr,
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                  // color: color.green,
                                                  fontSize: 9.sp),
                                            ),
                                          ],
                                          SizedBox(
                                            width: 75.w,
                                            child: Text(
                                              "${Addressdata!.address} ${Addressdata!.area}",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 9.sp),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ],
                                ),
                                SizedBox(
                                  height: 2.5.h,
                                ),
                              ],
                            ],
                            if (userid == null || userid == "") ...[
                              Text(
                                'Customer_information'.tr,
                                style: TextStyle(
                                    fontFamily: 'Poppins_semibold',
                                    fontSize: 12.5.sp),
                              ),
                              SizedBox(height: 1.5.h),
                              SizedBox(
                                height: 6.h,
                                child: TextFormField(
                                  controller: fullname,
                                  cursorColor: Colors.grey,
                                  validator: (value) => Validators.validateName(
                                      value!, Full_name.tr),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                      hintText: Full_name.tr,
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.5.sp,
                                          fontFamily: "Poppins"),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      )),
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              SizedBox(
                                height: 6.h,
                                child: TextFormField(
                                  controller: email,
                                  cursorColor: Colors.grey,
                                  textAlignVertical: TextAlignVertical.center,
                                  validator: (value) =>
                                      Validators.validateEmail(
                                    value!,
                                  ),
                                  decoration: InputDecoration(
                                      hintText: Email.tr,
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.5.sp,
                                          fontFamily: "Poppins"),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      )),
                                ),
                              ),
                              SizedBox(height: 1.5.h),
                              SizedBox(
                                height: 6.h,
                                child: TextFormField(
                                  controller: mobile_no,
                                  cursorColor: Colors.grey,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      Validators.validateMobile(value!),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                      hintText: 'Mobile'.tr,
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.5.sp,
                                          fontFamily: "Poppins"),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      )),
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                            Text(
                              'Special_instructions'.tr,
                              style: TextStyle(
                                  fontFamily: 'Poppins_semibold',
                                  fontSize: 12.5.sp),
                            ),
                            SizedBox(height: 1.5.h),
                            Container(
                              width: double.infinity,
                              height: 14.5.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)),
                              child: TextField(
                                controller: Ordernote,
                                maxLines: maxLines,
                                cursorColor: Colors.grey,
                                textAlignVertical: TextAlignVertical.top,
                                // controller: Phoneno,
                                decoration: InputDecoration(
                                    hintText:
                                        LocaleKeys.Write_order_instructions.tr,
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.5.sp,
                                        fontFamily: "Poppins"),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  if (int.parse(minorder_amount!) >
                          double.parse(ordersubtotal) ||
                      int.parse(maxorder_amount!) <
                          double.parse(ordersubtotal)) {
                    loader.showErroDialog(
                        description:
                            "${'Order_amount_must_be_between'.tr} $minorder_amount ${'To'.tr} $maxorder_amount");
                  } else {
                    var map;
                    isopencloseMODEL? isopendata;

                    loader.showLoading();
                    if (userid == null || userid == "") {
                      map = {"session_id": sessionid};
                    } else {
                      map = {"user_id": userid};
                    }
                    print(map);
                    var response = await Dio().post(
                      DefaultApi.appUrl + PostAPI.isopenclose,
                      data: map,
                    );
                    print(response);
                    isopendata = isopencloseMODEL.fromJson(response.data);
                    loader.hideLoading();

                    if (isopendata.status == 1) {
                      if (userid == null || userid == "") {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.setString(Full_name, fullname.text.toString());
                        pref.setString(Email, email.text.toString());
                        pref.setString(Mobile_no, mobile_no.text.toString());
                        if (_formkey.currentState!.validate()) {
                          if (fullname == "") {
                            loader.showErroDialog(
                                description: LocaleKeys.Please_enter_full_name
                                  ..tr);
                          } else if (email == "") {
                            loader.showErroDialog(
                                description: LocaleKeys
                                    .Please_enter_valid_email_address.tr);
                          } else if (mobile_no == "") {
                            loader.showErroDialog(
                                description: 'Please_enter_phone_no'.tr);
                          } else {
                            if (order_type == "1") {
                              if (lati_tude == "" ||
                                  longi_tude == "" ||
                                  confirm_Address == "" ||
                                  confirm_house == "" ||
                                  confirm_Area == "") {
                                loader.showErroDialog(
                                    description: LocaleKeys
                                        .Please_select_delivery_address
                                      ..tr);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Paymentoption(
                                            double.parse(ordertotal)
                                                .toStringAsFixed(2)
                                                .toString(),
                                            order_type,
                                            promocodedata,
                                            discountoffer,
                                            summarydata!.summery!.tax
                                                .toString(),
                                            double.parse(deliveryfees)
                                                .toStringAsFixed(2)
                                                .toString(),
                                            //address
                                            addresstype,
                                            confirm_Address,
                                            confirm_Area,
                                            confirm_house,
                                            lati_tude,
                                            longi_tude,
                                            Ordernote.value.text,
                                          )),
                                );
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Paymentoption(
                                    ordertotal,
                                    order_type,
                                    promocodedata,
                                    discountoffer,
                                    summarydata!.summery!.tax.toString(),
                                    "0.0",
                                    //address
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    Ordernote.value.text,
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      } else {
                        if (isopendata.isCartEmpty == "0") {
                          if (widget.ordertype == "1") {
                            if (Addressdata == null) {
                              loader.showErroDialog(
                                description:
                                    'Please_select_delivery_address'.tr,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Paymentoption(
                                          double.parse(ordertotal)
                                              .toStringAsFixed(2)
                                              .toString(),
                                          widget.ordertype,
                                          promocodedata,
                                          discountoffer,
                                          summarydata!.summery!.tax.toString(),
                                          double.parse(deliveryfees)
                                              .toStringAsFixed(2)
                                              .toString(),
                                          //address
                                          Addressdata!.addressType.toString(),
                                          Addressdata!.address ?? "",
                                          Addressdata!.area ?? "",
                                          Addressdata!.houseNo ?? "",
                                          Addressdata!.lang ?? "",
                                          Addressdata!.lat ?? "",
                                          Ordernote.value.text,
                                        )),
                              );
                            }
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Paymentoption(
                                  ordertotal,
                                  widget.ordertype,
                                  promocodedata,
                                  discountoffer,
                                  summarydata!.summery!.tax.toString(),
                                  "0.0",
                                  //address
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  Ordernote.value.text,
                                ),
                              ),
                            );
                          }
                        } else {
                          Get.to(() => Homepage(0));
                        }
                      }
                    } else {
                      loader.showErroDialog(description: isopendata.message);
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: color.primarycolor,
                ),
                child: Text(
                  'Process_to_pay'.tr,
                  style: TextStyle(
                      fontFamily: 'Poppins_semibold',
                      color: Colors.white,
                      fontSize: fontsize.Buttonfontsize),
                ),
              ),
            ),
          );
        },
      ));
    });
  }
}
