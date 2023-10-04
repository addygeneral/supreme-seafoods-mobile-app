// ignore_for_file: prefer_const_constructors,   unrelated_type_equality_checks, use_build_context_synchronously, non_constant_identifier_names, unused_local_variable, prefer_is_empty

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/Model/cartpage/Qtyupdatemodel.dart';
import 'package:singlerestaurant/Model/favoritepage/addtocartmodel.dart';
import 'package:singlerestaurant/Model/favoritepage/favoritelistmodel.dart';
import 'package:singlerestaurant/Widgets/loader.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/common%20class/icons.dart';
import 'package:singlerestaurant/common%20class/prefs_name.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singlerestaurant/pages/Favorite/showvariation.dart';
import 'package:singlerestaurant/pages/Home/Homepage.dart';
import 'package:singlerestaurant/pages/Home/product.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userid;
  favoritelistmodel? favoritedata;
  addtocartmodel? addtocartdata;
  cartcount count = Get.put(cartcount());
  int? cart;
  String? currency;
  String? currency_position;

  FavoriteAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    currency = prefs.getString(APPcurrency);
    currency_position = prefs.getString(APPcurrency_position);
    try {
      var map = {"user_id": userid};

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Favoritelist, data: map);
      favoritedata = favoritelistmodel.fromJson(response.data);

      if (favoritedata!.status == 1) {
        return favoritedata;
      } else {
        loader.showErroDialog(description: favoritedata!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  addtocart(int? selectedindex) async {
    loader.showLoading();
    try {
      var map = {
        "user_id": userid,
        "item_id": favoritedata!.data![selectedindex!].id,
        "item_name": favoritedata!.data![selectedindex].itemName,
        "item_image": favoritedata!.data![selectedindex].imageName,
        "item_type": favoritedata!.data![selectedindex].itemType,
        "tax": favoritedata!.data![selectedindex].tax,
        "item_price": numberFormat
            .format(double.parse(favoritedata!.data![selectedindex].price!)),
        "variation_id": "",
        "variation": "",
        "addons_id": "",
        "addons_name": "",
        "addons_price": "",
        "addons_total_price": numberFormat.format(double.parse("0")),
      };
      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Addtocart, data: map);
      addtocartdata = addtocartmodel.fromJson(response.data);
      loader.hideLoading();
      if (addtocartdata!.status == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(APPcart_count, addtocartdata!.cartCount.toString());
        count.cartcountnumber(int.parse(prefs.getString(APPcart_count)!));

        setState(() {
          FavoriteAPI();
        });
      } else {
        loader.showErroDialog(description: addtocartdata!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  variationaddonsadd_to_cartAPI(int? itemindex, int? variationindex) async {
    try {
      var map = {
        "user_id": userid,
        "item_id": favoritedata!.data![itemindex!].id,
        "item_name": favoritedata!.data![itemindex].itemName,
        "item_image": favoritedata!.data![itemindex].imageName,
        "item_type": favoritedata!.data![itemindex].itemType,
        "tax": numberFormat.format(double.parse(
          favoritedata!.data![itemindex].tax!,
        )),
        "item_price": numberFormat
            .format(double.parse(favoritedata!.data![itemindex].price!)),
        "variation_id": favoritedata!.data![itemindex].hasVariation == "1"
            ? favoritedata!.data![itemindex].variation![variationindex!].id
            : "",
        "variation": favoritedata!.data![itemindex].hasVariation == "1"
            ? favoritedata!
                .data![itemindex].variation![variationindex!].variation
            : "",
        "addons_id": "",
        "addons_name": "",
        "addons_price": "",
        "addons_total_price": numberFormat.format(double.parse("0")),
      };
    } catch (e) {
      rethrow;
    }
  }

  removefavarite(itemid) async {
    try {
      loader.showLoading();
      var map = {"user_id": userid, "item_id": itemid, "type": "unfavorite"};
      var response = await Dio()
          .post(DefaultApi.appUrl + PostAPI.Managefavorite, data: map);
      var finaldata = QTYupdatemodel.fromJson(response.data);
      setState(() {
        favoritedata!.data!.remove(itemid);
      });
      loader.hideLoading();
      if (finaldata.status == 1) {
        loader.hideLoading();
      } else {
        loader.showErroDialog(description: finaldata.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refreshData() async {
    try {
      var map = {"user_id": userid};

      var response =
          await Dio().post(DefaultApi.appUrl + PostAPI.Favoritelist, data: map);
      favoritedata = favoritelistmodel.fromJson(response.data);

      if (favoritedata!.status == 1) {
        setState(() {
          // Update your data here and rebuild the UI.
        });
      } else {
        loader.showErroDialog(description: favoritedata!.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(UD_user_id);
    currency = prefs.getString(APPcurrency);
    currency_position = prefs.getString(APPcurrency_position);

    // Load data initially
    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;

    Color backgroundColor = brightness == Brightness.light
        ? Colors.white // Light mode color
        : Colors.grey;
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Favorite_list'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.red,
        child: FutureBuilder(
          future: FavoriteAPI(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (favoritedata!.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No_data_found'.tr,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: Colors.grey),
                  ),
                );
              }
              return StatefulBuilder(
                  builder: (context, setState) => ListView.builder(
                        itemCount: favoritedata!.data!.length,
                        itemBuilder: (context, index) => Container(
                          margin: EdgeInsets.only(
                            top: 0.7.h,
                            bottom: 0.7.h,
                            left: 3.5.w,
                            right: 3.5.w,
                          ),
                          height: 14.h,
                          decoration: BoxDecoration(
                              color: backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.3), // Shadow color
                                  spreadRadius: 0, // Spread radius
                                  blurRadius: 5, // Blur radius
                                  offset: Offset(0, 2), // Offset of the shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.2.sp,
                              )),
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                () => Product(
                                  favoritedata!.data![index].id,
                                ),
                              );
                            },
                            child: Row(children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    width: 28.w,
                                    height: 15.5.h,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Image(
                                          image: NetworkImage(
                                            favoritedata!.data![index].imageUrl
                                                .toString(),
                                          ),
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  Positioned(
                                      child: InkWell(
                                    onTap: () {
                                      removefavarite(
                                          favoritedata!.data![index].id);
                                    },
                                    child: Container(
                                        height: 4.h,
                                        width: 9.w,
                                        padding: EdgeInsets.all(2.5.sp),
                                        margin: EdgeInsets.only(
                                            left: 1.w, right: 1.w, top: 0.5.h),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: Color(0xFFE82428),
                                        ),
                                        child: SvgPicture.asset(
                                          'Assets/Icons/Favoritedark.svg',
                                          color: Colors.white,
                                        )),
                                  )),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 1.h,
                                        left: 2.2.w,
                                        right: 2.2.w,
                                      ),
                                      child: Row(
                                        children: [
                                          if (favoritedata!
                                                  .data![index].itemType ==
                                              "1") ...[
                                            SizedBox(
                                              height: 2.h,
                                              // color: Colors.black,
                                              child: Image.asset(
                                                Defaulticon.vegicon,
                                              ),
                                            ),
                                          ] else if (favoritedata!
                                                  .data![index].itemType ==
                                              "2") ...[
                                            SizedBox(
                                              height: 2.h,
                                              // color: Colors.black,
                                              child: Image.asset(
                                                Defaulticon.nonvegicon,
                                              ),
                                            ),
                                          ],
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                left: 2.2.w,
                                                right: 2.2.w,
                                              ),
                                              child: Text(
                                                favoritedata!
                                                    .data![index].itemName!,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.5.sp,
                                                  fontFamily: 'Poppins_medium',
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 2.2.w,
                                        right: 2.2.w,
                                      ),
                                      child: Text(
                                        favoritedata!.data![index].categoryInfo!
                                            .categoryName!,
                                        style: TextStyle(
                                          fontSize: 7.5.sp,
                                          fontFamily: 'Poppins',
                                          color: color.red,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 2.2.w,
                                          right: 2.2.w,
                                          bottom: 0.8.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          if (favoritedata!
                                                  .data![index].hasVariation ==
                                              "1") ...[
                                            Text(
                                              currency_position == "1"
                                                  ? "$currency${numberFormat.format(
                                                      double.parse(favoritedata!
                                                          .data![index]
                                                          .variation![0]
                                                          .productPrice
                                                          .toString()),
                                                    )}"
                                                  : "${numberFormat.format(
                                                      double.parse(favoritedata!
                                                          .data![index]
                                                          .variation![0]
                                                          .productPrice
                                                          .toString()),
                                                    )}$currency",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: 'Poppins_semibold',
                                              ),
                                            )
                                          ] else if (favoritedata!
                                                  .data![index].hasVariation ==
                                              "2") ...[
                                            Text(
                                              currency_position == "1"
                                                  ? "$currency${numberFormat.format(
                                                      double.parse(favoritedata!
                                                          .data![index].price!),
                                                    )}"
                                                  : "${numberFormat.format(
                                                      double.parse(favoritedata!
                                                          .data![index].price!),
                                                    )}$currency",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: 'Poppins_semibold',
                                              ),
                                            )
                                          ],
                                          Spacer(),
                                          if (favoritedata!
                                                  .data![index].isCart ==
                                              "0") ...[
                                            InkWell(
                                              onTap: () async {
                                                if (favoritedata!.data![index]
                                                            .hasVariation ==
                                                        "1" ||
                                                    favoritedata!.data![index]
                                                        .addons!.isNotEmpty) {
                                                  cart = await Get.to(() =>
                                                      showvariation(
                                                          favoritedata!
                                                              .data![index]));

                                                  if (cart == 1) {
                                                    _scaffoldKey.currentContext
                                                        .reactive;
                                                    setState(() {
                                                      favoritedata!.data![index]
                                                          .isCart = "1";

                                                      favoritedata!.data![index]
                                                          .itemQty = int.parse(
                                                              favoritedata!
                                                                  .data![index]
                                                                  .itemQty
                                                                  .toString()) +
                                                          1;
                                                    });
                                                  }
                                                } else {
                                                  addtocart(index);
                                                }
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFE82428),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                          fontFamily: 'Poppins',
                                                          fontSize: 9.5.sp,
                                                          color: color.white),
                                                    ),
                                                  )),
                                            ),
                                          ] else if (favoritedata!
                                                  .data![index].isCart ==
                                              "1") ...[
                                            Container(
                                              height: 3.6.h,
                                              width: 22.w,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE82428),
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 255, 255, 255)),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  InkWell(
                                                      onTap: () {
                                                        loader.showErroDialog(
                                                          description: LocaleKeys
                                                              .The_item_has_multtiple_customizations_added_Go_to_cart__to_remove_item
                                                              .tr,
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: color.white,
                                                        size: 16,
                                                      )),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                    ),
                                                    child: Text(
                                                      favoritedata!
                                                          .data![index].itemQty!
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: color.white,
                                                          fontSize: 10.sp),
                                                    ),
                                                  ),
                                                  InkWell(
                                                      onTap: () async {
                                                        if (favoritedata!
                                                                    .data![
                                                                        index]
                                                                    .hasVariation ==
                                                                "1" ||
                                                            favoritedata!
                                                                    .data![
                                                                        index]
                                                                    .addons!
                                                                    .length >
                                                                0) {
                                                          cart = await Get.to(
                                                              () => showvariation(
                                                                  favoritedata!
                                                                          .data![
                                                                      index]));
                                                          if (cart == 1) {
                                                            setState(() {
                                                              favoritedata!
                                                                  .data![index]
                                                                  .itemQty = int.parse(favoritedata!
                                                                      .data![
                                                                          index]
                                                                      .itemQty
                                                                      .toString()) +
                                                                  1;
                                                            });
                                                          }
                                                        } else {
                                                          addtocart(index);
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
                                  ],
                                ),
                              )
                            ]),
                          ),
                        ),
                      ));
            }
            return Center(
              child: CircularProgressIndicator(color: color.primarycolor),
            );
          },
        ),
      ),
    ));
  }
}
