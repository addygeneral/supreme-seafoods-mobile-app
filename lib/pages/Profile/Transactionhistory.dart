// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, file_names, camel_case_types, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/Model/settings%20model/wallettransactionmodel.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class Transaction_history extends StatefulWidget {
  const Transaction_history({Key? key}) : super(key: key);

  @override
  State<Transaction_history> createState() => _Transaction_historyState();
}

class _Transaction_historyState extends State<Transaction_history> {
  wallettransactionmodel? transactiondata;

  @override
  void initState() {
    super.initState();
    transactionAPI();
  }

  String? currency;
  String? currency_position;

  transactionAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = (prefs.getString(UD_user_id) ?? "null");
    currency = (prefs.getString(APPcurrency) ?? "");
    currency_position = (prefs.getString(APPcurrency_position) ?? "");
    try {
      var map = {"user_id": userid};
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Wallettransactions, data: map);
      var finallist = await response.data;
      transactiondata = wallettransactionmodel.fromJson(finallist);
      return transactiondata!.transactions;
    } catch (e) {
      rethrow;
    }
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
            'Transaction_History'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: transactionAPI(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (transactiondata!.transactions!.isEmpty) {
                  return Center(
                    child: Text(
                      'No_data_found'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins_medium',
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: transactiondata!.transactions!.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(top: 1.5.h, left: 3.w, right: 1.w),
                    width: double.infinity,
                    height: 10.h,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "1") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: color.red.withOpacity(0.2)),
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: color.red,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "2") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "3") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "4") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "5") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "6") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "7") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "8") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ] else if (transactiondata!
                                      .transactions![index].transactionType ==
                                  "9") ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: color.red.withOpacity(0.2)),
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: color.red,
                                    size: 25,
                                  ),
                                )
                              ] else ...[
                                Container(
                                  height: 7.5.h,
                                  width: 7.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: color.lightgreen.withOpacity(0.3),
                                  ),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: color.lightgreen,
                                    size: 25,
                                  ),
                                )
                              ]
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 3.w, right: 3.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transactiondata!.transactions![index]
                                          .transactionType ==
                                      "1") ...[
                                    Text(
                                      'Wallet_Order'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "2") ...[
                                    Text(
                                      'Order_Cancel'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "3") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "4") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "5") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "6") ...[
                                    Text(
                                      'Referral_Amount'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "7") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "8") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Poppins',
                                          fontSize: 16),
                                    )
                                  ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                      "9") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ]else if (transactiondata!
                                      .transactions![index]
                                      .transactionType ==
                                      "10") ...[
                                    Text(
                                      'Wallet_Recharge'.tr,
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ] else ...[
                                    Text(
                                      transactiondata!
                                          .transactions![index].transactionType
                                          .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 16),
                                    )
                                  ],
                                  Row(
                                    children: [
                                      if (transactiondata!.transactions![index]
                                              .transactionType ==
                                          "1") ...[
                                        Text(
                                          "${'Order_Id'.tr} ${transactiondata!.transactions![index].orderNumber}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "2") ...[
                                        Text(
                                          "${'Order_Id'.tr} ${transactiondata!.transactions![index].orderNumber}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "3") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'RazorPay'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "4") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'Stripepay'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "5") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'Flutterwave'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "6") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'Paystack'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "7") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'MercadoPago'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "8") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'myFatoorah'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "9") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'paypal'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ]else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                          "10") ...[
                                        Text(
                                          "${'Paymenttype'.tr} ${'ToyyibPay'.tr}",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10),
                                        )
                                      ],
                                      Spacer(),
                                      if (transactiondata!.transactions![index]
                                              .transactionType ==
                                          "1") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: color.red,
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "2") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "3") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "4") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "5") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "6") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "7") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Color(0xff35C759),
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "8") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                              .transactions![index]
                                              .transactionType ==
                                          "9") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else if (transactiondata!
                                          .transactions![index]
                                          .transactionType ==
                                          "10") ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ] else ...[
                                        Text(
                                          currency_position == "1"
                                              ? '$currency${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}'
                                              : '${numberFormat.format(double.parse(transactiondata!.transactions![index].amount.toString()))}$currency',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontFamily: 'Poppins_Semibold',
                                              fontSize: 16),
                                        ),
                                      ]
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        FormatedDate(transactiondata!
                                            .transactions![index].date
                                            .toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                  separatorBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.height / 95,
                        right: MediaQuery.of(context).size.height / 95),
                    color: Colors.grey,
                    height: 1,
                    width: MediaQuery.of(context).size.width / 1.05,
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color: color.primarycolor,
                ),
              );
            }));
  }
}
