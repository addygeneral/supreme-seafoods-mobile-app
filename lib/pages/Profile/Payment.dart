// ignore_for_file: prefer_const_constructors, must_be_immutable, camel_case_types, use_key_in_widget_constructors, non_constant_identifier_names, file_names, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/cartpage/toyyibpaymodel.dart';
import 'package:singlerestaurant/Model/settings%20model/addwalletMODEL.dart';
import 'package:singlerestaurant/Model/settings%20model/paymentoptionmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/payment/Razorpay.dart';
import 'package:singlerestaurant/payment/flutterwave.dart';
import 'package:singlerestaurant/payment/paystack.dart';
import 'package:singlerestaurant/payment/stripe.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import '../../Model/cartpage/mercadorequestmodel.dart';
import '../../payment/mercadopago.dart';
import '../../payment/myfatoorah.dart';
import '../../payment/paypal.dart';
import '../../payment/toyyibpay.dart';
import 'Addmoney.dart';

class selectpayment extends GetxController {
  RxInt? selectedindex = 0.obs;
}

class Payment extends StatefulWidget {
  String? amount;
  // const Payment({Key? key}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
  Payment([this.amount]);
}

class _PaymentState extends State<Payment> {
  int? selectedindex;
  paymentoptionModel? paymentlist;
  mercadopagomodel? mercadodata;
  String? userid;
  String? walletamount;
  String? payment_name;
  String? environment;
  String? currency;
  String? public_key;
  String? secret_key;
  String? encryption_key;
  bool iscome = true;
  toyyibpaymodel? paydata;

  // selectpayment select = Get.put(selectpayment());
  paymentoptionAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    walletamount = prefs.getString(UD_user_wallet);
    var map = {
      "user_id": userid,
      "type": "wallet",
    };
    print(map);
    var response = await Dio()
        .post(DefaultApi.appUrl + PostAPI.Paymentmethodlist, data: map);
    print(response);
    var finalist = await response.data;
    paymentlist = paymentoptionModel.fromJson(finalist);
    iscome = false;
    return paymentlist;
  }

  toyyibpayAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);

    try {
      loader.showLoading();
      var map = {
        "name":userid == "" || userid == null ? prefs.getString(Full_name) : prefs.getString(UD_user_name),
        "email":userid == "" || userid == null ? prefs.getString(Email) : prefs.getString(UD_user_email),
        "mobile":userid == "" || userid == null ? prefs.getString(Mobile_no) : prefs.getString(UD_user_mobile),
        "grand_total" :  widget.amount,
      };
      print(map);
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.toyyibpayrequest, data: map);
      var finalist = await response.data;
      print(response);
      paydata = toyyibpaymodel.fromJson(finalist);
      if(paydata!.status == 1){
        prefs.setString(toyyibpayurl, paydata!.redirecturl.toString());
        prefs.setString(toyyibpaysuccessurl, paydata!.successurl.toString());
        prefs.setString(toyyibpayfailurl, paydata!.failureurl.toString());
        prefs.setString(toyyibpaybillcode, paydata!.billcode.toString());
        Get.off(() => Toyyibpay())?.then((value) => Addwalletapi());
      }

      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }
  mercadopayAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);

    try {
      loader.showLoading();
      var map = {
        "name":userid == "" || userid == null ? prefs.getString(Full_name) : prefs.getString(UD_user_name),
        "email":"",
        "mobile":userid == "" || userid == null ? prefs.getString(Mobile_no) : prefs.getString(UD_user_mobile),
        "grand_total" :  widget.amount,
      };
      print(map);
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.mercadorequest, data: map);
      var finalist = await response.data;
      print(response);
      mercadodata = mercadopagomodel.fromJson(finalist);
      if(mercadodata!.status == 1){
        prefs.setString(mercadopayurl, mercadodata!.redirecturl.toString());
        prefs.setString(mercadopaysuccessurl, mercadodata!.successurl.toString());
        prefs.setString(mercadopayfailurl, mercadodata!.failureurl.toString());
        Get.off(() => Mercadopago())?.then((value) => mercadowalletapi());
      }

      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }

  addwalletMODEL? addwalletdata;

  Addwalletapi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString(UD_user_id);
    var transcationid = prefs.getString(toyyibpaytransctionid);
    loader.showLoading();
    try {
      var map = {
        "user_id": userid,
        "amount": widget.amount,
        "transaction_type": "10",
        "transaction_id": transcationid,
      };
      var response =
      await Dio().post(DefaultApi.appUrl + PostAPI.addwallet, data: map);
      addwalletdata = addwalletMODEL.fromJson(response.data);
      if (addwalletdata!.status == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(toyyibpaytransctionid, "");
        prefs.setString(UD_user_wallet, addwalletdata!.totalWallet.toString());
        loader.hideLoading();
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        // Navigator.popUntil(context, ModalRoute.withName('/Wallet'));
      } else {
        loader.hideLoading();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (c) => Addmoney()), (r) => false);
      }
    } catch (e) {
      rethrow;
    }
  }
  mercadowalletapi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = prefs.getString(UD_user_id);
    var mercadotranscationid = prefs.getString(mercadopaytransctionid);
    loader.showLoading();
    try {
      var map = {
        "user_id": userid,
        "amount": widget.amount,
        "transaction_type": "7",
        "transaction_id": mercadotranscationid,
      };
      var response =
      await Dio().post(DefaultApi.appUrl + PostAPI.addwallet, data: map);
      addwalletdata = addwalletMODEL.fromJson(response.data);
      if (addwalletdata!.status == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(mercadopaytransctionid, "");
        prefs.setString(UD_user_wallet, addwalletdata!.totalWallet.toString());
        loader.hideLoading();
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        // Navigator.popUntil(context, ModalRoute.withName('/Wallet'));
      } else {
        loader.hideLoading();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (c) => Addmoney()), (r) => false);
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
          leading: IconButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => Addmoney()),
                );
              },
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                size: 20,
              )),
          title: Text(
            'Payment'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: iscome == true ? paymentoptionAPI() : null,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.only(left: 4.w, right: 4.w),
                itemCount: paymentlist!.paymentmethods!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          print(index);
                          setState(() {
                            selectedindex = index;
                            payment_name =
                                paymentlist!.paymentmethods![index].paymentName;
                            environment = paymentlist!
                                .paymentmethods![index].environment
                                .toString();
                            currency =
                                paymentlist!.paymentmethods![index].currency;
                            encryption_key = paymentlist!
                                .paymentmethods![index].encryptionKey;
                            if (paymentlist!.paymentmethods![index].environment
                                    .toString() ==
                                "1") {
                              public_key =
                                  paymentlist!.paymentmethods![index].publicKey;
                              secret_key =
                                  paymentlist!.paymentmethods![index].secretKey;
                            } else if (paymentlist!
                                    .paymentmethods![index].environment
                                    .toString() ==
                                "2") {
                              public_key =
                                  paymentlist!.paymentmethods![index].publicKey;
                              secret_key =
                                  paymentlist!.paymentmethods![index].secretKey;
                            }
                          });
                        },
                        child: SizedBox(
                          height: 7.h,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 13.w,
                                child: Image.network(
                                  paymentlist!.paymentmethods![index].image!,
                                  height: 4.h,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 1.w,
                                ),
                                child: Text(
                                  paymentlist!
                                      .paymentmethods![index].paymentName
                                      .toString(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Container(
                                height: 3.3.h,
                                width: 3.3.h,
                                decoration: BoxDecoration(
                                  color: selectedindex == index
                                      ? color.green
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(Icons.done,
                                    color: selectedindex == index
                                        ? Colors.white
                                        : Colors.transparent,
                                    size: 13.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        height: 0.8.sp,
                      ),
                    ],
                  );
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: color.primarycolor,
              ),
            );
          },
        ),
        bottomSheet: InkWell(
          onTap: () {
            if (selectedindex == null) {
              loader.showErroDialog(
                description: 'Please_select_payment_option'.tr,
              );
            } else {
              print(payment_name);
              if (payment_name == "RazorPay") {
                print(userid);
                print(public_key);
                print(secret_key);
                print(encryption_key);
                print(widget.amount);
                print(currency);
                Get.to(
                  () => razor_pay(
                    public_key,
                    secret_key,
                    widget.amount.toString(),
                    currency,
                  ),
                );
              }
              else if (payment_name == "Stripe") {
                Get.to(() => stripe(widget.amount.toString()));
              }
              else if (payment_name == "Flutterwave") {
                Get.to(
                  () => flutterwavepayment(
                    public_key,
                    secret_key,
                    encryption_key,
                    widget.amount.toString(),
                    currency,
                    environment,
                  ),
                );
              }
              else if (payment_name == "Paystack") {
                Get.to(() => paystack_method(
                      public_key,
                      secret_key,
                      widget.amount,
                      encryption_key,
                      currency,
                    ));
              }
              else if (payment_name == "MercadoPago") {
                mercadopayAPI();
              }
              else if (payment_name == "myFatoorah") {
                Get.to(() => myfatoorah(
                  public_key,
                  secret_key,
                  widget.amount,
                  currency,
                ));
              }
              else if (payment_name == "paypal") {
                Get.to(() => Paypal(
                  public_key,
                  secret_key,
                  widget.amount,
                  environment,
                  currency,
                  onFinish: (number) async {
                    // payment done
                    final snackBar = SnackBar(
                      content: const Text("Payment done Successfully"),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                    // _scaffoldKey.currentState!.showSnackbar(snackBar);
                  },
                ));
              }
              else if (payment_name == "ToyyibPay") {
                toyyibpayAPI();
              }
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h, left: 4.w, right: 4.w),
            height: 6.5.h,
            width: double.infinity,
            decoration: BoxDecoration(color: color.green),
            child: Center(
              child: Text(
                'Process_to_pay'.tr,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
