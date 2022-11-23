import 'dart:convert';
import 'dart:io';

import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/MyOrder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../All_Category.dart';
import '../My_Wallet.dart';
import '../Product_Detail.dart';
import '../Splash.dart';
import '../main.dart';
import 'Constant.dart';
import 'Session.dart';
import 'String.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  final BuildContext context;
  final Function updateHome;

  PushNotificationService({this.context, this.updateHome});

  Future initialise() async {
    iOSPermission();
    messaging.getToken().then((token) async {
      CUR_USERID = await getPrefrence(ID);
      if (CUR_USERID != null && CUR_USERID != "") _registerToken(token);
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var data = message.notification;
      var title = data.title.toString();
      var body = data.body.toString();
      var image = message.data['image'] ?? '';

      var type = message.data['type'] ?? '';
      var id = '';
      id = message.data['type_id'] ?? '';

      if (image != null && image != 'null' && image != '') {
        generateImageNotication(title, body, image, type, id);
      } else {
        generateSimpleNotication(title, body, type, id);
      }
    });

    messaging.getInitialMessage().then((RemoteMessage message) async {
      bool back = await getPrefrenceBool(ISFROMBACK);

      if (message != null && back) {
        var type = message.data['type'] ?? '';
        var id = '';
        id = message.data['type_id'] ?? '';

        if (type == "products") {
          getProduct(id, 0, 0, true);
        } else if (type == "categories") {
          Navigator.push(context,
              (MaterialPageRoute(builder: (context) => AllCategory())));
        } else if (type == "wallet") {
          // Navigator.push(
          //     context, (MaterialPageRoute(builder: (context) => MyWallet())));
        } else if (type == 'order') {
          Navigator.push(
              context, (MaterialPageRoute(builder: (context) => MyOrder(isback: false,))));
        } else {
          Navigator.push(
              context, (MaterialPageRoute(builder: (context) => Splash())));
        }
        setPrefrenceBool(ISFROMBACK, false);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      //  bool back = await getPrefrenceBool(ISFROMBACK, "open");

      if (message != null) {
        var type = message.data['type'] ?? '';
        var id = '';

        id = message.data['type_id'] ?? '';

        if (type == "products") {
          getProduct(id, 0, 0, true);
        } else if (type == "categories") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AllCategory()),
          );
        } /*else if (type == "wallet") {
          Navigator.push(
              context, (MaterialPageRoute(builder: (context) => MyWallet())));
        }*/ else if (type == 'order') {
          Navigator.push(
              context, (MaterialPageRoute(builder: (context) => MyOrder(isback: false,))));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
        setPrefrenceBool(ISFROMBACK, false);
      }
    });
  }

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerToken(String token) async {
    var parameter = {USER_ID: CUR_USERID, FCM_ID: token};

    Response response =
        await post(updateFcmApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

    var getdata = json.decode(response.body);
  }

  Future onSelectNotification(String payload) {
    if (payload != null) {
      List<String> pay = payload.split(",");
      if (pay[0] == "products") {
        getProduct(pay[1], 0, 0, true);
      } else if (pay[0] == "categories") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllCategory()),
        );
      } /*else if (pay[0] == "wallet") {
        Navigator.push(
            context, (MaterialPageRoute(builder: (context) => MyWallet())));
      }*/ else if (pay[0] == 'order') {
        Navigator.push(
            context, (MaterialPageRoute(builder: (context) => MyOrder(isback: false,))));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Splash()),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    try {
      var parameter = {
        ID: id,
      };

      //if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
      Response response =
          await post(getProductApi, headers: headers, body: parameter)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        List<Product> items = [];

        items =
            (data as List).map((data) => new Product.fromJson(data)).toList();

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductDetail(
                  index: int.parse(id),
                  updateHome: updateHome,
                  updateParent: updateHome,
                  model: items[0],
                  secPos: secPos,
                  list: list,
                )));
      } else {
        //if (msg != "Products Not Found !") setSnackbar(msg);
      }
    } catch (Exception) {}
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  await setPrefrenceBool(ISFROMBACK, true);
  bool back = await getPrefrenceBool(ISFROMBACK);
  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var response = await http.get(Uri.parse(url));

  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> generateImageNotication(
    String title, String msg, String image, String type, String id) async {
  var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'big text channel id',
      'big text channel name',

      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation);
  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: type + "," + id);
}

Future<void> generateSimpleNotication(
    String title, String msg, String type, String id) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  var iosDetail = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosDetail);
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: type + "," + id);
}
