import 'dart:async';
import 'dart:io';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:eshop/utils/color_res.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    startTime();
    _controller = AnimationController(
      duration: Duration(seconds: (5)),
      vsync: this,
    );
    // startTime();
  }

  int openAppCount = 0;
  int openContinue = 0;
  int onTapLaterCount = 0;

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Color(0xFF280F43),
                  // Color(0xffE5CCFF),
                  colors.darkColor,
                  colors.darkColor.withOpacity(0.8),
                  Color(0xFFF8F8FF),
                ]),
          ),
         /* child: Lottie.asset(
            'assets/animations/animation.json',
            controller: _controller,
            height: MediaQuery.of(context).size.height * 1,
            animate: true,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration
                ..forward().whenComplete(() {
                  navigationPage().then((value) async {
                    print("SHOULD OPEN First $openContinue");
                    openContinue = await getPreferencesInt("openContinue") ?? 0;
                    if (openContinue == 0) {
                      openAppCount =
                          await getPreferencesInt("OpenAppCount") ?? 0;

                      if (openAppCount != 0) {
                        openAppCount = openAppCount + 1;
                        removePreferences("OpenAppCount");
                        setPreferencesInt("OpenAppCount", openAppCount);
                      } else {
                        openAppCount = 1;
                        removePreferences("OpenAppCount");
                        setPreferencesInt("OpenAppCount", openAppCount);
                      }
                      if (openAppCount == 5) {
                        showCustomDialog();
                      }
                      // showCustomDialog();
                    }
                  });
                });
            },
          ),*/
          child: Center(
            child: Image.asset("assets/images/new_title_logo.png",height: 100,),
          ),
        ));
  }

  startTime() async {
    var _duration = Duration(seconds: 2);
    return Timer(_duration, navigationPage);
  }

  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: 'microsoftStoreId',
      );

  showCustomDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: Center(child: Text('Rate this app'),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/odeva_logo.png",
                  height: 100,
                ),
                Platform.isAndroid
                    ? Text("Please would you help us by rating Odeva app?")
                    : SizedBox(),
                Platform.isIOS
                    ? Text("Please would you help us by rating Odeva app?")
                    : SizedBox(),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: colors.darkColor,
                      child: Text(
                        'No',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        onTapLaterCount =
                            await getPreferencesInt("onTapLaterCount") ?? 0;
                        if (onTapLaterCount != 0) {
                          onTapLaterCount = onTapLaterCount + 1;
                          setPreferencesInt("onTapLaterCount", onTapLaterCount);
                        }else{
                          setPreferencesInt("onTapLaterCount", 1);
                        }
                        if (onTapLaterCount == 3) {
                          removePreferences("OpenAppCount");
                          setPreferencesInt("OpenAppCount", 6);
                        } else {
                          removePreferences("OpenAppCount");
                          setPreferencesInt("OpenAppCount", 0);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    FlatButton(
                      color: colors.darkColor,
                      child: Text(
                        'Yes',
                        style: TextStyle(color: ColorRes.white),
                      ),
                      onPressed: () {
                        removePreferences("openContinue");
                        setPreferencesInt("openContinue", 1);
                        _openStoreListing();
                      },
                    )
                  ],
                ),
                SizedBox(height: 5),
              ],
            ),
          );
        });
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
    CUR_USERID = await getPrefrence(ID);
    if (CUR_USERID != null) {
      //if (isFirstTime) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInUpAcc(),
          ));
    }
    // } else {
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => IntroSlider(),
    //         ));
    // }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
