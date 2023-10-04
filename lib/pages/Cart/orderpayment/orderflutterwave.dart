// ignore_for_file: non_constant_identifier_names, camel_case_types, use_key_in_widget_constructors, unnecessary_null_comparison, must_be_immutable, use_build_context_synchronously, prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Model/cartpage/orderplaceMODEL.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/ordersucess.dart';

class orderflutterwave extends StatefulWidget {
  String? ordertotal;
  String? ordertype;
  String? offercode;
  String? discountamount;
  String? taxamount;
  String? delivery_charge;
  //
  String? addresstype;
  String? address;
  String? area;
  String? houseno;
  String? lang;
  String? lat;
  //
  String? ordernote;
  //
  String? publickey;
  String? secretkey;
  String? encryption_key;
  String? currency;
  String? environment;

  // const orderflutterwave({Key? key}) : super(key: key);

  @override
  State<orderflutterwave> createState() => _orderflutterwaveState();
  orderflutterwave([
    this.ordertotal,
    this.ordertype,
    this.offercode,
    this.taxamount,
    this.discountamount,
    this.delivery_charge,
    //
    this.addresstype,
    this.address,
    this.area,
    this.houseno,
    this.lang,
    this.lat,
    //
    this.ordernote,
    //
    this.publickey,
    this.secretkey,
    this.encryption_key,
    this.currency,
    this.environment,
  ]);
}

class _orderflutterwaveState extends State<orderflutterwave> {
  __handlePaymentInitialization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString(UD_user_id)!;
    String name = prefs.getString(UD_user_name)!;
    String email = prefs.getString(UD_user_email)!;
    String mobile = prefs.getString(UD_user_mobile)!;
    String sessionid = prefs.getString(UD_user_session_id)!;
    String lati_tude = prefs.getString(latitude)!;
    String longi_tude = prefs.getString(longitude)!;
    String confirm_Address = prefs.getString(confirmAddress)!;
    String confirm_house = prefs.getString(confirmhouse_no)!;
    String confirm_Area = prefs.getString(confirmArea)!;
    String Fullname = prefs.getString(Full_name)!;
    String pref_email = prefs.getString(Email)!;
    String pref_mobile = prefs.getString(Mobile_no)!;
    String addressType  = prefs.getString(Addresstype)!;
    final Customer customer = Customer(
      email: userid == null || userid == "" ?  pref_email : email,
      name: userid == null || userid == "" ? Fullname :name,
      phoneNumber: userid == null || userid == "" ? pref_mobile :mobile,
    );
    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: widget.publickey!,
      currency: widget.currency,
      redirectUrl: "https://google.com",
      txRef: DateTime.now().toString(),
      amount: widget.ordertotal!,
      customer: customer,
      paymentOptions: "card, payattitude, barter",
      customization: Customization(title: "Test Payment"),
      isTestMode: widget.environment.toString() == "1" ? false : true,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response != null) {
      loader.showLoading();
      var map = {
        "user_id": userid,
        "session_id":sessionid,
        "grand_total": widget.ordertotal,
        "transaction_type": "5",
        "transaction_id": response.transactionId,
        "order_type": widget.ordertype,
        "address_type": userid == null || userid == "" ? addressType :widget.addresstype,
        "address":  userid == null || userid == "" ? confirm_Address : widget.address,
        "area":  userid == null || userid == "" ? confirm_Area :widget.area,
        "house_no":  userid == null || userid == "" ? confirm_house :widget.houseno,
        "lang":  userid == null || userid == "" ? longi_tude :widget.lang,
        "lat":  userid == null || userid == "" ? lati_tude :widget.lat,
        "offer_code": widget.offercode == "0" ? "" : widget.offercode,
        "discount_amount": widget.discountamount,
        "tax_amount": widget.taxamount,

        "delivery_charge": widget.delivery_charge,
        "order_notes": widget.ordernote,
        "order_from": "flutter",

        "card_number": "",
        "card_exp_month": "",
        "card_exp_year": "",
        "card_cvc": "",
        "name":Fullname,
        "email":pref_email,
        "mobile":pref_mobile,
      };

      var finaldata =
          await Dio().post(DefaultApi.appUrl + PostAPI.Order, data: map);
      orderplaceMODEL placedorederdata =
          orderplaceMODEL.fromJson(finaldata.data);
      if (placedorederdata.status == 1) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Ordersucesspage()));
      } else {
        loader.showErroDialog(description: placedorederdata.message);
      }
    }
  }

  getpublickey() {
    if (isTestMode) {
      return widget.publickey;
    }
    return widget.encryption_key;
  }

  final publickeycontroller = TextEditingController();
  bool isTestMode = true;

  @override
  void initState() {
    super.initState();
    __handlePaymentInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
