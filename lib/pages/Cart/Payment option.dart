// ignore_for_file: prefer_const_constructors, file_names, must_be_immutable, non_constant_identifier_names, use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/cartpage/isopenmodel.dart';
import 'package:singlerestaurant/Model/cartpage/orderplaceMODEL.dart';
import 'package:singlerestaurant/Model/cartpage/toyyibpaymodel.dart';
import 'package:singlerestaurant/Model/settings%20model/paymentoptionmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/orderpayment/orderflutterwave.dart';
import 'package:singlerestaurant/pages/Cart/orderpayment/orderpaystack.dart';
import 'package:singlerestaurant/pages/Cart/orderpayment/orderrazorpay.dart';
import 'package:singlerestaurant/pages/Cart/orderpayment/orderstripe.dart';
import 'package:singlerestaurant/pages/Cart/orderpayment/ordertoyyibpay.dart';
import 'package:singlerestaurant/pages/Cart/ordersucess.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import '../../Model/cartpage/mercadorequestmodel.dart';
import 'orderpayment/ordermercadopago.dart';
import 'orderpayment/ordermyfatoorah.dart';
import 'orderpayment/orderpaypal.dart';

class Paymentoption extends StatefulWidget {
  String? ordertotal;
  String? ordertype;
  String? offer_code;
  String? discount_amount;
  String? tax_amount;
  String? delivery_charge;
  //address
  String? addresstype;
  String? address;
  String? area;
  String? houseno;
  String? lang;
  String? lat;
  //
  String? ordernote;

  // const Paymentoption({Key? key}) : super(key: key);

  @override
  State<Paymentoption> createState() => _PaymentoptionState();
  Paymentoption([
    this.ordertotal,
    this.ordertype,
    this.offer_code,
    this.discount_amount,
    this.tax_amount,
    this.delivery_charge,
    // address
    this.addresstype,
    this.address,
    this.area,
    this.houseno,
    this.lang,
    this.lat,
    this.ordernote,
  ]);
}

class _PaymentoptionState extends State<Paymentoption> {
  int? selectedindex;
  String? userid;
  String? sessionid;
  paymentoptionModel? paymentlist;
  bool iscome = true;
  String? namepay;
  String? environment;
  orderplaceMODEL? placedorederdata;
  mercadopagomodel? mercadodata;
  toyyibpaymodel? paydata;
  String? public_key;
  String? secret_key;

  String? encryption_key;
  String? currency;
  String? currency_position;
  String? lati_tude;
  String? longi_tude;
  String? confirm_Address;
  String? confirm_house;
  String? confirm_Area;
  String? addressType;
  String? toyyibTransctionId;
  String? mercadoTransctionId;

  @override
  void initState() {
    super.initState();
  }

  paymentoptionAPI() async {
    print("hello");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    sessionid = prefs.getString(UD_user_session_id);
    currency = prefs.getString(APPcurrency);
    currency_position = prefs.getString(APPcurrency_position);
    lati_tude = prefs.getString(latitude);
    longi_tude = prefs.getString(longitude);
    confirm_Address = prefs.getString(confirmAddress);
    confirm_house = prefs.getString(confirmhouse_no);
    confirm_Area = prefs.getString(confirmArea);
    addressType = prefs.getString(Addresstype);
    var map = {
      "user_id": userid,
      "type": "order",
    };
    print(map);
    var response = await Dio()
        .post(DefaultApi.appUrl + PostAPI.Paymentmethodlist, data: map);
    var finalist = await response.data;
    print(finalist);
    paymentlist = paymentoptionModel.fromJson(finalist);
    iscome = false;
    return paymentlist;
  }

  placeorderAPI(type) async {
    try {
      loader.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getString(UD_user_id);
      sessionid = prefs.getString(UD_user_session_id);
      lati_tude = prefs.getString(latitude);
      longi_tude = prefs.getString(longitude);
      confirm_Address = prefs.getString(confirmAddress);
      confirm_house = prefs.getString(confirmhouse_no);
      confirm_Area = prefs.getString(confirmArea);
      addressType = prefs.getString(Addresstype);
      var map = {
        "user_id": userid,
        "session_id": sessionid,
        "grand_total": widget.ordertotal,
        "transaction_type": type,
        "transaction_id": "",
        "order_type": widget.ordertype,
        "address_type":
            userid == null || userid == "" ? addressType : widget.addresstype,
        "address":
            userid == null || userid == "" ? confirm_Address : widget.address,
        "area": userid == null || userid == "" ? confirm_Area : widget.area,
        "house_no":
            userid == null || userid == "" ? confirm_house : widget.houseno,
        "lang": userid == null || userid == "" ? longi_tude : widget.lang,
        "lat": userid == null || userid == "" ? lati_tude : widget.lat,
        "offer_code": widget.offer_code == "0" ? "" : widget.offer_code,
        "discount_amount": widget.discount_amount,
        "tax_amount": double.parse(widget.tax_amount.toString()),
        "delivery_charge": widget.delivery_charge,
        "order_notes": widget.ordernote,
        "order_from": "flutter",
        "card_number": "",
        "card_exp_month": "",
        "card_exp_year": "",
        "card_cvc": "",
        "name": prefs.getString(Full_name),
        "email": prefs.getString(Email),
        "mobile": prefs.getString(Mobile_no)
      };
      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Order, data: map);
      placedorederdata = orderplaceMODEL.fromJson(response.data);
      loader.hideLoading();
      if (placedorederdata!.status == 1) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Ordersucesspage()));
      } else {
        loader.showErroDialog(description: placedorederdata!.message);
      }
    } catch (e) {
      print(e);
    }
  }

  toyyibpayAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);

    try {
      loader.showLoading();
      var map = {
        "name": userid == "" || userid == null
            ? prefs.getString(Full_name)
            : prefs.getString(UD_user_name),
        "email": userid == "" || userid == null
            ? prefs.getString(Email)
            : prefs.getString(UD_user_email),
        "mobile": userid == "" || userid == null
            ? prefs.getString(Mobile_no)
            : prefs.getString(UD_user_mobile),
        "grand_total": widget.ordertotal,
      };
      print(map);
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.toyyibpayrequest, data: map);
      var finalist = await response.data;
      print(response);
      paydata = toyyibpaymodel.fromJson(finalist);
      if (paydata!.status == 1) {
        prefs.setString(toyyibpayurl, paydata!.redirecturl.toString());
        prefs.setString(toyyibpaysuccessurl, paydata!.successurl.toString());
        prefs.setString(toyyibpayfailurl, paydata!.failureurl.toString());
        prefs.setString(toyyibpaybillcode, paydata!.billcode.toString());
        Get.off(() => OrderToyyibpay())?.then((value) => api());
      }

      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }

  mercadopagoAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    try {
      loader.showLoading();
      var map = {
        "name": userid == "" || userid == null
            ? prefs.getString(Full_name)
            : prefs.getString(UD_user_name),
        "email": "",
        "mobile": userid == "" || userid == null
            ? prefs.getString(Mobile_no)
            : prefs.getString(UD_user_mobile),
        "grand_total": widget.ordertotal,
      };
      print(map);
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.mercadorequest, data: map);
      var finalist = await response.data;
      print(response);
      mercadodata = mercadopagomodel.fromJson(finalist);
      if (mercadodata!.status == 1) {
        prefs.setString(mercadopayurl, mercadodata!.redirecturl.toString());
        prefs.setString(
            mercadopaysuccessurl, mercadodata!.successurl.toString());
        prefs.setString(mercadopayfailurl, mercadodata!.failureurl.toString());
        Get.off(() => OrderMercadopago())?.then((value) => mercadoapi());
      }

      loader.hideLoading();
    } catch (e) {
      rethrow;
    }
  }

  api() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    toyyibTransctionId = prefs.getString(toyyibpaytransctionid);
    try {
      loader.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getString(UD_user_id);
      sessionid = prefs.getString(UD_user_session_id);
      lati_tude = prefs.getString(latitude);
      longi_tude = prefs.getString(longitude);
      confirm_Address = prefs.getString(confirmAddress);
      confirm_house = prefs.getString(confirmhouse_no);
      confirm_Area = prefs.getString(confirmArea);
      addressType = prefs.getString(Addresstype);
      var map = {
        "user_id": userid,
        "session_id": sessionid,
        "grand_total": widget.ordertotal,
        "transaction_type": "10",
        "transaction_id": toyyibTransctionId,
        "order_type": widget.ordertype,
        "address_type":
            userid == null || userid == "" ? addressType : widget.addresstype,
        "address":
            userid == null || userid == "" ? confirm_Address : widget.address,
        "area": userid == null || userid == "" ? confirm_Area : widget.area,
        "house_no":
            userid == null || userid == "" ? confirm_house : widget.houseno,
        "lang": userid == null || userid == "" ? longi_tude : widget.lang,
        "lat": userid == null || userid == "" ? lati_tude : widget.lat,
        "offer_code": widget.offer_code == "0" ? "" : widget.offer_code,
        "discount_amount": widget.discount_amount,
        "tax_amount": double.parse(widget.tax_amount.toString()),
        "delivery_charge": widget.delivery_charge,
        "order_notes": widget.ordernote,
        "order_from": "flutter",
        "card_number": "",
        "card_exp_month": "",
        "card_exp_year": "",
        "card_cvc": "",
        "name": prefs.getString(Full_name),
        "email": prefs.getString(Email),
        "mobile": prefs.getString(Mobile_no)
      };
      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Order, data: map);
      placedorederdata = orderplaceMODEL.fromJson(response.data);
      loader.hideLoading();
      if (placedorederdata!.status == 1) {
        prefs.setString(toyyibpaytransctionid, "");
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Ordersucesspage()));
      } else {
        loader.showErroDialog(description: placedorederdata!.message);
      }
    } catch (e) {
      print(e);
    }
  }

  mercadoapi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    mercadoTransctionId = prefs.getString(mercadopaytransctionid);
    try {
      loader.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getString(UD_user_id);
      sessionid = prefs.getString(UD_user_session_id);
      lati_tude = prefs.getString(latitude);
      longi_tude = prefs.getString(longitude);
      confirm_Address = prefs.getString(confirmAddress);
      confirm_house = prefs.getString(confirmhouse_no);
      confirm_Area = prefs.getString(confirmArea);
      addressType = prefs.getString(Addresstype);
      var map = {
        "user_id": userid,
        "session_id": sessionid,
        "grand_total": widget.ordertotal,
        "transaction_type": "7",
        "transaction_id": mercadoTransctionId,
        "order_type": widget.ordertype,
        "address_type":
            userid == null || userid == "" ? addressType : widget.addresstype,
        "address":
            userid == null || userid == "" ? confirm_Address : widget.address,
        "area": userid == null || userid == "" ? confirm_Area : widget.area,
        "house_no":
            userid == null || userid == "" ? confirm_house : widget.houseno,
        "lang": userid == null || userid == "" ? longi_tude : widget.lang,
        "lat": userid == null || userid == "" ? lati_tude : widget.lat,
        "offer_code": widget.offer_code == "0" ? "" : widget.offer_code,
        "discount_amount": widget.discount_amount,
        "tax_amount": double.parse(widget.tax_amount.toString()),
        "delivery_charge": widget.delivery_charge,
        "order_notes": widget.ordernote,
        "order_from": "flutter",
        "card_number": "",
        "card_exp_month": "",
        "card_exp_year": "",
        "card_cvc": "",
        "name": prefs.getString(Full_name),
        "email": prefs.getString(Email),
        "mobile": prefs.getString(Mobile_no)
      };
      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Order, data: map);
      placedorederdata = orderplaceMODEL.fromJson(response.data);
      loader.hideLoading();
      if (placedorederdata!.status == 1) {
        prefs.setString(mercadopaytransctionid, "");
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Ordersucesspage()));
      } else {
        loader.showErroDialog(description: placedorederdata!.message);
      }
    } catch (e) {
      print(e);
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
                );
              },
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                size: 20,
              )),
          title: Text(
            'Payment_Option'.tr,
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
                            environment = paymentlist!
                                .paymentmethods![index].environment
                                .toString();
                            namepay =
                                paymentlist!.paymentmethods![index].paymentName;
                            currency =
                                paymentlist!.paymentmethods![index].currency;
                            selectedindex = index;

                            public_key =
                                paymentlist!.paymentmethods![index].publicKey;
                            secret_key =
                                paymentlist!.paymentmethods![index].secretKey;
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
                                  paymentlist!.paymentmethods![index]
                                              .paymentName ==
                                          "Wallet"
                                      ? currency_position.toString() == "1"
                                          ? "${paymentlist!.paymentmethods![index].paymentName.toString()} ($currency${numberFormat.format(double.parse(paymentlist!.totalWallet ?? "0.0"))})"
                                          : "${paymentlist!.paymentmethods![index].paymentName.toString()} (${numberFormat.format(double.parse(paymentlist!.totalWallet ?? "0.0"))}$currency)"
                                      : paymentlist!
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
                                      ? color.red
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
                        // margin: EdgeInsets.only(top: 1.h, bottom: 2.5.w),
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
        bottomSheet: Container(
          margin: EdgeInsets.only(bottom: 1.h, left: 4.w, right: 4.w),
          height: 6.5.h,
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              isopencloseMODEL? isopendata;
              if (selectedindex == null) {
                loader.showErroDialog(
                    description: 'Please_select_payment_option'.tr);
              } else {
                var map;
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
                  if (isopendata.isCartEmpty == "0") {
                    if (namepay == "COD") {
                      placeorderAPI("1");
                    } else if (namepay == "Wallet") {
                      print(widget.ordertotal!);
                      print(paymentlist!.totalWallet);
                      if (double.parse(widget.ordertotal!) >=
                          double.parse(paymentlist!.totalWallet.toString())) {
                        loader.showErroDialog(
                          description: LocaleKeys
                              .You_dont_have_sufficient_wallet_amonut_Please_select_another_payment_option
                              .tr,
                        );
                      } else {
                        placeorderAPI("2");
                      }
                    } else if (namepay == "RazorPay") {
                      if (userid == "" || userid == null) {
                        Get.to(() => orderrazorpay(
                              // order
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              confirm_Address,
                              confirm_Area,
                              confirm_house,
                              lati_tude,
                              longi_tude,
                              // extra
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,
                              currency,
                            ));
                      } else {
                        Get.to(() => orderrazorpay(
                              // order
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              widget.address,
                              widget.area,
                              widget.houseno,
                              widget.lang,
                              widget.lat,
                              // extra
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,
                              currency,
                            ));
                      }
                    } else if (namepay == "Stripe") {
                      print("stripe");
                      if (userid == "" || userid == null) {
                        Get.to(() => orderstripe(
                              //order
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              // address
                              widget.addresstype,
                              confirm_Address,
                              confirm_Area,
                              confirm_house,
                              lati_tude,
                              longi_tude,
                              //extra
                              widget.ordernote,
                            ));
                      } else {
                        Get.to(() => orderstripe(
                              //order
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              // address
                              widget.addresstype,
                              widget.address,
                              widget.area,
                              widget.houseno,
                              widget.lang,
                              widget.lat,
                              //extra
                              widget.ordernote,
                            ));
                      }
                    } else if (namepay == "Flutterwave") {
                      print(currency);
                      if (userid == "" || userid == null) {
                        Get.to(() => orderflutterwave(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              confirm_Address,
                              confirm_Area,
                              confirm_house,
                              lati_tude,
                              longi_tude,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,

                              encryption_key,
                              currency,
                            ));
                      } else {
                        Get.to(() => orderflutterwave(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              widget.address,
                              widget.area,
                              widget.houseno,
                              widget.lang,
                              widget.lat,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,

                              encryption_key,
                              currency,
                            ));
                      }
                    } else if (namepay == "Paystack") {
                      if (userid == "" || userid == null) {
                        Get.to(() => order_paystack(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              confirm_Address,
                              confirm_Area,
                              confirm_house,
                              lati_tude,
                              longi_tude,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,
                              encryption_key,
                              currency,
                            ));
                      } else {
                        Get.to(() => order_paystack(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              widget.address,
                              widget.area,
                              widget.houseno,
                              widget.lang,
                              widget.lat,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,
                              encryption_key,
                              currency,
                            ));
                      }

                      print("Paystack");
                    } else if (namepay == "MercadoPago") {
                      mercadopagoAPI();
                    } else if (namepay == "myFatoorah") {
                      print(currency);
                      if (userid == "" || userid == null) {
                        Get.to(() => myfatoorah(
                            widget.ordertotal,
                            widget.ordertype,
                            widget.offer_code,
                            widget.discount_amount,
                            widget.tax_amount,
                            widget.delivery_charge,
                            //address
                            widget.addresstype,
                            confirm_Address,
                            confirm_Area,
                            confirm_house,
                            lati_tude,
                            longi_tude,
                            //
                            widget.ordernote,
                            //key
                            public_key,
                            secret_key,
                            encryption_key,
                            currency,
                            environment));
                      } else {
                        Get.to(() => myfatoorah(
                            widget.ordertotal,
                            widget.ordertype,
                            widget.offer_code,
                            widget.discount_amount,
                            widget.tax_amount,
                            widget.delivery_charge,
                            //address
                            widget.addresstype,
                            widget.address,
                            widget.area,
                            widget.houseno,
                            widget.lang,
                            widget.lat,
                            //
                            widget.ordernote,
                            //key
                            public_key,
                            secret_key,
                            encryption_key,
                            currency,
                            environment));
                      }
                    } else if (namepay == "paypal") {
                      print(currency);
                      if (userid == "" || userid == null) {
                        Get.to(() => PaypalPayment(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              confirm_Address,
                              confirm_Area,
                              confirm_house,
                              lati_tude,
                              longi_tude,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,

                              encryption_key,
                              currency,
                              environment,
                              onFinish: (number) async {
                                // payment done
                                final snackBar = SnackBar(
                                  content:
                                      const Text("Payment done Successfully"),
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
                      } else {
                        Get.to(() => PaypalPayment(
                              widget.ordertotal,
                              widget.ordertype,
                              widget.offer_code,
                              widget.discount_amount,
                              widget.tax_amount,
                              widget.delivery_charge,
                              //address
                              widget.addresstype,
                              widget.address,
                              widget.area,
                              widget.houseno,
                              widget.lang,
                              widget.lat,
                              //
                              widget.ordernote,
                              //key
                              public_key,
                              secret_key,

                              encryption_key,
                              currency,
                              environment,
                              onFinish: (number) async {
                                // payment done
                                final snackBar = SnackBar(
                                  content:
                                      const Text("Payment done Successfully"),
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
                    } else if (namepay == "ToyyibPay") {
                      toyyibpayAPI();
                    }
                  } else {
                    Get.to((_) => Homepage(0));
                  }
                } else {
                  loader.showErroDialog(description: isopendata.message);
                }
              }
            },
            style: TextButton.styleFrom(backgroundColor: color.primarycolor),
            child: Text(
              'Place_Order'.tr,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp),
            ),
          ),
        ),
      ),
    );
  }
}
