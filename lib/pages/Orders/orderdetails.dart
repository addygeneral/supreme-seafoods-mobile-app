// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, unnecessary_string_interpolations, must_be_immutable, use_key_in_widget_constructors, body_might_complete_normally_nullable,   unrelated_type_equality_checks, unused_local_variable, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/icons.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/addonslist.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../Model/Ordersmodel/orderdetailsModel.dart';
import '../Cart/cartpage.dart';

class Orderdetails extends StatefulWidget {
  String? Orderid;

  @override
  State<Orderdetails> createState() => _OrderdetailsState();

  Orderdetails([this.Orderid]);
}

class _OrderdetailsState extends State<Orderdetails> {
  Orderdetailsmodel? Orderdetailsdata;
  dynamic alldata;
  String? currency;
  String? currency_position;

  Future<Orderdetailsmodel?> OrderdetailsAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString(UD_user_id)!;
    currency = (prefs.getString('currency') ?? "");
    currency_position = (prefs.getString('currency_position') ?? "");

    try {
      var map = {
        "order_id": widget.Orderid,
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Getorderdetails, data: map);

      var finalist = await response.data;
      Orderdetailsdata = Orderdetailsmodel.fromJson(finalist);

      return Orderdetailsdata;
    } catch (e) {
      rethrow;
    }
  }

  cancelorder() async {
    try {
      var map = {"order_id": widget.Orderid};
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.ordercancel, data: map);
      var finaldata = QTYupdatemodel.fromJson(response.data);
      if (finaldata.status == 1) {
        Navigator.of(context).pop();
      } else {
        loader.showErroDialog(description: finaldata.message);
      }
    } catch (e) {
      loader.showErroDialog(description: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: OrderdetailsAPI(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: color.primarycolor,
                ),
              ),
            );
          }
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(builder: (context) => Viewcart()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      size: 20,
                    )),
                title: Text(
                  'Order_Details'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins_semibold', fontSize: 12.sp),
                ),
                centerTitle: true,
              ),
              body: Container(
                margin: EdgeInsets.only(
                  top: 2.h,
                  left: 3.w,
                  right: 3.w,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(1.h),
                          width: double.infinity,
                          height: 16.h,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "#${Orderdetailsdata?.summery!.orderNumber}",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'Poppins_bold'),
                                    ),
                                    Spacer(),
                                    if (Orderdetailsdata?.summery!.status ==
                                        "1") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status1,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Placed'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "2") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status2,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Preparing'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "3") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status3,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Ready'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "4") ...[
                                      if (Orderdetailsdata
                                              ?.summery!.orderType ==
                                          "1") ...[
                                        Container(
                                          decoration: BoxDecoration(
                                              color: color.status4,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(7),
                                          height: 4.5.h,
                                          child: Center(
                                            child: Text('On_the_way'.tr,
                                                style: TextStyle(
                                                    fontSize: 9.5.sp,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ] else if (Orderdetailsdata
                                              ?.summery!.status ==
                                          "2") ...[
                                        Container(
                                          decoration: BoxDecoration(
                                              color: color.status4,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          padding: EdgeInsets.all(7),
                                          height: 4.5.h,
                                          child: Center(
                                            child: Text('Waiting_for_pickup'.tr,
                                                style: TextStyle(
                                                    fontSize: 9.5.sp,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ]
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "5") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status5,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Completed'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "6") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status67,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Cancelled'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ] else if (Orderdetailsdata
                                            ?.summery!.status ==
                                        "7") ...[
                                      Container(
                                        decoration: BoxDecoration(
                                            color: color.status67,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        padding: EdgeInsets.all(7),
                                        height: 4.5.h,
                                        child: Center(
                                          child: Text('Cancelled'.tr,
                                              style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white)),
                                        ),
                                      )
                                    ],
                                  ],
                                ),
                                Container(
                                  height: 0.8.sp,
                                  color: Colors.grey,
                                ),
                                Row(
                                  children: [
                                    Text('Paymenttype'.tr,
                                        style: TextStyle(
                                            fontSize: 8.8.sp,
                                            fontFamily: 'Poppins',
                                            color: Colors.grey)),
                                    if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "1") ...[
                                      Text(
                                        'Cash'.tr,
                                        style: TextStyle(
                                          fontSize: 8.5.sp,
                                          fontFamily: 'Poppins',
                                          color: color.grey,
                                        ),
                                      ),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "2") ...[
                                      Text('Wallet'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "3") ...[
                                      Text('RazorPay'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "4") ...[
                                      Text('Stripepay'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "5") ...[
                                      Text('Flutterwave'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "6") ...[
                                      Text('Paystack'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "7") ...[
                                      Text('MercadoPago'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "8") ...[
                                      Text('Myfatoorah'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "9") ...[
                                      Text('Paypal'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.transactionType ==
                                        "10") ...[
                                      Text('ToyyibPay'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ],
                                    Spacer(),
                                    if (Orderdetailsdata?.summery!.orderType ==
                                        "1") ...[
                                      Text('Delivery'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ] else if (Orderdetailsdata
                                            ?.summery!.orderType ==
                                        "2") ...[
                                      Text('Take_away'.tr,
                                          style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontFamily: 'Poppins',
                                              color: Colors.grey)),
                                    ],
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        FormatedDate(
                                            Orderdetailsdata?.summery!.date),
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontFamily: 'Poppins',
                                        )),
                                    Text(
                                        currency_position == "1"
                                            ? "$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.orderTotal.toString()))}"
                                            : "${numberFormat.format(double.parse(Orderdetailsdata!.summery!.orderTotal.toString()))}$currency",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'Poppins_semibold',
                                        )),
                                  ],
                                )
                              ])),
                      SizedBox(
                        height: Orderdetailsdata!.data!.length * 15.5.h,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: Orderdetailsdata!.data!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                top: 1.h,
                              ),
                              height: 14.5.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.8.sp,
                                  )),
                              child: Row(children: [
                                SizedBox(
                                  width: 28.w,
                                  height: 15.5.h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.network(
                                      Orderdetailsdata!.data![index].itemImage
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
                                              if (Orderdetailsdata!
                                                      .data![index].itemType ==
                                                  "1") ...[
                                                SizedBox(
                                                  height: 2.h,
                                                  // color: Colors.black,
                                                  child: Image.asset(
                                                    Defaulticon.vegicon,
                                                  ),
                                                ),
                                              ] else if (Orderdetailsdata!
                                                      .data![index].itemType ==
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
                                                  Orderdetailsdata!
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
                                        if (Orderdetailsdata!
                                                .data![index].variation ==
                                            "") ...[
                                          Expanded(
                                            child: Text(
                                              "-",
                                              overflow: TextOverflow.ellipsis,
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
                                              Orderdetailsdata!
                                                  .data![index].variation
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                color: Colors.grey,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (Orderdetailsdata!
                                                .data![index].addonsName ==
                                            "") ...[
                                          Expanded(
                                            child: Text(
                                              "-",
                                              overflow: TextOverflow.ellipsis,
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
                                                    Orderdetailsdata!
                                                        .data![index]
                                                        .addonsName,
                                                    Orderdetailsdata!
                                                        .data![index]
                                                        .addonsPrice,
                                                    currency,
                                                    currency_position);
                                              },
                                              child: Text(
                                                "${'Add_ons'.tr}>>",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9.sp,
                                                  color: Colors.grey,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        Padding(
                                          padding: EdgeInsets.only(top: 0),
                                          child: Row(children: [
                                            Text(
                                              "${'Qty'.tr} ${Orderdetailsdata!.data![index].qty.toString()}",
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontFamily: 'Poppins_medium',
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                              child: Text(
                                                currency_position == "1"
                                                    ? "$currency${(numberFormat.format((double.parse(Orderdetailsdata!.data![index].itemPrice!.toString()) + double.parse(Orderdetailsdata!.data![index].addonsTotalPrice!.toString()))))}"
                                                    : "${(numberFormat.format((double.parse(Orderdetailsdata!.data![index].itemPrice!.toString()) + double.parse(Orderdetailsdata!.data![index].addonsTotalPrice!.toString()))))}$currency",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontFamily:
                                                      'Poppins_semibold',
                                                ),
                                              ),
                                            ),
                                          ]),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(top: 2.5.h, left: 1.w, right: 1.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill_Details'.tr,
                              style: TextStyle(
                                  fontFamily: 'Poppins_semibold',
                                  fontSize: 12.sp),
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
                                      ? '$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.orderTotal.toString()))}'
                                      : '${numberFormat.format(double.parse(Orderdetailsdata!.summery!.orderTotal.toString()))}$currency',
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
                                      ? '$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.tax))}'
                                      : '${numberFormat.format(double.parse(Orderdetailsdata!.summery!.tax))}$currency',
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
                                Text(
                                  currency_position == "1"
                                      ? '$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.deliveryCharge.toString()))}'
                                      : '${numberFormat.format(double.parse(Orderdetailsdata!.summery!.deliveryCharge.toString()))}$currency',
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      fontSize: 11.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Discount_Offer'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10.sp),
                                ),
                                Text(
                                  currency_position == "1"
                                      ? '$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.discountAmount.toString()))}'
                                      : '${numberFormat.format(double.parse(Orderdetailsdata!.summery!.discountAmount.toString()))}$currency',
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      fontSize: 11.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Container(
                              height: 0.8.sp,
                              color: color.grey,
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
                                      ? '$currency${numberFormat.format(double.parse(Orderdetailsdata!.summery!.grandTotal.toString()))}'
                                      : '${numberFormat.format(double.parse(Orderdetailsdata!.summery!.grandTotal.toString()))}$currency',
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semiBold',
                                      color: color.red,
                                      fontSize: 12.5.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            if ((Orderdetailsdata?.summery!.orderType == '1') &&
                                (Orderdetailsdata?.summery!.status == "4" ||
                                    Orderdetailsdata?.summery!.status ==
                                        "5")) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Driver_information'.tr,
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semibold',
                                        fontSize: 11.5.sp),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Row(
                                children: [
                                  ClipOval(
                                    child: CircleAvatar(
                                      child: Image.network(
                                        Orderdetailsdata!
                                            .driverInfo!.profileImage,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.5.w,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Orderdetailsdata!.driverInfo!.name,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10.5.sp),
                                      ),
                                      Text(
                                        Orderdetailsdata!.driverInfo!.email,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 9.sp),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () async {
                                        FlutterPhoneDirectCaller.callNumber(
                                            Orderdetailsdata!
                                                .driverInfo!.mobile);
                                      },
                                      icon: Icon(Icons.phone))
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                            ],
                            if (Orderdetailsdata?.summery!.orderType ==
                                '1') ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Deliveryaddress'.tr,
                                    style: TextStyle(
                                        fontFamily: 'Poppins_semibold',
                                        fontSize: 12.5.sp),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 3.h,
                                    width: 4.w,
                                    child: Image.asset(
                                      'Assets/Icons/address.png',
                                      height: 2.5.h,
                                      color: color.primarycolor,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      right: 10,
                                      left: 10,
                                    ),
                                    width: 82.w,
                                    child: Text(
                                      '${Orderdetailsdata!.summery!.address}${Orderdetailsdata!.summery!.houseNo}',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            SizedBox(
                              height: 2.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Special_instructions'.tr,
                                  style: TextStyle(
                                      fontFamily: 'Poppins_semibold',
                                      fontSize: 12.5.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Row(
                              children: [
                                Text(
                                  Orderdetailsdata!.summery!.orderNotes == "" ||
                                          Orderdetailsdata!
                                                  .summery!.orderNotes ==
                                              null
                                      ? "-"
                                      : Orderdetailsdata!.summery!.orderNotes,
                                  style: TextStyle(
                                      fontFamily: 'Poppins_medium',
                                      fontSize: 10.sp),
                                ),
                              ],
                            ),
                            if (Orderdetailsdata!.summery!.status == "1") ...[
                              SizedBox(
                                height: 8.h,
                              )
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomSheet: Orderdetailsdata!.summery!.status == "1"
                  ? InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Supreme_Seafood'.tr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: 'Poppins_semibold',
                                  ),
                                ),
                                content: Text(
                                  LocaleKeys
                                      .Are_you_sure_to_cancel_this_order_If_yes_then_order_amount_Online_payment_OR_Wallet_payment_will_be_transferred_to_your_wallet
                                      .tr,
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color.primarycolor,
                                    ),
                                    child: Text(
                                      'Yes'.tr,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      cancelorder();
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color.primarycolor,
                                    ),
                                    child: Text(
                                      'No'.tr,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 1.h,
                          left: 3.w,
                          right: 3.w,
                          bottom: 1.h,
                        ),
                        height: 6.5.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFE82428),
                            ),
                            borderRadius: BorderRadius.circular(6.5)),
                        child: Center(
                          child: Text(
                            'Cancel_Order'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins_semibold',
                              fontSize: 11.5.sp,
                              color: Color(0xFFE82428),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null);
        },
      ),
    );
  }
}
