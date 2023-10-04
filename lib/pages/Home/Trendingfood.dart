// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors, non_constant_identifier_names, must_be_immutable,   prefer_is_empty

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Authentication/Login.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/favoritepage/addtocartmodel.dart';
import 'package:singlerestaurant/Model/home/searchmodel.dart';
import 'package:singlerestaurant/Theme/ThemeModel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/icons.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Favorite/showvariation.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/pages/Home/product.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class Trendingfood extends StatefulWidget {
  String? type;
  String? typename;

  @override
  State<Trendingfood> createState() {
    return _TrendingfoodState();
  }

  Trendingfood([this.type, this.typename]);
}

class _TrendingfoodState extends State<Trendingfood> {
  String? userid;
  String? sessionid;
  String? islogin;
  searchmodel? itemdata;
  String? currency;
  String? currency_position;
  addtocartmodel? addtocartdata;
  int? cart;
  cartcount count = Get.put(cartcount());
  bool isfirstcome = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  viewallAPI(filter) async {
    var map;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    userid = prefs.getString(UD_user_id);
    sessionid = prefs.getString(UD_user_session_id);
    islogin = prefs.getString(UD_user_is_login_required);
    currency = prefs.getString(APPcurrency);
    currency_position = prefs.getString(APPcurrency_position);
    try {
      loader.showLoading();
      if (userid == "" || userid == null) {
        map = {
          "session_id": sessionid,
          "filter": filter,
          "search": widget.type,
        };
      } else {
        map = {
          "user_id": userid,
          "filter": filter,
          "search": widget.type,
        };
      }
      print(map);
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Searchitem, data: map);
      isfirstcome = false;
      loader.hideLoading();
      itemdata = searchmodel.fromJson(response.data);
      setState(() {
        _scaffoldKey.currentWidget.reactive();
      });
      return itemdata;
    } catch (e) {
      rethrow;
    }
  }

  addtocart(itemid, itemname, itemimage, itemtype, itemtax, itemprice) async {
    try {
      loader.showLoading();
      isfirstcome = true;
      var map;
      if (userid == "" || userid == null) {
        map = {
          "session_id": sessionid,
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
        setState(() {});
      }
    } catch (e) {
      rethrow;
    }
  }

  managefavarite(
    var itemid,
    String isfavorite,
    index,
  ) async {
    try {
      loader.showLoading();
      var map = {"user_id": userid, "item_id": itemid, "type": isfavorite};

      var favoriteresponse = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Managefavorite, data: map);
      var finaldata = QTYupdatemodel.fromJson(favoriteresponse.data);

      if (finaldata.status == 1) {
        setState(() {
          isfavorite == "favorite"
              ? itemdata!.data![index].isFavorite = "1"
              : itemdata!.data![index].isFavorite = "0";
        });
        loader.hideLoading();
      } else {
        loader.hideLoading();
        loader.showErroDialog(description: finaldata.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;

    // Define the colors for light and dark mode
    Color backgroundColor = brightness == Brightness.light
        ? Colors.white // Light mode color
        : Colors.grey; // Dark mode color

    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              leadingWidth: 40,
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 20,
                  )),
              title: Text(
                widget.typename!,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 16),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Consumer(builder:
                              (context, ThemeModel themenofier, child) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Container(
                                  color: themenofier.isdark
                                      ? Colors.black
                                      : Colors.white,
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          25,
                                      right: MediaQuery.of(context).size.width /
                                          30),
                                  height:
                                      MediaQuery.of(context).size.height / 2.5,
                                  child: Column(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: 10)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Filter_Options'.tr,
                                            style: TextStyle(
                                                fontFamily: 'Poppins_bold',
                                                fontSize: 20),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: Icon(Icons.close))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          isfirstcome = true;
                                          setState(() {
                                            itemdata!.data!.clear();
                                          });
                                          viewallAPI("1");
                                          Get.back();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Veg'.tr,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          isfirstcome = true;
                                          setState(() {
                                            itemdata!.data!.clear();
                                          });
                                          viewallAPI("2");
                                          Get.back();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Nonveg'.tr,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          isfirstcome = true;
                                          setState(() {
                                            itemdata!.data!.clear();
                                          });
                                          viewallAPI("");
                                          Get.back();
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Both'.tr,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        height: 1,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          });
                        });
                  },
                  icon: ImageIcon(
                    AssetImage('Assets/Icons/Filter.png'),
                    size: 22,
                  ),
                )
              ],
            ),
            body: FutureBuilder(
              future: isfirstcome == true ? viewallAPI("") : null,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                      shrinkWrap: true,
                      itemCount: itemdata!.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 10,
                              crossAxisCount: 2),
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 33,
                          bottom: MediaQuery.of(context).size.height / 95,
                          right: MediaQuery.of(context).size.width / 33),
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // Spread radius
                                  blurRadius: 3, // Blur radius
                                  offset: Offset(0, 2), // Offset of the shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 70,
                            ),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                    () => Product(itemdata!.data![index].id));
                              },
                              child: Column(children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width /
                                              2.3,
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5)),
                                        child: Image.network(
                                          itemdata!.data![index].imageUrl,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    if (islogin == "1") ...[
                                      Positioned(
                                          top: 5.0,
                                          right: 5.0,
                                          child: InkWell(
                                            onTap: () {
                                              if (userid == "") {
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (c) =>
                                                                Login()),
                                                        (r) => false);
                                              } else if (itemdata!.data![index]
                                                      .isFavorite ==
                                                  "0") {
                                                managefavarite(
                                                  itemdata!.data![index].id,
                                                  "favorite",
                                                  index,
                                                );
                                              } else if (itemdata!.data![index]
                                                      .isFavorite ==
                                                  "1") {
                                                managefavarite(
                                                  itemdata!.data![index].id,
                                                  "unfavorite",
                                                  index,
                                                );
                                              }
                                            },
                                            child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    24,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    11,
                                                padding: EdgeInsets.all(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        120),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Color(0xFFE82428),
                                                ),
                                                child: itemdata!.data![index]
                                                            .isFavorite ==
                                                        "0"
                                                    ? SvgPicture.asset(
                                                        'Assets/Icons/Favorite.svg',
                                                        color: Colors.white,
                                                      )
                                                    : SvgPicture.asset(
                                                        'Assets/Icons/Favoritedark.svg',
                                                        color: Colors.white,
                                                      )),
                                          )),
                                    ]
                                  ],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                95)),
                                Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                50)),
                                    Text(
                                      itemdata!.data![index].categoryInfo!
                                          .categoryName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
                                        color: color.red,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      height: 14,
                                      width: 14,
                                      child:
                                          itemdata!.data![index].itemType == "1"
                                              ? Image.asset(
                                                  Defaulticon.vegicon,
                                                )
                                              : Image.asset(
                                                  Defaulticon.nonvegicon,
                                                ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                50))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                50)),
                                    Expanded(
                                      child: Text(
                                        itemdata!.data![index].itemName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontFamily: 'Poppins_semibold',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          50,
                                      right: MediaQuery.of(context).size.width /
                                          50),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (itemdata!.data![index].hasVariation ==
                                          "1") ...[
                                        Text(
                                          currency_position == "1"
                                              ? "$currency${numberFormat.format(double.parse(itemdata!.data![index].variation![0].productPrice.toString()))}"
                                              : "${numberFormat.format(double.parse(itemdata!.data![index].variation![0].productPrice.toString()))}$currency",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontFamily: 'Poppins_bold',
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          currency_position == "1"
                                              ? "$currency${numberFormat.format(double.parse(itemdata!.data![index].price.toString()))}"
                                              : "${numberFormat.format(double.parse(itemdata!.data![index].price.toString()))}$currency",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontFamily: 'Poppins_bold',
                                          ),
                                        ),
                                      ],
                                      //

                                      if (itemdata!.data![index].isCart ==
                                          "0") ...[
                                        InkWell(
                                          onTap: () async {
                                            if (itemdata!.data![index]
                                                        .hasVariation ==
                                                    "1" ||
                                                itemdata!.data![index].addons!
                                                    .isNotEmpty) {
                                              cart = await Get.to(() =>
                                                  showvariation(
                                                      itemdata!.data![index]));
                                              if (cart == 1) {
                                                setState(() {
                                                  itemdata!.data![index]
                                                      .isCart = "1";
                                                  itemdata!.data![index]
                                                      .itemQty = int.parse(
                                                          itemdata!.data![index]
                                                              .itemQty!
                                                              .toString()) +
                                                      1;
                                                });
                                              }
                                            } else {
                                              // if (userid == "") {
                                              //   Navigator.of(context)
                                              //       .pushAndRemoveUntil(
                                              //       MaterialPageRoute(
                                              //           builder: (c) =>
                                              //               Login()),
                                              //           (r) => false);
                                              // } else {
                                              addtocart(
                                                  itemdata!.data![index].id,
                                                  itemdata!
                                                      .data![index].itemName,
                                                  itemdata!
                                                      .data![index].imageName,
                                                  itemdata!
                                                      .data![index].itemType,
                                                  itemdata!.data![index].tax,
                                                  itemdata!.data![index].price);
                                            }
                                            // }
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE82428),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              height: 3.5.h,
                                              width: 17.w,
                                              child: Center(
                                                child: Text(
                                                  'ADD'.tr,
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 9.5.sp,
                                                      color: color.white),
                                                ),
                                              )),
                                        ),
                                      ] else if (itemdata!
                                              .data![index].isCart ==
                                          "1") ...[
                                        Container(
                                          height: 3.6.h,
                                          width: 22.w,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE82428),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    loader.showErroDialog(
                                                        description: LocaleKeys
                                                            .The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item
                                                            .tr);
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: color.white,
                                                    size: 16,
                                                  )),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  itemdata!
                                                      .data![index].itemQty!
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFECF1F6),
                                                      fontSize: 10.sp),
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: () async {
                                                    if (itemdata!.data![index]
                                                                .hasVariation ==
                                                            "1" ||
                                                        itemdata!
                                                                .data![index]
                                                                .addons!
                                                                .length >
                                                            0) {
                                                      cart = await Get.to(() =>
                                                          showvariation(
                                                              itemdata!.data![
                                                                  index]));
                                                      if (cart == 1) {
                                                        setState(
                                                          () {
                                                            itemdata!
                                                                    .data![index]
                                                                    .itemQty =
                                                                int.parse(itemdata!
                                                                        .data![
                                                                            index]
                                                                        .itemQty!
                                                                        .toString()) +
                                                                    1;
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      addtocart(
                                                          itemdata!
                                                              .data![index].id,
                                                          itemdata!.data![index]
                                                              .itemName,
                                                          itemdata!.data![index]
                                                              .imageName,
                                                          itemdata!.data![index]
                                                              .itemType,
                                                          itemdata!
                                                              .data![index].tax,
                                                          itemdata!.data![index]
                                                              .price);
                                                    }
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: color.white,
                                                    size: 16,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width /
                                            70)),
                              ]),
                            ));
                      });
                }
                return SizedBox(
                  height: 1,
                );
              },
            )));
  }
}
