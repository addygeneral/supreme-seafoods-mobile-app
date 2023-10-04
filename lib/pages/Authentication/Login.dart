// ignore_for_file: file_names, use_build_context_synchronously, unused_field, prefer_final_fields, non_constant_identifier_names, unused_element,   prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:singlerestaurant/Widgets/test.dart';
import 'package:singlerestaurant/pages/Authentication/Otp.dart';
import 'package:singlerestaurant/Model/authentication/Loginmodel.dart';
import 'package:singlerestaurant/Model/authentication/signupmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:singlerestaurant/validation/validator.dart/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../config/API/API.dart';
import '../Home/Homepage.dart';
import 'Forgotpassword.dart';
import 'Signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    token();
  }

  String? Logintype = "";
  String? countrycode = "91";

  token() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Logintype = prefs.getString(APPCheck_addons);

      if (DefaultApi.environment == "sendbox") {
        email.value = TextEditingValue(text: "user@gmail.com");
        password.value = TextEditingValue(text: "123456");
      }
    });
    await FirebaseMessaging.instance.getToken().then((token) {
      if (kDebugMode) {
        print("token: ${token}");
      }
      Googletoken = token!;
      print("google token ${Googletoken}");
    });
  }

  GoogleSignInAccount? user;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  Map? userdata;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _obscureText = true;
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  final password = TextEditingController();
  Loginmodel? jsondata;
  Map<String, dynamic>? _userData;
  bool _loggedIn = true;
  String _name = "You're not logged in";
  AccessToken? _accessToken;
  String? Googletoken;

  _FBlogin() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      Map userdata = await FacebookAuth.instance.getUserData();

      print(userdata);

      _FBlogout();
      registerAPIforfb(userdata["email"], userdata["name"], userdata["id"]);
    } else {}
  }

  _FBlogout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
  }

  registerAPIforfb(email, name, id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loader.showLoading();
    var map = {};
    var response =
        await Dio().post(DefaultApi.appUrl + PostAPI.register, data: map);
    Signupmodel data = Signupmodel.fromJson(response.data);
    loader.hideLoading();
    if (data.status == 1) {
      prefs.setString(UD_user_id, data.data!.id.toString());
      prefs.setString(UD_user_name, data.data!.name.toString());
      prefs.setString(UD_user_mobile, data.data!.mobile.toString());
      prefs.setString(UD_user_email, data.data!.email.toString());
      prefs.setString(UD_user_profileimage, data.data!.profileImage.toString());
      prefs.setString(UD_user_logintype, data.data!.loginType.toString());
      Get.to(() => Homepage(0));
    } else if (data.status == 2) {
      Get.to(() => Signup(email, name, "facebook", id.toString()));
    } else if (data.status == 3) {
      Get.to(() => Otp(
            email,
            data.otp.toString(),
          ));
    } else {
      loader.showErroDialog(description: data.message);
    }
  }

  login() async {
    try {
      loader.showLoading();

      var map = Logintype == "mobile"
          ? {
              "mobile": "+${countrycode! + mobile.value.text}",
              "token": Googletoken,
            }
          : {
              "password": password.text.toString(),
              "email": email.text.toString(),
              "token": Googletoken
            };

      var response = await Dio().post(
        DefaultApi.appUrl + PostAPI.loginAPi,
        data: map,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.statusCode! > 300) {
        loader.showErroDialog(description: "Somthing went wrong");
      }
      // print(response.data);
      var finallist = await response.data;
      jsondata = Loginmodel.fromJson(finallist);

      loader.hideLoading();

      if (jsondata!.status == 1) {
        password.clear();
        email.clear();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(UD_user_id, jsondata!.data!.id.toString());
        prefs.setString(UD_user_name, jsondata!.data!.name.toString());
        prefs.setString(UD_user_mobile, jsondata!.data!.mobile.toString());
        prefs.setString(UD_user_email, jsondata!.data!.email.toString());
        prefs.setString(
            UD_user_logintype, jsondata!.data!.loginType.toString());
        prefs.setString(UD_user_wallet, jsondata!.data!.wallet.toString());
        prefs.setString(
            UD_user_isnotification, jsondata!.data!.isNotification.toString());
        prefs.setString(UD_user_ismail, jsondata!.data!.isMail.toString());
        prefs.setString(
            UD_user_refer_code, jsondata!.data!.referralCode.toString());
        prefs.setString(
            UD_user_profileimage, jsondata!.data!.profileImage.toString());

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Homepage(0)),
        );
      } else if (jsondata!.status == 2) {
        // password.clear();
        // email.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Otp(
                Logintype == "mobile"
                    ? "+${countrycode! + mobile.value.text}"
                    : email.text.toString(),
                jsondata!.otp.toString()),
          ),
        );
      } else {
        loader.showErroDialog(description: jsondata!.message);
      }

      return jsondata;
    } on DioError catch (e) {
      print(e);
      loader.showErroDialog(description: "server time  out");

      if (e.type == DioErrorType.connectTimeout) {
        loader.showErroDialog(description: "server time  out");
      }
      loader.hideLoading();

      // loader.showErroDialog(description: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          final value = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  'Supreme_Seafood'.tr,
                  style: TextStyle(
                      fontSize: 14.sp, fontFamily: 'Poppins_semibold'),
                ),
                content: Text(
                  'Are_you_sure_to_exit_from_this_app'.tr,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.primarycolor,
                    ),
                    child: Text(
                      'No'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.primarycolor,
                    ),
                    child: Text(
                      'Yes'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          if (value != null) {
            return Future.value(value);
          } else {
            return Future.value(false);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin:
                        EdgeInsets.only(left: 4.5.w, top: 3.5.h, bottom: 1.h),
                    child: Text(
                      'Login'.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 23.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins_Bold'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(
                      left: 4.5.w,
                    ),
                    child: Text(
                      'Signin_to_your_account'.tr,
                      // Signin_to_your_account,
                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                    ),
                  ),
                  if (Logintype == "mobile") ...[
                    Container(
                      margin: EdgeInsets.only(
                        top: 2.5.h,
                        bottom: 2.5.h,
                        left: 4.w,
                        right: 4.w,
                      ),
                      child: Center(
                        child: IntlPhoneField(
                          cursorColor: Colors.grey,
                          disableLengthCheck: true,
                          controller: mobile,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Phoneno'.tr,
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          initialCountryCode: 'US',
                          onCountryChanged: (value) {
                            countrycode = value.dialCode;
                          },
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      margin:
                          EdgeInsets.only(top: 2.5.h, left: 4.w, right: 4.w),
                      child: Center(
                        child: TextFormField(
                          validator: (value) => Logintype == "email"
                              ? Validators.validateEmail(value!)
                              : null,
                          cursorColor: Colors.grey,
                          controller: email,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: Email.tr,
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              )),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 2.5.h, left: 4.w, right: 4.w),
                      child: Center(
                        child: TextFormField(
                          validator: (value) =>
                              Validators.validatePassword(value!),
                          cursorColor: Colors.grey,
                          controller: password,
                          obscureText: _obscureText,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  )),
                              hintText: 'Password'.tr,
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              )),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(right: 4.w, top: 1.5.h),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Forgotpass()),
                          );
                        },
                        child: Text(
                          'Forgot_Password'.tr,
                          style: TextStyle(
                              fontFamily: 'Poppins_semiBold',
                              fontSize: 10.5.sp),
                        ),
                      ),
                    ),
                  ],
                  Container(
                    margin: EdgeInsets.only(
                      top: 2.h,
                      right: 4.w,
                      left: 4.w,
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFFE82428),
                        borderRadius: BorderRadius.circular(40)),
                    height: 6.5.h,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        // if (mobile.value.text.isEmpty) {
                        //   loader.showErroDialog(description: "enter");
                        // }

                        if (_formkey.currentState!.validate()) {
                          if (Logintype == "mobile") {
                            if (mobile.value.text.isEmpty) {
                              loader.showErroDialog(
                                  description: 'Please_enter_all_details'.tr);
                            } else {
                              login();
                            }
                          } else {
                            login();
                          }
                        }
                      },
                      child: Text(
                        'Sign in'.tr,
                        style: TextStyle(
                            fontFamily: 'Poppins_Bold',
                            color: Colors.white,
                            fontSize: 13.sp),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4.5.h),
                    child: Text('OR'.tr,
                        style: TextStyle(
                          fontFamily: 'Poppins_semiBold',
                          fontSize: 11.sp,
                        )),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                    top: 4.h,
                  )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 2.h,
                          right: 4.w,
                          left: 4.w,
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xFF5384EE),
                            borderRadius: BorderRadius.circular(40)),
                        child: InkWell(
                          borderRadius: BorderRadius.zero,
                          onTap: () async {
                            googlelogin();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // White background for the circular container
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(
                                    0.1), // Adjust padding as needed
                                child: Image.asset(
                                  'Assets/Icons/google.png',
                                  height: 6.h,
                                  width: 7.w, // Adjust width for a square image
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 2.h,
                          right: 4.w,
                          left: 4.w,
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xFF415792),
                            borderRadius: BorderRadius.circular(40)),
                        child: InkWell(
                          onTap: () async {
                            _FBlogin();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(0.1),
                                child: Image.asset(
                                  'Assets/Icons/facebook.png',
                                  height: 6.h,
                                  width: 7.w,
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Text(
                                'Continue with Facebook',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    child: Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 7.h),
                        child: Text(
                          'Dont_have_an_account'.tr,
                          style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 10.5.sp),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      child: Text(
                        'Signup'.tr,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins_semiBold',
                            fontSize: 12.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
              decoration: BoxDecoration(
                color: Color(0xFFE82428),
              ),
              height: 8.h,
              width: MediaQuery.of(context).size.width,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Homepage(0)),
                  );
                },
                child: Center(
                    child: Text(
                  'Skip_continue'.tr,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 13.sp),
                )),
              )),
        ),
      ),
    );
  }

  googlelogin() async {
    loader.showLoading();
    await _googleSignIn.signIn().then((value) {
      loader.hideLoading();
      _googleSignIn.signOut();
      registerAPI(value!);
    }).catchError((e) {
      print(e);
      // loader.showErroDialog();
    });
  }

  registerAPI(GoogleSignInAccount value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loader.showLoading();
    var map = {
      "name": value.displayName,
      "email": value.email,
      "mobile": "",
      "token": Googletoken,
      "google_id": value.id,
      "login_type": "google",
    };
    var response =
        await Dio().post(DefaultApi.appUrl + PostAPI.register, data: map);
    Signupmodel data = Signupmodel.fromJson(response.data);
    loader.hideLoading();
    if (data.status == 1) {
      prefs.setString(UD_user_id, data.data!.id.toString());
      prefs.setString(UD_user_name, data.data!.name.toString());
      prefs.setString(UD_user_mobile, data.data!.mobile.toString());
      prefs.setString(UD_user_email, data.data!.email.toString());
      prefs.setString(UD_user_profileimage, data.data!.profileImage.toString());
      prefs.setString(UD_user_logintype, data.data!.loginType.toString());
      Get.to(() => Homepage(0));
    } else if (data.status == 2) {
      Get.to(() => Signup(
          value.email, value.displayName, "google", value.id.toString()));
    } else if (data.status == 3) {
      Get.to(() => Otp(
            value.email,
            data.otp.toString(),
          ));
    } else {
      loader.showErroDialog(description: data.message);
    }
  }
}
