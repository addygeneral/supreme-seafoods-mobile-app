// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:singlerestaurant/Model/settings%20model/privacymodel.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Privacypolicy extends StatefulWidget {
  const Privacypolicy({Key? key}) : super(key: key);

  @override
  State<Privacypolicy> createState() => _PrivacypolicyState();
}

class _PrivacypolicyState extends State<Privacypolicy> {
  String privacycode = "";
  cmsMODEL? privacydata;
  PrivacyAPI() async {
    var response = await Dio().get(DefaultApi.appUrl + GetAPI.cmspages);
    privacydata = cmsMODEL.fromJson(response.data);
    privacycode = privacydata!.privacypolicy!;
    return cmsMODEL;
  }

  late WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            )),
        title: Text(
          'Privacy_Policy'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: PrivacyAPI(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: color.primarycolor,
              ),
            );
          }
          return WebView(
            javascriptMode: JavascriptMode.unrestricted,
            zoomEnabled: true,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          );
        },
      ),
    ));
  }

  _loadHtmlFromAssets() async {
    _controller.loadUrl(Uri.dataFromString(privacycode,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
