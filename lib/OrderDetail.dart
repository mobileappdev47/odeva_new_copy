import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eshop/Cart.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'Model/User.dart';

class OrderDetail extends StatefulWidget {
  final OrderModel model;
  final Function updateHome;

  const OrderDetail({Key key, this.model, this.updateHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController controller = new ScrollController();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<User> tempList = [];
  bool _isCancleable, _isReturnable;
  bool _isProgress = false;
  int offset = 0;
  int total = 0;
  List<User> reviewList = [];
  bool isLoadingmore = true;
  bool _isReturnClick = true;
  String proId, image;

  @override
  void initState() {
    super.initState();
    print("Order Status: " + widget.model.activeStatus.toString());
    if (widget.model.address != null) {
      print("Order Add: " + widget.model.address.toString());
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

  updateDetail() {
    if (mounted) setState(() {});
  }

  _getAppbar() {
    return AppBar(
      title: Text(
        getTranslated(context, 'ORDER_DETAIL'),
        style: TextStyle(
          color: colors.fontColor,
        ),
      ),
      iconTheme: new IconThemeData(color: colors.primary),
      backgroundColor: colors.darkColor,
      //colors.white,
      // elevation: 5,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4.0),
              child: InkWell(
                child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        );
      }),
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsetsDirectional.only(top: 10.0, bottom: 10, end: 10),
          child: Container(
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Cart(widget.updateHome, updateDetail),
                      ));
                },
                child: new Stack(children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SvgPicture.asset(
                        'assets/images/noti_cart.svg',
                      ),
                    ),
                  ),
                  (CUR_CART_COUNT != null &&
                          CUR_CART_COUNT.isNotEmpty &&
                          CUR_CART_COUNT != "0")
                      ? new Positioned(
                          top: 0.0,
                          right: 5.0,
                          bottom: 10,
                          child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      : Container()
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    OrderModel model = widget.model;
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus.contains(PLACED)) {
      pDate = model.listDate[model.listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(PROCESSED)) {
      prDate = model.listDate[model.listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(SHIPED)) {
      sDate = model.listDate[model.listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(DELIVERD)) {
      dDate = model.listDate[model.listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(CANCLED)) {
      cDate = model.listDate[model.listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus.contains(RETURNED)) {
      rDate = model.listDate[model.listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;

    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: _getAppbar(),
      body: _isNetworkAvail
          ? Stack(
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
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: controller,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                    width: deviceWidth,
                                    child: Card(
                                        elevation: 0,
                                        child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  getTranslated(context,
                                                          'ORDER_ID_LBL') +
                                                      " - " +
                                                      model.orderNumber,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .copyWith(
                                                          color:
                                                              colors.lightBlack,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                              ],
                                            )))),
                                model.otp != null &&
                                        model.otp.isNotEmpty &&
                                        model.otp != "0"
                                    ? Container(
                                        width: deviceWidth,
                                        child: Card(
                                            elevation: 0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 5),
                                                    child: Text(
                                                      getTranslated(
                                                              context, 'OTP') +
                                                          " - " +
                                                          model.otp,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2
                                                          .copyWith(
                                                              color: colors
                                                                  .lightBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    )),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12.0),
                                                    child: Text(
                                                      "Please give this to the delivery driver",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2
                                                          .copyWith(
                                                              color: colors
                                                                  .lightBlack2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                    )),
                                              ],
                                            )))
                                    : Container(),

                                Container(
                                    width: deviceWidth,
                                    child: Card(
                                        elevation: 0,
                                        child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Status" + " - ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .copyWith(
                                                          color:
                                                              colors.lightBlack,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                ),
                                                Text(
                                                  "Order" +
                                                      " " +
                                                      model.activeStatus,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      .copyWith(
                                                          color:
                                                              colors.lightBlack,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                ),
                                              ],
                                            )))),

                                model.delDate != null &&
                                        model.delDate.isNotEmpty
                                    ? Container(
                                        width: deviceWidth,
                                        child: Card(
                                            elevation: 0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getTranslated(context,
                                                            'PREFER_DATE_TIME1') +
                                                        ": ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        .copyWith(
                                                            color: colors
                                                                .lightBlack,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  Text(
                                                    model.delDate +
                                                        " - " +
                                                        model.delTime,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle2
                                                        .copyWith(
                                                            color: colors
                                                                .lightBlack,
                                                            fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      )
                                    : Container(),

                                shippingDetails(),
                                orders(model),
                                // Container(
                                //     width: deviceWidth,
                                //     child: Card(
                                //         elevation: 0,
                                //         child: Padding(
                                //             padding: EdgeInsets.all(12.0),
                                //             child: Row(
                                //               children: [
                                //                 Text("Items",
                                //                   style: Theme.of(context)
                                //                       .textTheme
                                //                       .subtitle2
                                //                       .copyWith(
                                //                       color: colors.fontColor,fontWeight: FontWeight.bold),
                                //                 ),
                                //               ],
                                //             )))),
                                // ListView.builder(
                                //   shrinkWrap: true,
                                //   itemCount: model.itemList.length,
                                //   physics: NeverScrollableScrollPhysics(),
                                //   itemBuilder: (context, i) {
                                //     OrderItem orderItem = model.itemList[i];
                                //     proId = orderItem.id;
                                //     return productItem(orderItem, model);
                                //   },
                                // ),
                                //DwnInvoice(),

                                priceDetails(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      (!widget.model.itemList[0].listStatus
                                  .contains(DELIVERD) &&
                              (!widget.model.itemList[0].listStatus
                                  .contains(RETURNED)) &&
                              _isCancleable &&
                              widget.model.itemList[0].isAlrCancelled == "0")
                          ? cancelable()
                          : (widget.model.itemList[0].listStatus
                                      .contains(DELIVERD) &&
                                  _isReturnable &&
                                  widget.model.itemList[0].isAlrReturned == "0")
                              ? returnable()
                              : Container(),
                    ],
                  ),
                ),
                showCircularProgress(_isProgress, colors.primary),
              ],
            )
          : noInternet(context),
    );
  }

  returnable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: colors.black26, blurRadius: 10)],
      ),
      width: deviceWidth,
      child: InkWell(
        onTap: _isReturnClick
            ? () {
                setState(() {
                  _isReturnClick = false;
                  _isProgress = true;
                });
                cancelOrder(RETURNED, updateOrderApi, widget.model.id);
              }
            : null,
        child: Center(
            child: Text(
          getTranslated(context, 'RETURN_ORDER'),
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(fontWeight: FontWeight.bold, color: colors.white),
        )),
      ),
    );
  }

  cancelable() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1]),
        boxShadow: [BoxShadow(color: colors.black26, blurRadius: 10)],
      ),
      width: deviceWidth,
      child: InkWell(
        onTap: _isReturnClick
            ? () {
                setState(() {
                  _isReturnClick = false;
                  _isProgress = true;
                });
                cancelOrder(CANCLED, updateOrderApi, widget.model.id);
              }
            : null,
        child: Center(
            child: Text(
          getTranslated(context, 'CANCEL_ORDER'),
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(fontWeight: FontWeight.bold, color: colors.white),
        )),
      ),
    );
  }

  priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                  child: Text(getTranslated(context, 'PRICE_DETAIL'),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: colors.fontColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
              Divider(
                color: colors.lightBlack,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'PRICE_LBL') + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack)),
                    Text(CUR_CURRENCY + " " + widget.model.subTotal,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'DELIVERY_CHARGE') + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack)),
                    Text("+ " + CUR_CURRENCY + " " + widget.model.delCharge,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        getTranslated(context, 'PROMO_CODE_DIS_LBL') +
                            " " +
                            ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack)),
                    Text("- " + CUR_CURRENCY + " " + widget.model.promoDis,
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'WALLET_BAL') + " " + ":",
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack)),
                    Text(
                        "- " +
                            CUR_CURRENCY +
                            " " +
                            double.parse(widget.model.walBal.toString())
                                .toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: colors.lightBlack))
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(getTranslated(context, 'PAYABLE') + " " + ":",
              //           style: Theme.of(context)
              //               .textTheme
              //               .button
              //               .copyWith(color: colors.lightBlack)),
              //       Text(CUR_CURRENCY + " " + widget.model.payable,
              //           style: Theme.of(context)
              //               .textTheme
              //               .button
              //               .copyWith(color: colors.lightBlack))
              //     ],
              //   ),
              // ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 15.0, end: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Card Payment" + " " + ":",
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: colors.lightBlack,
                            fontWeight: FontWeight.bold)),
                    Text(
                        CUR_CURRENCY +
                            " " +
                            double.parse(widget.model.total).toStringAsFixed(2),
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: colors.lightBlack,
                            fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ])));
  }

  orders(OrderModel model) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                "Items",
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: colors.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Divider(
              color: colors.lightBlack,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: model.itemList.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                OrderItem orderItem = model.itemList[i];
                proId = orderItem.orderNumber;
                return productItem(orderItem, model);
              },
            ),
          ],
        ),
      ),
    );
  }

  shippingDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                getTranslated(context, 'DELIVERY_ADDRESS'),
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: colors.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Divider(
              color: colors.lightBlack,
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                widget.model.name + ",",
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                widget.model.address ?? "",
                style: TextStyle(color: colors.lightBlack2),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
              child: Text(
                widget.model.mobile,
                style: TextStyle(
                  color: colors.lightBlack2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  productItem(OrderItem orderItem, OrderModel model) {
    String pDate, prDate, sDate, dDate, cDate, rDate;

    if (orderItem.listStatus.contains(PLACED)) {
      pDate = orderItem.listDate[orderItem.listStatus.indexOf(PLACED)];
    }
    if (orderItem.listStatus.contains(PROCESSED)) {
      prDate = orderItem.listDate[orderItem.listStatus.indexOf(PROCESSED)];
    }
    if (orderItem.listStatus.contains(SHIPED)) {
      sDate = orderItem.listDate[orderItem.listStatus.indexOf(SHIPED)];
    }
    if (orderItem.listStatus.contains(DELIVERD)) {
      dDate = orderItem.listDate[orderItem.listStatus.indexOf(DELIVERD)];
    }
    if (orderItem.listStatus.contains(CANCLED)) {
      cDate = orderItem.listDate[orderItem.listStatus.indexOf(CANCLED)];
    }

    debugPrint("======>>> $pDate , $prDate , $sDate , $dDate , $cDate , $rDate");
    if (orderItem.listStatus.contains(RETURNED)) {
      rDate = orderItem.listDate[orderItem.listStatus.indexOf(RETURNED)];
    }
    List att, val;
    if (orderItem.attr_name.isNotEmpty) {
      att = orderItem.attr_name.split(',');
      val = orderItem.varient_values.split(',');
    }
    return Card(
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(orderItem.image),
                          height: 90.0,
                          width: 90.0,
                          fit: BoxFit.cover,
                          placeholder: placeHolder(90),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItem.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      color: colors.lightBlack,
                                      fontWeight: FontWeight.normal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            orderItem.attr_name.isNotEmpty
                                ? ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att.length,
                                    itemBuilder: (context, index) {
                                      return Row(children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ":",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(
                                                    color: colors.lightBlack2),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              start: 5.0),
                                          child: Text(
                                            val[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(
                                                    color: colors.lightBlack),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),

                            Row(children: [
                              Text(
                                getTranslated(context, 'QUANTITY_LBL') + ":",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(color: colors.lightBlack2),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(start: 5.0),
                                child: Text(
                                  orderItem.qty,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(color: colors.lightBlack),
                                ),
                              )
                            ]),
                            Text(
                              CUR_CURRENCY + " " + orderItem.price,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: colors.fontColor),
                            ),

                            //  Text(orderItem.status)
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                // pDate != null
                //     ? Divider(
                //         color: colors.lightBlack,
                //       )
                //     : Container(),
                // pDate != null
                //     ? Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             getPlaced(pDate),
                //             getProcessed(prDate, cDate),
                //             getShipped(sDate, cDate),
                //             getDelivered(dDate, cDate),
                //             getCanceled(cDate),
                //             getReturned(orderItem, rDate, model),
                //           ],
                //         ),
                //       )
                //     : Container(),
                // model.itemList.length > 1
                //     ? (!orderItem.listStatus.contains(DELIVERD) &&
                //             (!orderItem.listStatus.contains(RETURNED)) &&
                //             orderItem.isCancle == "1" &&
                //             orderItem.isAlrCancelled == "0")
                //         ? Column(
                //             children: [
                //               Divider(),
                //               Align(
                //                 alignment: AlignmentDirectional.bottomEnd,
                //                 child: CupertinoButton(
                //                   padding: EdgeInsets.zero,
                //                   child: Container(
                //                       padding: EdgeInsets.symmetric(
                //                           horizontal: 15, vertical: 5),
                //                       decoration: BoxDecoration(
                //                           color: colors.lightWhite,
                //                           borderRadius: new BorderRadius.all(
                //                               const Radius.circular(4.0))),
                //                       child: Text(ITEM_CANCEL,
                //                           textAlign: TextAlign.center,
                //                           style: Theme.of(context)
                //                               .textTheme
                //                               .button
                //                               .copyWith(
                //                                 color: colors.fontColor,
                //                               ))),
                //                   onPressed: _isReturnClick
                //                       ? () {
                //                           setState(() {
                //                             _isReturnClick = false;
                //                             _isProgress = true;
                //                           });
                //                           cancelOrder(CANCLED,
                //                               updateOrderItemApi, orderItem.id);
                //                         }
                //                       : null,
                //                 ),
                //               ),
                //             ],
                //           )
                //         : (orderItem.listStatus.contains(DELIVERD) &&
                //                 orderItem.isReturn == "1" &&
                //                 orderItem.isAlrReturned == "0")
                //             ? Column(
                //                 children: [
                //                   Divider(),
                //                   Align(
                //                     alignment: AlignmentDirectional.bottomEnd,
                //                     child: CupertinoButton(
                //                       padding: EdgeInsets.zero,
                //                       child: Container(
                //                           padding: EdgeInsets.symmetric(
                //                               horizontal: 15, vertical: 5),
                //                           decoration: BoxDecoration(
                //                               color: colors.lightWhite,
                //                               borderRadius: new BorderRadius
                //                                       .all(
                //                                   const Radius.circular(4.0))),
                //                           child: Text(ITEM_RETURN,
                //                               textAlign: TextAlign.center,
                //                               style: Theme.of(context)
                //                                   .textTheme
                //                                   .button
                //                                   .copyWith(
                //                                     color: colors.fontColor,
                //                                   ))),
                //                       onPressed: _isReturnClick
                //                           ? () {
                //                               setState(() {
                //                                 _isReturnClick = false;
                //                                 _isProgress = true;
                //                               });
                //                               cancelOrder(
                //                                   RETURNED,
                //                                   updateOrderItemApi,
                //                                   orderItem.id);
                //                             }
                //                           : null,
                //                     ),
                //                   ),
                //                 ],
                //               )
                //             : Container()
                //     : Container(),

                ///yahan tak status hai orders ka

                // orderItem.status == DELIVERD ? Divider() : Container(),
                // orderItem.status == DELIVERD
                //     ? InkWell(
                //         child: ListTile(
                //           dense: true,
                //           title: Text(
                //             getTranslated(context, 'WRITE_REVIEW_LBL'),
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .subtitle2
                //                 .copyWith(color: colors.lightBlack),
                //           ),
                //           trailing: RatingBarIndicator(
                //             rating: 5,
                //             itemBuilder: (context, index) => Icon(
                //               Icons.star,
                //               color: colors.primary,
                //             ),
                //             itemCount: 5,
                //             itemSize: 15.0,
                //             direction: Axis.horizontal,
                //           ),
                //         ),
                //         onTap: () async {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => GiveRating(
                //                         productId: orderItem.productId,
                //                         name: orderItem.name,
                //                         img: orderItem.image,
                //                       )));
                //         })
                //     : Container()
              ],
            )));
  }

  getPlaced(String pDate) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.circle,
          color: colors.primary,
          size: 15,
        ),
        Container(
          margin: const EdgeInsetsDirectional.only(start: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, 'ORDER_NPLACED'),
                style: TextStyle(fontSize: 8),
              ),
              Text(
                pDate,
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  getProcessed(String prDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: prDate == null ? Colors.grey : colors.primary,
                      )),
                  Icon(
                    Icons.circle,
                    color: prDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'ORDER_PROCESSED'),
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      prDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : prDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_PROCESSED'),
                          style: TextStyle(fontSize: 8),
                        ),
                        Text(
                          prDate ?? " ",
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getShipped(String sDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: sDate == null ? Colors.grey : colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: sDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'ORDER_SHIPPED'),
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      sDate ?? " ",
                      style: TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          )
        : sDate == null
            ? Container()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 2,
                          color: colors.primary,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: colors.primary,
                        size: 15,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, 'ORDER_SHIPPED'),
                          style: TextStyle(fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          sDate ?? " ",
                          style: TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              );
  }

  getDelivered(String dDate, String cDate) {
    return cDate == null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: dDate == null ? Colors.grey : colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: dDate == null ? Colors.grey : colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'ORDER_DELIVERED'),
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      dDate ?? " ",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getCanceled(String cDate) {
    return cDate != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'ORDER_CANCLED'),
                      style: TextStyle(fontSize: 8),
                    ),
                    Text(
                      cDate ?? "",
                      style: TextStyle(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  getReturned(OrderItem item, String rDate, OrderModel model) {
    return item.listStatus.contains(RETURNED)
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Container(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 2,
                      color: colors.primary,
                    ),
                  ),
                  Icon(
                    Icons.cancel_rounded,
                    color: colors.primary,
                    size: 15,
                  ),
                ],
              ),
              Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_RETURNED'),
                        style: TextStyle(fontSize: 8),
                      ),
                      Text(
                        rDate ?? " ",
                        style: TextStyle(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
            ],
          )
        : Container();
  }

  Future<void> cancelOrder(String status, Uri api, String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ORDERID: id, STATUS: status};
        Response response = await post((api), body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          Future.delayed(Duration(seconds: 1)).then((_) async {
            Navigator.pop(context, 'update');
          });
        }

        if (mounted)
          setState(() {
            _isProgress = false;
            _isReturnClick = true;
          });
        setSnackbar(msg);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isReturnClick = true;
        });
    }
  }

  setSnackbar(String msg) {
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.black),
      ),
      backgroundColor: colors.white,
      elevation: 1.0,
    ));
  }

  DwnInvoice() {
    return Card(
      elevation: 0,
      child: InkWell(
          child: ListTile(
            dense: true,
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: colors.primary,
            ),
            leading: Icon(
              Icons.receipt,
              color: colors.primary,
            ),
            title: Text(
              getTranslated(context, 'DWNLD_INVOICE'),
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: colors.lightBlack),
            ),
          ),
          onTap: () async {
            final status = await Permission.storage.request();

            if (status == PermissionStatus.granted) {
              if (mounted)
                setState(() {
                  _isProgress = true;
                });
              var targetPath;

              if (Platform.isIOS) {
                Directory target = await getApplicationDocumentsDirectory();
                targetPath = target.path.toString();
              } else {
                Directory downloadsDirectory =
                    await DownloadsPathProvider.downloadsDirectory;
                targetPath = downloadsDirectory.path.toString();
              }

              var targetFileName = "Invoice_${widget.model.id}";
              var generatedPdfFile, filePath;
              try {
                generatedPdfFile =
                    await FlutterHtmlToPdf.convertFromHtmlContent(
                        widget.model.invoice, targetPath, targetFileName);
                filePath = generatedPdfFile.path;
              } catch (Exception) {
                filePath = targetPath + "/" + targetFileName + ".html";
              }

              if (mounted)
                setState(() {
                  _isProgress = false;
                });
              ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                content: new Text(
                  "${getTranslated(context, 'INVOICE_PATH')} $targetFileName",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.black),
                ),
                action: SnackBarAction(
                    label: getTranslated(context, 'VIEW'),
                    onPressed: () async {
                      final result = await OpenFile.open(filePath);
                      print(result);
                    }),
                backgroundColor: colors.white,
                elevation: 1.0,
              ));
            }
          }),
    );
  }
}
