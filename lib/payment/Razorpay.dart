// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, must_be_immutable, camel_case_types, use_key_in_widget_constructors, file_names, non_constant_identifier_names, avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/settings%20model/addwalletMODEL.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Profile/Addmoney.dart';

class razor_pay extends StatefulWidget {
  String? publickey;
  String? secretkey;
  String? amount;
  String? currency;

  // const razor_pay({Key? key}) : super(key: key);

  @override
  State<razor_pay> createState() => _razor_payState();
  razor_pay([
    this.publickey,
    this.secretkey,
    this.amount,
    this.currency,
  ]);
}

class _razor_payState extends State<razor_pay> {
  String? payment_keys;
  String? pay_message;
  late Razorpay razorpay;
  String? userid;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    openchekout();
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("succes");
    print("maaaa${response.paymentId}");
    payment_keys = response.paymentId;
    pay_message = "sucscess"; // Do

    Add_wallet_api(payment_keys); // something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
    Get.back();
    loader.showErroDialog(description: "payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    loader.showErroDialog(description: response.toString());
  }

  openchekout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    var options = {
      'key': widget.publickey,
      'amount': (double.parse(widget.amount!) * 100).toInt(),
      'name': prefs.getString(UD_user_name),
      'currecy': widget.currency,
      'description': "Service Provider",
      'prefill': {
        'contact': prefs.getString(UD_user_mobile),
        'email': prefs.getString(UD_user_email),
      }
    };
    print("option $options");
    try {
      razorpay.open(options);
    } catch (e) {
      print("error $e");
    }
  }

  addwalletMODEL? addwalletdata;
  Add_wallet_api(paymentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    loader.showLoading();
    try {
      var map = {
        "user_id": userid,
        "amount": widget.amount,
        "transaction_type": "3",
        "transaction_id": paymentid,
        "card_number": "",
        "card_exp_month": "",
        "card_exp_year": "",
        "card_cvc": ""
      };
      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.addwallet, data: map);
      addwalletdata = addwalletMODEL.fromJson(response.data);
      print(response);
      if (addwalletdata!.status == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString(UD_user_wallet, addwalletdata!.totalWallet.toString());
        loader.hideLoading();

        int count = 0;
        Navigator.popUntil(
          context,
          (route) {
            return count++ == 2;
          },
        );
      } else {
        loader.hideLoading();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (c) => Addmoney(),
            ),
            (r) => false);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
