import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';

import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

// ignore: must_be_immutable
class AddAddress extends StatefulWidget {
  final bool update;
  final int index;
  Function refresh;

  AddAddress({Key key, this.update, this.index, this.refresh})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

String latitude, longitude, state, country, pincode;

class StateAddress extends State<AddAddress> with TickerProviderStateMixin {
  String name1,
      name2,
      mobile,
      city,
      area,
      address,
      landmark,
      altMob,
      type = "Home",
      isDefault;
  bool checkedDefault = false, isArea = true;
  bool _isProgress = false;

  //bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<User> cityList = [];
  List<User> areaList = [];
  TextEditingController nameC1,
      nameC2,
      mobileC,
      pincodeC,
      addressC,
      landmarkC,
      stateC,
      altMobC;
  TextEditingController cityC = TextEditingController();
  TextEditingController countryC = TextEditingController();
  int selectedType = 1;
  bool _isNetworkAvail = true;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  FocusNode firstnameFocus,
      secondnameFocus,
      monoFocus,
      almonoFocus,
      addFocus,
      landFocus,
      pinFocus,
      cityFocus,
      countryFocus,
      locationFocus = FocusNode();

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
    callApi();

    mobileC = new TextEditingController();
    nameC1 = new TextEditingController();
    nameC2 = new TextEditingController();
    altMobC = new TextEditingController();
    pincodeC = new TextEditingController();
    addressC = new TextEditingController();
    stateC = new TextEditingController();
    countryC = new TextEditingController();
    landmarkC = new TextEditingController();

    if (widget.update) {
      User item = addressList[widget.index];
      mobileC.text = item.mobile;
      nameC1.text = item.name.toString().split(" ")[0];
      nameC2.text = item.name.toString().split(" ")[1];
      altMobC.text = item.altMob;
      landmarkC.text = item.landmark;
      pincodeC.text = item.pincode;
      addressC.text = item.address;
      stateC.text = item.state;
      countryC.text = item.country;
      stateC.text = item.state;
      latitude = item.latitude;
      longitude = item.longitude;

      type = item.type;
      city = item.cityId;
      area = item.areaId;
      if (type.toLowerCase() == HOME.toLowerCase())
        selectedType = 1;
      else if (type.toLowerCase() == OFFICE.toLowerCase())
        selectedType = 2;
      else
        selectedType = 3;

      checkedDefault = item.isDefault == "1" ? true : false;
    } else {
      // countryC.text="United Kingdom";
      countryC.text = "India";
      getCurrentLoc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: colors.darkColor,
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
          getTranslated(context, 'ADDRESS_LBL'),
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
      ),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
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

  addBtn() {
    return AppBtn(
      title: widget.update
          ? getTranslated(context, 'UPDATEADD')
          : getTranslated(context, 'ADDADDRESS'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () {
        validateAndSubmit();
      },
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState;

    form.save();
    if (form.validate()) {
      if (city == null || city.isEmpty) {
        setSnackbar(getTranslated(context, 'cityWarning'));
      } else if (area == null || area.isEmpty) {
        area = "India";
        return true;
        // setSnackbar(getTranslated(context, 'areaWarning'));
      }
      // else if (latitude == null || longitude == null) {
      //   setSnackbar(getTranslated(context, 'locationWarning'));
      // }
      else
        return true;
    }
    return false;
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      addNewAddress();
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

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  username() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              focusNode: firstnameFocus,
              controller: nameC1,
              textCapitalization: TextCapitalization.words,
              validator: (val) => validateUserName(
                  val,
                  getTranslated(context, 'FIRSTNAME_REQUIRED'),
                  getTranslated(context, 'USER_LENGTH')),
              onSaved: (String value) {
                name1 = value;
              },
              onFieldSubmitted: (v) {
                _fieldFocusChange(context, firstnameFocus, secondnameFocus);
              },
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: colors.fontColor),
              decoration: InputDecoration(
                isDense: true,
                hintText: getTranslated(context, 'FIRSTNAME_LBL'),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              focusNode: secondnameFocus,
              controller: nameC2,
              textCapitalization: TextCapitalization.words,
              validator: (val) => validateUserName(
                  val,
                  getTranslated(context, 'SECONDNAME_REQUIRED'),
                  getTranslated(context, 'USER_LENGTH')),
              onSaved: (String value) {
                name2 = value;
              },
              onFieldSubmitted: (v) {
                _fieldFocusChange(context, secondnameFocus, monoFocus);
              },
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: colors.fontColor),
              decoration: InputDecoration(
                isDense: true,
                hintText: getTranslated(context, 'LASTNAME_LBL'),
              ),
            ),
          )
        ],
      ),
    );
  }

  setMobileNo() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: mobileC,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      focusNode: monoFocus,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      validator: (val) => validateMob(
          val,
          getTranslated(context, 'MOB_REQUIRED'),
          getTranslated(context, 'VALID_MOB')),
      onSaved: (String value) {
        mobile = value;
      },
      onFieldSubmitted: (v) {
        _fieldFocusChange(context, monoFocus, almonoFocus);
      },
      decoration: InputDecoration(
        hintText: getTranslated(context, 'MOBILEHINT_LBL'),
        isDense: true,
      ),
    );
  }

  setAltMobileNo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: altMobC,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        focusNode: almonoFocus,
        validator: (val) =>
            validateAltMob(val, getTranslated(context, 'VALID_MOB')),
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(color: colors.fontColor),
        onSaved: (String value) {
          altMob = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, almonoFocus, addFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'ALT_MOB'),
        ),
      ),
    );
  }

  /*setCities() {

    return DropdownButtonFormField(
      iconEnabledColor: colors.fontColor,
      isDense: true,
      hint: new Text(
        getTranslated(context, 'CITYSELECT_LBL'),
      ),
      value: city,
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        setState(() {
          currentFocus.unfocus();
        });
      },
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      onChanged: (String newValue) {
        if (mounted)
          setState(() {
            FocusScopeNode currentFocus = FocusScope.of(context);
            city = newValue;
            isArea = false;
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          });
        getArea(city, true);
      },
      items: cityList.map((User user) {
        return DropdownMenuItem<String>(
          value: user.id,
          child: Text(
            user.name,
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 5),
      ),
    );
  }*/

  setCities() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      controller: cityC,
      focusNode: cityFocus,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String value) {
        city = value;
      },
      validator: (val) =>
          validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
      decoration: InputDecoration(
        hintText: "City Name",
        isDense: true,
      ),
    );
  }

  ///country list dropdown
/*  setArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField(
        iconEnabledColor: colors.fontColor,
        isDense: true,
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(color: colors.fontColor),
        hint: new Text(
          getTranslated(context, 'AREASELECT_LBL'),
        ),
        value: area,
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          setState(() {
            currentFocus.unfocus();
          });
        },
        onChanged: isArea
            ? (newValue) {
                if (mounted)
                  setState(() {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    area = newValue;
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  });
              }
            : null,
        items: areaList.map((User user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.name,
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: new EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }*/

  setArea() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      controller: countryC,
      focusNode: countryFocus,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String value) {
        country = value;
      },
      validator: (val) =>
          validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
      decoration: InputDecoration(
        hintText: "Country Name",
        isDense: true,
      ),
    );
  }

  setAddress() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context)
                .textTheme
                .subtitle2
                .copyWith(color: colors.fontColor),
            focusNode: addFocus,
            controller: addressC,
            validator: (val) =>
                validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
            onSaved: (String value) {
              address = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addFocus, locationFocus);
            },
            decoration: InputDecoration(
              hintText: "First Line of Address",
              //getTranslated(context, 'ADDRESS_LBL'),
              isDense: true,
            ),
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 5),
          width: 40,
          child: IconButton(
            icon: new Icon(
              Icons.my_location,
              size: 20,
            ),
            focusNode: locationFocus,
            onPressed: () async {
              Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);

              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Map(
                            latitude: latitude == null
                                ? position.latitude
                                : double.parse(latitude),
                            longitude: longitude == null
                                ? position.longitude
                                : double.parse(longitude),
                            from: getTranslated(context, 'ADDADDRESS'),
                          )));
              if (mounted) setState(() {});
              List<Placemark> placemark = await placemarkFromCoordinates(
                  double.parse(latitude), double.parse(longitude));
              state = ""; //placemark[0].administrativeArea;
              country = "United Kingdom"; //placemark[0].country;
              pincode = placemark[0].postalCode;
              var address;
              address = placemark[0].name;
              address = address + " " + placemark[0].subLocality;
              addressC.text = address;
              if (mounted)
                setState(() {
                  //countryC.text = "United Kingdom";
                  //stateC.text = state;
                  pincodeC.text = pincode;
                  addressC.text = address;
                });
            },
          ),
        )
      ],
    );
  }

  setPincode() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      controller: pincodeC,
      focusNode: pinFocus,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String value) {
        pincode = value;
      },
      validator: (val) =>
          validatePincode(val, getTranslated(context, 'PIN_REQUIRED')),
      decoration: InputDecoration(
        hintText: "Postcode (Please enter space between sections)",
        //getTranslated(context, 'PINCODEHINT_LBL'),
        isDense: true,
      ),
    );
  }

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCities();
      if (widget.update) {
        getArea(addressList[widget.index].cityId, false);
      }
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      });
    }
  }

  Future<void> getCities() async {
    try {
      Response response = await post(getCitiesApi, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        cityList =
            (data as List).map((data) => new User.fromJson(data)).toList();
      } else {
        setSnackbar(msg);
      }
      if (mounted) if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  Future<void> getArea(String city, bool clear) async {
    try {
      var data = {
        ID: city,
      };

      Response response =
          await post(getAreaByCityApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        var data = getdata["data"];
        areaList.clear();
        if (clear) area = null;
        areaList =
            (data as List).map((data) => new User.fromJson(data)).toList();
      } else {
        setSnackbar(msg);
      }
      if (mounted) if (mounted)
        setState(() {
          isArea = true;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
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

  setLandmark() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      focusNode: landFocus,
      controller: landmarkC,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      onFieldSubmitted: (v) {
        _fieldFocusChange(context, landFocus, pinFocus);
      },

      // validator: (val) =>
      //     validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
      onSaved: (String value) {
        landmark = value;
      },
      decoration: InputDecoration(
        hintText: "Second Line of Address (Optional)",
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  setStateField() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: stateC,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      readOnly: true,
      //validator: validateField,
      onChanged: (v) => setState(() {
        state = v;
      }),
      onSaved: (String value) {
        state = value;
      },
      decoration: InputDecoration(
        hintText: getTranslated(context, 'STATE_LBL'),
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  setCountry() {
    return TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      controller: countryC,
      // readOnly: true,
      style: Theme.of(context)
          .textTheme
          .subtitle2
          .copyWith(color: colors.fontColor),
      onSaved: (String value) {
        country = value;
      },
      validator: (val) =>
          validateField(val, getTranslated(context, 'FIELD_REQUIRED')),
      decoration: InputDecoration(
        hintText: getTranslated(context, 'COUNTRY_LBL'),
        isDense: true,
        contentPadding: new EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  Future<void> addNewAddress() async {
    if (mounted)
      setState(() {
        _isProgress = true;
      });

    try {
      var data = {
        USER_ID: CUR_USERID,
        NAME: name1 + " " + name2,
        MOBILE: mobile,
        PINCODE: pincode,
        CITY_ID: city,
        AREA_ID: area,
        ADDRESS: address,
        STATE: " ",
        COUNTRY: " ",
        TYPE: type,
        ISDEFAULT: checkedDefault.toString() == "true" ? "1" : "0",
        LATITUDE: latitude != 0.0 && latitude != null ? latitude : "0",
        LONGITUDE: longitude != 0.0 && longitude != null ? longitude : "0",
        'landmark': landmark != "" ? landmark : "",
      };
      if (widget.update) data[ID] = addressList[widget.index].id;
      print("Parametrs of add address: " + data.toString());
      Response response = await post(
              widget.update ? updateAddressApi : getAddAddressApi,
              body: data,
              headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];

        await buttonController.reverse();
        if (!error) {
          var data = getdata["data"];

          if (widget.update) {
            if (checkedDefault.toString() == "true" ||
                addressList.length == 1) {
              for (User i in addressList) {
                i.isDefault = "0";
              }

              addressList[widget.index].isDefault = "1";

              if (!ISFLAT_DEL) {
                if (oriPrice <
                    double.parse(addressList[selectedAddress].freeAmt)) {
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                } else
                  delCharge = 0;

                totalPrice = totalPrice - delCharge;
              }

              User value = new User.fromAddress(data[0]);

              addressList[widget.index] = value;

              selectedAddress = widget.index;
              selAddress = addressList[widget.index].id;

              if (!ISFLAT_DEL) {
                if (totalPrice <
                    double.parse(addressList[selectedAddress].freeAmt)) {
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                } else
                  delCharge = 0;
                totalPrice = totalPrice + delCharge;
              }
            }
          } else {
            User value = new User.fromAddress(data[0]);
            addressList.add(value);

            if (checkedDefault.toString() == "true" ||
                addressList.length == 1) {
              for (User i in addressList) {
                i.isDefault = "0";
              }

              addressList[widget.index].isDefault = "1";

              if (!ISFLAT_DEL && addressList.length != 1) {
                if (oriPrice <
                    double.parse(addressList[selectedAddress].freeAmt)) {
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                } else
                  delCharge = 0;

                totalPrice = totalPrice - delCharge;
              }

              selectedAddress = widget.index;
              selAddress = addressList[widget.index].id;

              if (!ISFLAT_DEL) {
                if (totalPrice <
                    double.parse(addressList[selectedAddress].freeAmt)) {
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                } else
                  delCharge = 0;
                totalPrice = totalPrice + delCharge;
              }
            }
          }

          if (mounted)
            setState(() {
              _isProgress = false;
            });

          if (widget.refresh != null) {
            widget.refresh();
          }

          Navigator.of(context).pop();
        } else {
          setSnackbar(msg);
          showAlertDialog(context, msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  showAlertDialog(BuildContext context, String msg) {
    // set up the button
    // ignore: deprecated_member_use
    Widget okButton = FlatButton(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text("OK"),
      ),
      onPressed: () {
        if (mounted)
          setState(() {
            _isProgress = false;
            Navigator.pop(context);
          });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text("My title"),
      content: Text(msg), //Text("Error Msg"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    buttonController.dispose();
    mobileC?.dispose();
    nameC1?.dispose();
    nameC2?.dispose();
    stateC?.dispose();
    countryC?.dispose();
    altMobC?.dispose();
    landmarkC?.dispose();
    addressC.dispose();
    pincodeC?.dispose();

    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  typeOfAddress() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: InkWell(
            child: Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: selectedType,
                  activeColor: colors.fontColor,
                  value: 1,
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        selectedType = val;
                        type = HOME;
                      });
                  },
                ),
                Expanded(child: Text(getTranslated(context, 'HOME_LBL')))
              ],
            ),
            onTap: () {
              if (mounted)
                setState(() {
                  selectedType = 1;
                  type = HOME;
                });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            child: Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: selectedType,
                  activeColor: colors.fontColor,
                  value: 2,
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        selectedType = val;
                        type = OFFICE;
                      });
                  },
                ),
                Expanded(child: Text(getTranslated(context, 'OFFICE_LBL')))
              ],
            ),
            onTap: () {
              if (mounted)
                setState(() {
                  selectedType = 2;
                  type = OFFICE;
                });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            child: Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: selectedType,
                  activeColor: colors.fontColor,
                  value: 3,
                  onChanged: (val) {
                    if (mounted)
                      setState(() {
                        selectedType = val;
                        type = OTHER;
                      });
                  },
                ),
                Expanded(child: Text(getTranslated(context, 'OTHER_LBL')))
              ],
            ),
            onTap: () {
              if (mounted)
                setState(() {
                  selectedType = 3;
                  type = OTHER;
                });
            },
          ),
        )
      ],
    );
  }

  defaultAdd() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: SwitchListTile(
          value: checkedDefault,
          activeColor: Theme.of(context).accentColor,
          dense: true,
          onChanged: (newValue) {
            if (mounted)
              setState(() {
                checkedDefault = newValue;
              });
          },
          title: Text(
            getTranslated(context, 'DEFAULT_ADD'),
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                color: colors.lightBlack, fontWeight: FontWeight.bold),
          ),
        ));
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
    //name = await getPrefrence(USERNAME);
    //email = await getPrefrence(EMAIL);
    // city = await getPrefrence(CITY);
    // area = await getPrefrence(AREA);
    // pincode = await getPrefrence(PINCODE);
    // address = await getPrefrence(ADDRESS);
    // image = await getPrefrence(IMAGE);
    // cityName = await getPrefrence(CITYNAME);
    // areaName = await getPrefrence(AREANAME);

    mobileC.text = mobile;
    //nameC.text = name;
    //emailC.text = email;
    // pincodeC.text = pincode;
    // addressC.text = address;
  }

  _showContent() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Color(0xFF280F43),
                  // Color(0xffE5CCFF),
                  // Color(0xFF200738),
                  // Color(0xFF3B147A),
                  colors.darkColor,
                  colors.darkColor.withOpacity(0.8),
                  Color(0xFFF8F8FF),
                ]),
          ),
          child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    //setUserName(),
                                    username(),
                                    setMobileNo(),
                                    //setAltMobileNo(),
                                    setAddress(),
                                    setLandmark(),
                                    setCities(),
                                    setArea(),
                                    setPincode(),
                                    //setStateField(),
                                    //setCountry(),
                                    typeOfAddress(),

                                    // addBtn(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          defaultAdd(),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        height: 55,
                        decoration: new BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colors.grad1Color, colors.grad2Color],
                              stops: [0, 1]),
                        ),
                        child: Text(getTranslated(context, 'SAVE_LBL'),
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: colors.white,
                                    ))),
                    onTap: () {
                      validateAndSubmit();
                    },
                  )
                ],
              )),
        ),
        showCircularProgress(_isProgress, colors.primary)
      ],
    );
  }

  Future<void> getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();

    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude), double.parse(longitude),
        localeIdentifier: "en");

    state = placemark[0].administrativeArea;
    country = "United Kingdom"; //placemark[0].country;
    pincode = placemark[0].postalCode;
    // address = placemark[0].name;
    if (mounted)
      setState(() {
        // countryC.text = "United Kingdom";
        countryC.text = "India";
        stateC.text = "";
        pincodeC.text = pincode;
        // addressC.text = address;
      });
  }
}
