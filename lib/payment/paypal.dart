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
import '../../../common class/prefs_name.dart';
import '../Model/settings model/addwalletMODEL.dart';

class Paypal extends StatefulWidget {
  String? publickey;
  String? secretkey;
  String? amount;
  String? environment;
  String? currency;
  final Function onFinish;

  Paypal(
      this.publickey,
      this.secretkey,
      this.amount,
      this.environment,
      this.currency,
      {required this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalState();
  }
}

class PaypalState extends State<Paypal> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var checkoutUrl;
  var executeUrl;
  var accessToken;

  String? domain;
  String? paykey;

  bool isEnableShipping = false;
  bool isEnableAddress = false;
  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';
  addwalletMODEL? add_money;

  payment_API() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loader.showLoading();
    try {
      loader.showLoading();
      var map = {
        "user_id": prefs.getString(UD_user_id),
        "amount": widget.amount,
        "transaction_type": "9",
        "transaction_id": paykey,
      };
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.addwallet, data: map);

      var finallist = await response.data;
      add_money = addwalletMODEL.fromJson(finallist);
      if (add_money!.status == 1) {
        print("status 5766 === ${add_money!.status}");
        loader.hideLoading();
        prefs.setString(UD_user_wallet, add_money!.totalWallet.toString());
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 4;
        });
      } else {
        loader.hideLoading();
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 4;
        });
      }
      return add_money;
    } catch (e) {
      loader.hideLoading();
      // loader.showErroDialog(description: "No Data Found");
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await getAccessToken();
        final transactions = getOrderParams();
        final res = await createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];

            paykey = executeUrl
                .replaceAll(
                "https://api.sandbox.paypal.com/v1/payments/payment/", "")
                .replaceAll("/execute", "");
            //api.sandbox.paypal.com","v1/payments/payment/PAYID-MRFZTBY0WJ22418U5996042K/execute"
          });
        }
        // ignore: empty_catches
      } catch (ex) {}
    });
  }

  getOrderParams() {
    List items = [
      {
        "name": "Single Restaurant payment",
        "quantity": 1,
        "price": double.parse(widget.amount!),
        "currency": widget.currency
      }
    ];

    var totalAmount = double.parse(widget.amount!);

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
    if (widget.environment == "1") {
      domain = "https://api.sandbox.paypal.com";
    } else {
      domain = "https://api.paypal.com";
    }
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

  Future createPaypalPayment(transactions, accessToken) async {
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
      var uul = Uri.https("api.sandbox.paypal.com",
          "v1/payments/payment/PAYID-MRFZTBY0WJ22418U5996042K/execute");
      var response = await http.post(uul,
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer' + accessToken
          });

      final body = convert.jsonDecode(response.body);

      log(response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 401) {
        payment_API();
        return body["id"];
      }
    } catch (e) {
      {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);

              final payerID = uri.queryParameters['PayerID'];

              if (payerID != null) {
                executePayment(executeUrl, payerID, accessToken).then((id) {
                  widget.onFinish(id);
                });
              } else {
                Navigator.of(context).pop();
              }
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
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
