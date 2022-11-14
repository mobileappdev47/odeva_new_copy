import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Home3.dart';
import 'package:eshop/Login.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Helper/Color.dart';
import 'SendOtp.dart';

class SignInUpAcc extends StatefulWidget {
  @override
  _SignInUpAccState createState() => new _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc> {
  bool isUpdate = false;

  _subLogo() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 30.0),
        child: Container(
          height: deviceHeight * 0.365,
          width: deviceWidth * 0.765,
          child: Image.asset(
            'assets/images/homelogo.png',
          ),
        ));
  }

  welcomeEshopTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 30.0),
      child: new Text(
        getTranslated(context, 'WELCOME_ESHOP'),
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: colors.fontColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 5.0,
      ),
      child: new Text(
        getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS'),
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
      ),
    );
  }

  signInyourAccTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 80.0, bottom: 40),
      child: new Text(
        getTranslated(context, 'SIGNIN_ACC_LBL'),
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: colors.fontColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  signInBtn() {
    return CupertinoButton(
      child: Container(
          width: deviceWidth * 0.8,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.grad1Color, colors.grad2Color],
                stops: [0, 1]),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'SIGNIN_LBL'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: colors.white, fontWeight: FontWeight.normal))),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      },
    );
  }

  createAccBtn() {
    return CupertinoButton(
      child: Container(
          width: deviceWidth * 0.8,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.grad1Color, colors.grad2Color],
                stops: [0, 1]),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'CREATE_ACC_LBL'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: colors.white, fontWeight: FontWeight.normal))),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SendOtp(
            title: getTranslated(context, 'SEND_OTP_TITLE'),
          ),
        ));
      },
    );
  }

  skipSignInBtn() {
    return CupertinoButton(
      child: Container(
          width: deviceWidth * 0.8,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.grad1Color, colors.grad2Color],
                stops: [0, 1]),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: colors.white, fontWeight: FontWeight.normal))),
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      },
    );
  }




  @override
  void initState() {
    checkVersion(context);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    print("call");
    checkVersion(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return  Container(
            //color: colors.lightWhite,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Color(0xFF280F43),
                    // Color(0xffE5CCFF),
                    Color(0xFF200738),
                    Color(0xFF3B147A),
                    Color(0xFFF8F8FF),
                  ]),
            ),
            child: Center(
                child: SingleChildScrollView(
                    child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _subLogo(),
                //welcomeEshopTxt(),
                //eCommerceforBusinessTxt(),
                //signInyourAccTxt(),
                signInBtn(),
                createAccBtn(),
                skipSignInBtn(),
              ],
            ))));
  }
}
