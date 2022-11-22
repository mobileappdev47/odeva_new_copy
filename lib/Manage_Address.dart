import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Add_Address.dart';
import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/CustomRadio.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

class ManageAddress extends StatefulWidget {
  final bool home;

  const ManageAddress({Key key, this.home}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

class StateAddress extends State<ManageAddress> with TickerProviderStateMixin {
  bool _isLoading = false, _isProgress = false;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<RadioModel> addModel = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refresh();
    if (widget.home) {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
      _getAddress();
    } else {
      addAddressModel();
    }

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
                  addressList.clear();
                  addModel.clear();
                  if (!ISFLAT_DEL) delCharge = 0;
                  _getAddress();
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

  Future<Null> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        print("Parameters of getaddressapi: " + parameter.toString());
        Response response =
            await post(getAddressApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        print("Response of getaddress api : " + getdata.toString());
        bool error = getdata["error"];
        // String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          addressList =
              (data as List).map((data) => new User.fromAddress(data)).toList();

          for (int i = 0; i < addressList.length; i++) {
            if (addressList[i].isDefault == "1") {
              selectedAddress = i;
              selAddress = addressList[i].id;
              if (!ISFLAT_DEL) {
                if (totalPrice < double.parse(addressList[i].freeAmt))
                  delCharge = double.parse(addressList[i].deliveryCharge);
                else
                  delCharge = 0;
              }
            }
          }

          addAddressModel();
        } else {}
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    return null;
  }

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    addressList.clear();
    addModel.clear();
    if (!ISFLAT_DEL) delCharge = 0;
    return _getAddress();
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
          "Shipping Address",
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
      ),
      backgroundColor: colors.lightWhite,
      body: _isNetworkAvail
          ? Container(
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
              child: Column(
                children: [
                  Expanded(
                    child: _isLoading
                        ? shimmer()
                        : addressList.length == 0
                            ? Center(
                                child:
                                    Text(getTranslated(context, 'NOADDRESS')))
                            : Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: RefreshIndicator(
                                        key: _refreshIndicatorKey,
                                        onRefresh: _refresh,
                                        child: ListView.builder(
                                            // shrinkWrap: true,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: addressList.length,
                                            itemBuilder: (context, index) {
                                              return addressItem(index);
                                            })),
                                  ),
                                  showCircularProgress(
                                      _isProgress, colors.primary),
                                ],
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
                        child: Text(getTranslated(context, 'ADDADDRESS'),
                            style:
                                Theme.of(context).textTheme.subtitle1.copyWith(
                                      color: colors.white,
                                    ))),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddAddress(
                                  update: false,
                                  index: addressList.length,
                                  refresh: _refresh,
                                )),
                      );
                      if (mounted)
                        setState(() {
                          addModel.clear();
                          addAddressModel();
                        });
                    },
                  )
                ],
              ),
            )
          : noInternet(context),
    );
  }

  Future<void> setAsDefault(int index) async {
    try {
      var data = {
        USER_ID: CUR_USERID,
        ID: addressList[index].id,
        ISDEFAULT: "1",
      };

      Response response =
          await post(updateAddressApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];

      if (!error) {
        // var data = getdata["data"];

        for (User i in addressList) {
          i.isDefault = "0";
        }

        addressList[index].isDefault = "1";
      } else {
        setSnackbar(msg);
      }
      if (mounted)
        setState(() {
          _isProgress = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  addressItem(int index) {
    return Card(
        elevation: 0.2,
        child: new InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            if (mounted)
              setState(() {
                if (!ISFLAT_DEL) {
                  if (oriPrice <
                      double.parse(addressList[selectedAddress].freeAmt)) {
                    delCharge = double.parse(
                        addressList[selectedAddress].deliveryCharge);
                  } else
                    delCharge = 0;
                  totalPrice = totalPrice - delCharge;
                }

                selectedAddress = index;
                selAddress = addressList[index].id;

                if (!ISFLAT_DEL) {
                  if (totalPrice <
                      double.parse(addressList[selectedAddress].freeAmt)) {
                    delCharge = double.parse(
                        addressList[selectedAddress].deliveryCharge);
                  } else
                    delCharge = 0;

                  totalPrice = totalPrice + delCharge;
                }

                addModel.forEach((element) => element.isSelected = false);
                addModel[index].isSelected = true;
              });
          },
          child: new RadioItem(addModel[index]),
        ));
  }

  Future<void> deleteAddress(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: addressList[index].id,
        };
        Response response =
            await post(deleteAddressApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          if (!ISFLAT_DEL) {
            if (addressList.length != 1) {
              if (oriPrice <
                  double.parse(addressList[selectedAddress].freeAmt)) {
                delCharge =
                    double.parse(addressList[selectedAddress].deliveryCharge);
              } else
                delCharge = 0;
              totalPrice = totalPrice - delCharge;

              addressList
                  .removeWhere((item) => item.id == addressList[index].id);
              selectedAddress = 0;
              selAddress = addressList[0].id;

              if (totalPrice <
                  double.parse(addressList[selectedAddress].freeAmt)) {
                delCharge =
                    double.parse(addressList[selectedAddress].deliveryCharge);
              } else
                delCharge = 0;

              totalPrice = totalPrice + delCharge;
            } else {
              addressList
                  .removeWhere((item) => item.id == addressList[index].id);
              selAddress = null;
            }
          } else {
            addressList.removeWhere((item) => item.id == addressList[index].id);
            selAddress = null;
          }

          // addressList.removeWhere((item) => item.id == addressList[index].id);

          addModel.clear();
          addAddressModel();
        } else {
          setSnackbar(msg);
        }
        if (mounted)
          setState(() {
            _isProgress = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void addAddressModel() {
    for (int i = 0; i < addressList.length; i++) {
      addModel.add(RadioModel(
          isSelected: i == selectedAddress ? true : false,
          name: addressList[i].name,
          add1: addressList[i].address,
          add2: addressList[i].landmark,
          cityorarea: addressList[i].city,
          postcode: addressList[i].pincode,
          mobile: addressList[i].mobile,
          addItem: addressList[i],
          show: !widget.home,
          onSetDefault: () {
            if (mounted)
              setState(() {
                _isProgress = true;
              });
            setAsDefault(i);
          },
          onDeleteSelected: () {
            if (mounted)
              setState(() {
                _isProgress = true;
              });
            deleteAddress(i);
          },
          onEditSelected: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAddress(
                    update: true,
                    index: i,
                    refresh: _refresh,
                  ),
                ));

            if (mounted)
              setState(() {
                addModel.clear();
                addAddressModel();
              });
          }));
    }
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
