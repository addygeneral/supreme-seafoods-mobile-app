
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:myfatoorah_flutter/embeddedapplepay/MFApplePayButton.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:myfatoorah_flutter/utils/MFCountry.dart';
import 'package:myfatoorah_flutter/utils/MFEnvironment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Widgets/loader.dart';

import '../Model/settings model/addwalletMODEL.dart';
import '../common class/prefs_name.dart';
import '../config/API/API.dart';
import '../pages/Profile/Addmoney.dart';


// You can get the API Token Key from here:
// https://myfatoorah.readme.io/docs/test-token
//  "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL";

class myfatoorah extends StatefulWidget {
  String? publickey;
  String? secretkey;
  String? amount;
  String? currency;

   myfatoorah(
       this.publickey,
       this.secretkey,
       this.amount,
       this.currency,
      );

  @override
  _myfatoorahState createState() => _myfatoorahState();
}

class _myfatoorahState extends State<myfatoorah> {
  addwalletMODEL? addwalletdata;
  String? paymentid;
  String? userid;

  String _response = '';
  String _loading = "Loading...";
  // late MFPaymentCardView mfPaymentCardView;
  late MFApplePayButton mfApplePayButton;

  @override
  void initState() {
    super.initState();
    // get();
    final String mAPIKey = widget.secretkey.toString();
    if (mAPIKey.isEmpty) {
      setState(() {
        _response =
        "Missing API Token Key.. You can get it from here: https://myfatoorah.readme.io/docs/test-token";
      });
      return;
    }

    MFSDK.init(mAPIKey, MFCountry.KUWAIT, MFEnvironment.TEST);
    initiateSession();

    MFSDK.setUpAppBar(isShowAppBar: false);

  }

  void initiateSession() {
    MFSDK.initiateSession(
        null,
            (MFResult<MFInitiateSessionResponse> result) => {
          if (result.isSuccess())
            {
              if (Platform.isIOS) loadApplePay(result.response!)
            }
          else
            {
              setState(() {
                _response = result.error!.message!;
              })
            }
        });
  }

  void loadApplePay(MFInitiateSessionResponse mfInitiateSessionResponse) {
    var request = MFExecutePaymentRequest.constructorForApplyPay(
        double.parse(widget.amount.toString()), MFCurrencyISO.KUWAIT_KWD);
    mfApplePayButton.loadWithStartLoading(
        mfInitiateSessionResponse,
        request,
        MFAPILanguage.EN,
            () {
          setState(() {
            _response = "Loading...";
          });
        },
            (String invoiceId, MFResult<MFPaymentStatusResponse> result) => {
          if (result.isSuccess())
            {
              setState(() {
                print("invoiceId: " + invoiceId);
                print("Response: " + result.response!.toJson().toString());
                _response = result.response!.toJson().toString();
                paymentid = result.response!.invoiceTransactions![0].transactionId.toString();
                payment_API();
              })
            }
          else
            {
              setState(() {
                print("invoiceId: " + invoiceId);
                print("Error: " + result.error!.toJson().toString());
                _response = result.error!.message!;
              })
            }
        });
  }
 executeRegularPayment() {
  // The value 1 is the paymentMethodId of KNET payment method.
  // You should call the "initiatePayment" API to can get this id and the ids of all other payment methods
  int paymentMethod = 1;

  var request = new MFExecutePaymentRequest(paymentMethod, double.parse(widget.amount.toString()));

  MFSDK.executePayment(context, request, MFAPILanguage.EN,
      onInvoiceCreated: (String invoiceId) =>
      {print("invoiceId: " + invoiceId)},
      onPaymentResponse: (String invoiceId,
          MFResult<MFPaymentStatusResponse> result) =>
      {
        if (result.isSuccess())
          {
            setState(() {
              print("invoiceId: " + invoiceId);
              print("Response: " + result.response!.toJson().toString());
              _response = result.response!.toJson().toString();
              paymentid = result.response!.invoiceTransactions![0].transactionId.toString();
              print(paymentid);
              payment_API();
            })
          }
        else
          {
            setState(() {
              print("invoiceId: " + invoiceId);
              print("Response: " + result.error!.toJson().toString());
              _response = result.error!.message!;
            })
          }
      });

  setState(() {
    _response = _loading;
  });
}
  payment_API() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    try {
      loader.showLoading();
      var map = {
        "user_id": userid,
        "amount": widget.amount,
        "transaction_type": "8",
        "transaction_id": paymentid,
      };
      print(map);
      var response =
      await Dio().post(DefaultApi.appUrl + PostAPI.addwallet, data: map);
      addwalletdata = addwalletMODEL.fromJson(response.data);
      print(response);
      if (addwalletdata!.status == 1) {

        // Navigator.of(context).popUntil((route) => true);
        prefs.setString(UD_user_wallet, addwalletdata!.totalWallet.toString());
        loader.hideLoading();
        // Navigator.pushReplacement(context, MaterialPageRoute(
        //   builder: (context) {
        //     return Wallet();
        //   },
        // ));
        int count = 0;
        Navigator.popUntil(
          context,
              (route) {
            return count++ == 2;
          },
        );
        // Get.offAll(Wallet());
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (c) => Wallet()), (r) => true);
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
    return Scaffold(
      body: executeRegularPayment(),
    );
  }
}
