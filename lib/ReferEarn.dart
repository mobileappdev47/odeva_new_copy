import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';

class ReferEarn extends StatefulWidget {
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor:  colors.darkColor,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
        title: Text(
          getTranslated(context, 'REFEREARN'),
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/refer.png",
                          height: Get.height * 0.35,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: Text(
                            getTranslated(context, 'REFEREARN'),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: colors.fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated(context, 'REFER_TEXT'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.fontColor, //Color(0xff65299A),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: Text(
                            getTranslated(context, 'YOUR_CODE'),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: colors.fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: new BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: colors.secondary,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  REFER_CODE,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(color: Color(0xFFe7bd07)),
                                ),
                              )),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  color: colors.lightWhite,
                                  borderRadius: new BorderRadius.all(
                                      const Radius.circular(4.0))),
                              child: Text(
                                  getTranslated(context, 'TAP_TO_COPY'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                    color: colors.fontColor,
                                  ))),
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: REFER_CODE));
                            setSnackbar('Refercode Copied to clipboard');
                          },
                        ),
                        CupertinoButton(
                          child: Container(
                              width: deviceWidth-deviceWidth*0.260,
                              height: 35,
                              alignment: FractionalOffset.center,
                              decoration: new BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3B147A),
                                      Color(0xFF3B147A)
                                    ],
                                    stops: [
                                      0,
                                      1
                                    ]),
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(10.0)),
                              ),
                              child: Text(getTranslated(context, "SHARE_APP"),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal))),
                          onPressed: () {
                            var str =
                                "$appName\nRefer Code:$REFER_CODE\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";
                            Share.share(str);
                          },
                        ),
                        // SimBtn(
                        //   size: 0.8,
                        //   title: getTranslated(context, "SHARE_APP"),
                        //   onBtnSelected: () {
                        //     var str =
                        //         "$appName\nRefer Code:$REFER_CODE\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";
                        //     Share.share(str);
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}