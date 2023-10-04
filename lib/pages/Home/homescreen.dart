// ignore_for_file: prefer_const_constructors, camel_case_types, non_constant_identifier_names,   unused_element, prefer_is_empty

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:singlerestaurant/pages/Authentication/Login.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/favoritepage/addtocartmodel.dart';
import 'package:singlerestaurant/Model/home/homescreenmodel.dart';
import 'package:singlerestaurant/Theme/ThemeModel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Cart/cartpage.dart';
import 'package:singlerestaurant/pages/Favorite/showvariation.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/pages/Home/categoriesinfo.dart';
import 'package:singlerestaurant/pages/Home/product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Profile/profilepage.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';
import '../../common class/icons.dart';
import 'package:badges/badges.dart' as badges;
import 'Categories.dart';
import 'Search.dart';
import 'Trendingfood.dart';
import 'package:get/get.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
  }

  String username = "";
  String userid = "";
  String? islogin;
  String session_id = "";
  String? currency;
  String? currency_position;
  String? profileimage;
  cartcount count = Get.put(cartcount());
  int? cart;

  homescreenmodel? homedata;
  addtocartmodel? addtocartdata;

  Future homescreenAPI() async {
    var map;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = (prefs.getString(UD_user_name) ?? "");
    userid = (prefs.getString(UD_user_id) ?? "");
    islogin = prefs.getString(UD_user_is_login_required);
    profileimage = (prefs.getString(UD_user_profileimage) ?? "");
    session_id = (prefs.getString(UD_user_session_id) ?? "");
    print("user" + userid);
    print("session" + session_id);
    try {
      if (userid != "") {
        map = {"user_id": userid};
      } else {
        map = {"session_id": session_id};
      }
      print(map);
      var response = await Dio().post(
        DefaultApi.appUrl + PostAPI.Home,
        data: map,
      );

      var finalist = await response.data;
      print(response);

      homedata = homescreenmodel.fromJson(finalist);
      print(homedata!.appdata!.maintenanceMode);
      if (homedata!.appdata!.maintenanceMode.toString() == "1") {
        dialogbox.showDialog(
          description: LocaleKeys
              .Sorry_for_the_inconvenience_but_we_are_performing_some_maintenanceatthemomentWewillbebackonlineshortly
              .tr,
        );
      }

      prefs.setString(UD_user_id, homedata!.getprofile!.id.toString());
      prefs.setString(UD_user_name, homedata!.getprofile!.name.toString());
      if (session_id == "") {
        prefs.setString(UD_user_session_id, homedata!.session_id.toString());
      }
      prefs.setString(UD_user_mobile, homedata!.getprofile!.mobile.toString());
      prefs.setString(UD_user_email, homedata!.getprofile!.email.toString());
      prefs.setString(
          UD_user_logintype, homedata!.getprofile!.loginType.toString());
      prefs.setString(UD_user_wallet, homedata!.getprofile!.wallet.toString());
      prefs.setString(UD_user_isnotification,
          homedata!.getprofile!.isNotification.toString());
      prefs.setString(UD_user_ismail, homedata!.getprofile!.isMail.toString());
      prefs.setString(
          UD_user_refer_code, homedata!.getprofile!.referralCode.toString());
      prefs.setString(
          UD_user_profileimage, homedata!.getprofile!.profileImage.toString());
      prefs.setString(APPcurrency, homedata!.appdata!.currency.toString());
      prefs.setString(
          APPcurrency_position, homedata!.appdata!.currencyPosition.toString());
      prefs.setString(APPcart_count, homedata!.cartdata!.totalCount.toString());
      prefs.setString(
          min_order_amount, homedata!.appdata!.minOrderAmount.toString());
      prefs.setString(
          max_order_amount, homedata!.appdata!.maxOrderAmount.toString());
      prefs.setString(restaurantlat, homedata!.appdata!.lat.toString());
      prefs.setString(restaurantlang, homedata!.appdata!.lang.toString());
      prefs.setString(
          deliverycharges, homedata!.appdata!.deliveryCharge.toString());
      prefs.setString(about_us, homedata!.appdata!.aboutContent.toString());
      prefs.setString(
          referral_amount, homedata!.appdata!.referralAmount.toString());
      prefs.setString(
          UD_user_logintype, homedata!.getprofile!.loginType.toString());
      prefs.setString(APPCheck_addons, homedata!.checkaddons.toString());
      prefs.setString(Androidlink, homedata!.appdata!.android.toString());
      prefs.setString(Ioslink, homedata!.appdata!.ios.toString());
      currency = (prefs.getString(APPcurrency) ?? "");
      currency_position = (prefs.getString(APPcurrency_position) ?? "");
      count.cartcountnumber(int.parse(prefs.getString(APPcart_count)!));
      return homedata;
    } catch (e) {
      print(e);
      loader.hideLoading();
      loader.showErroDialog(description: "Somthing went wrong!");
    }
  }

  addtocart(itemid, itemname, itemimage, itemtype, itemtax, itemprice) async {
    try {
      var map;
      loader.showLoading();
      if (userid == "" || userid == null) {
        map = {
          "session_id": session_id,
          "item_id": itemid,
          "item_name": itemname,
          "item_image": itemimage,
          "item_type": itemtype,
          "tax": itemtax,
          "item_price": numberFormat.format(double.parse(itemprice)),
          "variation_id": "",
          "variation": "",
          "addons_id": "",
          "addons_name": "",
          "addons_price": "",
          "addons_total_price": numberFormat.format(double.parse("0")),
        };
      } else {
        map = {
          "user_id": userid,
          "item_id": itemid,
          "item_name": itemname,
          "item_image": itemimage,
          "item_type": itemtype,
          "tax": itemtax,
          "item_price": numberFormat.format(double.parse(itemprice)),
          "variation_id": "",
          "variation": "",
          "addons_id": "",
          "addons_name": "",
          "addons_price": "",
          "addons_total_price": numberFormat.format(double.parse("0")),
        };
      }

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Addtocart, data: map);
      addtocartdata = addtocartmodel.fromJson(response.data);
      if (addtocartdata!.status == 1) {
        loader.hideLoading();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(APPcart_count, addtocartdata!.cartCount.toString());

        count.cartcountnumber(int.parse(prefs.getString(APPcart_count)!));
        setState(() {
          // FavoriteAPI();
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  managefavarite(var itemid, String isfavorite, index, String type) async {
    try {
      loader.showLoading();
      var map = {"user_id": userid, "item_id": itemid, "type": isfavorite};

      var favoriteresponse = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Managefavorite, data: map);
      var finaldata = QTYupdatemodel.fromJson(favoriteresponse.data);

      if (finaldata.status == 1) {
        loader.hideLoading();
        if (type == "trending") {
          setState(() {
            isfavorite == "favorite"
                ? homedata!.trendingitems![index].isFavorite = "1"
                : homedata!.trendingitems![index].isFavorite = "0";
            homedata!.trendingitems.reactive;
          });
        } else if (type == "todayspecial") {
          setState(() {
            isfavorite == "favorite"
                ? homedata!.todayspecial![index].isFavorite = "1"
                : homedata!.todayspecial![index].isFavorite = "0";
          });
        } else if (type == "recommendeditems") {
          isfavorite == "favorite"
              ? homedata!.recommendeditems![index].isFavorite = "1"
              : homedata!.recommendeditems![index].isFavorite = "0";
        }
      } else {
        loader.hideLoading();
        loader.showErroDialog(description: finaldata.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refresh() {
    return homescreenAPI().then((_) {
      return Future.delayed(Duration(seconds: 4));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      displacement: 80,
      color: Colors.red,
      child: Consumer(
        builder: (context, ThemeModel themenofier, child) {
          return SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: FutureBuilder(
                future: homescreenAPI(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (homedata!.appdata!.maintenanceMode.toString() == "1") {
                      return SizedBox();
                    } else {
                      return Scaffold(
                        drawer: const Drawer(
                          child: Center(
                            child: Profilepage(),
                          ),
                        ),
                        appBar: AppBar(
                          automaticallyImplyLeading: false,
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(builder: (context) {
                                return IconButton(
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  icon: const Icon(Icons.menu),
                                  iconSize: 35,
                                );
                              }),
                              Spacer(),
                              Builder(builder: (context) {
                                return IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          backgroundColor: Colors.white,
                                          body: Viewcart(),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Obx(
                                    () => count.cartcountnumber.value == 0
                                        ? SvgPicture.asset(
                                            'Assets/Icons/bx-shopping-bag.svg',
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
                                              count.cartcountnumber.value
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            child: SvgPicture.asset(
                                              'Assets/Icons/bx-shopping-bag.svg',
                                              color: themenofier.isdark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                              /* if (username != "") ...[
                                SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          profileimage.toString(),
                                          fit: BoxFit.cover,
                                        )))
                              ]*/
                            ],
                          ),
                        ),
                        body: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      top: 1.h,
                                      left: 4.w,
                                      right: 4.w,
                                      bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Color(0xFFECF1F6),
                                  ),
                                  height: 6.h,
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Search()),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 3.w,
                                          ),
                                          Icon(
                                            Icons.search,
                                            size: 18.sp,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(
                                            width: 2.w,
                                          ),
                                          Text(
                                            'SearchFood_Here'.tr,
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey,
                                                fontFamily: "Poppins"),
                                          )
                                        ],
                                      ))),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (username == "") ...[
                                    SizedBox(width: 8),
                                    Text(
                                      'Welcome'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 13.sp),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Supreme_Seafood'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 13.sp),
                                    ),
                                  ] else ...[
                                    SizedBox(width: 8),
                                    Text(
                                      'Hello'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 14.sp),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      username,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 14.sp),
                                    ),
                                    Text(
                                      '!',
                                      style: TextStyle(
                                        fontFamily: "Poppins_bold",
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              if (homedata!
                                  .banners!.topbanners!.isNotEmpty) ...[
                                SizedBox(
                                  height: 2.h,
                                ),
                                SizedBox(
                                  height: 24.h,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return CarouselSlider(
                                        items: homedata!.banners!.topbanners!
                                            .map((banner) {
                                          return Container(
                                            margin: EdgeInsets.only(
                                                left: 0.w, right: 0.w),
                                            width: 100.w,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (banner.type == "2") {
                                                  Get.to(() => Product(
                                                      int.parse(banner.itemId
                                                          .toString())));
                                                } else if (banner.type == "1") {
                                                  Get.to(() => categories_items(
                                                        banner.catId,
                                                        banner.categoryInfo!
                                                            .categoryName,
                                                      ));
                                                }
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: Image.network(
                                                  banner.image.toString(),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        options: CarouselOptions(
                                          aspectRatio: 2.0,
                                          autoPlay: true,
                                          enlargeCenterPage: true,
                                          viewportFraction: 0.9,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 2.5.h,
                                ),
                              ],
                              if (homedata!.categories!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 4.w,
                                      ),
                                    ),
                                    Text(
                                      'Categories'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Categoriespage(
                                                      homedata!.categories)),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 2.5.h,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        right: 1.w,
                                      ),
                                      height: 21.5.h,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: homedata!.categories!.length,
                                        itemBuilder: (context, index) =>
                                            GestureDetector(
                                          onTap: () {
                                            Get.to(
                                              () => categories_items(
                                                homedata!.categories![index].id,
                                                homedata!.categories![index]
                                                    .categoryName
                                                    .toString(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 50.w,
                                            margin: EdgeInsets.only(right: 0.w),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    bottom: 1.h,
                                                  ),
                                                  height: 17.5.h,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.network(
                                                      homedata!
                                                          .categories![index]
                                                          .image
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  homedata!.categories![index]
                                                      .categoryName
                                                      .toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "Poppins_medium",
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                  ],
                                ),
                              ],
                              if (homedata!.recommendeditems!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 4.w,
                                        top: 2.h,
                                      ),
                                    ),
                                    Text(
                                      'Recommended'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Trendingfood(
                                              "3",
                                              'Recommended'.tr,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 2.5.h,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 33.h,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      right: 8.w,
                                      bottom: 5.0,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        homedata!.recommendeditems!.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Product(
                                                  homedata!
                                                      .recommendeditems![index]
                                                      .id)),
                                        );
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            color: themenofier.isdark
                                                ? Color.fromARGB(
                                                    255, 184, 178, 178)
                                                : Color.fromARGB(
                                                    255, 255, 255, 255),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                    0.3), // Shadow color
                                                spreadRadius:
                                                    0, // Spread radius
                                                blurRadius: 5, // Blur radius
                                                offset: Offset(0,
                                                    2), // Offset of the shadow
                                              ),
                                            ],
                                          ),
                                          margin: EdgeInsets.only(
                                            top: 1.h,
                                            left: 3.5.w,
                                          ),
                                          height: 32.h,
                                          width: 45.w,
                                          child: Column(children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 20.h,
                                                  width: 46.w,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(
                                                                      5))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5)),
                                                    child: Image.network(
                                                      homedata!
                                                          .recommendeditems![
                                                              index]
                                                          .imageUrl
                                                          .toString(),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                if (islogin == "1") ...[
                                                  Positioned(
                                                      top: 5.0,
                                                      right: 5.0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (userid == "") {
                                                            Navigator.of(
                                                                    context)
                                                                .pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (c) =>
                                                                                Login()),
                                                                    (r) =>
                                                                        false);
                                                          } else if (homedata!
                                                                  .recommendeditems![
                                                                      index]
                                                                  .isFavorite ==
                                                              "0") {
                                                            managefavarite(
                                                                homedata!
                                                                    .recommendeditems![
                                                                        index]
                                                                    .id,
                                                                "favorite",
                                                                index,
                                                                "todayspecial");
                                                          } else if (homedata!
                                                                  .recommendeditems![
                                                                      index]
                                                                  .isFavorite ==
                                                              "1") {
                                                            managefavarite(
                                                                homedata!
                                                                    .recommendeditems![
                                                                        index]
                                                                    .id,
                                                                "unfavorite",
                                                                index,
                                                                "recommendeditems");
                                                          }
                                                        },
                                                        child: Container(
                                                            height: 4.h,
                                                            width: 8.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Color(
                                                                  0xFFE82428),
                                                            ),
                                                            child: Center(
                                                              child: homedata!
                                                                          .recommendeditems![
                                                                              index]
                                                                          .isFavorite ==
                                                                      "0"
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      'Assets/Icons/Favorite.svg',
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : SvgPicture
                                                                      .asset(
                                                                      'Assets/Icons/Favoritedark.svg',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            )),
                                                      )),
                                                ]
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.9.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          homedata!
                                                              .recommendeditems![
                                                                  index]
                                                              .categoryInfo!
                                                              .categoryName
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 8.sp,
                                                            fontFamily:
                                                                'Poppins',
                                                            color: Color(
                                                                0xFFE82428),
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .itemType ==
                                                          "1") ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .vegicon))
                                                      ] else ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .nonvegicon))
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.5.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          homedata!
                                                              .recommendeditems![
                                                                  index]
                                                              .itemName
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontFamily:
                                                                'Poppins_semibold',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 2.w,
                                                      right: 2.w,
                                                      top: 1.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (homedata!
                                                              .recommendeditems![
                                                                  index]
                                                              .hasVariation ==
                                                          "1") ...[
                                                        Expanded(
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.recommendeditems![index].variation![0].productPrice.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.recommendeditems![index].variation![0].productPrice.toString()))}$currency",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        Expanded(
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.recommendeditems![index].price.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.recommendeditems![index].price.toString()))}$currency",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      if (homedata!
                                                              .recommendeditems![
                                                                  index]
                                                              .isCart ==
                                                          "0") ...[
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (homedata!
                                                                        .recommendeditems![
                                                                            index]
                                                                        .hasVariation ==
                                                                    "1" ||
                                                                homedata!
                                                                    .recommendeditems![
                                                                        index]
                                                                    .addons!
                                                                    .isNotEmpty) {
                                                              cart = await Get.to(() =>
                                                                  showvariation(
                                                                      homedata!
                                                                              .recommendeditems![
                                                                          index]));
                                                              if (cart == 1) {
                                                                setState(() {
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .isCart = "1";
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .itemQty = int.parse(homedata!
                                                                          .recommendeditems![
                                                                              index]
                                                                          .itemQty!
                                                                          .toString()) +
                                                                      1;
                                                                });
                                                              }
                                                            } else {
                                                              // if (userid == "") {
                                                              //   Navigator.of(
                                                              //           context)
                                                              //       .pushAndRemoveUntil(
                                                              //           MaterialPageRoute(
                                                              //               builder: (c) =>
                                                              //                   Login()),
                                                              //           (r) =>
                                                              //               false);
                                                              // } else {
                                                              addtocart(
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .id,
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .itemName,
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .imageName,
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .itemType,
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .tax,
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .price);
                                                            }
                                                            // }
                                                          },
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFE82428),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xFFE82428))),
                                                              height: 3.5.h,
                                                              width: 17.w,
                                                              child: Center(
                                                                child: Text(
                                                                  'ADD'.tr,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontSize:
                                                                          9.5
                                                                              .sp,
                                                                      color: color
                                                                          .white),
                                                                ),
                                                              )),
                                                        ),
                                                      ] else if (homedata!
                                                              .recommendeditems![
                                                                  index]
                                                              .isCart ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.6.h,
                                                          width: 22.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE82428),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    loader
                                                                        .showErroDialog(
                                                                      description:
                                                                          'The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item'
                                                                              .tr,
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                child: Text(
                                                                  homedata!
                                                                      .recommendeditems![
                                                                          index]
                                                                      .itemQty!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: color
                                                                          .white,
                                                                      fontSize:
                                                                          10.sp),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    if (homedata!.recommendeditems![index].hasVariation ==
                                                                            "1" ||
                                                                        homedata!.recommendeditems![index].addons!.length >
                                                                            0) {
                                                                      cart = await Get.to(() =>
                                                                          showvariation(
                                                                              homedata!.recommendeditems![index]));
                                                                      if (cart ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          homedata!
                                                                              .recommendeditems![index]
                                                                              .itemQty = int.parse(homedata!.recommendeditems![index].itemQty!.toString()) + 1;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      addtocart(
                                                                          homedata!
                                                                              .recommendeditems![
                                                                                  index]
                                                                              .id,
                                                                          homedata!
                                                                              .recommendeditems![
                                                                                  index]
                                                                              .itemName,
                                                                          homedata!
                                                                              .recommendeditems![
                                                                                  index]
                                                                              .imageName,
                                                                          homedata!
                                                                              .recommendeditems![
                                                                                  index]
                                                                              .itemType,
                                                                          homedata!
                                                                              .recommendeditems![
                                                                                  index]
                                                                              .tax,
                                                                          homedata!
                                                                              .recommendeditems![index]
                                                                              .price);
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0.1.h,
                                                )
                                              ],
                                            )
                                          ])),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 2.5.h,
                                ),
                              ],
                              if (homedata!
                                  .banners!.bannersection1!.isNotEmpty) ...[
                                Container(
                                  margin: EdgeInsets.only(top: 1.h),
                                  height: 17.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!
                                        .banners!.bannersection1!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (homedata!
                                                  .banners!
                                                  .bannersection1![index]
                                                  .type ==
                                              "2") {
                                            Get.to(() => Product(int.parse(
                                                homedata!
                                                    .banners!
                                                    .bannersection1![index]
                                                    .itemId)));
                                          } else if (homedata!
                                                  .banners!
                                                  .bannersection1![index]
                                                  .type ==
                                              "1") {
                                            Get.to(() => categories_items(
                                                  homedata!
                                                      .banners!
                                                      .bannersection1![index]
                                                      .catId,
                                                  homedata!
                                                      .banners!
                                                      .bannersection1![index]
                                                      .categoryInfo!
                                                      .categoryName,
                                                ));
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal:
                                                  8.0), // Add margin for spacing
                                          width: 96.w,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                          0.3), // Shadow color
                                                  spreadRadius:
                                                      0, // Spread radius
                                                  blurRadius: 5, // Blur radius
                                                  offset: Offset(0,
                                                      2), // Offset of the shadow
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: Image.network(
                                                homedata!
                                                    .banners!
                                                    .bannersection1![index]
                                                    .image
                                                    .toString(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                              if (homedata!.trendingitems!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 4.w,
                                      ),
                                    ),
                                    Text(
                                      'Orderagain'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Categoriespage(
                                                      homedata!.categories)),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 2.5.h,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 33.h,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      right: 3.w,
                                      bottom: 5.0,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!.trendingitems!.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Product(
                                                  homedata!
                                                      .trendingitems![index]
                                                      .id)),
                                        );
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: themenofier.isdark
                                                  ? Color.fromARGB(
                                                      255, 184, 178, 178)
                                                  : Color.fromARGB(
                                                      255, 255, 255, 255),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                          0.3), // Shadow color
                                                  spreadRadius:
                                                      0, // Spread radius
                                                  blurRadius: 5, // Blur radius
                                                  offset: Offset(0,
                                                      2), // Offset of the shadow
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              border: Border.all(
                                                  width: 0.2.sp,
                                                  color: Colors.grey)),
                                          margin: EdgeInsets.only(
                                            top: 1.h,
                                            left: 3.5.w,
                                          ),
                                          height: 32.h,
                                          width: 45.w,
                                          child: Column(children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 20.h,
                                                  width: 46.w,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(
                                                                      5))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      topRight:
                                                          Radius.circular(5),
                                                    ),
                                                    child: Image.network(
                                                      homedata!
                                                          .trendingitems![index]
                                                          .imageUrl
                                                          .toString(),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                if (islogin == "1") ...[
                                                  Positioned(
                                                    top: 5.0,
                                                    right: 5.0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (userid == "") {
                                                          Navigator.of(context)
                                                              .pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (c) =>
                                                                              Login()),
                                                                  (r) => false);
                                                        } else if (homedata!
                                                                .trendingitems![
                                                                    index]
                                                                .isFavorite ==
                                                            "0") {
                                                          managefavarite(
                                                              homedata!
                                                                  .trendingitems![
                                                                      index]
                                                                  .id,
                                                              "favorite",
                                                              index,
                                                              "trending");
                                                        } else if (homedata!
                                                                .trendingitems![
                                                                    index]
                                                                .isFavorite ==
                                                            "1") {
                                                          managefavarite(
                                                              homedata!
                                                                  .trendingitems![
                                                                      index]
                                                                  .id,
                                                              "unfavorite",
                                                              index,
                                                              "trending");
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 4.h,
                                                        width: 8.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color:
                                                              Color(0xFFE82428),
                                                        ),
                                                        child: Center(
                                                          child: homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .isFavorite ==
                                                                  "0"
                                                              ? SvgPicture
                                                                  .asset(
                                                                  'Assets/Icons/Favorite.svg',
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : SvgPicture
                                                                  .asset(
                                                                  'Assets/Icons/Favoritedark.svg',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.9.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        homedata!
                                                            .trendingitems![
                                                                index]
                                                            .categoryInfo!
                                                            .categoryName
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          fontFamily: 'Poppins',
                                                          color:
                                                              Color(0xFFE82428),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .itemType ==
                                                          "1") ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .vegicon))
                                                      ] else ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .nonvegicon))
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.5.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .itemName
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontFamily:
                                                                'Poppins_semibold',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 2.w,
                                                      right: 2.w,
                                                      top: 1.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .hasVariation ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.trendingitems![index].variation![0].productPrice.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.trendingitems![index].variation![0].productPrice.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.trendingitems![index].price.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.trendingitems![index].price.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                      //////
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .isCart ==
                                                          "0") ...[
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (homedata!
                                                                        .trendingitems![
                                                                            index]
                                                                        .hasVariation ==
                                                                    "1" ||
                                                                homedata!
                                                                    .trendingitems![
                                                                        index]
                                                                    .addons!
                                                                    .isNotEmpty) {
                                                              cart = await Get.to(() =>
                                                                  showvariation(
                                                                      homedata!
                                                                              .trendingitems![
                                                                          index]));
                                                              if (cart == 1) {
                                                                setState(() {
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .isCart = "1";
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemQty = int.parse(homedata!
                                                                          .trendingitems![
                                                                              index]
                                                                          .itemQty!
                                                                          .toString()) +
                                                                      1;
                                                                });
                                                              }
                                                            } else {
                                                              // if (userid == "") {
                                                              //   Navigator.of(
                                                              //           context)
                                                              //       .pushAndRemoveUntil(
                                                              //           MaterialPageRoute(
                                                              //               builder: (c) =>
                                                              //                   Login()),
                                                              //           (r) =>
                                                              //               false);
                                                              // } else {
                                                              addtocart(
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .id,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemName,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .imageName,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemType,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .tax,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .price);
                                                              //   }
                                                            }
                                                          },
                                                          child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xFFE82428),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              height: 3.5.h,
                                                              width: 17.w,
                                                              child: Center(
                                                                child: Text(
                                                                  'ADD'.tr,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins_medium',
                                                                      fontSize:
                                                                          9.5
                                                                              .sp,
                                                                      color: color
                                                                          .white),
                                                                ),
                                                              )),
                                                        ),
                                                      ] else if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .isCart ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.6.h,
                                                          width: 22.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE82428),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    loader
                                                                        .showErroDialog(
                                                                      description:
                                                                          'The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item'
                                                                              .tr,
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                child: Text(
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemQty!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: color
                                                                          .white,
                                                                      fontSize:
                                                                          10.sp),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (homedata!.trendingitems![index].hasVariation ==
                                                                            "1" ||
                                                                        homedata!.trendingitems![index].addons!.length >
                                                                            0) {
                                                                      cart = await Navigator.of(
                                                                              context)
                                                                          .push(
                                                                              MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                showvariation(homedata!.trendingitems![index]),
                                                                      ));

                                                                      if (cart ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          homedata!
                                                                              .trendingitems![index]
                                                                              .itemQty = int.parse(homedata!.trendingitems![index].itemQty) + 1;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      addtocart(
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .id,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .itemName,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .imageName,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .itemType,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .tax,
                                                                          homedata!
                                                                              .trendingitems![index]
                                                                              .price);
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0.2.h,
                                                )
                                              ],
                                            )
                                          ])),
                                    ),
                                  ),
                                ),
                              ],
                              if (homedata!.trendingitems!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 4.w,
                                        top: 2.h,
                                      ),
                                    ),
                                    Text(
                                      'Trending'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Trendingfood(
                                              "2",
                                              'Trending'.tr,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 2.5.h,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 33.h,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      right: 3.w,
                                      bottom: 5.0,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!.trendingitems!.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Product(
                                                  homedata!
                                                      .trendingitems![index]
                                                      .id)),
                                        );
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: themenofier.isdark
                                                  ? Color.fromARGB(
                                                      255, 184, 178, 178)
                                                  : Color.fromARGB(
                                                      255, 255, 255, 255),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                          0.3), // Shadow color
                                                  spreadRadius:
                                                      0, // Spread radius
                                                  blurRadius: 5, // Blur radius
                                                  offset: Offset(0,
                                                      2), // Offset of the shadow
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              border: Border.all(
                                                  width: 0.sp,
                                                  color: Colors.grey)),
                                          margin: EdgeInsets.only(
                                            top: 1.h,
                                            left: 3.5.w,
                                          ),
                                          height: 32.h,
                                          width: 45.w,
                                          child: Column(children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 20.h,
                                                  width: 46.w,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(
                                                                      5))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      topRight:
                                                          Radius.circular(5),
                                                    ),
                                                    child: Image.network(
                                                      homedata!
                                                          .trendingitems![index]
                                                          .imageUrl
                                                          .toString(),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                if (islogin == "1") ...[
                                                  Positioned(
                                                    top: 5.0,
                                                    right: 5.0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (userid == "") {
                                                          Navigator.of(context)
                                                              .pushAndRemoveUntil(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (c) =>
                                                                              Login()),
                                                                  (r) => false);
                                                        } else if (homedata!
                                                                .trendingitems![
                                                                    index]
                                                                .isFavorite ==
                                                            "0") {
                                                          managefavarite(
                                                              homedata!
                                                                  .trendingitems![
                                                                      index]
                                                                  .id,
                                                              "favorite",
                                                              index,
                                                              "trending");
                                                        } else if (homedata!
                                                                .trendingitems![
                                                                    index]
                                                                .isFavorite ==
                                                            "1") {
                                                          managefavarite(
                                                              homedata!
                                                                  .trendingitems![
                                                                      index]
                                                                  .id,
                                                              "unfavorite",
                                                              index,
                                                              "trending");
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 4.h,
                                                        width: 8.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color:
                                                              Color(0xFFE82428),
                                                        ),
                                                        child: Center(
                                                          child: homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .isFavorite ==
                                                                  "0"
                                                              ? SvgPicture
                                                                  .asset(
                                                                  'Assets/Icons/Favorite.svg',
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : SvgPicture
                                                                  .asset(
                                                                  'Assets/Icons/Favoritedark.svg',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.9.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        homedata!
                                                            .trendingitems![
                                                                index]
                                                            .categoryInfo!
                                                            .categoryName
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          fontFamily: 'Poppins',
                                                          color:
                                                              Color(0xFFE82428),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .itemType ==
                                                          "1") ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .vegicon))
                                                      ] else ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .nonvegicon))
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.5.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .itemName
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontFamily:
                                                                'Poppins_semibold',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 2.w,
                                                      right: 2.w,
                                                      top: 1.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .hasVariation ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.trendingitems![index].variation![0].productPrice.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.trendingitems![index].variation![0].productPrice.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.trendingitems![index].price.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.trendingitems![index].price.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                      //////
                                                      if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .isCart ==
                                                          "0") ...[
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (homedata!
                                                                        .trendingitems![
                                                                            index]
                                                                        .hasVariation ==
                                                                    "1" ||
                                                                homedata!
                                                                    .trendingitems![
                                                                        index]
                                                                    .addons!
                                                                    .isNotEmpty) {
                                                              cart = await Get.to(() =>
                                                                  showvariation(
                                                                      homedata!
                                                                              .trendingitems![
                                                                          index]));
                                                              if (cart == 1) {
                                                                setState(() {
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .isCart = "1";
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemQty = int.parse(homedata!
                                                                          .trendingitems![
                                                                              index]
                                                                          .itemQty!
                                                                          .toString()) +
                                                                      1;
                                                                });
                                                              }
                                                            } else {
                                                              // if (userid == "") {
                                                              //   Navigator.of(
                                                              //           context)
                                                              //       .pushAndRemoveUntil(
                                                              //           MaterialPageRoute(
                                                              //               builder: (c) =>
                                                              //                   Login()),
                                                              //           (r) =>
                                                              //               false);
                                                              // } else {
                                                              addtocart(
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .id,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemName,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .imageName,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemType,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .tax,
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .price);
                                                              //   }
                                                            }
                                                          },
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFE82428),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xFFE82428))),
                                                              height: 3.5.h,
                                                              width: 17.w,
                                                              child: Center(
                                                                child: Text(
                                                                  'ADD'.tr,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins_medium',
                                                                      fontSize:
                                                                          9.5
                                                                              .sp,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          253,
                                                                          253)),
                                                                ),
                                                              )),
                                                        ),
                                                      ] else if (homedata!
                                                              .trendingitems![
                                                                  index]
                                                              .isCart ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.6.h,
                                                          width: 22.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE82428),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    loader
                                                                        .showErroDialog(
                                                                      description:
                                                                          'The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item'
                                                                              .tr,
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                child: Text(
                                                                  homedata!
                                                                      .trendingitems![
                                                                          index]
                                                                      .itemQty!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: color
                                                                          .white,
                                                                      fontSize:
                                                                          10.sp),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    if (homedata!.trendingitems![index].hasVariation ==
                                                                            "1" ||
                                                                        homedata!.trendingitems![index].addons!.length >
                                                                            0) {
                                                                      cart = await Navigator.of(
                                                                              context)
                                                                          .push(
                                                                              MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                showvariation(homedata!.trendingitems![index]),
                                                                      ));

                                                                      if (cart ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          homedata!
                                                                              .trendingitems![index]
                                                                              .itemQty = int.parse(homedata!.trendingitems![index].itemQty) + 1;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      addtocart(
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .id,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .itemName,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .imageName,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .itemType,
                                                                          homedata!
                                                                              .trendingitems![
                                                                                  index]
                                                                              .tax,
                                                                          homedata!
                                                                              .trendingitems![index]
                                                                              .price);
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: color
                                                                        .white,
                                                                    size: 16,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0.2.h,
                                                )
                                              ],
                                            )
                                          ])),
                                    ),
                                  ),
                                ),
                              ],
                              if (homedata!.todayspecial!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 4.w,
                                        top: 2.h,
                                      ),
                                    ),
                                    Text(
                                      'Todays_special'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Trendingfood(
                                              "1",
                                              'Todays_special'.tr,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 2.5.h,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 33.h,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      right: 3.w,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!.todayspecial!.length,
                                    itemBuilder: (context, index) =>
                                        GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Product(
                                                  homedata!.todayspecial![index]
                                                      .id)),
                                        );
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFE82428),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              border: Border.all(
                                                  width: 0.8.sp,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255))),
                                          margin: EdgeInsets.only(
                                            top: 1.h,
                                            left: 3.5.w,
                                          ),
                                          height: 32.h,
                                          width: 45.w,
                                          child: Column(children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 20.h,
                                                  width: 46.w,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topLeft: Radius
                                                                  .circular(5),
                                                              topRight: Radius
                                                                  .circular(
                                                                      5))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5)),
                                                    child: Image.network(
                                                      homedata!
                                                          .todayspecial![index]
                                                          .imageUrl
                                                          .toString(),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                if (islogin == "1") ...[
                                                  Positioned(
                                                      top: 5.0,
                                                      right: 5.0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (userid == "") {
                                                            Navigator.of(
                                                                    context)
                                                                .pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (c) =>
                                                                                Login()),
                                                                    (r) =>
                                                                        false);
                                                          } else if (homedata!
                                                                  .todayspecial![
                                                                      index]
                                                                  .isFavorite ==
                                                              "0") {
                                                            managefavarite(
                                                                homedata!
                                                                    .todayspecial![
                                                                        index]
                                                                    .id,
                                                                "favorite",
                                                                index,
                                                                "todayspecial");
                                                          } else if (homedata!
                                                                  .todayspecial![
                                                                      index]
                                                                  .isFavorite ==
                                                              "1") {
                                                            managefavarite(
                                                                homedata!
                                                                    .todayspecial![
                                                                        index]
                                                                    .id,
                                                                "unfavorite",
                                                                index,
                                                                "todayspecial");
                                                          }
                                                        },
                                                        child: Container(
                                                            height: 4.h,
                                                            width: 8.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1),
                                                              color: Color(
                                                                  0xFFE82428),
                                                            ),
                                                            child: Center(
                                                              child: homedata!
                                                                          .todayspecial![
                                                                              index]
                                                                          .isFavorite ==
                                                                      "0"
                                                                  ? SvgPicture
                                                                      .asset(
                                                                      'Assets/Icons/Favorite.svg',
                                                                      color: Colors
                                                                          .white,
                                                                    )
                                                                  : SvgPicture
                                                                      .asset(
                                                                      'Assets/Icons/Favoritedark.svg',
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                            )),
                                                      )),
                                                ]
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.9.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        homedata!
                                                            .todayspecial![
                                                                index]
                                                            .categoryInfo!
                                                            .categoryName
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 8.sp,
                                                          fontFamily: 'Poppins',
                                                          color: Color.fromARGB(
                                                              255,
                                                              253,
                                                              251,
                                                              251),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      if (homedata!
                                                              .todayspecial![
                                                                  index]
                                                              .itemType ==
                                                          "1") ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .vegicon))
                                                      ] else ...[
                                                        SizedBox(
                                                            height: 2.h,
                                                            child: Image.asset(
                                                                Defaulticon
                                                                    .nonvegicon))
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 2.w,
                                                    right: 2.w,
                                                    top: 0.5.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          homedata!
                                                              .todayspecial![
                                                                  index]
                                                              .itemName
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontFamily:
                                                                'Poppins_semibold',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 2.w,
                                                      right: 2.w,
                                                      top: 1.h),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (homedata!
                                                              .todayspecial![
                                                                  index]
                                                              .hasVariation ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.todayspecial![index].variation![0].productPrice.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.todayspecial![index].variation![0].productPrice.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        Container(
                                                          height: 3.h,
                                                          width: 18.w,
                                                          child: Text(
                                                            currency_position ==
                                                                    "1"
                                                                ? "$currency${numberFormat.format(double.parse(homedata!.todayspecial![index].price.toString()))}"
                                                                : "${numberFormat.format(double.parse(homedata!.todayspecial![index].price.toString()))}$currency",
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontFamily:
                                                                  'Poppins_bold',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                      if (homedata!
                                                              .todayspecial![
                                                                  index]
                                                              .isCart ==
                                                          "0") ...[
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (homedata!
                                                                        .todayspecial![
                                                                            index]
                                                                        .hasVariation ==
                                                                    "1" ||
                                                                homedata!
                                                                    .todayspecial![
                                                                        index]
                                                                    .addons!
                                                                    .isNotEmpty) {
                                                              cart = await Get.to(() =>
                                                                  showvariation(
                                                                      homedata!
                                                                              .todayspecial![
                                                                          index]));
                                                              if (cart == 1) {
                                                                setState(() {
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .isCart = "1";
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .itemQty = int.parse(homedata!
                                                                          .todayspecial![
                                                                              index]
                                                                          .itemQty!
                                                                          .toString()) +
                                                                      1;
                                                                });
                                                              }
                                                            } else {
                                                              // if (userid == "") {
                                                              //   Navigator.of(
                                                              //           context)
                                                              //       .pushAndRemoveUntil(
                                                              //           MaterialPageRoute(
                                                              //               builder: (c) =>
                                                              //                   Login()),
                                                              //           (r) =>
                                                              //               false);
                                                              // } else {
                                                              addtocart(
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .id,
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .itemName,
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .imageName,
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .itemType,
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .tax,
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .price);
                                                              // }
                                                            }
                                                          },
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFE82428),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  border: Border.all(
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255))),
                                                              height: 3.5.h,
                                                              width: 17.w,
                                                              child: Center(
                                                                child: Text(
                                                                  'ADD'.tr,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins',
                                                                      fontSize:
                                                                          9.5
                                                                              .sp,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255)),
                                                                ),
                                                              )),
                                                        ),
                                                      ] else if (homedata!
                                                              .todayspecial![
                                                                  index]
                                                              .isCart ==
                                                          "1") ...[
                                                        Container(
                                                          height: 3.6.h,
                                                          width: 22.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    loader
                                                                        .showErroDialog(
                                                                      description:
                                                                          'The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item'
                                                                              .tr,
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Color(
                                                                        0xFFE82428),
                                                                    size: 16,
                                                                  )),
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                child: Text(
                                                                  homedata!
                                                                      .todayspecial![
                                                                          index]
                                                                      .itemQty!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10.sp),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    if (homedata!.todayspecial![index].hasVariation ==
                                                                            "1" ||
                                                                        homedata!.todayspecial![index].addons!.length >
                                                                            0) {
                                                                      cart = await Get.to(() =>
                                                                          showvariation(
                                                                              homedata!.todayspecial![index]));
                                                                      if (cart ==
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          homedata!
                                                                              .todayspecial![index]
                                                                              .itemQty = int.parse(homedata!.todayspecial![index].itemQty!.toString()) + 1;
                                                                        });
                                                                      }
                                                                    } else {
                                                                      addtocart(
                                                                          homedata!
                                                                              .todayspecial![
                                                                                  index]
                                                                              .id,
                                                                          homedata!
                                                                              .todayspecial![
                                                                                  index]
                                                                              .itemName,
                                                                          homedata!
                                                                              .todayspecial![
                                                                                  index]
                                                                              .imageName,
                                                                          homedata!
                                                                              .todayspecial![
                                                                                  index]
                                                                              .itemType,
                                                                          homedata!
                                                                              .todayspecial![
                                                                                  index]
                                                                              .tax,
                                                                          homedata!
                                                                              .todayspecial![index]
                                                                              .price);
                                                                      // addtocart(
                                                                      //     index,
                                                                      //     "trending");
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: Color(
                                                                        0xFFE82428),
                                                                    size: 16,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0.2.h,
                                                )
                                              ],
                                            )
                                          ])),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 2.5.h,
                                ),
                              ],
                              /*if (homedata!
                                  .banners!.bannersection2!.isNotEmpty) ...[
                                SizedBox(
                                  height: 25.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!
                                        .banners!.bannersection2!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (homedata!
                                                  .banners!
                                                  .bannersection2![index]
                                                  .type ==
                                              "2") {
                                            Get.to(() => Product(homedata!
                                                .banners!
                                                .bannersection2![index]
                                                .itemId));
                                          } else if (homedata!
                                                  .banners!
                                                  .bannersection2![index]
                                                  .type ==
                                              "1") {
                                            Get.to(() => categories_items(
                                                  homedata!
                                                      .banners!
                                                      .bannersection2![index]
                                                      .catId,
                                                  homedata!
                                                      .banners!
                                                      .bannersection2![index]
                                                      .categoryInfo!
                                                      .categoryName,
                                                ));
                                          }
                                        },
                                        child: Container(
                                            padding: EdgeInsets.only(
                                              left: 2.w,
                                              right: 2.w,
                                            ),
                                            width: 60.w,
                                            height: 60.w,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: Image.network(
                                                homedata!
                                                    .banners!
                                                    .bannersection2![index]
                                                    .image
                                                    .toString(),
                                                fit: BoxFit.fill,
                                              ),
                                            )),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              */
                              if (homedata!
                                  .banners!.bannersection3!.isNotEmpty) ...[
                                Container(
                                  margin:
                                      EdgeInsets.only(bottom: 2.h, top: 3.h),
                                  height: 15.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: homedata!
                                        .banners!.bannersection3!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (homedata!
                                                  .banners!
                                                  .bannersection3![index]
                                                  .type ==
                                              "2") {
                                            Get.to(() => Product(int.parse(
                                                homedata!
                                                    .banners!
                                                    .bannersection3![index]
                                                    .itemId)));
                                          } else if (homedata!
                                                  .banners!
                                                  .bannersection3![index]
                                                  .type ==
                                              "1") {
                                            Get.to(() => categories_items(
                                                  homedata!
                                                      .banners!
                                                      .bannersection3![index]
                                                      .catId,
                                                  homedata!
                                                      .banners!
                                                      .bannersection3![index]
                                                      .categoryInfo!
                                                      .categoryName,
                                                ));
                                          }
                                        },
                                        child: Container(
                                            padding: EdgeInsets.only(
                                              left: 2.w,
                                              right: 2.w,
                                            ),
                                            width: 100.w,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: Image.network(
                                                homedata!
                                                    .banners!
                                                    .bannersection3![index]
                                                    .image
                                                    .toString(),
                                                fit: BoxFit.fill,
                                              ),
                                            )),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              if (homedata!.testimonials!.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 2.5.h, left: 4.w),
                                    ),
                                    Text(
                                      'Testimonials'.tr,
                                      style: TextStyle(
                                          fontFamily: "Poppins_bold",
                                          fontSize: 15.sp),
                                    ),
                                  ],
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                      top: 2.h,
                                      // bottom: 20,
                                      left: 4.w,
                                      right: 4.w,
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 3.h,
                                      bottom: 1.5.h,
                                      left: 2.5.w,
                                      right: 2.5.w,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xFFE82428),
                                    ),
                                    child: CarouselSlider.builder(
                                        itemCount:
                                            homedata!.testimonials!.length,
                                        itemBuilder:
                                            (context, index, realIndex) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    homedata!
                                                        .testimonials![index]
                                                        .profileImage
                                                        .toString()),
                                              ),
                                              SizedBox(
                                                height: 0.8.h,
                                              ),
                                              Text(
                                                  homedata!
                                                      .testimonials![index].name
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: "Poppins")),
                                              SizedBox(
                                                height: 1.5.h,
                                              ),
                                              if (homedata!.testimonials![index]
                                                      .ratting ==
                                                  "1") ...[
                                                SizedBox(
                                                  child: Image.asset(
                                                    "Assets/Image/ratting1.png",
                                                    color: Colors.white,
                                                    width: 25.w,
                                                  ),
                                                )
                                              ] else if (homedata!
                                                      .testimonials![index]
                                                      .ratting ==
                                                  "2") ...[
                                                Image.asset(
                                                  "Assets/Image/ratting2.png",
                                                  color: Colors.white,
                                                  width: 25.w,
                                                )
                                              ] else if (homedata!
                                                      .testimonials![index]
                                                      .ratting ==
                                                  "3") ...[
                                                Image.asset(
                                                  "Assets/Image/ratting3.png",
                                                  color: Colors.white,
                                                  width: 25.w,
                                                )
                                              ] else if (homedata!
                                                      .testimonials![index]
                                                      .ratting ==
                                                  "4") ...[
                                                Image.asset(
                                                  "Assets/Image/ratting4.png",
                                                  color: Colors.white,
                                                  width: 25.w,
                                                )
                                              ] else if (homedata!
                                                      .testimonials![index]
                                                      .ratting ==
                                                  "5") ...[
                                                Image.asset(
                                                  "Assets/Image/ratting5.png",
                                                  color: Colors.white,
                                                  width: 25.w,
                                                )
                                              ],
                                              SizedBox(
                                                height: 1.5.h,
                                              ),
                                              Text(
                                                "${homedata!.testimonials![index].ratting.toString()} / 5.0 Reviews",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9.sp,
                                                    fontFamily: "Poppins"),
                                              ),
                                              SizedBox(
                                                height: 1.5.h,
                                              ),
                                              Text(
                                                homedata!.testimonials![index]
                                                    .comment
                                                    .toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily: "Poppins"),
                                              ),
                                            ],
                                          );
                                        },
                                        options: CarouselOptions(
                                          enableInfiniteScroll: true,
                                          disableCenter: true,
                                          viewportFraction: 1,
                                        ))),
                                SizedBox(height: 3.h),
                              ],
                              if (homedata!.appdata!.isAppBottomImage
                                      .toString() ==
                                  "1") ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: Image.network(
                                    homedata!.appdata!.appBottomImageUrl
                                        .toString(),
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: color.primarycolor,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
