// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:get/get.dart';
// import 'package:singlerestaurant/Model/home/homescreenmodel.dart';
// import 'package:singlerestaurant/common%20class/color.dart';
// import 'package:singlerestaurant/config/API/API.dart';

// // flutter api call using Getx?
// enum DataStatus { none, compleated, error }

// class apicontoller extends GetxController {
//   homescreenmodel? homedetails;
//   // Rx<homescreenmodel> homescreenmodeldata = homescreenmodel().obs;
//   Rx<DataStatus> dataStatus = DataStatus.none.obs;

//   @override
//   void onInit() {
//     homeAPI();
//     super.onInit();
//   }

//   void updete() {
//     super.update();
//   }

//   homeAPI() async {
//     var map = {"user_id": ""};
//     print(map);
//     var response =
//         await Dio().post(DefaultApi.appUrl + PostAPI.Home, data: map);
//     print(response);
//     homedetails = homescreenmodel.fromJson(response.data);
//     homedetails!.status == 1 ? dataStatus(DataStatus.compleated) : null;
//   }
// }

// class demoget extends StatefulWidget {
//   const demoget({super.key});

//   @override
//   State<demoget> createState() => _demogetState();
// }

// class _demogetState extends State<demoget> {
//   final apicontoller data = Get.put<apicontoller>(apicontoller());
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<apicontoller>(
//       builder: (controller) {
//         return SafeArea(
//           child: Scaffold(
//             appBar: AppBar(
//               title: Text("dzfkjh"),
//             ),
//             body: Obx(
//               () {
//                 switch (data.dataStatus.value) {
//                   case DataStatus.error:
//                     return const Center(
//                       child: Text('Unknown Error'),
//                     );
//                   case DataStatus.compleated:
//                     return Center(
//                         child: ListView.builder(
//                       itemCount: data.homedetails!.trendingitems!.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           height: 80,
//                           margin: EdgeInsets.only(top: 10),
//                           child: Column(
//                             children: [
//                               TextButton(
//                                   onPressed: () {
//                                     data.homedetails!.trendingitems![index]
//                                         .isFavorite = "1";
//                                     data.updete();
//                                     print(data.homedetails!
//                                         .trendingitems![index].isFavorite);
//                                   },
//                                   child: Text(data
//                                               .homedetails!
//                                               .trendingitems![index]
//                                               .isFavorite ==
//                                           "0"
//                                       ? "favotite ${data.homedetails!.trendingitems![index].isFavorite}"
//                                       : data.homedetails!.trendingitems![index]
//                                           .isFavorite)),
//                               Text(data
//                                   .homedetails!.trendingitems![index].itemName)
//                             ],
//                           ),
//                         );
//                       },
//                     ));
//                   default:
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                 }
//               },
//             ),

//             //  Obx(() {
//             //   switch (data.dataStatus.value) {
//             //     case DataStatus.none:
//             //       return Container(
//             //         child: Text("data done"),
//             //       )
//             //           // TODO: Handle this case.
//             //           ;
//             //     case DataStatus.compleated:
//             //       // TODO: Handle this case.
//             //       break;
//             //     case DataStatus.error:
//             //       // TODO: Handle this case.
//             //       break;
//             //     default:
//             //       return Text("data");
//             //   }
//             // }),
//             // // body: Container(
//             //   // color: color.green,
//             //   height: 1000,
//             //   width: 100,
//             // ),
//           ),
//         );
//       },
//     );
//   }
// }
