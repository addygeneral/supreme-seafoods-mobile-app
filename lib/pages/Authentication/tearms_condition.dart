// ignore_for_file: camel_case_types

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:singlerestaurant/Model/settings%20model/privacymodel.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class teamscondition extends StatefulWidget {
  const teamscondition({Key? key}) : super(key: key);

  @override
  State<teamscondition> createState() => _teamsconditionState();
}

class _teamsconditionState extends State<teamscondition> {
  cmsMODEL? data;
  String? htmlcode;

  teamsAPI() async {
    try {
      var response = await Dio().get(DefaultApi.appUrl + GetAPI.cmspages);
      data = cmsMODEL.fromJson(response.data);
      htmlcode = data!.termscondition;

      return data;
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
          'TeamsConditions'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: teamsAPI(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: color.primarycolor),
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
          }),
    ));
  }

  _loadHtmlFromAssets() async {
    _controller.loadUrl(Uri.dataFromString(htmlcode!,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  late WebViewController _controller;
}
