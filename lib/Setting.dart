import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Privacy_Policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';

class Setting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateSetting();
}

class StateSetting extends State<Setting> with TickerProviderStateMixin {
  TextEditingController curPassC, newPassC, confPassC;
  String curPass, newPass, confPass, mobile;
  bool _showPassword = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;

  Animation buttonSqueezeanimation;

  AnimationController buttonController;

  @override
  void initState() {
    super.initState();

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

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
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

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, OLDPASS: curPass, NEWPASS: newPass};

    Response response =
        await post(getUpdateUserApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    if (response.statusCode == 200) {
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'USER_UPDATE_MSG'));
      } else {
        setSnackbar(msg);
      }
    }
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

  changePass() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 10.0),
        child: Card(
            elevation: 0,
            shadowColor: colors.lightWhite,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        getTranslated(context, 'CHANGE_PASS_LBL'),
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle2
                            .copyWith(
                                color: colors.lightBlack,
                                fontWeight: FontWeight.bold),
                      )),
                  Spacer(),
                  Padding(
                      padding: EdgeInsetsDirectional.only(end: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: colors.primary,
                      )),
                ],
              ),
              onTap: () {
                _showDialog();
              },
            )));
  }

  changeLangauge() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: colors.lightWhite,
            child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          getTranslated(context, 'CHANGE_LANGUAGE_LBL'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                                  color: colors.lightBlack,
                                  fontWeight: FontWeight.bold),
                        )),
                    Spacer(),
                    Padding(
                        padding: EdgeInsetsDirectional.only(end: 15.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: colors.primary,
                        )),
                  ],
                ),
                onTap: () {
                  //   languageDialog();
                })));
  }

  changeTheme() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: colors.lightWhite,
            child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          getTranslated(context, 'CHANGE_THEME_LBL'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                                  color: colors.lightBlack,
                                  fontWeight: FontWeight.bold),
                        )),
                    Spacer(),
                    Padding(
                        padding: EdgeInsetsDirectional.only(end: 15.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: colors.primary,
                        )),
                  ],
                ),
                onTap: () {
                  //  themeDialog();
                })));
  }

  privacyPolicy() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: colors.lightWhite,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(getTranslated(context, 'PRIVACY'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                                  color: colors.lightBlack,
                                  fontWeight: FontWeight.bold))),
                  Spacer(),
                  Padding(
                      padding: EdgeInsetsDirectional.only(end: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: colors.primary,
                      )),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicy(
                        title: getTranslated(context, 'PRIVACY'),
                      ),
                    ));
              },
            )));
  }

  termCondition() {
    return Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 3.0),
        child: Card(
            elevation: 0,
            shadowColor: colors.lightWhite,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(getTranslated(context, 'TERM'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                                  color: colors.lightBlack,
                                  fontWeight: FontWeight.bold))),
                  Spacer(),
                  Padding(
                      padding: EdgeInsetsDirectional.only(end: 15.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: colors.primary,
                      )),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicy(
                        title: getTranslated(context, 'TERM'),
                      ),
                    ));
              },
            )));
  }

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'CHANGE_PASS_LBL'),
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: colors.fontColor),
                            )),
                        Divider(color: colors.lightBlack),
                        Form(
                            key: _formkey,
                            child: new Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (val) => validatePass(
                                          val,
                                          getTranslated(
                                              context, 'PWD_REQUIRED'),
                                          getTranslated(context, 'PWD_LENGTH')),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: getTranslated(
                                              context, 'CUR_PASS_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: curPassC,
                                      onChanged: (v) => setState(() {
                                        curPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (val) => validatePass(
                                          val,
                                          getTranslated(
                                              context, 'PWD_REQUIRED'),
                                          getTranslated(context, 'PWD_LENGTH')),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: getTranslated(
                                              context, 'NEW_PASS_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: newPassC,
                                      onChanged: (v) => setState(() {
                                        newPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value.length == 0)
                                          return getTranslated(
                                              context, 'CON_PASS_REQUIRED_MSG');
                                        if (value != newPass) {
                                          return getTranslated(context,
                                              'CON_PASS_NOT_MATCH_MSG');
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: getTranslated(
                                              context, 'CONFIRMPASSHINT_LBL'),
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1
                                              .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: colors.lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: confPassC,
                                      onChanged: (v) => setState(() {
                                        confPass = v;
                                      }),
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, 'CANCEL'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.lightBlack,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new TextButton(
                    child: Text(
                      getTranslated(context, 'SAVE_LBL'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formkey.currentState;
                      if (form.validate()) {
                        form.save();
                        if (mounted)
                          setState(() {
                            Navigator.pop(context);
                          });
                        // checkNetwork();
                      }
                    })
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: getAppBar(getTranslated(context, 'SETTING'), context),
      body: _isNetworkAvail
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  changePass(),
                  changeLangauge(),
                  changeTheme(),
                  privacyPolicy(),
                  termCondition(),
                ],
              ),
            )
          : noInternet(context),
    );
  }
}
