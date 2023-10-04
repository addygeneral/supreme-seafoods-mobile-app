// // ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:singlerestaurant/pages/Home/Homepage.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'dart:async';

// class NotificationApi {
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static final onNotifications = BehaviorSubject<String?>();

//   static Future _notificationDetails() async {
//     final largeIconPath = await Utils.downloadFile(
//         'https://image.flaticon.com/icons/png/512/1277/1277314.png',
//         'largeIcon');

//     final bigPicturePath = await Utils.downloadFile(
//         'https://www.simplyrecipes.com/thmb/8caxM88NgxZjz-T2aeRW3xjhzBg=/2000x1125/smart/filters:no_upscale()/__opt__aboutcom__coeus__resources__content_migration__simply_recipes__uploads__2019__09__easy-pepperoni-pizza-lead-3-8f256746d649404baa36a44d271329bc.jpg',
//         'bigPicture');
//     final styleInformation = BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath),
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//     );

//     return NotificationDetails(
//       android: AndroidNotificationDetails(
//         'channel id',
//         'channel name',
//         // 'channel description',
//         importance: Importance.max, //comment this out to not see banner on top
//         // Add playSound false to remove sound when notification is sent.
//         // playSound: false,
//         // for iOS, set presentSound=false inside IOSNotificationDetails().
//         styleInformation: styleInformation,
//       ),
//       iOS: IOSNotificationDetails(),
//     );
//   }

//   static Future init({bool initScheduled = false}) async {
//     FirebaseMessaging.instance;
//     final android = AndroidInitializationSettings('@drawable/ic_notification');
//     final iOS = IOSInitializationSettings();
//     final settings = InitializationSettings(android: android, iOS: iOS);

//     /// when app is closed
//     final details = await _notifications.getNotificationAppLaunchDetails();
//     if (details != null && details.didNotificationLaunchApp) {
//       onNotifications.add(details.payload);
//     }
//     await _notifications.initialize(
//       settings,
//       onSelectNotification: (payload) async {
//         onNotifications.add(payload);
//       },
//     );
//   }

//   static tz.TZDateTime _scheduleDaily(Time time) {
//     final now = tz.TZDateTime.now(tz.local);
//     final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
//         time.hour, time.minute, time.second);

//     return scheduledDate.isBefore(now)
//         ? scheduledDate.add(Duration(days: 1))
//         : scheduledDate;
//   }

//   static tz.TZDateTime _scheduleWeekly(Time time, {required List<int> days}) {
//     tz.TZDateTime scheduledDate = _scheduleDaily(time);

//     while (!days.contains(scheduledDate.weekday)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//     return scheduledDate;
//   }

//   static void cancel(int id) => _notifications.cancel(id);

//   static void cancelAll() => _notifications.cancelAll();

//   static Future showNotification(
//           {int id = 0, String? title, String? body, String? payload}) async =>
//       _notifications.show(
//         id,
//         title,
//         body,
//         await _notificationDetails(),
//         payload: payload,
//       );

//   static Future showScheduledNotification({
//     int id = 555,
//     String? title,
//     String? body,
//     String? payload,
//     required DateTime scheduledDate,
//   }) async =>
//       _notifications.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(scheduledDate, tz.local),
//         await _notificationDetails(),
//         payload: payload,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );

//   static Future showDailyScheduledNotification({
//     int id = 0221,
//     String? title,
//     String? body,
//     String? payload,
//     required DateTime scheduledDate,
//   }) async =>
//       _notifications.zonedSchedule(
//         id,
//         title,
//         body,
//         _scheduleDaily(Time(15, 43)),
//         //tz.TZDateTime.from(scheduledDate, tz.local),
//         await _notificationDetails(),
//         payload: payload,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );

//   static Future showWeeklyScheduledNotification({
//     int id = 0221,
//     String? title,
//     String? body,
//     String? payload,
//     required DateTime scheduledDate,
//   }) async =>
//       _notifications.zonedSchedule(
//         id,
//         title,
//         body,
//         _scheduleWeekly(Time(15, 43),
//             days: [DateTime.monday, DateTime.tuesday, DateTime.wednesday]),
//         //tz.TZDateTime.from(scheduledDate, tz.local),
//         await _notificationDetails(),
//         payload: payload,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       );
// }
