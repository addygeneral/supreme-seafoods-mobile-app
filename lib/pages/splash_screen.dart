import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/pages/Onboarding/Onboarding.dart';

import '../Model/authentication/loginrequiredmodel.dart';

class splash_screen extends StatefulWidget {
  const splash_screen({Key? key}) : super(key: key);

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {

  int? initscreen;
  String? sessionid;

  @override
  void initState() {
    super.initState();
    login_required();
  }

  goup() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    initscreen = pref.getInt(init_Screen);
    await Future.delayed(Duration(seconds: 1));
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return initscreen == 0 || initscreen == null
            ? OnBoarding()
            : Homepage(0);
      },
    ));
  }

  login_required() async {
    loginrequiredmodel data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionid = (prefs.getString(UD_user_session_id) ?? "");
    var map = {

    };
    var response =
        await Dio().post(DefaultApi.appUrl + PostAPI.loginrequired, data: map);
    print(response);
     data = loginrequiredmodel.fromJson(response.data);
    if (data.status == 1) {
      if (sessionid == "" || sessionid == null) {
        prefs.setString(UD_user_session_id, data.sessionId.toString());
        print(data.sessionId.toString());
      }
      prefs.setString(UD_user_is_login_required, data.isLoginRequired.toString());
      print(data.isLoginRequired.toString());
      goup();
    }
    else{
      loader.showErroDialog(description: data.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
             "Assets/Icons/ic_logo.png",
              height: MediaQuery.of(context).size.height / 5,
              fit: BoxFit.fill,
            ),
          ),],
      ),
    );
  }
}
