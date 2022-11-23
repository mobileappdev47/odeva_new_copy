import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop/Home3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/User.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

String lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {
  String name,
      email,
      mobile,
      city,
      area,
      pincode,
      address,
      image,
      cityName,
      areaName,
      curPass,
      newPass,
      confPass,
      loaction;
  List<User> cityList = [];
  List<User> areaList = [];
  bool _isLoading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameC,
      emailC,
      mobileC,
      pincodeC,
      addressC,
      curPassC,
      newPassC,
      confPassC;
  bool isSelected = false, isArea = true;
  bool _isNetworkAvail = true;
  bool _showPassword = false, _scPwd = false, _cPwd = false;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;

  @override
  void initState() {
    checkVersion(context);
    super.initState();

    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    emailC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC = new TextEditingController();
    getUserDetails();
    callApi();
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
  void didChangeDependencies() {
    checkVersion(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    buttonController.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC.dispose();
    pincodeC?.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
    name = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);
    city = await getPrefrence(CITY);
    area = await getPrefrence(AREA);
    pincode = await getPrefrence(PINCODE);
    address = await getPrefrence(ADDRESS);
    image = await getPrefrence(IMAGE);
    cityName = await getPrefrence(CITYNAME);
    areaName = await getPrefrence(AREANAME);

    mobileC.text = mobile;
    nameC.text = name;
    emailC.text = email;
    pincodeC.text = pincode;
    addressC.text = address;
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      if (city != null && city != "") {
        getArea(setState);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setUpdateUser();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> setProfilePic(File _image) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
      try {
        var request = http.MultipartRequest("POST", (getUpdateUserApi));
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID;
        var pic = await http.MultipartFile.fromPath(IMAGE, _image.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          setSnackbar(getTranslated(context, 'PROFILE_UPDATE_MSG'));
          List data = getdata["data"];
          for (var i in data) {
            image = i[IMAGE];
          }
          setPrefrence(IMAGE, image);
        } else {
          setSnackbar(msg);
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, USERNAME: name, EMAIL: email};
    if (newPass != null && newPass != "") {
      data[NEWPASS] = newPass;
    }
    if (curPass != null && curPass != "") {
      data[OLDPASS] = curPass;
    }
    if (city != null && city != "") {
      data[CITY] = city;
    }
    if (area != null && area != "") {
      data[AREA] = area;
    }
    if (address != null && address != "") {
      data[ADDRESS] = address;
    }
    if (pincode != null && pincode != "") {
      data[PINCODE] = pincode;
    }

    if (lat != null && lat != "") {
      data[LATITUDE] = lat;
    }
    if (long != null && long != "") {
      data[LONGITUDE] = long;
    }

    http.Response response = await http
        .post(getUpdateUserApi, body: data, headers: headers)
        .timeout(Duration(seconds: timeOut));
    if (response.statusCode == 200) {
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      await buttonController.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'USER_UPDATE_MSG'));
        var i = getdata["data"][0];

        CUR_USERID = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        city = i[CITY];
        area = i[AREA];
        address = i[ADDRESS];
        pincode = i[PINCODE];
        lat = i[LATITUDE];
        long = i[LONGITUDE];

        saveUserDetail(CUR_USERID, name, email, mobile, city, area, address,
            pincode, lat, long, image);
        setPrefrence(CITYNAME, cityName);
        setPrefrence(AREANAME, areaName);
      } else {
        setSnackbar(msg);
      }
    }
  }

  _imgFromGallery() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File image = File(result.files.single.path);
      if (image != null) {
        if (mounted)
          setState(() {
            _isLoading = true;
          });
        setProfilePic(image);
      }
    } else {
      // User canceled the picker
    }
  }

  Future<void> getCities() async {
    try {
      var response = await http
          .post(getCitiesApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        cityList =
            (data as List).map((data) => new User.fromJson(data)).toList();
        for (int i = 0; i < cityList.length; i++) {
          if (cityList[i].id == city) {
            if (mounted)
              setState(() {
                cityName = cityList[i].name;
              });
          }
        }
      } else {
        setSnackbar(msg);
      }
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> getArea(StateSetter setState) async {
    try {
      var data = {
        ID: city,
      };

      var response = await http
          .post(getAreaByCityApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        var data = getdata["data"];

        areaList.clear();
        area = null;

        areaList =
            (data as List).map((data) => new User.fromJson(data)).toList();

        if (areaList.length == 0) {
          areaName = "";
        } else {
          for (int i = 0; i < areaList.length; i++) {
            if (areaList[i].id == area) {
              areaName = areaList[i].name;
            }
          }
        }
      } else {
        setSnackbar(msg);
      }
      if (mounted)
        setState(() {
          isArea = true;
          _isLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.primary),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  setUser() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            SvgPicture.asset('assets/images/username.svg', fit: BoxFit.fill),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'NAME_LBL'),
                      style: Theme.of(this.context).textTheme.caption.copyWith(
                          color: colors.lightBlack2,
                          fontWeight: FontWeight.normal),
                    ),
                    name != "" && name != null
                        ? Text(
                      name,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                          color: colors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )
                        : Container()
                  ],
                )),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: colors.lightBlack,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0))),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                  child: Text(
                                    getTranslated(context, 'ADD_NAME_LBL'),
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: colors.fontColor),
                                  )),
                              Divider(color: colors.lightBlack),
                              Form(
                                  key: _formKey,
                                  child: Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                            color: colors.lightBlack,
                                            fontWeight: FontWeight.normal),
                                        validator: (val) => validateUserName(
                                            val,
                                            getTranslated(
                                                context, 'USER_REQUIRED'),
                                            getTranslated(
                                                context, 'USER_LENGTH')),
                                        autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                        controller: nameC,
                                        onChanged: (v) => setState(() {
                                          name = v;
                                        }),
                                      )))
                            ]),
                        actions: <Widget>[
                          new TextButton(
                              child: Text(getTranslated(context, 'CANCEL'),
                                  style: TextStyle(
                                      color: colors.lightBlack,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (mounted)
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                              }),
                          new TextButton(
                              child: Text(getTranslated(context, 'SAVE_LBL'),
                                  style: TextStyle(
                                      color: colors.fontColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  if (mounted)
                                    setState(() {
                                      name = nameC.text;
                                      Navigator.pop(context);
                                    });
                                  checkNetwork();
                                }
                              })
                        ],
                      );
                    });
              },
            )
          ],
        ));
  }

  setEmail() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            SvgPicture.asset('assets/images/email.svg', fit: BoxFit.fill),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'EMAILHINT_LBL'),
                      style: Theme.of(this.context).textTheme.caption.copyWith(
                          color: colors.lightBlack2,
                          fontWeight: FontWeight.normal),
                    ),
                    email != null && email != ""
                        ? Text(
                      email,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                          color: colors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )
                        : Container()
                  ],
                )),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: colors.lightBlack,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(0.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0))),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                  child: Text(
                                    getTranslated(context, 'ADD_EMAIL_LBL'),
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: colors.fontColor),
                                  )),
                              Divider(color: colors.lightBlack),
                              Form(
                                  key: _formKey,
                                  child: Padding(
                                      padding:
                                      EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                            color: colors.lightBlack,
                                            fontWeight: FontWeight.normal),
                                        validator: (val) => validateEmail(
                                            val,
                                            getTranslated(
                                                context, 'EMAIL_REQUIRED'),
                                            getTranslated(
                                                context, 'VALID_EMAIL')),
                                        autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                        controller: emailC,
                                        onChanged: (v) => setState(() {
                                          email = v;
                                        }),
                                      )))
                            ]),
                        actions: <Widget>[
                          new TextButton(
                              child: Text(getTranslated(context, 'CANCEL'),
                                  style: TextStyle(
                                      color: colors.lightBlack,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (mounted)
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                              }),
                          new TextButton(
                              child: Text(getTranslated(context, 'SAVE_LBL'),
                                  style: TextStyle(
                                      color: colors.fontColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  if (mounted)
                                    setState(() {
                                      email = emailC.text;
                                      Navigator.pop(context);
                                    });
                                  checkNetwork();
                                }
                              })
                        ],
                      );
                    });
              },
            )
          ],
        ));
  }

  setMobileNo() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: Row(
          children: <Widget>[
            SvgPicture.asset('assets/images/mobilenumber.svg',
                fit: BoxFit.fill),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'MOBILEHINT_LBL'),
                      style: Theme.of(this.context).textTheme.caption.copyWith(
                          color: colors.lightBlack2,
                          fontWeight: FontWeight.normal),
                    ),
                    mobile != null && mobile != ""
                        ? Text(
                      mobile,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                          color: colors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )
                        : Container()
                  ],
                )),
          ],
        ));
  }

  setLocation() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset('assets/images/location.svg', fit: BoxFit.fill),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'LOCATION_LBL'),
                      style: Theme.of(this.context).textTheme.caption.copyWith(
                          color: colors.lightBlack2,
                          fontWeight: FontWeight.normal),
                    ),
                    areaName != null && areaName != ""
                        ? Text(
                      "$cityName,$areaName",
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                          color: colors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )
                        : Text(
                      "${cityName ?? ''}",
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                          color: colors.lightBlack,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
            Spacer(),
            IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 20,
                  color: colors.lightBlack,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setStater) {
                        return AlertDialog(
                          contentPadding: const EdgeInsets.all(0.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(5.0))),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                  child: Text(
                                    getTranslated(context, 'ADD_LOCATION_LBL'),
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                        color: colors.fontColor,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Divider(color: colors.lightBlack),
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                  child: Text(
                                    getTranslated(context, 'CITY_LBL'),
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                        color: colors.lightBlack,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                  child: DropdownButtonFormField(
                                    isDense: true,
                                    iconEnabledColor: colors.fontColor,
                                    hint: new Text(
                                      getTranslated(context, 'CITYSELECT_LBL'),
                                      style: Theme.of(this.context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                          color: colors.fontColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value: city,
                                    onChanged: (newValue) {
                                      if (mounted)
                                        setState(() {
                                          city = newValue;
                                          isArea = false;
                                        });

                                      getArea(setStater);
                                    },
                                    items: cityList.map((User user) {
                                      return DropdownMenuItem<String>(
                                        value: user.id,
                                        child: Text(
                                          user.name,
                                          style: Theme.of(this.context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                              color: colors.fontColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          setStater(() {
                                            cityName = user.name;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  )),
                              SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                  child: Text(
                                    getTranslated(context, 'AREA_LBL'),
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                        color: colors.lightBlack,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                  padding:
                                  EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                  child: DropdownButtonFormField(
                                    isDense: true,
                                    iconEnabledColor: colors.fontColor,
                                    hint: new Text(
                                      getTranslated(context, 'AREASELECT_LBL'),
                                      style: Theme.of(this.context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                          color: colors.fontColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value: area,
                                    onChanged: isArea
                                        ? (newValue) {
                                      if (mounted)
                                        setState(() {
                                          area = newValue;
                                        });
                                    }
                                        : null,
                                    items: areaList.map((User user) {
                                      return DropdownMenuItem<String>(
                                        value: user.id,
                                        child: Text(
                                          user.name,
                                          style: Theme.of(this.context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                              color: colors.fontColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          setStater(() {
                                            areaName = user.name;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  )),
                            ],
                          ),
                          actions: <Widget>[
                            new TextButton(
                                child: Text(getTranslated(context, 'CANCEL'),
                                    style: TextStyle(
                                        color: colors.lightBlack,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  if (mounted)
                                    setState(() async {
                                      Navigator.pop(context);
                                    });
                                }),
                            new TextButton(
                                child: Text(getTranslated(context, 'SAVE_LBL'),
                                    style: TextStyle(
                                        color: colors.fontColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  if (areaName != "" &&
                                      areaName != null &&
                                      cityName != null &&
                                      cityName != "") {
                                    if (mounted)
                                      setState(() {
                                        Navigator.pop(context);
                                        checkNetwork();
                                      });
                                  }
                                })
                          ],
                        );
                      });
                    },
                  );
                })
          ],
        ));
  }

  changePass() {
    return Container(
        height: 60,
        width: deviceWidth,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: InkWell(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 20.0, top: 15.0, bottom: 15.0),
                child: Text(
                  getTranslated(context, 'CHANGE_PASS_LBL'),
                  style: Theme.of(this.context).textTheme.subtitle2.copyWith(
                      color: colors.fontColor, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                _showDialog();
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
                                key: _formKey,
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
                                                icon: Icon(_cPwd
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                iconSize: 20,
                                                color: colors.lightBlack,
                                                onPressed: () {
                                                  setStater(() {
                                                    _cPwd = !_cPwd;
                                                  });
                                                },
                                              )),
                                          obscureText: !_cPwd,
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
                                              return getTranslated(
                                                  context, 'CON_PASS_REQUIRED_MSG');
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
                                                icon: Icon(_scPwd
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                iconSize: 20,
                                                color: colors.lightBlack,
                                                onPressed: () {
                                                  setStater(() {
                                                    _scPwd = !_scPwd;
                                                  });
                                                },
                                              )),
                                          obscureText: !_scPwd,
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
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            if (mounted)
                              setState(() {
                                Navigator.pop(context);
                              });
                            checkNetwork();
                          }
                        })
                  ],
                );
              });
        });
  }

  profileImage() {
    return Container(
        padding: EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 30.0),
        child: Stack(
          children: <Widget>[
            image != null && image != ""
                ? CircleAvatar(
                radius: 50,
                backgroundColor: colors.primary,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: new FadeInImage(
                    fadeInDuration: Duration(milliseconds: 150),
                    image: NetworkImage(image),
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                    placeholder: placeHolder(100),
                  ),
                ))
                : Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: colors.primary)),
                child: Icon(Icons.account_circle, size: 100)),
            Positioned(
                bottom: 3,
                right: 5,
                child: Container(
                  height: 20,
                  width: 20,
                  child: InkWell(
                    child: Icon(
                      Icons.edit,
                      color: colors.white,
                      size: 10,
                    ),
                    onTap: () {
                      if (mounted)
                        setState(() {
                          _imgFromGallery();
                          //_showPicker(context);
                        });
                    },
                  ),
                  decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(color: colors.primary)),
                )),
          ],
        ));
  }

  updateBtn() {
    return AppBtn(
      title: getTranslated(context, 'UPDATE_PROFILE_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () {
        validateAndSubmit();
      },
    );
  }

  _getDivider() {
    return Divider(
      height: 1,
      color: colors.lightBlack,
    );
  }

  _showContent1() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
      // Color(0xFF280F43),
      // Color(0xffE5CCFF),
        colors.darkColor,
        colors.darkColor.withOpacity(0.8),
      Color(0xFFF8F8FF),
      ]),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: _isNetworkAvail
                        ? Column(children: <Widget>[
                      profileImage(),
                      Padding(
                          padding: const EdgeInsetsDirectional.only(
                              top: 20, bottom: 5.0),
                          child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10.0))),
                              child: Column(
                                children: <Widget>[
                                  setUser(),
                                  _getDivider(),
                                  setEmail(),
                                  _getDivider(),
                                  setMobileNo(),
                                  _getDivider(),
                                  setLocation(),
                                ],
                              ))),
                      changePass()
                    ])
                        : noInternet(context))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor:  colors.darkColor,
        titleSpacing: 0,
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
          "Edit Profile",
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _showContent1(),
          showCircularProgress(_isLoading, colors.primary)
        ],
      ),
    );
  }
}

