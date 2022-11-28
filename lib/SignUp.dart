import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool _showPassword = false;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final nameController1 = TextEditingController();
  final nameController2 = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  int count = 1;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String name1, name2,name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode firstnameFocus,
      secondnameFocus,
      emailFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    countrycode = await getPrefrence(COUNTRY_CODE);
    if (mounted) setState(() {});
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (referCode != null) getRegisterUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController.reverse();
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

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.fontColor),
      ),
      elevation: 1.0,
      backgroundColor: colors.lightWhite,
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

  Future<void> getRegisterUser() async {
    try {
      var data = {
        MOBILE: mobile,
        NAME: name1+" "+name2,
        EMAIL: email,
        PASSWORD: password,
        COUNTRY_CODE: countrycode,
        REFERCODE: referCode,
        FRNDCODE: friendCode
      };

      Response response =
          await post(getUserSignUpApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG'));
        var i = getdata["data"][0];

        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;
        CUR_USERNAME = name;
        saveUserDetail(id, name, email, mobile, city, area, address, pincode,
            latitude, longitude, "");

        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      } else {
        setSnackbar(msg);
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      await buttonController.reverse();
    }
  }

  subLogo() {
    return Expanded(
      flex: 2,
      child: Center(
        child: Container(
            height: deviceHeight*0.365,
            width: deviceWidth*0.765,
            child: new Image.asset('assets/images/homelogo.png')),
      ),
    );
  }

  registerTxt() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 30.0),
        child: Center(
          child: new Text(getTranslated(context, 'USER_REGISTER_DETAILS'),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: colors.fontColor, fontWeight: FontWeight.bold)),
        ));
  }

  setUserName() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: 30.0,
              start: 25.0,
              end: 3.0
            ),
            child: TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              controller: nameController1,
              focusNode: firstnameFocus,
              textInputAction: TextInputAction.next,
              style:
                  TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
              validator: (val) => validateUserName(
                  val,
                  getTranslated(context, 'USER_REQUIRED'),
                  getTranslated(context, 'USER_LENGTH')),
              onSaved: (String value) {
                name1 = value;
              },
              onFieldSubmitted: (v) {
                _fieldFocusChange(context, firstnameFocus, secondnameFocus);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: colors.fontColor,
                  size: 17,
                ),
                hintText: getTranslated(context, 'FIRSTNAME_LBL'),
                hintStyle: Theme.of(this.context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
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
            ),
          ),
        ),
        Expanded(child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: 30.0,
            start: 3.0,
            end: 25.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            controller: nameController2,
            focusNode: secondnameFocus,
            textInputAction: TextInputAction.next,
            style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
            validator: (val) => validateUserName(
                val,
                getTranslated(context, 'USER_REQUIRED'),
                getTranslated(context, 'USER_LENGTH')),
            onSaved: (String value) {
              name2 = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, secondnameFocus, emailFocus);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_outline,
                color: colors.fontColor,
                size: 17,
              ),
              hintText: getTranslated(context, 'LASTNAME_LBL'),
              hintStyle: Theme.of(this.context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
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
          ),
        ),),

      ],
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 25.0,
        end: 25.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, passFocus);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_outlined,
            color: colors.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
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
      ),
    );
  }

  setRefer() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 25.0,
        end: 25.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style:
            TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
        onSaved: (String value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: colors.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2
              .copyWith(color: colors.fontColor, fontWeight: FontWeight.normal),
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
      ),
    );
  }

  setPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !this._showPassword,
          focusNode: passFocus,
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus, referFocus);
          },
          textInputAction: TextInputAction.next,
          style:
              TextStyle(color: colors.fontColor, fontWeight: FontWeight.normal),
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

  showPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: colors.fontColor,
              activeColor: colors.lightWhite,
              onChanged: (bool value) {
                if (mounted)
                  setState(() {
                    _showPassword = value;
                  });
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD'),
                style: TextStyle(
                    color: colors.fontColor, fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'REGISTER_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  loginTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 30.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER'),
              style: Theme.of(context).textTheme.caption.copyWith(
                  color: colors.fontColor, fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL'),
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: colors.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS || Platform.isAndroid
        ? Container(
        margin: EdgeInsets.only(left: 10,top: 20),
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

  expandedBottomView() {
    return Expanded(
        flex: 8,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
                child: Form(
              key: _formkey,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsetsDirectional.only(
                    start: 20.0, end: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    registerTxt(),
                    setUserName(),
                    setEmail(),
                    setPass(),
                    setRefer(),
                    showPass(),
                    verifyBtn(),
                    loginTxt(),
                  ],
                ),
              ),
            )),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
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

    generateReferral();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? SafeArea(
                child: Container(
                    //color: colors.lightWhite,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.darkColor,
                            colors.darkColor.withOpacity(0.8),
                            Color(0xFFF8F8FF),
                          ]),
                    ),
                    padding: EdgeInsetsDirectional.only(
                      bottom: 20.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        backBtn(),
                        subLogo(),
                        expandedBottomView(),
                      ],
                    )),
              )
            : noInternet(context));
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };

      Response response =
          await post(validateReferalApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        referCode = refer;
        REFER_CODE = refer;
        if (mounted) setState(() {});
      } else {
        if (count < 5) generateReferral();
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
