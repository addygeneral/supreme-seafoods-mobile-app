import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Mercadopago extends StatefulWidget {
  const Mercadopago({Key? key}) : super(key: key);

  @override
  State<Mercadopago> createState() => _MercadopagoState();
}

class _MercadopagoState extends State<Mercadopago> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    get();
  }
  String? url;
  String? successurl;
  String? failurl;
  String? transactionid;
  get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    url = prefs.getString(mercadopayurl);
    successurl = prefs.getString(mercadopaysuccessurl);
    failurl = prefs.getString(mercadopayfailurl);
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
          if(url.contains(successurl!) == true){
            var inputstring = url.toString();
            inputstring = inputstring.substring(inputstring.indexOf("?") + 1 , inputstring.indexOf("&"));
            transactionid = inputstring.replaceAll("collection_id=","");
            print("transactionid : $transactionid");
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString(mercadopaytransctionid, transactionid.toString());
            Navigator.pop(context,true);
          }
        },
      ),
    );
  }

  _loadUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString(mercadopayurl)!;
    print("mercado pay url = $url");
    _webViewController.loadUrl(url);
  }
}
