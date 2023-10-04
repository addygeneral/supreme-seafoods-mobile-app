// ignore_for_file: prefer_const_constructors,   file_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:singlerestaurant/Model/settings%20model/blogsmodel.dart';
import 'package:singlerestaurant/common%20class/Allformater.dart';
import 'package:singlerestaurant/common%20class/color.dart';
import 'package:singlerestaurant/config/API/API.dart';
import 'package:singlerestaurant/pages/Profile/blogdetails.dart';
import 'package:singlerestaurant/translation/locale_keys.g.dart';
import 'package:sizer/sizer.dart';

class Blogspage extends StatefulWidget {
  const Blogspage({Key? key}) : super(key: key);

  @override
  State<Blogspage> createState() => _BlogspageState();
}

class _BlogspageState extends State<Blogspage> {
  blogsmodel? blogsdata;
  blogsAPI() async {
    try {
      var response = await Dio().get(DefaultApi.appUrl + GetAPI.blogs);
      var finallist = await response.data;
      blogsdata = blogsmodel.fromJson(finallist);
      return blogsdata;
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
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 20,
                  )),
              title: Text(
                'Blogs'.tr,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontFamily: 'Poppins_semibold', fontSize: 12.sp),
              ),
              leadingWidth: 40,
              centerTitle: true,
            ),
            body: FutureBuilder(
              future: blogsAPI(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (blogsdata!.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No_data_found'.tr,
                        style:
                            TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: blogsdata!.data!.length,
                    itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.only(
                          left: Get.size.width * 0.03,
                          top: Get.size.height * 0.002,
                          bottom: Get.size.height * 0.002,
                          right: Get.size.width * 0.03),
                      child: InkWell(
                        onTap: () {
                          Get.to(() => Blogsdetailspage(
                                blogsdata!.data![index].imageUrl.toString(),
                                blogsdata!.data![index].title.toString(),
                                blogsdata!.data![index].date.toString(),
                                blogsdata!.data![index].description.toString(),
                              ));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: Get.size.height * 0.25,
                              width: Get.size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  blogsdata!.data![index].imageUrl.toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: Get.size.height * 0.015,
                                bottom: Get.size.height * 0.015,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      blogsdata!.data![index].title.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: 'Poppins_bold'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${'Posted_by'.tr} Admin",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10.5.sp,
                                      fontFamily: 'Poppins_semibold'),
                                ),
                                Text(
                                  FormatedDate(
                                      blogsdata!.data![index].date.toString()),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10.5.sp,
                                      fontFamily: 'Poppins_semibold'),
                                ),
                              ],
                            ),
                            Text(
                              blogsdata!.data![index].description.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: Get.size.height * 0.01,
                                bottom: Get.size.height * 0.005,
                              ),
                              height: Get.size.height * 0.0015,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: color.primarycolor,
                  ),
                );
              },
            )));
  }
}
