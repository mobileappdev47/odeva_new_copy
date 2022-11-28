import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Home3.dart';
import 'package:eshop/SendOtp.dart';
import 'package:eshop/chat_fire/chat_room_service.dart';
import 'package:eshop/firebase_message/firebase_message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String countryName;
  FocusNode passFocus, monoFocus;
  ScrollController _scrollController = ScrollController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  @override
  void initState() {
    super.initState();
    monoFocus = FocusNode()
      ..addListener(() {
        _scrollController.jumpTo(10);
      });
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        await buttonController.reverse();
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.fontColor),
      ),
      backgroundColor: colors.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  intializeFirebase(String email, String mobileNo) async {
    DocumentSnapshot doc;
    String fcmToken = await MessageService().getFcmToken();
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: "123456");
      print(user.user.uid);
      final FirebaseAuth auth = FirebaseAuth.instance;
      print(auth.currentUser);


      if (user.user.uid != null) {
        doc = await ChatRoomservice().isRoomAvailable(mobileNo);
        if (doc.exists) {
          // DocumentSnapshot docs = await FirebaseFirestore.instance
          //     .collection("chatroom")
          //     .doc(mobileNo)
          //     .get();
          Map data = doc.data() as Map;
          if (data["isManager"].toString() == "true") {
            await FirebaseFirestore.instance.collection("chatroom").doc(mobileNo).update({"fcmToken":fcmToken});
            setPrefrence("isManager", "true");
            isManager = "true";
          } else {
            await FirebaseFirestore.instance.collection("chatroom").doc(mobileNo).update({"fcmToken":fcmToken});
            setPrefrence("isManager", "false");
            isManager = "false";
          }
        } else {
          setPrefrence("isManager", "false");
          isManager = "false";
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: "123456");
        print(user.user.uid);
      }
    }
  }

  Future<void> getLoginUser() async {
    var data = {MOBILE: mobile, PASSWORD: password};
print("DATE LOGIN :  $data");
    Response response =
        await post(getUserLoginApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);

    bool error = getdata["error"];
    String msg = getdata["message"];
    await buttonController.reverse();
    if (!error) {
      setSnackbar(msg);

      var i = getdata["data"][0];

      id = i[ID];
      username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
      image = i[IMAGE];
      intializeFirebase(
          i[EMAIL] == "" ? "stackapp.dev@gmail.com" : i[EMAIL], i[MOBILE]);
      CUR_USERID = id;
      CUR_USERNAME = username;

      saveUserDetail(id, username, email, mobile, city, area, address, pincode,
          latitude, longitude, image);

      Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
    } else {
      setSnackbar(msg);
    }
  }

  _subLogo() {
    return Container(
      // padding: EdgeInsets.only(top: 10),
      height: deviceHeight * 0.15,
      width: deviceWidth * 0.765,
      child: Image.asset(
        'assets/images/homelogo.png',
        fit: BoxFit.fill,
      ),
    );
  }

  signInTxt() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 10.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            getTranslated(context, 'SIGNIN_LBL'),
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: colors.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ));
  }

  setMobileNo() {
    return Container(
      width: deviceWidth * 0.7,
      padding: EdgeInsetsDirectional.only(
        top: 5.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.call_outlined,
            color: colors.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: colors.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.fontColor),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.lightWhite),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Container(
        width: deviceWidth * 0.7,
        padding: EdgeInsetsDirectional.only(top: 16.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: true,
          focusNode: passFocus,
          style: TextStyle(color: colors.fontColor),
          onTap: () {
            setState(() {
              Future.delayed(Duration(seconds: 1), () {
                if (_scrollController.position.hasPixels) {
                  _scrollController.position.animateTo(100,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.bounceOut);
                }
              });

              /*        _scrollController.position.animateTo(200,
                  duration: Duration(milliseconds: 100), curve: Curves.bounceOut);*/
            });
            /*      monoFocus = FocusNode()..addListener(() {
              _scrollController.jumpTo(200);
            });*/
          },
          controller: passwordController,
          validator: (val) => validatePass(
              val,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String value) {
            password = value;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: colors.fontColor,
              size: 17,
            ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(this.context).textTheme.subtitle2.copyWith(
                color: colors.fontColor, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: colors.lightWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.lightWhite),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  forgetPass() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: 15.0, end: 25.0, top: 7.0, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrence(ID, id);
                setPrefrence(MOBILE, mobile);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendOtp(
                              title:
                                  getTranslated(context, 'FORGOT_PASS_TITLE'),
                            )));
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL'),
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: colors.fontColor, fontWeight: FontWeight.normal)),
            ),
          ],
        ));
  }

  termAndPolicyTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'DONT_HAVE_AN_ACC'),
              style: Theme.of(context).textTheme.caption.copyWith(
                  color: colors.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ));
              },
              child: Text(
                getTranslated(context, 'SIGN_UP_LBL'),
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: Color(0xfffed100),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: 21),
              ))
        ],
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, 'SIGNIN_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  _expandedBottomView() {
    return Expanded(
      //  flex: 2,
      child: Container(
        padding: EdgeInsets.only(top: 5),
        alignment: Alignment.center,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Form(
                key: _formkey,
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsetsDirectional.only(
                      start: 20.0, end: 20.0, top: 2.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      signInTxt(),
                      setMobileNo(),
                      setPass(),
                      forgetPass(),
                      loginBtn(),
                      termAndPolicyTxt(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  backBtn() {
    return Platform.isIOS || Platform.isAndroid
        ? Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            padding: EdgeInsets.only(top: 20.0, left: 10.0),
            alignment: Alignment.topLeft,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InkWell(
                  child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Container(
                //color: colors.lightWhite,
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
                // padding: EdgeInsetsDirectional.only(
                //   bottom: 2.0,
                // ),
                child: Column(
                  children: <Widget>[
                    backBtn(),
                    _subLogo(),
                    _expandedBottomView(),
                  ],
                ))
            : noInternet(context));
  }
}
