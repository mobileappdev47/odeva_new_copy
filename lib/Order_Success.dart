import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/MyOrder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Helper/String.dart';
class OrderSuccess extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.darkColor,
        elevation: 0,
        leading: InkWell(
          onTap: (){
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false);
          },
          child: Icon(Icons.arrow_back,color: Colors.white,),
        ),
      ),

      // appBar: AppBar(
      //   titleSpacing: 0,
      //   backgroundColor: Color(0xff200738),
      //   leadingWidth: 15,
      //   // leading: Builder(builder: (BuildContext context) {
      //   //   return Container(
      //   //     margin: EdgeInsets.all(10),
      //   //     decoration: shadow(),
      //   //     child: Card(
      //   //       elevation: 0,
      //   //       child: InkWell(
      //   //         borderRadius: BorderRadius.circular(4),
      //   //         onTap: () => Navigator.of(context).pop(),
      //   //         child: Center(
      //   //           child: Icon(
      //   //             Icons.keyboard_arrow_left,
      //   //             color: colors.primary,
      //   //           ),
      //   //         ),
      //   //       ),
      //   //     ),
      //   //   );
      //   // }),
      //   title: Text( getTranslated(context, 'ORDER_PLACED'),
      //     style: TextStyle(
      //       color: colors.fontColor,
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF280F43),
                // Color(0xffE5CCFF),
                // Color(0xff315835),
                // Color(0xff315835).withOpacity(0.5),
                colors.darkColor,
                colors.darkColor2,
                Color(0xFFF8F8FF),
              ]),
        ),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      getTranslated(context,'ORD_PLC'),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  Text(
                    getTranslated(context,'ORD_PLC_SUCC'),
                    style: TextStyle(color: colors.fontColor),
                  ),
                  Container(
                    padding: EdgeInsets.all(25),
                    margin: EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 0),
                    child: SvgPicture.asset("assets/images/orderplaced.svg"),
                    decoration: BoxDecoration(
                        color: colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 0.0),
                    child: CupertinoButton(
                      child: Container(
                          width: deviceWidth * 0.7,
                          height: 45,
                          alignment: FractionalOffset.center,
                          decoration: new BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [colors.grad1Color, colors.grad2Color],
                                stops: [0, 1]),
                            borderRadius:
                            new BorderRadius.all(const Radius.circular(10.0)),
                          ),
                          child: Text(getTranslated(context, 'CONTINUE_SHOPPING'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6.copyWith(
                                  color: colors.white, fontWeight: FontWeight.normal))),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home', (Route<dynamic> route) => false);
                      },
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Container(
                        width: deviceWidth * 0.7,
                        height: 45,
                        alignment: FractionalOffset.center,
                        decoration: new BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colors.grad1Color, colors.grad2Color],
                              stops: [0, 1]),
                          borderRadius:
                          new BorderRadius.all(const Radius.circular(10.0)),
                        ),
                        child: Text("MY ORDERS",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6.copyWith(
                                color: colors.white, fontWeight: FontWeight.normal))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyOrder(isback: true,)),
                      );
                    },
                  ),
                  SizedBox(height: 20,),
                  // Container(
                  //   padding: EdgeInsets.only(left: 60),
                  //   width: Get.width,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         getTranslated(context, 'flllows'),
                  //         style: TextStyle(
                  //             color: Colors.white, fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 20,),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 60),
                  //   child: Row(
                  //     children: [
                  //       InkWell(
                  //         onTap: () {
                  //           url("https://www.facebook.com/Odeva.click/");
                  //         },
                  //         child: Container(
                  //             height: 40,
                  //             width: 40,
                  //             child: Image.asset(
                  //               "assets/images/facebook.png",
                  //               fit: BoxFit.cover,
                  //             )),
                  //       ),
                  //       SizedBox(
                  //         width: 20,
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           url("https://www.instagram.com/accounts/login/?next=/odeva.click/");
                  //         },
                  //         child: Container(
                  //             height: 40,
                  //             width: 40,
                  //             child: Image.asset(
                  //               "assets/images/Instagram.png",
                  //               fit: BoxFit.cover,
                  //             )),
                  //       ),
                  //       SizedBox(
                  //         width: 20,
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           url("https://www.tiktok.com/@odevaapp");
                  //         },
                  //         child: Container(
                  //             height: 40,
                  //             width: 40,
                  //             child: Image.asset(
                  //               "assets/images/tiktok.png",
                  //               fit: BoxFit.cover,
                  //             )),
                  //       ),
                  //       SizedBox(
                  //         width: 20,
                  //       ),
                  //       InkWell(
                  //         onTap: () {
                  //           url("https://twitter.com/Odeva_app");
                  //         },
                  //         child: Container(
                  //             height: 40,
                  //             width: 40,
                  //             child: Image.asset(
                  //               "assets/images/twitter.png",
                  //               fit: BoxFit.cover,
                  //             )),
                  //       )
                  //     ],
                  //   ),
                  // ),
                ],
              )),
        ),
      ),
    );
  }
  url(String url) async {
    // ignore: deprecated_member_use
    await launch(url);
  }
}
