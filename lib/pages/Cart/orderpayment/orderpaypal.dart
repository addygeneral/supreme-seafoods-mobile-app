import 'dart:core';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http_auth/http_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/cartpage/orderplaceMODEL.dart';
import '../../../common class/prefs_name.dart';
import '../ordersucess.dart';

class PaypalPayment extends StatefulWidget {
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
  final Function onFinish;

  //final Function onFinish;

  PaypalPayment(
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
       {required this.onFinish}
      );

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var checkoutUrl;
  var executeUrl;
  var accessToken;
  String? userid;
  String? area;
  String? deliverycharge;

  String? username;
  String? useremail;
  String? usermobile;
  String? currency;
  orderplaceMODEL? placedorederdata;
  String? lati_tude;
  String? longi_tude;
  String? confirm_Address;
  String? confirm_house;
  String? confirm_Area;
  String? domain;
  String? paymentid;
  String? payment_id;
  String? sessionid;

  String? Fullname;
  String? pref_email;
  String? pref_mobile;
  String? addressType;
  var map;

  bool isEnableShipping = false;
  bool isEnableAddress = false;
  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  @override
  void initState() {
    super.initState();

    //var services = PaypalServices();

    Future.delayed(Duration.zero, () async {
      try {
        //accessToken = await services.getAccessToken();
        accessToken =await getAccessToken();
        final transactions = getOrderParams();
        final res =  await createPaypalPayment(transactions, accessToken);
           // await services.createPaypalPayment(transactions, accessToken);
       // paymentid = accessToken;
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
            print("eurllll : $executeUrl");


             payment_id = executeUrl.replaceAll("https://api.sandbox.paypal.com/v1/payments/payment/","").replaceAll("/execute","");
            print("payment_id... : $payment_id");
            print("executeUrl.. : $executeUrl");
            //api.sandbox.paypal.com","v1/payments/payment/PAYID-MRFZTBY0WJ22418U5996042K/execute"
          });
        }
      } catch (ex) {
        print(ex);
      }
    });
  }

   getOrderParams() {
    List items = [
      {
        "name": "Single Resturant payment",
        "quantity": 1,
        "price": double.parse(widget.ordertotal!),
        "currency": widget.currency
      }
    ];

    var totalAmount = double.parse(widget.ordertotal!);
    print(totalAmount);
    // var subTotalAmount = double.parse(widget.ordertotal!);
    // print(subTotalAmount);
    var shippingCost = double.parse(widget.delivery_charge.toString()) +
        double.parse(widget.taxamount.toString());
    print(shippingCost);

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": widget.currency,
            "details": {
              "subtotal": totalAmount,
              "shipping": 0,
              "shipping_discount": "0.0"
            }
          },
          "description": "-",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (isEnableShipping && isEnableAddress)
              "shipping_address": {
                "recipient_name": "",
                "line1": "",
                "line2": "",
                "city": "",
                "country_code": "",
                "postal_code": "",
                "phone": "",
                "state": ""
              },
          }
        }
      ],
      "note_to_payer": "-",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;

  }

  Future getAccessToken() async {
    if(widget.environment == "1"){
      domain = "https://api.sandbox.paypal.com";
    }else{
      domain =  "https://api.paypal.com";
    }
    print(domain);
    try {
      var client = BasicAuthClient(widget.publickey!, widget.secretkey!);
      var response = await client.post(
          Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: convert.jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];
          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
         return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }
  /// for carrying out the payment process
  Future executePayment(url, payerId, accessToken) async {
    try {
      var uul = Uri.https("api.sandbox.paypal.com","v1/payments/payment/PAYID-MRFZTBY0WJ22418U5996042K/execute");
      print("urllllll...:$uul");
      var response = await http.post(uul,
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer' + accessToken
          });
      print(" response body === ${response.body}");
      final body = convert.jsonDecode(response.body);
      print("body === $body");
      log(response.statusCode.toString());
      print("hellohhhh   === ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 401) {
        placeorderAPI();
        return body["id"];
      }
   //   placeorders();
     // return null;
    } catch (e) {
      {
        rethrow;
      }
    }
  }


  placeorderAPI() async {
    try {
      print("ggfvc");
      loader.showLoading();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userid = prefs.getString(UD_user_id);
      sessionid = prefs.getString(UD_user_session_id);
      lati_tude = prefs.getString(latitude);
      longi_tude = prefs.getString(longitude);
      confirm_Address = prefs.getString(confirmAddress);
      confirm_house = prefs.getString(confirmhouse_no);
      confirm_Area = prefs.getString(confirmArea);
      Fullname = prefs.getString(Full_name);
      pref_email = prefs.getString(Email);
      pref_mobile = prefs.getString(Mobile_no);
      addressType = prefs.getString(Addresstype);
      var map = {
        "user_id": userid,
        "session_id":sessionid,
        "grand_total": widget.ordertotal,
        "transaction_type": "8",
        "transaction_id": paymentid,
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

  @override
  Widget build(BuildContext context) {

    print(checkoutUrl);
    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Paypal",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request)  {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              print("urlllll : $uri");
              final payerID = uri.queryParameters['PayerID'];
              print("jphjkgkj : $payerID");
              paymentid = payerID;
              if (payerID != null) {
                     executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                      widget.onFinish(id);
                  //Navigator.of(context).pop();
                });
              } else {
                Navigator.of(context).pop();
              }

              print("payment successfull");

            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
              print("hujdfh");
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
