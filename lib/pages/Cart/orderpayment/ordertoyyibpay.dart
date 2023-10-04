
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrderToyyibpay extends StatefulWidget {
  const OrderToyyibpay({Key? key}) : super(key: key);

  @override
  State<OrderToyyibpay> createState() => _OrderToyyibpayState();
}

class _OrderToyyibpayState extends State<OrderToyyibpay> {
  late WebViewController _webViewController;


  @override
  void initState() {
    super.initState();
    get();
  }
  String? url;
  String? billcode;
  String? successurl;
  String? failurl;
  String? transactionid;
  String? uriii;
  get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    url = prefs.getString(toyyibpayurl);
    billcode = prefs.getString(toyyibpaybillcode);
    successurl = prefs.getString(toyyibpaysuccessurl);
    failurl = prefs.getString(toyyibpayfailurl);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        zoomEnabled: true,
        initialUrl: url,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
          _loadUrl();
        },
        onPageStarted: (url) async {
          print("urllll == $url");
          transactionid = url.replaceAll("$successurl?status_id=1&billcode=","").replaceAll(billcode!,"").replaceAll("&order_id=&msg=ok&transaction_id=","");
          print("transactionid : $transactionid");
          uriii = url.replaceAll("?status_id=1&billcode=","").replaceAll(billcode!,"").replaceAll("&order_id=&msg=ok&transaction_id=","").replaceAll(transactionid.toString(),"");
          print("uriii : $uriii");
          if(uriii == successurl){
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString(toyyibpaytransctionid, transactionid.toString());
           Navigator.pop(context,true);
          }
          },
      ),
    );
  }

  _loadUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString(toyyibpayurl)!;
    print("toyyib pay url = $url");
    _webViewController.loadUrl(url);
  }
}
