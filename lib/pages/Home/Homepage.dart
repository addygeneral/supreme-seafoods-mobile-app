// ignore_for_file: file_names, camel_case_types, prefer_const_constructors, avoid_print, unrelated_type_equality_checks, use_key_in_widget_constructors, must_be_immutable, non_constant_identifier_names, prefer_collection_literals

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/main.dart';
import 'package:singlerestaurant/pages/Authentication/Login.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/height.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Orders/orderdetails.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import '../../Theme/ThemeModel.dart';
import '../Cart/cartpage.dart';
import '../Favorite/favoritepage.dart';
import '../Orders/orders.dart';
import '../Profile/profilepage.dart';
import 'homescreen.dart';

void showNotification() {
  flutterLocalNotificationsPlugin.show(
    0,
    "single",
    "single resuaurant ?",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id, channel.name,
        importance: Importance.high,
        // color: Colors.blue,
        playSound: true,
        icon: '@drawable/ic_notification',
        fullScreenIntent: true,
      ),
    ),
    payload: {
      "category_name": "1",
      "category_id": "2",
      "sub_type": "3",
      "item_id": "4",
      "type": "order",
      "order_id": "252"
    }.toString(),
  );
}

class cartcount extends GetxController {
  RxInt cartcountnumber = 0.obs;
}

class payloadsModel {
  dynamic categoryName;
  dynamic categoryId;
  dynamic subType;
  dynamic itemId;
  dynamic type;
  dynamic orderId;

  payloadsModel(
      {this.categoryName,
      this.categoryId,
      this.subType,
      this.itemId,
      this.type,
      this.orderId});

  payloadsModel.fromJson(Map<String, dynamic> json) {
    categoryName = json['category_name'];
    categoryId = json['category_id'];
    subType = json['sub_type'];
    itemId = json['item_id'];
    type = json['type'];
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['category_name'] = categoryName;
    data['category_id'] = categoryId;
    data['sub_type'] = subType;
    data['item_id'] = itemId;
    data['type'] = type;
    data['order_id'] = orderId;
    return data;
  }
}

class ClassName {
  ClassName({
    required this.id,
    required this.user,
  });

  String id;
  String user;

  ClassName.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        user = json['user'];
}

class Homepage extends StatefulWidget {
  int? count;
  Homepage(this.count);
  // const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // GlobalKey<FormState> homekey = GlobalKey<FormState>();

  late StreamSubscription subscription;
  int _selectedindex = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
  //
  //
  Future<dynamic> onSelectNotification(payload) async {
    String a = "{\"id\": \"24VQUCeGD4KnW6tvfhj8MJjuASk\", \"user\": \"user\"}";
    Map<String, dynamic> someData = jsonDecode(a);
    var className = ClassName.fromJson(someData);
    print(className.id);

    // String b =
    //     "{\"category_name\": \"1\" , \"category_id\": \"2\" , \"sub_type\": \"3\", \"item_id\": \"4\" , \"type\": \"order\",\"order_id\": \"252\"}";

    // print(313);
    // Map<String, dynamic> someData = jsonDecode(b);
    print("20");
    // var className = payloadsModel.fromJson(someData);
    print(jsonDecode(payload));
    payloadsModel? data;
    data = payloadsModel.fromJson(json.decode(payload));
    print(data);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Homepage(3),
        ),
      );
    }
  }

  Notificationss() async {
    FirebaseMessaging.instance;
    final largeIconPath = await Utils.downloadFile(
        'https://image.flaticon.com/icons/png/512/1277/1277314.png',
        'largeIcon');

    final bigPicturePath = await Utils.downloadFile(
        'https://www.simplyrecipes.com/thmb/8caxM88NgxZjz-T2aeRW3xjhzBg=/2000x1125/smart/filters:no_upscale()/__opt__aboutcom__coeus__resources__content_migration__simply_recipes__uploads__2019__09__easy-pepperoni-pizza-lead-3-8f256746d649404baa36a44d271329bc.jpg',
        'bigPicture');
    final styleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    var initializationsettingsAndroid =
        const AndroidInitializationSettings('@drawable/ic_notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationsettingsAndroid);
    FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        String action = jsonEncode(message.data);

        print("action $action");
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                icon: '@drawable/ic_notification',
                channel.id,
                channel.name,
                styleInformation: styleInformation,
              ),
              iOS: IOSNotificationDetails()),
          payload: jsonEncode(message.data.toString()),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          Get.to(() => Orderdetails("171"));
          loader.showErroDialog(description: "sfggfgdfdsd");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text(notification.title!),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body!),
                      ],
                    ),
                  ));
            },
          );
        }
      },
    );
  }

  String? userid;
  String? is_login;
  PageController pageController = PageController();
  int cardcount = 0;
  cartcount count = Get.put(cartcount());

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    is_login = prefs.getString(UD_user_is_login_required);
    setState(() {
      if (is_login == "1") {
        _selectedindex = widget.count!;
        userid = (prefs.getString(UD_user_id) ?? "");
        if (widget.count == 2 || widget.count == 3 || widget.count == 0) {
          pageController.animateToPage(
            widget.count!,
            duration: const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
        }
      }
    });
  }

  void onTapped(int index) {
    if (userid != "") {
      setState(() {
        _selectedindex = index;
        widget.count = index;
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 1),
          curve: Curves.ease,
        );
      });
    }
    // else if (index == 1) {
    //   print(0);
    //   if(is_login == "1"){
    //     if (userid == "") {
    //       print(1);
    //       Navigator.of(context).pushAndRemoveUntil(
    //           MaterialPageRoute(builder: (c) => Login()), (r) => false);
    //     }
    //   }
    //   else{
    //     Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(builder: (c) => Homepage(1)), (r) => false);
    //   }
    // }
    // else if (index == 2) {
    //   print(2);
    //   if (userid == "") {
    //     Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(builder: (c) => Login()), (r) => false);
    //   }
    // }
    // else if (index == 3) {
    //   print(3);
    //   if (userid == "") {
    //     Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(builder: (c) => Login()), (r) => false);
    //   }
    // }
    else {
      setState(() {
        _selectedindex = index;
        widget.count = index;
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 1),
          curve: Curves.ease,
        );
      });
    }
  }

  List pages = [
    Homescreen(),
    Favorite(),
    Viewcart(),
    Orderhistory(),
    Profilepage()
  ];

  @override
  void initState() {
    _selectedindex = widget.count!;
    super.initState();
    getdata();
    Notificationss();
  }

  @override
  Widget build(BuildContext context) {
    // connections().conect();
    return Consumer(builder: (context, ThemeModel themenofier, child) {
      return WillPopScope(
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
          body: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Homescreen(),
              if (is_login == "1" && userid != "" && userid != null) ...[
                Favorite()
              ],
              Viewcart(),
              if (is_login == "1" && userid != "" && userid != null) ...[
                Orderhistory()
              ],
              Profilepage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'Assets/Icons/Home.svg',
                  height: height.bottombaricon,
                  color: themenofier.isdark ? Colors.white : Colors.black,
                ),
                label: "",
                activeIcon: SvgPicture.asset(
                  'Assets/Icons/Homedark.svg',
                  height: height.bottombaricon,
                  color: themenofier.isdark ? Colors.white : Color(0xFFE82428),
                ),
              ),
              if (is_login == "1" && userid != "" && userid != null) ...[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'Assets/Icons/Favorite.svg',
                    height: height.bottombaricon,
                    color: themenofier.isdark ? Colors.white : Colors.black,
                  ),
                  label: "",
                  activeIcon: SvgPicture.asset(
                    'Assets/Icons/Favoritedark.svg',
                    height: height.bottombaricon,
                    color:
                        themenofier.isdark ? Colors.white : Color(0xFFE82428),
                  ),
                ),
              ],
              BottomNavigationBarItem(
                  icon: Obx(
                    () => count.cartcountnumber.value == 0
                        ? SvgPicture.asset(
                            'Assets/Icons/bx-shopping-bag.svg',
                            height: height.bottombaricon,
                            color: themenofier.isdark
                                ? Colors.white
                                : Colors.black,
                          )
                        : badges.Badge(
                            // alignment: Alignment.topCenter,
                            padding: EdgeInsets.all(5),
                            toAnimate: false,
                            elevation: 0,
                            badgeColor: Color(0xFFE82428),
                            badgeContent: Text(
                              count.cartcountnumber.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'Assets/Icons/bx-shopping-bag.svg',
                              height: height.bottombaricon,
                              color: themenofier.isdark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                  ),
                  label: "",
                  activeIcon: Obx(
                    () => count.cartcountnumber.value == 0
                        ? SvgPicture.asset(
                            'Assets/Icons/Cartdark.svg',
                            height: height.bottombaricon,
                            color: themenofier.isdark
                                ? Colors.white
                                : Color(0xFFE82428),
                          )
                        : badges.Badge(
                            padding: const EdgeInsets.all(5),
                            toAnimate: false,
                            elevation: 0,
                            badgeColor: Color(0xFFE82428),
                            badgeContent: Text(
                              count.cartcountnumber.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'Assets/Icons/Cartdark.svg',
                              height: height.bottombaricon,
                              color: themenofier.isdark
                                  ? Colors.white
                                  : Color(0xFFE82428),
                            ),
                          ),
                  )),
              if (is_login == "1" && userid != "" && userid != null) ...[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'Assets/Icons/Order.svg',
                    height: height.bottombaricon,
                    color: themenofier.isdark ? Colors.white : Colors.black,
                  ),
                  label: "",
                  activeIcon: SvgPicture.asset('Assets/Icons/Orderdark.svg',
                      height: height.bottombaricon,
                      color: themenofier.isdark
                          ? Colors.white
                          : Color(0xFFE82428)),
                ),
              ],
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'Assets/Icons/Profile.svg',
                  height: height.bottombaricon,
                  color: themenofier.isdark ? Colors.white : Colors.black,
                ),
                label: "",
                activeIcon: SvgPicture.asset(
                  'Assets/Icons/Profiledark.svg',
                  height: height.bottombaricon,
                  color: themenofier.isdark ? Colors.white : Color(0xFFE82428),
                ),
              ),
            ],
            currentIndex: _selectedindex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: themenofier.isdark ? Colors.black : Colors.white,
            onTap: onTapped,
            selectedFontSize: 1,
            unselectedFontSize: 1,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      );
    });
  }
}

class Utils {
  static Future<String> downloadFile(String url, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
