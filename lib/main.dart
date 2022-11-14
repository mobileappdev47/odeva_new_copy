import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Login.dart';
import 'package:eshop/Splash.dart';
import 'package:eshop/utils/rate_my_app_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import 'Helper/Demo_Localization.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Helper/Theme.dart';

//import 'Home.dart';
//import 'Home2.dart';
import 'Home3.dart';

//import 'Home1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  loadSVG();
  Stripe.publishableKey =
      "pk_test_51J3jqhC1MwKHfh2WkSH8jz6UQHRNEqZvNk7vRrJP7FsL2W6PFqP11wKjbc6aGW7r5l3Z6H1KTt4UqGIyzDYfHCqm00aNGqj647";
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  await firebaseMessaging();

  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (BuildContext context) {
          String theme = value.getString(APP_THEME);

          if (theme == DARK)
            ISDARK = "true";
          else if (theme == LIGHT) ISDARK = "false";

          if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
            value.setString(APP_THEME, DEFAULT_SYSTEM);
            var brightness =
                SchedulerBinding.instance.window.platformBrightness;
            ISDARK = (brightness == Brightness.dark).toString();

            return ThemeNotifier(ThemeMode.system);
          }
          return ThemeNotifier(
              theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
        },
        child: MyApp(),
      ),
    );
  });
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  setLocale(Locale locale) {
    if (mounted)
      setState(() {
        _locale = locale;
      });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted)
        setState(() {
          this._locale = locale;
        });
    });
    super.didChangeDependencies();
  }

/*  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    // minDays: 1,
    minLaunches: 2,
    remindDays: 7,
    remindLaunches: 10,
    googlePlayIdentifier: 'odeva.clickk',
    // appStoreIdentifier: '1491556149',
  );*/

  @override
  void initState() {
    checkVersion(context);
    super.initState();
  }

/*  showRatingPopUp() {
    debugPrint("CALL SHOW RATE DIALOG ");
    rateMyApp.showStarRateDialog(
      context,
      title: 'Rate this app',
      // The dialog title.
      message:
      'You like this app ? Then take a little bit of your time to leave a rating :',
      // The dialog message.
      // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
      actionsBuilder: (context, stars) {
        // Triggered when the user updates the star rating.
        return [
          // Return a list of actions (that will be shown at the bottom of the dialog).
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              print('Thanks for the ' +
                  (stars == null ? '0' : stars.round().toString()) +
                  ' star(s) !');
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
              await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              Navigator.pop<RateMyAppDialogButton>(
                  context, RateMyAppDialogButton.rate);
            },
          ),
        ];
      },
      ignoreNativeDialog: Platform.isAndroid,
      // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
      dialogStyle: const DialogStyle(
        // Custom dialog styles.
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20),
      ),
      starRatingOptions: const StarRatingOptions(),
      // Custom star bar rating options.
      onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
          .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
    );
  }*/

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (this._locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
        ),
      );
    } else {
      return GetMaterialApp(
        //scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: _locale,
        supportedLocales: [
          Locale("en", "US"),
          Locale("zh", "CN"),
          Locale("es", "ES"),
          Locale("hi", "IN"),
          Locale("ar", "DZ"),
          Locale("ru", "RU"),
          Locale("ja", "JP"),
          Locale("de", "DE")
        ],
        localizationsDelegates: [
          CountryLocalizations.delegate,
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        title: appName,
        theme: ThemeData(
          canvasColor: colors.lightWhite,
          cardColor: colors.white,
          dialogBackgroundColor: colors.white,
          iconTheme:
              Theme.of(context).iconTheme.copyWith(color: colors.primary),
          primarySwatch: colors.primary_app,
          primaryColor: colors.lightWhite,
          fontFamily: 'opensans',
          brightness: Brightness.light,
          textTheme: TextTheme(
                  headline6: TextStyle(
                    color: colors.fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle1: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold))
              .apply(bodyColor: colors.fontColor),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/home': (context) => Home(),
          '/login': (context) => Login()
        },

        darkTheme: ThemeData(
          canvasColor: colors.darkColor,
          cardColor: colors.darkColor2,
          dialogBackgroundColor: colors.darkColor2,
          primarySwatch: colors.primary_app,
          primaryColor: colors.darkColor,
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: colors.primary,
              selectionColor: colors.primary,
              selectionHandleColor: colors.secondary),
          toggleableActiveColor: colors.primary,
          fontFamily: 'opensans',
          brightness: Brightness.dark,
          accentColor: colors.secondary,
          iconTheme:
              Theme.of(context).iconTheme.copyWith(color: colors.secondary),
          textTheme: TextTheme(
                  headline6: TextStyle(
                    color: colors.fontColor,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle1: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold))
              .apply(bodyColor: colors.secondary),
        ),
        themeMode: themeNotifier.getThemeMode(),
      );
    }
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
AndroidNotificationChannel channel;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future onDidReceiveLocalNotification(
  int id,
  String title,
  String body,
  String payload,
) async {
  print("iOS notification $title $body $payload");
}

Future<void> firebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
/*  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);*/
/*  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        print("onSelectNotification Called");
        if (payload != null) {
         // final newPay = jsonDecode(payload);

          */ /*         UserModel userModel = await userService.getUserModel(newPay['id']);
              Get.offAll(
                      () => new Person.ChatScreen(userModel, false, newPay['roomId']));*/ /*

        }
      });*/

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("onMessage Called");
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    // Map<String, dynamic> payload = message.data;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification.title, notification.body, NotificationDetails());
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp Called ");
    await Firebase.initializeApp();

    /*       UserModel userModel = await userService.getUserModel(message.data['id']);
        Get.to(() => Person.ChatScreen(userModel, false, message.data['roomId']));*/
  });

  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage message) async {
    print("getInitialMessage Called ");
    if (message != null) {
      await Firebase.initializeApp();

      /* UserModel userModel =
          await userService.getUserModel(message.data['id']);
          Get.to(
                  () => Person.ChatScreen(userModel, false, message.data['roomId']));*/

    }
  });
}

Future<void> loadSVG() async {
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_myorder.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_address.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_wh.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_th.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_pass.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_referral.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_customersupport.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_pp.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_tc.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_rateus.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_customersupport.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_share.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/pro_logout.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/username.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/stripe.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/sliderph.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/sel_notification.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/search.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/rozerpay.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/profile.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/payu.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/paytm.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/paystack.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/paypal.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/orderplaced.svg",
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/noti_cart.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/nonvag.svg",
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/no_internet.svg',
    ),
    null,
  );
  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/mobilenumber.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/location.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/flutterwave.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/empty_cart.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/email.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/desel_user.svg',
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/desel_search.svg",
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/desel_notification.svg",
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/desel_home.svg",
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/desel_fav.svg",
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      "assets/images/des_heart.svg",
    ),
    null,
  );

  await precachePicture(
    ExactAssetPicture(
      SvgPicture.svgStringDecoderBuilder,
      'assets/images/cod.svg',
    ),
    null,
  );
}
