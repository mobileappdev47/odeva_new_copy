import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Home3.dart' as hm;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'add_address.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Helper/Stripe_Service.dart';
import 'Home.dart';
import 'Manage_Address.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'Model/User.dart';
import 'Order_Success.dart';

import 'PaypalWebviewActivity.dart';


String stripePayId = "";
// bool isTimeSlot;
int cnt = 0;
bool callStripePayment = false;

class Cart extends StatefulWidget {
  final Function updateHome, updateParent;
  final Product model;
  final int secpos, index;
  final bool list;

  Cart(this.updateHome, this.updateParent,
      {this.model, this.secpos, this.index, this.list});

  @override
  State<StatefulWidget> createState() => StateCart();
}

List<User> addressList = [];
//List<SectionModel> cartList = [];
double totalPrice = 0, oriPrice = 0, delCharge = 0, taxPer = 0;

int selectedAddress = 0;
String latitude,
    longitude,
    selAddress,
    payMethod = '',
    payIcon = '',
    selTime,
    selDate,
    promocode;
double freeDeliveryAMt;
bool isPromoValid = false, isUseWallet = false, isPayLayShow = true;
int selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal, usedBal = 0;
String razorpayId,
    paystackId,
    stripeId,
    stripeSecret,
    stripeMode = "test",
    stripeCurCode,
    paytmMerId,
    paytmMerKey;
bool payTesting = true;
String gpayEnv = "TEST",
    gpayCcode = "US",
    gpaycur = "USD",
    gpayMerId = "01234567890123456789",
    gpayMerName = "Example Merchant Name";

class StateCart extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();
  bool _isProgress = false;
  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
      new GlobalKey<ScaffoldMessengerState>();
  List<Model> deliverableList = [];
  bool _isCartLoad = true, _placeOrder = true;
  HomePage home;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  // stripe.CardFieldInputDetails _card;

  List<TextEditingController> _controller = [];
  TextEditingController amtC = TextEditingController();
  TextEditingController msgC = TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<SectionModel> saveLaterList = [];
  String msg;
  bool _isLoading = true;
  // Razorpay _razorpay;
  TextEditingController promoC = new TextEditingController();
  TextEditingController deliveryC = new TextEditingController();
  StateSetter checkoutState;
  // final paystackPlugin = PaystackPlugin();
  ScrollController _scrollController = new ScrollController();
  bool deliverable = false;
  bool isShow = false;
  bool isShow1 = false;
  StateSetter stateSet;
  TextEditingController paymentController = TextEditingController();
  bool isLoading = false;
  List delayProductList = [];
  List<String> grams = [];

  //List<PaymentItem> _gpaytItems = [];
  //Pay _gpayClient;

  @override
  void initState() {
    hm.checkVersion(context);
    super.initState();

    clearAll();

    _getCart("0");
    _getSaveLater("1");
    // _getAddress();
    home = new HomePage(widget.updateHome);
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
    paymentController.text =
        " " + double.parse(usedBal.toString()).toStringAsFixed(2);
  }

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isCartLoad = true;
      });
    clearAll();

    _getCart("0");
    return _getSaveLater("1");
  }

  clearAll() {
    totalPrice = 0;
    oriPrice = 0;

    taxPer = 0;
    delCharge = 0;
    addressList.clear();
    cartList.clear();

    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    payMethod = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
  }

  @override
  void didChangeDependencies() {
    hm.checkVersion(context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    buttonController.dispose();
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();

    // if (_razorpay != null) _razorpay.clear();
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

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    // selectedMethod = 6;

    // payMethod = getTranslated(context, 'STRIPE_LBL');
    // payIcon = 'assets/images/stripe.svg';

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: colors.darkColor,
            leading: Builder(builder: (BuildContext context) {
              return Container(
                margin: EdgeInsets.all(10),
                decoration: shadow(),
                child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      //Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                      Navigator.pop(context, true);
                    },
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
              getTranslated(context, 'CART'),
              style: TextStyle(
                color: colors.fontColor,
              ),
            ),
          ),
          body: isLoading
              ? Container(
                  height: Get.height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Stack(
                  children: [
                    _isNetworkAvail
                        ? Stack(
                            children: <Widget>[
                              _showContent(),
                              showCircularProgress(_isProgress, colors.primary),
                            ],
                          )
                        : noInternet(context),

                    ///todo : chat button 5
                    /*      Positioned(
                        bottom: 60,
                        right: 10,
                        child: FloatingActionButton(
                          backgroundColor: Color(0xff341069),
                          onPressed: () async {
                            // Future.delayed(Duration(milliseconds: 100), () {
                            //   isShow = true;
                            // });
                            // Future.delayed(Duration(seconds: 5), () {
                            //   isShow1 = true;
                            // });
                            CUR_USERID = await getPrefrence(ID);
                            if (CUR_USERID != null) {
                              setState(() {});
                              String isManager;
                              isManager = await getPrefrence("isManager");

                              if (isManager == "true") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ChatManager()));
                              } else {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    )),
                                    builder: (builder) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          setState = setState;
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.1,
                                            child: ChatFireScreen(
                                              isManager: false,
                                              roomId: null,
                                            ),
                                          );
                                        },
                                      );
                                    });
                                //Navigator.push(context,MaterialPageRoute(builder: (_)=>ChatFireScreen(isManager: false,roomId: null,)));
                              }
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ));
                            }
                          },
                          child: Center(
                            child: Icon(
                              Icons.chat,
                              color: Colors.white,
                            ),
                          ),
                        )),*/
                  ],
                )),
    );
  }

  // ignore: missing_return
  Future<bool> onWillPop() {
    Navigator.pop(context, true);
/*if(detail ==true){
  Navigator.push(
    context,
    PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductDetail(
          model: widget.model,
          updateParent: widget.updateParent,
          index: widget.index,
          secPos: 0,
          updateHome: widget.updateHome,
          list: true,
        )),
  );
}*/

    // Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  String priceUpdate({String grams2, String price2}) {
    double price = double.parse(price2.toString());
    int gram = int.parse(grams2.toString());
    var gramPrice;
    if (gram == 0) {
      gramPrice = price;
    } else {
      gramPrice = (price * gram) / 1000;
    }

    return gramPrice.toString();
  }

  Widget listItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
        i < cartList[index].productList[0].prVarientList.length;
        i++) {
      if (cartList[index].varientId ==
          cartList[index].productList[0].prVarientList[i].id) selectedPos = i;
    }

    double price = double.parse(
        cartList[index].productList[0].prVarientList[selectedPos].disPrice);
    if (price == 0)
      price = double.parse(
          cartList[index].productList[0].prVarientList[selectedPos].price);

    cartList[index].perItemPrice = price.toString();

    ///per Item

    double gm = double.parse(grams[index].toString());
    double p = (gm == 0 ? price : ((gm * price) / 1000));

    cartList[index].perItemTotal =
        (/*price*/ p * double.parse(cartList[index].qty)).toString();

    print("PER ITEM TOTAL ${cartList[index].perItemTotal}");

    if (_controller.length < index + 1)
      _controller.add(new TextEditingController());

    _controller[index].text = cartList[index].qty;
    List att, val;
    if (cartList[index].productList[0].prVarientList[selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList[0]
          .prVarientList[selectedPos]
          .attr_name
          .split(',');
      val = cartList[index]
          .productList[0]
          .prVarientList[selectedPos]
          .varient_value
          .split(',');
    }

    ///todo : set gram order wise
    //   String dropdownValue = cartList[index].productList[0].defaultOrder;
    String dropdownValue = grams[index];

    var items = [
      '50',
      '100',
      '250',
      '500',
      '1000',
    ];
    if (int.parse(cartList[index].productList[0].minimumOrderQuantity) == 100) {
      items.remove("50");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        250) {
      items.remove("50");
      items.remove("100");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        500) {
      items.remove("50");
      items.remove("100");
      items.remove("250");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        1000) {
      items.remove("50");
      items.remove("100");
      items.remove("250");
      items.remove("500");
    }
    if (!items.contains(cartList[index].productList[0].defaultOrder)) {
      items.add(cartList[index].productList[0].defaultOrder);
    }

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Hero(
                tag: "$index${cartList[index].productList[0].id}",
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: FadeInImage(
                      image: NetworkImage(cartList[index].productList[0].image),
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          erroWidget(80),
                      placeholder: placeHolder(80),
                    ))),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(top: 5.0),
                            child: Text(
                              cartList[index].productList[0].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: colors.lightBlack),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                                start: 8.0, end: 8, bottom: 8),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: colors.fontColor,
                            ),
                          ),
                          onTap: () {
                            if (_isProgress == false)
                              removeFromCart(
                                  index, true, cartList, false, grams[index]);
                          },
                        )
                      ],
                    ),
                    cartList[index]
                                    .productList[0]
                                    .prVarientList[selectedPos]
                                    .attr_name !=
                                null &&
                            cartList[index]
                                .productList[0]
                                .prVarientList[selectedPos]
                                .attr_name
                                .isNotEmpty
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
                                          color: colors.lightBlack,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 5.0),
                                  child: Text(
                                    val[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                            color: colors.lightBlack,
                                            fontWeight: FontWeight.bold),
                                  ),
                                )
                              ]);
                            })
                        : Container(),
                    Row(
                      children: <Widget>[
                        Text(
                          double.parse(cartList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .disPrice) !=
                                  0
                              ? CUR_CURRENCY +
                                  "" +
                                  cartList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .price
                              : "",
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                        ),
                        Text(
                          " " +
                              CUR_CURRENCY +
                              " " +
                              priceUpdate(
                                  price2: price.toString(),
                                  grams2: dropdownValue
                                      .toString()) /*price.toString()*/,
                          style: TextStyle(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: Get.width,
                      height: 30,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: colors.black.withOpacity(0.6)),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.only(left: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: dropdownValue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: items.map((String items) {
                            return DropdownMenuItem(
                              enabled: true,
                              value: items,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "$items gm",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              dropdownValue = val;
                              grams.removeAt(index);
                              grams.insert(index, val);
                            });
                            print("SELECTED DROPDOWN VAL : $dropdownValue");
                            // updateHomePage();
                          },
                        ),
                      ),
                    ),
                    cartList[index].productList[0].availability == "1" ||
                            cartList[index].productList[0].stockType == "null"
                        ? Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsetsDirectional.only(
                                          end: 8, top: 8, bottom: 8),
                                      child: Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: colors.fontColor,
                                      ),
                                      decoration: BoxDecoration(
                                          color: colors.lightWhite,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                    ),
                                    onTap: () {
                                      if (_isProgress == false)
                                        removeFromCart(index, false, cartList,
                                            false, grams[index]);
                                    },
                                  ),
                                  Container(
                                    width: 40,
                                    height: 20,
                                    child: Stack(
                                      children: [
                                        TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                          controller: _controller[index],
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(5.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: colors.fontColor,
                                                  width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: colors.fontColor,
                                                  width: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                        ),
                                        /* PopupMenuButton<String>(
                                          tooltip: '',
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            size: 1,
                                          ),
                                          onSelected: (String value) {
                                            if (_isProgress == false)
                                              addToCart(index, value);
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return cartList[index]
                                                .productList[0]
                                                .itemsCounter
                                                .map<PopupMenuItem<String>>(
                                                    (String value) {
                                              return new PopupMenuItem(
                                                  child: new Text(value),
                                                  value: value);
                                            }).toList();
                                          },
                                        ),*/
                                      ],
                                    ),
                                  ), // ),

                                  GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.add,
                                        size: 14,
                                        color: colors.fontColor,
                                      ),
                                      decoration: BoxDecoration(
                                          color: colors.lightWhite,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3))),
                                    ),
                                    onTap: () {
                                      if (_isProgress == false) {
                                        addToCart(
                                            index,
                                            (int.parse(cartList[index].qty) +
                                                    int.parse(cartList[index]
                                                        .productList[0]
                                                        .qtyStepSize))
                                                .toString(),
                                            dropdownValue);
                                      }
                                    },
                                  )
                                ],
                              ),
                              Flexible(
                                child: GestureDetector(
                                  child: Container(
                                    margin:
                                        EdgeInsetsDirectional.only(start: 8),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: colors.lightWhite,
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(4.0))),
                                    child: Text(
                                      getTranslated(
                                          context, 'SAVEFORLATER_BTN'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: colors.fontColor,
                                          fontSize: 11),
                                    ),
                                  ),
                                  onTap: !_isProgress
                                      ? () {
                                          saveForLater(
                                              cartList[index].varientId,
                                              "1",
                                              cartList[index].qty,
                                              double.parse(
                                                  cartList[index].perItemTotal),
                                              cartList[index],
                                              grams[index]);
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cartItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
        i < cartList[index].productList[0].prVarientList.length;
        i++) {
      if (cartList[index].varientId ==
          cartList[index].productList[0].prVarientList[i].id) selectedPos = i;
    }

    double price = double.parse(
        cartList[index].productList[0].prVarientList[selectedPos].disPrice);
    if (price == 0)
      price = double.parse(
          cartList[index].productList[0].prVarientList[selectedPos].price);

    cartList[index].perItemPrice = price.toString();

    ///per item
    double gm = double.parse(grams[index].toString());
    double p = (gm == 0 ? price : ((gm * price) / 1000));
    cartList[index].perItemTotal =
        (/*price*/ p * double.parse(cartList[index].qty)).toString();
    print("PER ITEM TOTAL ${cartList[index].perItemTotal}");

    _controller[index].text = cartList[index].qty;

    List att, val;
    if (cartList[index].productList[0].prVarientList[selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList[0]
          .prVarientList[selectedPos]
          .attr_name
          .split(',');
      val = cartList[index]
          .productList[0]
          .prVarientList[selectedPos]
          .varient_value
          .split(',');
    }


    bool avail = false;

    ///todo : set gram order wise
    //   String dropdownValue = cartList[index].productList[0].defaultOrder;
    String dropdownValue = grams[index];

    var items = [
      '50',
      '100',
      '250',
      '500',
      '1000',
    ];
    if (int.parse(cartList[index].productList[0].minimumOrderQuantity) == 100) {
      items.remove("50");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        250) {
      items.remove("50");
      items.remove("100");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        500) {
      items.remove("50");
      items.remove("100");
      items.remove("250");
    } else if (int.parse(cartList[index].productList[0].minimumOrderQuantity) ==
        1000) {
      items.remove("50");
      items.remove("100");
      items.remove("250");
      items.remove("500");
    }
    if (!items.contains(cartList[index].productList[0].defaultOrder)) {
      items.add(cartList[index].productList[0].defaultOrder);
    }

    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Hero(
                    tag: "$index${cartList[index].productList[0].id}",
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: FadeInImage(
                          image: NetworkImage(
                              cartList[index].productList[0].image),
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(80),

                          // errorWidget: (context, url, e) => placeHolder(60),
                          placeholder: placeHolder(80),
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  cartList[index].productList[0].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          color: colors.black, fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 8.0, end: 8, bottom: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: colors.fontColor,
                                ),
                              ),
                              onTap: () {
                                if (_isProgress == false)
                                  removeFromCartCheckout(
                                      index, true, grams[index]);
                              },
                            )
                          ],
                        ),
                        cartList[index]
                                        .productList[0]
                                        .prVarientList[selectedPos]
                                        .attr_name !=
                                    null &&
                                cartList[index]
                                    .productList[0]
                                    .prVarientList[selectedPos]
                                    .attr_name
                                    .isNotEmpty
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
                                              color: colors.lightBlack,
                                            ),
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
                                                color: colors.lightBlack,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ]);
                                })
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      double.parse(cartList[index]
                                                  .productList[0]
                                                  .prVarientList[selectedPos]
                                                  .disPrice) !=
                                              0
                                          ? CUR_CURRENCY +
                                              "" +
                                              double.parse(cartList[index]
                                                      .productList[0]
                                                      .prVarientList[
                                                          selectedPos]
                                                      .price)
                                                  .toStringAsFixed(2)
                                          : "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              letterSpacing: 0.7),
                                    ),
                                  ),
                                  Text(
                                    " " +
                                        CUR_CURRENCY +
                                        " " + //price
                                        priceUpdate(
                                            price2: price
                                                .toStringAsFixed(2)
                                                .toString(),
                                            grams2: grams[index]),
                                    style: TextStyle(
                                        color: colors.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            cartList[index].productList[0].availability ==
                                        "1" ||
                                    cartList[index].productList[0].stockType ==
                                        "null"
                                ? Row(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              margin:
                                                  EdgeInsetsDirectional.only(
                                                      end: 8,
                                                      top: 8,
                                                      bottom: 8),
                                              child: Icon(
                                                Icons.remove,
                                                size: 12,
                                                color: colors.fontColor,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: colors.lightWhite,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3))),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false)
                                                removeFromCartCheckout(
                                                    index, false, grams[index]);
                                            },
                                          ),

                                          Container(
                                            width: 40,
                                            height: 20,
                                            child: Stack(
                                              children: [
                                                TextField(
                                                  textAlign: TextAlign.center,
                                                  readOnly: true,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                  controller:
                                                      _controller[index],
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(5.0),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              colors.fontColor,
                                                          width: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              colors.fontColor,
                                                          width: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                  ),
                                                ),
                                                // PopupMenuButton<String>(
                                                //   tooltip: '',
                                                //   icon: const Icon(
                                                //     Icons.arrow_drop_down,
                                                //     size: 1,
                                                //   ),
                                                //   onSelected: (String value) {
                                                //     addToCartCheckout(
                                                //         index, value);
                                                //   },
                                                //   itemBuilder:
                                                //       (BuildContext context) {
                                                //     return cartList[index]
                                                //         .productList[0]
                                                //         .itemsCounter
                                                //         .map<
                                                //                 PopupMenuItem<
                                                //                     String>>(
                                                //             (String value) {
                                                //       return new PopupMenuItem(
                                                //           child:
                                                //               new Text(value),
                                                //           value: value);
                                                //     }).toList();
                                                //   },
                                                // ),
                                              ],
                                            ),
                                          ), // ),

                                          GestureDetector(
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              margin: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.add,
                                                size: 12,
                                                color: colors.fontColor,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: colors.lightWhite,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3))),
                                            ),
                                            onTap: () {
                                              addToCartCheckout(
                                                  index,
                                                  (int.parse(cartList[index]
                                                              .qty) +
                                                          int.parse(cartList[
                                                                  index]
                                                              .productList[0]
                                                              .qtyStepSize))
                                                      .toString(),
                                                  grams[index]);
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                        Container(
                          width: Get.width,
                          height: 30,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: colors.black.withOpacity(0.6)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          padding: EdgeInsets.only(left: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: dropdownValue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  enabled: true,
                                  value: items,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey))),
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      "$items gm",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  dropdownValue = val;
                                  grams.removeAt(index);
                                  grams.insert(index, val);
                                });
                                addToCartCheckout(
                                    index,
                                    (int.parse(cartList[index]
                                            .qty) /* +
                                        int.parse(cartList[
                                        index]
                                            .productList[0]
                                            .qtyStepSize)*/
                                        )
                                        .toString(),
                                    grams[index]);
                                print(
                                    "SELECTED DROPDOWN VAL qqqw : $dropdownValue");
                                // updateHomePage();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'SUBTOTAL'),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black),
                ),
                Text(
                  CUR_CURRENCY + " " + price.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black),
                ),
                Text(
                  CUR_CURRENCY +
                      " " +
                      double.parse(cartList[index].perItemTotal)
                          .toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TAXPER'),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black),
                ),
                Text(
                  cartList[index].productList[0].tax + "%",
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TOTAL_LBL'),
                  style: Theme.of(context).textTheme.caption.copyWith(
                      fontWeight: FontWeight.bold, color: colors.black),
                ),
                !avail && deliverableList.length > 0
                    ? Text(
                        getTranslated(context, 'NOT_DEL'),
                        style: TextStyle(color: colors.red),
                      )
                    : Container(),
                Text(
                  CUR_CURRENCY +
                      " " +
                      (double.parse(cartList[index].perItemTotal))
                          .toStringAsFixed(2)
                          .toString(),
                  //+ " "+cartList[index].productList[0].taxrs,
                  style: Theme.of(context).textTheme.caption.copyWith(
                      fontWeight: FontWeight.bold, color: colors.black),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget saveLaterItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
        i < saveLaterList[index].productList[0].prVarientList.length;
        i++) {
      if (saveLaterList[index].varientId ==
          saveLaterList[index].productList[0].prVarientList[i].id)
        selectedPos = i;
    }

    double price = double.parse(saveLaterList[index]
        .productList[0]
        .prVarientList[selectedPos]
        .disPrice);
    if (price == 0)
      price = double.parse(
          saveLaterList[index].productList[0].prVarientList[selectedPos].price);

    saveLaterList[index].perItemPrice = price.toString();
    saveLaterList[index].perItemTotal =
        (price * double.parse(saveLaterList[index].qty)).toString();

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Hero(
                tag: "$index${saveLaterList[index].productList[0].id}",
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: FadeInImage(
                      image: NetworkImage(
                          saveLaterList[index].productList[0].image),
                      height: 80.0,
                      width: 80.0,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          erroWidget(80),
                      placeholder: placeHolder(80),
                    ))),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(top: 5.0),
                            child: Text(
                              saveLaterList[index].productList[0].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: colors.lightBlack),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                                start: 8.0, end: 8, bottom: 8),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: colors.fontColor,
                            ),
                          ),
                          onTap: () {
                            if (_isProgress == false)
                              removeFromCart(index, true, saveLaterList, true,
                                  grams[index]);
                          },
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          double.parse(saveLaterList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .disPrice) !=
                                  0
                              ? CUR_CURRENCY +
                                  "" +
                                  saveLaterList[index]
                                      .productList[0]
                                      .prVarientList[selectedPos]
                                      .price
                              : "",
                          style: Theme.of(context).textTheme.overline.copyWith(
                              decoration: TextDecoration.lineThrough,
                              letterSpacing: 0.7),
                        ),
                        Text(
                          " " + CUR_CURRENCY + " " + price.toString(),
                          style: TextStyle(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    saveLaterList[index].productList[0].availability == "1" ||
                            saveLaterList[index].productList[0].stockType ==
                                "null"
                        ? Row(
                            children: <Widget>[
                              GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: colors.lightWhite,
                                      borderRadius: new BorderRadius.all(
                                          const Radius.circular(4.0))),
                                  child: Text(
                                    getTranslated(context, 'MOVE_TO_CART'),
                                    style: TextStyle(
                                        color: colors.fontColor, fontSize: 11),
                                  ),
                                ),
                                onTap: !_isProgress
                                    ? () {
                                        saveForLater(
                                            saveLaterList[index].varientId,
                                            "0",
                                            saveLaterList[index].qty,
                                            double.parse(saveLaterList[index]
                                                .perItemTotal),
                                            saveLaterList[index],
                                            grams[index]);
                                      }
                                    : null,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateCart() {
    if (mounted) setState(() {});
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        http.Response response = await http
            .post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          oriPrice = double.parse(getdata[SUB_TOTAL]);

          taxPer = double.parse(getdata[TAX_PER]);

          totalPrice = delCharge + oriPrice;
          cartList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();

          for (int i = 0; i < cartList.length; i++) {
            _controller.add(new TextEditingController());
            String gms = json.decode(response.body)["data"][i]["gram"];
            print("${json.decode(response.body)["data"][i]["gram"]} \n $gms");
            grams.add(gms);
          }
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg, _scaffoldKey);
        }
        if (mounted)
          setState(() {
            _isCartLoad = false;
          });
        if (mounted) setState(() {});

        _getAddress();
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<Null> _getSaveLater(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        http.Response response = await http
            .post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          saveLaterList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();

          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg, _scaffoldKey);
        }
        if (mounted) setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }

    return null;
  }

  Future<void> addToCart(int index, String qty, String gram) async {
    _isNetworkAvail = await isNetworkAvailable();

    //if (int.parse(qty) >= cartList[index].productList[0].minOrderQuntity) {
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        if (int.parse(qty) <
            1 /*cartList[index].productList[0].minOrderQuntity*/) {
          qty = cartList[index].productList[0].minOrderQuntity.toString();
          setSnackbar('Minimum order quantity is $qty', _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
          "gram": gram
        };
        http.Response response = await http
            .post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print("response addtocart : " + response.body.toString());
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          String qty = data['total_quantity'];
          CUR_CART_COUNT = data['cart_count'];
          CUR_CART_COUNT = data['total_items'];

          cartList[index].qty = qty;

          oriPrice = double.parse(data['sub_total']);

          _controller[index].text = qty;
          totalPrice = 0;

          if (!ISFLAT_DEL) {
            if ((oriPrice) < double.parse(addressList[selectedAddress].freeAmt))
              delCharge =
                  double.parse(addressList[selectedAddress].deliveryCharge);
            else
              delCharge = 0;
          } else {
            if (oriPrice < double.parse(MIN_AMT))
              delCharge = double.parse(CUR_DEL_CHR);
            else
              delCharge = 0;
          }
          totalPrice = delCharge + oriPrice;

          if (isPromoValid) {
            validatePromo(false);
          } else if (isUseWallet) {
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;
                _isProgress = false;
                selectedMethod = null;
              });
          } else {
            if (mounted)
              setState(() {
                _isProgress = false;
              });
          }
        } else {
          setSnackbar(msg, _scaffoldKey);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }

        if (widget.updateHome != null) widget.updateHome();
        if (widget.updateParent != null) {
          print("Here we go");
          widget.updateParent();
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), _scaffoldKey);
        if (mounted)
          setState(() {
            _isProgress = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    // } else
    // setSnackbar(
    //     "Minimum allowed quantity is ${cartList[index].productList[0].minOrderQuntity} ",
    //     _scaffoldKey);
  }

  Future<void> addToCartCheckout(int index, String qty, String gram) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          checkoutState(() {
            _isProgress = true;
          });
        setState(() {});

        // if (int.parse(qty) < cartList[index].productList[0].minOrderQuntity) {
        //   qty = cartList[index].productList[0].minOrderQuntity.toString();
        //   setSnackbar('Minimum order quantity is $qty', _checkscaffoldKey);
        // }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
          "gram": gram
        };

        http.Response response = await http
            .post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            CUR_CART_COUNT = data['cart_count'];
            CUR_CART_COUNT = data['total_items'];

            cartList[index].qty = qty;

            oriPrice = double.parse(data['sub_total']);
            _controller[index].text = qty;
            totalPrice = 0;

            if (!ISFLAT_DEL) {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress].freeAmt))
                delCharge =
                    double.parse(addressList[selectedAddress].deliveryCharge);
              else
                delCharge = 0;
            } else {
              if ((oriPrice) < double.parse(MIN_AMT))
                delCharge = double.parse(CUR_DEL_CHR);
              else
                delCharge = 0;
            }
            totalPrice = delCharge + oriPrice;

            if (isPromoValid) {
              validatePromo(true);
            } else if (isUseWallet) {
              if (mounted)
                checkoutState(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isUseWallet = false;
                  isPayLayShow = true;
                  _isProgress = false;
                  selectedMethod = null;
                });
              setState(() {});
            } else {
              if (mounted)
                checkoutState(() {
                  _isProgress = false;
                });
              setState(() {});
            }
          } else {
            setSnackbar(msg, _checkscaffoldKey);
            if (mounted)
              checkoutState(() {
                _isProgress = false;
              });
            setState(() {});
          }

          if (widget.updateHome != null) widget.updateHome();
          if (widget.updateParent != null) widget.updateParent();
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
        if (mounted)
          checkoutState(() {
            _isProgress = false;
          });
        setState(() {});
      }
    } else {
      if (mounted)
        checkoutState(() {
          _isNetworkAvail = false;
        });
      setState(() {});
    }
  }

  saveForLater(String id, String save, String qty, double price,
      SectionModel curItem, String gram) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save,
          "gram": gram
        };

        http.Response response = await http
            .post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          CUR_CART_COUNT = data['cart_count'];
          CUR_CART_COUNT = data['total_items'];

          if (save == "1") {
            saveLaterList.add(curItem);
            cartList.removeWhere((item) => item.varientId == id);
            oriPrice = oriPrice - price;
          } else {
            cartList.add(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            oriPrice = oriPrice + price;
          }

          totalPrice = 0;

          if (!ISFLAT_DEL && selectedAddress > 0) {
            if ((oriPrice) < double.parse(addressList[selectedAddress].freeAmt))
              delCharge =
                  double.parse(addressList[selectedAddress].deliveryCharge);
            else
              delCharge = 0;
          } else {
            if ((oriPrice) < double.parse(MIN_AMT))
              delCharge = double.parse(CUR_DEL_CHR);
            else
              delCharge = 0;
          }
          totalPrice = delCharge + oriPrice;

          if (isPromoValid) {
            validatePromo(false);
          } else if (isUseWallet) {
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;
                _isProgress = false;
              });
          } else {
            if (mounted)
              setState(() {
                _isProgress = false;
              });
          }
        } else {
          setSnackbar(msg, _scaffoldKey);
        }
        if (mounted)
          setState(() {
            _isProgress = false;
          });
        if (widget.updateHome != null) widget.updateHome();
        if (widget.updateParent != null) widget.updateParent();
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), _scaffoldKey);
        if (mounted)
          setState(() {
            _isProgress = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCartCheckout(int index, bool remove, String gram) async {
    _isNetworkAvail = await isNetworkAvailable();

    /*  if (!remove &&
        int.parse(cartList[index].qty) ==
            cartList[index].productList[0].minOrderQuntity) {
      setSnackbar('Minimum order quantity is ${cartList[index].qty}',
          _checkscaffoldKey);
    } else*/
    {
      if (_isNetworkAvail) {
        try {
          if (mounted)
            checkoutState(() {
              _isProgress = true;
            });
          setState(() {});

          int qty;
          if (remove)
            qty = 0;
          else {
            qty = (int.parse(cartList[index].qty) -
                int.parse(cartList[index].productList[0].qtyStepSize));

            // if (qty < cartList[index].productList[0].minOrderQuntity) {
            //   qty = cartList[index].productList[0].minOrderQuntity;
            //   setSnackbar('Minimum order quantity is $qty', _checkscaffoldKey);
            // }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString(),
            "gram": gram
          };

          http.Response response = await http
              .post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          if (response.statusCode == 200) {
            var getdata = json.decode(response.body);

            bool error = getdata["error"];
            String msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String qty = data['total_quantity'];
              CUR_CART_COUNT = data['cart_count'];
              CUR_CART_COUNT = data['total_items'];

              if (qty == "0") remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);

              if (!ISFLAT_DEL) {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress].freeAmt))
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                else
                  delCharge = 0;
              } else {
                if ((oriPrice) < double.parse(MIN_AMT))
                  delCharge = double.parse(CUR_DEL_CHR);
                else
                  delCharge = 0;
              }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice;

              if (isPromoValid) {
                validatePromo(true);
              } else if (isUseWallet) {
                if (mounted)
                  checkoutState(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                    _isProgress = false;
                  });
                setState(() {});
              } else {
                if (mounted)
                  checkoutState(() {
                    _isProgress = false;
                  });
                setState(() {});
              }
            } else {
              setSnackbar(msg, _checkscaffoldKey);
              if (mounted)
                checkoutState(() {
                  _isProgress = false;
                });
              setState(() {});
            }

            if (widget.updateHome != null) widget.updateHome();
          }
        } on TimeoutException catch (_) {
          setSnackbar(
              getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
          if (mounted)
            checkoutState(() {
              _isProgress = false;
            });
          setState(() {});
        }
      } else {
        if (mounted)
          checkoutState(() {
            _isNetworkAvail = false;
          });
        setState(() {});
      }
    }
  }

  removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
      String gram) async {
    _isNetworkAvail = await isNetworkAvailable();
    // if (!remove &&
    //     int.parse(cartList[index].qty) ==
    //         cartList[index].productList[0].minOrderQuntity) {
    //   setSnackbar(
    //       'Minimum order quantity is ${cartList[index].qty}', _scaffoldKey);
    // } else
    {
      if (_isNetworkAvail) {
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });

          int qty;
          if (remove) {
            qty = 0;
            grams.removeAt(index);
            gram = "0";
          } else {
            qty = (int.parse(cartList[index].qty) -
                int.parse(cartList[index].productList[0].qtyStepSize));

            ///minimun qty
            // if (qty < cartList[index].productList[0].minOrderQuntity) {
            //   qty = cartList[index].productList[0].minOrderQuntity;
            //   setSnackbar('Minimum order quantity is $qty', _checkscaffoldKey);
            // }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString(),
            "gram": gram
          };

          http.Response response = await http
              .post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            CUR_CART_COUNT = data['cart_count'];
            CUR_CART_COUNT = data['total_items'];

            if (move == false) {
              if (qty == "0") remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);
              if (!ISFLAT_DEL && selectedAddress > 0) {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress].freeAmt))
                  delCharge =
                      double.parse(addressList[selectedAddress].deliveryCharge);
                else
                  delCharge = 0;
              } else {
                if ((oriPrice) < double.parse(MIN_AMT))
                  delCharge = double.parse(CUR_DEL_CHR);
                else
                  delCharge = 0;
              }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice;
              if (isPromoValid) {
                validatePromo(false);
              } else if (isUseWallet) {
                if (mounted)
                  setState(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                    _isProgress = false;
                  });
              } else {
                if (mounted)
                  setState(() {
                    _isProgress = false;
                  });
              }
            } else {
              if (qty == "0") remove = true;

              if (remove) {
                cartList.removeWhere(
                    (item) => item.varientId == cartList[index].varientId);
              }
            }
          } else {
            setSnackbar(msg, _scaffoldKey);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
          if (widget.updateHome != null) widget.updateHome();
          if (widget.updateParent != null) widget.updateParent();
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), _scaffoldKey);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
      } else {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  setSnackbar(
      String msg, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
    if (msg.trim().isEmpty) {
      return;
    }
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

  _showContent() {
    return _isCartLoad
        ? shimmer()
        : cartList.length == 0 && saveLaterList.length == 0
            ? cartEmpty()
            : isLoading
                ? Container(
                    height: Get.height,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
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
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: RefreshIndicator(
                                  key: _refreshIndicatorKey,
                                  onRefresh: _refresh,
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: cartList.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return listItem(index);
                                          },
                                        ),
                                        saveLaterList.length > 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  getTranslated(context,
                                                      'SAVEFORLATER_HNDG'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1,
                                                ),
                                              )
                                            : Container(),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: saveLaterList.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return saveLaterItem(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ))),
                        ),
                        Container(
                          height: 55,
                          color: colors.white,
                          //pay rupee and and items card
                          child: Card(
                            child: Row(children: <Widget>[
                              Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        CUR_CURRENCY +
                                            oriPrice.toStringAsFixed(2),
                                        style: TextStyle(
                                            color: colors.fontColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(CUR_CART_COUNT + " Items"),
                                    ],
                                  )),
                              // Spacer(),
                              // SimBtn(
                              //     size: 0.4,
                              //     title: getTranslated(context, 'PROCEED_CHECKOUT'),
                              //     onBtnSelected: () async {
                              //       if (oriPrice > 0) {
                              //         /* await Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //             builder: (context) =>
                              //                 CheckOut(widget.updateHome),
                              //           ),
                              //         );*/
                              //         checkout();
                              //         if (mounted) setState(() {});
                              //       } else
                              //         setSnackbar(getTranslated(context, 'ADD_ITEM'),
                              //             _scaffoldKey);
                              //     }),
                            ]),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: colors.black26, blurRadius: 10)
                                ],
                              ),
                              width: deviceWidth * 0.5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home', (Route<dynamic> route) => false);
                                  //addToCart(false);
                                },
                                child: Center(
                                    child: Text(
                                  getTranslated(context, 'CONTINUE_SHOPPING'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.primary),
                                )),
                              ),
                            ),
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.grad1Color,
                                      colors.grad2Color
                                    ],
                                    stops: [
                                      0,
                                      1
                                    ]),
                                boxShadow: [
                                  BoxShadow(
                                      color: colors.black26, blurRadius: 10)
                                ],
                              ),
                              width: deviceWidth * 0.5,
                              child: InkWell(
                                onTap: () async {
                                  setDelayDeliver();
                                },
                                child: Center(
                                    child: Text(
                                  getTranslated(context, 'PROCEED_CHECKOUT'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.white),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
  }

  cartEmpty() {
    return Container(
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
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            noCartImage(context),
            //noCartText(context),
            noCartDec(context),
            shopNow()
          ]),
        ),
      ),
    );
  }

  noCartImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/empty_cart.svg',
      fit: BoxFit.contain,
    );
  }

  noCartText(BuildContext context) {
    return Container(
        child: Text(getTranslated(context, 'NO_CART'),
            style: Theme.of(context).textTheme.headline5.copyWith(
                color: colors.primary, fontWeight: FontWeight.normal)));
  }

  noCartDec(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(getTranslated(context, 'CART_DESC'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: colors.lightBlack2,
                fontWeight: FontWeight.normal,
              )),
    );
  }

  shopNow() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 28.0),
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
              borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
            ),
            child: Text(getTranslated(context, 'SHOP_NOW'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6.copyWith(
                    color: colors.white, fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        },
      ),
    );
  }

  // decoration: BoxDecoration(
  // gradient: LinearGradient(begin: Alignment.topCenter,
  // end: Alignment.bottomCenter,
  // colors: [
  // // Color(0xFF280F43),
  // // Color(0xffE5CCFF),
  // Color(0xFF200738),
  // Color(0xFF3B147A),
  // Color(0xFFF8F8FF),
  // ]),
  // ),

  checkout() {
    selectedDate = null;
    selectedTime = null;
    selDate = null;
    selTime = null;
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            checkoutState = setState;
            return Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  key: _checkscaffoldKey,
                  body: _isNetworkAvail
                      ? cartList.length == 0
                          ? cartEmpty()
                          : _isLoading
                              ? shimmer()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: <Widget>[
                                          ScrollConfiguration(
                                            behavior: MyBehavior(),
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    address(),
                                                    // payment(),
                                                    // showWallet(),
                                                    cartItems(),

                                                    ///todo dropdown 3
                                                    moredeliveryamt(),
                                                    //promo(),
                                                    deliveryTextInformation(),
                                                    orderSummary(),
                                                    opencontainer(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          showCircularProgress(
                                              _isProgress, colors.primary),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: Get.width,
                                      color: colors.white,
                                      child: Row(children: <Widget>[
                                        Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // decoration: BoxDecoration(border: Border.all()),
                                                  width: Get.width / 1.5 - 30,
                                                  child: Text(
                                                    "Amount payable " +
                                                        CUR_CURRENCY +
                                                        " ${totalPrice.toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        color: colors.fontColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(CUR_CART_COUNT + " Items"),
                                              ],
                                            )),
                                        Spacer(),
                                        SimBtn(
                                            size: 0.3,
                                            title: getTranslated(
                                                context, 'PLACE_ORDER'),
                                            onBtnSelected: _placeOrder
                                                ? () {
                                                    checkoutState(() {
                                                      // _placeOrder = false;
                                                    });
                                                    print("call");
                                                    print(payMethod);

                                                    if (selAddress == null ||
                                                        selAddress.isEmpty) {
                                                      print("call1");
                                                      msg = getTranslated(
                                                          context,
                                                          'addressWarning');
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ManageAddress(
                                                              home: false,
                                                            ),
                                                          ));
                                                      checkoutState(() {
                                                        _placeOrder = true;
                                                      });
                                                    }

                                                    /// todo : payment screen
                                                      placeOrder('');
                                                  }
                                                : chec)
                                        //}),
                                      ]),
                                    ),
                                  ],
                                )
                      : noInternet(context),
                ));
          });
        });
  }

  chec() {
    print("sell");
  }

  minimumOrderAmt() {
    if (!ISFLAT_DEL && selectedAddress > 0) {
      if ((oriPrice) < double.parse(addressList[selectedAddress].freeAmt)) {
        delCharge = double.parse(addressList[selectedAddress].deliveryCharge);
        MIN_AMT = delCharge.toStringAsFixed(2);
        MIN_AMT = double.parse(addressList[selectedAddress].freeAmt.toString())
            .toStringAsFixed(2);
      } else {
        delCharge = 0;
      }
    } else {
      if ((oriPrice) < double.parse(MIN_AMT)) {
        delCharge = double.parse(CUR_DEL_CHR);
        // MIN_AMT = delCharge.toStringAsFixed(2);
      } else
        delCharge = 0;
    }
    return double.parse(MIN_AMT);
  }

  deliveryTextInformation() {
    return Card(
      elevation: 0.5,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Delivery Instructions',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black, fontSize: 14),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: TextField(
                    onTap: () {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    },
                    controller: deliveryC,
                    style: Theme.of(context).textTheme.subtitle2,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(
                        5,
                      ),
                      hintText: 'Eg: Door bell does not work, please knock..',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colors.fontColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colors.fontColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  moredeliveryamt() {
    if (selectedAddress != null && !ISFLAT_DEL && selectedAddress > 0) {
      if ((oriPrice) < double.parse(addressList[selectedAddress].freeAmt)) {
        freeDeliveryAMt =
            (double.parse(addressList[selectedAddress].freeAmt) - oriPrice);
        return Container(
          width: double.infinity,
          child: Card(
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Spend " +
                        CUR_CURRENCY +
                        " " +
                        freeDeliveryAMt.toStringAsFixed(2) +
                        " more to get free delivery.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )),
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  opencontainer() {
    return SizedBox(height: deviceHeight * 0.180);
  }

/*  doPayment() {
    if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
      placeOrder('');
    } else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
      razorpayPayment();
    else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
      paystackPayment(context);
    else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
      flutterwavePayment();
    else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
      stripePayment();
    else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
      paytmPayment();
    else
      placeOrder('');
  }*/

  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        http.Response response = await http
            .post(getAddressApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            addressList = (data as List)
                .map((data) => new User.fromAddress(data))
                .toList();

            if (addressList.length == 1) {
              selectedAddress = 0;
              selAddress = addressList[0].id;
              if (!ISFLAT_DEL) {
                if (totalPrice < double.parse(addressList[0].freeAmt))
                  delCharge = double.parse(addressList[0].deliveryCharge);
                else
                  delCharge = 0;
              }
            } else {
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
            }

            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT))
                delCharge = double.parse(CUR_DEL_CHR);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          } else {
            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT))
                delCharge = double.parse(CUR_DEL_CHR);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          if (checkoutState != null) checkoutState(() {});
        } else {
          setSnackbar(
              getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   placeOrder(response.paymentId);
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   if (mounted)
  //     checkoutState(() {
  //       _isProgress = false;
  //       _placeOrder = true;
  //     });
  //   setState(() {});
  //   setSnackbar(response.message, _checkscaffoldKey);
  // }
  //
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   print("EXTERNAL_WALLET: " + response.walletName);
  // }

  updateCheckout() {
    if (mounted) checkoutState(() {});
  }


  Future<void> placeOrder(String tranId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      checkoutState(() {
        _isProgress = true;
      });

      String mob = await getPrefrence(MOBILE);
      String varientId, quantity;
      for (SectionModel sec in cartList) {
        varientId =
            varientId != null ? varientId + "," + sec.varientId : sec.varientId;
        quantity = quantity != null ? quantity + "," + sec.qty : sec.qty;
      }
      String payVia ="COD";
      // if (payMethod == getTranslated(context, 'COD_LBL'))
      //   payVia = "COD";
      // else if (payMethod == getTranslated(context, 'PAYPAL_LBL'))
      //   payVia = "PayPal";
      // else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL'))
      //   payVia = "PayUMoney";
      // else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
      //   payVia = "RazorPay";
      // else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
      //   payVia = "Paystack";
      // else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
      //   payVia = "Flutterwave";
      // else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
      //   payVia = "Stripe";
      // else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
      //   payVia = "Paytm";
      // else if (payMethod == "Wallet")
      //   payVia = "Wallet";
      // else if (payMethod == getTranslated(context, 'BANKTRAN'))
      //   payVia = "bank_transfer";
      try {
        var parameter = {
          // "gram":grams.toString(),
          USER_ID: CUR_USERID,
          MOBILE: mob,
          PRODUCT_VARIENT_ID: varientId,
          QUANTITY: quantity,
          TOTAL: double.parse(oriPrice.toString()).toStringAsFixed(2),
          DEL_CHARGE: delCharge.toString(),
          "note": deliveryC.text,
          // TAX_AMT: taxAmt.toString(),
          TAX_PER: taxPer.toString(),
          FINAL_TOTAL: double.parse(totalPrice.toString()).toStringAsFixed(2),
          PAYMENT_METHOD: payVia,
          ADD_ID: selAddress,
          ISWALLETBALUSED: isUseWallet ? "1" : "0",
          WALLET_BAL_USED: double.parse(usedBal.toString()).toStringAsFixed(2),
        };
        print("STRIPE PAYMENT PARAMETER : ${parameter.toString()}");
        parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
        // if (isTimeSlot) {
        //   parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
        //   parameter[DELIVERY_DATE] = selDate ?? '';
        // }
        if (isPromoValid) {
          parameter[PROMOCODE] = promocode;
          parameter[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
          parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
          if (tranId == "PaymentIntentsStatus.Succeeded")
            parameter[ACTIVE_STATUS] = PLACED;
          else
            parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
          parameter[ACTIVE_STATUS] = WAITING;
        }

        http.Response response = await http
            .post(placeOrderApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print("PLACE ORDER PERAMETER : $parameter");
        _placeOrder = true;
        print("STATUS CODE ${response.statusCode}");
        print(response.body);
        if (response.statusCode == 200) {
          //{\"error\":true,\"message\":\"Debited amount can't exceeds the user balance !\"}
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            String orderId = getdata["order_id"].toString();
            if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
              addTransaction(
                  stripePayId,
                  orderId,
                  tranId == "PaymentIntentsStatus.Succeeded" ? PLACED : WAITING,
                  msg,
                  true);
            } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else {
              CUR_CART_COUNT = "0";
              clearAll();
              // widget.updateHome();

              CUR_BALANCE = getdata['balance'][0]["balance"];
              getPayment();
              setState(() {});
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => OrderSuccess()),
                  ModalRoute.withName('/home'));
            }
          } else {
            setSnackbar(msg, _checkscaffoldKey);
            if (mounted)
              checkoutState(() {
                _isProgress = false;
              });
          }
        }
      } on TimeoutException catch (_) {
        if (mounted)
          checkoutState(() {
            _isProgress = false;
            _placeOrder = true;
          });
      }
    } else {
      if (mounted)
        checkoutState(() {
          _isNetworkAvail = false;
        });
    }
  }

  getPayment() async {
    try {
      var parameter = {TYPE: PAYMENT_METHOD, USER_ID: CUR_USERID};
      http.Response response = await http
          .post(getSettingApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          var payment = data["payment_method"];
          stripeId = payment['stripe_publishable_key'];
          stripeSecret = payment['stripe_secret_key'];
          stripeCurCode = payment['stripe_currency_code'];
          stripeMode = payment['stripe_mode'] ?? 'test';
          StripeService.secret = stripeSecret;
          StripeService.init(stripeId, stripeMode);
        }
      }
    } catch (e) {}
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
        AMOUNT: totalPrice.toString()
      };
      http.Response response = await http
          .post(paypalTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg = getdata["message"];
      if (!error) {
        String data = getdata["data"];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaypalWebview(
                      url: data,
                      from: "order",
                      orderId: orderId,
                    )));
        checkoutState(() {
          _isProgress = false;
        });
      } else {
        checkoutState(() {
          _isProgress = false;
        });
        setSnackbar(msg, _checkscaffoldKey);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
    }
  }

  Future<void> addTransaction(String tranId, String orderID, String status,
      String msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID.toString(),
        ORDER_ID: orderID.toString(),
        TYPE: payMethod.toString(),
        TXNID: tranId.toString(),
        AMOUNT: totalPrice.toString(),
        STATUS: status.toString(),
        MSG: msg.toString()
      };
      http.Response response = await http.post(addTransactionApi,
          body: parameter,
          headers: headers) /*.timeout(Duration(seconds: timeOut))*/;

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          CUR_CART_COUNT = "0";
          clearAll();
          // widget.updateHome();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => OrderSuccess()),
              ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1, _checkscaffoldKey);
      }
    } on TimeoutException catch (e) {
      print(e.toString());
      setSnackbar(getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
    }
  }

  stripePayment() async {
    var finalAmt = totalPrice.toStringAsFixed(2);

    var response = await StripeService.payWithPaymentSheet(
      amount: (double.parse(finalAmt.toString()).toPrecision(2) * 100)
          .toInt()
          .toString(),
      currency: stripeCurCode,
      from: "order",
      context: context,
    );

    if (response.message == "Transaction successful") {
      placeOrder(response.status);
      _placeOrder = false;
      setState(() {});
    } else if (response.status == 'pending' || response.status == "captured") {
      placeOrder(response.status);
      _placeOrder = false;
      setState(() {});
    } else {
      if (mounted) {
        setState(() {
          _placeOrder = true;
        });
      }
    }
    setSnackbar(response.message, _checkscaffoldKey);
  }

  address() {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on),
            addressList.length > 0
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(bottom: 5.0),
                            child: Text(
                              addressList[selectedAddress].name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            addressList[selectedAddress].address,
                            // +
                            // ", " +
                            // addressList[selectedAddress].area +
                            // ", " +
                            // addressList[selectedAddress].city +
                            // ", " +
                            // addressList[selectedAddress].state +
                            // ", " +
                            // addressList[selectedAddress].country +
                            // ", " +
                            // addressList[selectedAddress].pincode,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: colors.black, fontSize: 14),
                          ),
                          addressList[selectedAddress].landmark != ""
                              ? Text(
                                  addressList[selectedAddress].landmark,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: colors.black, fontSize: 14),
                                )
                              : Container(),
                          Text(
                            addressList[selectedAddress].city,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: colors.black, fontSize: 14),
                          ),
                          Text(
                            addressList[selectedAddress].pincode,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: colors.black, fontSize: 14),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Text(
                                  addressList[selectedAddress].mobile,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: colors.black, fontSize: 14),
                                ),
                                Spacer(),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: colors.lightWhite,
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(4.0))),
                                    child: Text(
                                      getTranslated(context, 'CHANGE'),
                                      style: TextStyle(
                                          color: colors.fontColor,
                                          fontSize: 10),
                                    ),
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ManageAddress(
                                                  home: false,
                                                )));

                                    checkoutState(() {
                                      deliverable = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: GestureDetector(
                        child: Text(
                          getTranslated(context, 'ADDADDRESS'),
                          style: TextStyle(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAddress(
                                      update: false,
                                      index: addressList.length,
                                    )),
                          );
                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }



  cartItems() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return cartItem(index);
      },
    );
  }

  orderSummary() {
    return Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, 'ORDER_SUMMARY') +
                    " (" +
                    cartList.length.toString() +
                    " items)",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: colors.black, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Amount",
                    //getTranslated(context, 'SUBTOTAL'),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: colors.black),
                  ),
                  Text(
                    CUR_CURRENCY + " " + oriPrice.toStringAsFixed(2),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: colors.black),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'DELIVERY_CHARGE'),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: colors.black),
                  ),
                  Text(
                    CUR_CURRENCY + " " + delCharge.toStringAsFixed(2),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: colors.black),
                  )
                ],
              ),
              isPromoValid
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'PROMO_CODE_DIS_LBL'),
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: colors.black),
                        ),
                        Text(
                          CUR_CURRENCY + " " + promoAmt.toStringAsFixed(2),
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(color: colors.black),
                        )
                      ],
                    )
                  : Container(),
              isUseWallet
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'WALLET_BAL'),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          CUR_CURRENCY + " " + usedBal.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ));
  }

  promo() {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  getTranslated(context, 'PROMOCODE_LBL'),
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.black, fontSize: 14),
                ),
                Spacer(),
                InkWell(
                  child: Icon(
                    Icons.refresh,
                    size: 15,
                  ),
                  onTap: () {
                    if (promoAmt != 0 && isPromoValid) {
                      if (mounted)
                        checkoutState(() {
                          totalPrice = totalPrice + promoAmt;
                          promoC.text = '';
                          isPromoValid = false;
                          promoAmt = 0;
                          promocode = '';
                        });
                    }
                  },
                )
              ],
            ),
            Container(
              //  color: red,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoC,
                      style: Theme.of(context).textTheme.subtitle2,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(
                          5,
                        ),
                        hintText: 'Promo Code..',
                        //hintStyle: TextStyle(color: colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.fontColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colors.fontColor),
                        ),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        alignment: FractionalOffset.center,
                        decoration: BoxDecoration(
                            color: colors.lightWhite,
                            borderRadius: new BorderRadius.all(
                                const Radius.circular(4.0))),
                        child: Text(getTranslated(context, 'APPLY'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.button.copyWith(
                                  color: colors.fontColor,
                                ))),
                    onPressed: () {
                      if (promoC.text.trim().isEmpty) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              Future.delayed(Duration(seconds: 3), () {
                                Navigator.of(context).pop(true);
                              });
                              return Container(
                                height: deviceWidth * 0.63,
                                width: deviceWidth - 80,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: AlertDialog(
                                  title: Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                          "assets/images/alert.png")),
                                  content: Text(
                                    getTranslated(context, 'ADD_PROMO'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              );
                            });
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      // setSnackbar(getTranslated(context, 'ADD_PROMO'),
                      //     _checkscaffoldKey);
                      else if (!isPromoValid) validatePromo(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> validatePromo(bool check) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        _isProgress = true;
        if (check) {
          if (this.mounted && checkoutState != null) checkoutState(() {});
        }
        setState(() {});
        var parameter = {
          USER_ID: CUR_USERID,
          PROMOCODE: promoC.text,
          FINAL_TOTAL: totalPrice.toString()
        };
        http.Response response = await http
            .post(validatePromoApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"][0];

            totalPrice = double.parse(data["final_total"]);

            promoAmt = double.parse(data["final_discount"]);
            promocode = data["promo_code"];
            isPromoValid = true;
            if (check) {
              showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.of(context).pop(true);
                    });
                    return Container(
                      height: deviceWidth * 0.63,
                      width: deviceWidth - 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: AlertDialog(
                        title: Container(
                            height: 30,
                            width: 30,
                            child: Image.asset("assets/images/tick.png")),
                        content: Text(
                          getTranslated(context, 'PROMO_SUCCESS'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  });
            }
            // setSnackbar(
            //     getTranslated(context, 'PROMO_SUCCESS'), _checkscaffoldKey);
          } else {
            isPromoValid = false;
            promoAmt = 0;
            promocode = null;
            promoC.clear();
            if (check) {
              showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.of(context).pop(true);
                    });
                    return Container(
                      height: deviceWidth * 0.63,
                      width: deviceWidth - 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: AlertDialog(
                        title: Container(
                            height: 30,
                            width: 30,
                            child: Image.asset("assets/images/alert.png")),
                        content: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    );
                  });
            }
            //setSnackbar(msg, _checkscaffoldKey);
          }
          if (isUseWallet) {
            remWalBal = 0;
            payMethod = null;
            usedBal = 0;
            isUseWallet = false;
            isPayLayShow = true;
            _isProgress = false;

            if (mounted && check) checkoutState(() {});
            setState(() {});
          } else {
            _isProgress = false;
            if (mounted && check) checkoutState(() {});
            setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        _isProgress = false;
        if (mounted && check) checkoutState(() {});
        setState(() {});
        setSnackbar(getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
      }
    } else {
      _isNetworkAvail = false;
      if (mounted && check) checkoutState(() {});
      setState(() {});
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> flutterwavePayment() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          checkoutState(() {
            _isProgress = true;
          });

        var parameter = {
          AMOUNT: totalPrice.toString(),
          USER_ID: CUR_USERID,
        };
        http.Response response = await http
            .post(flutterwaveApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["link"];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => PaypalWebview(
                          url: data,
                          from: "order",
                        )));
          } else {
            setSnackbar(msg, _checkscaffoldKey);
          }
          checkoutState(() {
            _isProgress = false;
          });
        }
      } on TimeoutException catch (_) {
        checkoutState(() {
          _isProgress = false;
        });
        setSnackbar(getTranslated(context, 'somethingMSg'), _checkscaffoldKey);
      }
    } else {
      if (mounted)
        checkoutState(() {
          _isNetworkAvail = false;
        });
    }
  }

  showWallet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          child: CUR_BALANCE != "0" &&
                  CUR_BALANCE != null &&
                  CUR_BALANCE.isNotEmpty &&
                  CUR_BALANCE != ""
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: double.parse(CUR_BALANCE) <= 20.0
                      ? InkWell(
                          onTap: () {
                            if (isUseWallet)
                              isUseWallet = false;
                            else
                              isUseWallet = true;
                            setState(() {});
                            if (mounted)
                              setState(() {
                                //isUseWallet = value;
                                if (isUseWallet) {
                                  if (totalPrice <= double.parse(CUR_BALANCE)) {
                                    remWalBal = (double.parse(CUR_BALANCE) -
                                        totalPrice);
                                    usedBal = totalPrice;
                                    payMethod = "Wallet";
                                    paymentController.clear();
                                    paymentController.text = " " +
                                        double.parse(usedBal.toString())
                                            .toStringAsFixed(2);
                                    checkoutState(() {});
                                    isPayLayShow = false;
                                  } else {
                                    remWalBal = 0;
                                    usedBal = double.parse(CUR_BALANCE);
                                    isPayLayShow = true;
                                    payMethod =
                                        getTranslated(context, 'STRIPE_LBL');
                                    setState(() {});
                                  }
                                  totalPrice = totalPrice - usedBal;
                                } else {
                                  totalPrice = totalPrice + usedBal;
                                  remWalBal = double.parse(CUR_BALANCE);
                                  payMethod = null;
                                  usedBal = 0;
                                  isPayLayShow = true;
                                  payMethod =
                                      getTranslated(context, 'STRIPE_LBL');
                                  setState(() {});
                                }
                                paymentController.text = " " +
                                    double.parse(usedBal.toString())
                                        .toStringAsFixed(2);
                                checkoutState(() {});
                                //widget.update();
                                setState(() {});
                                checkoutState(() {});
                                print("method");
                                print(payMethod);
                              });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*             Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, 'USE_WALLET'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Text(
                                      isUseWallet
                                          ? getTranslated(
                                                  context, 'REMAIN_BAL') +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              remWalBal.toStringAsFixed(2)
                                          : getTranslated(
                                                  context, 'TOTAL_BAL') +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              double.parse(
                                                      CUR_BALANCE.toString())
                                                  .toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 15, color: colors.black),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (isUseWallet)
                                        isUseWallet = false;
                                      else
                                        isUseWallet = true;
                                      setState(() {});
                                      if (mounted)
                                        setState(() {
                                          //isUseWallet = value;
                                          if (isUseWallet) {
                                            if (totalPrice <=
                                                double.parse(CUR_BALANCE)) {
                                              remWalBal =
                                                  (double.parse(CUR_BALANCE) -
                                                      totalPrice);
                                              usedBal = totalPrice;
                                              payMethod = "Wallet";
                                              paymentController.clear();
                                              paymentController.text = " " +
                                                  double.parse(
                                                          usedBal.toString())
                                                      .toStringAsFixed(2);
                                              checkoutState(() {});
                                              isPayLayShow = false;
                                            } else {
                                              remWalBal = 0;
                                              usedBal =
                                                  double.parse(CUR_BALANCE);
                                              isPayLayShow = true;
                                              payMethod = getTranslated(
                                                  context, 'STRIPE_LBL');
                                              setState(() {});
                                            }
                                            totalPrice = totalPrice - usedBal;
                                          } else {
                                            totalPrice = totalPrice + usedBal;
                                            remWalBal =
                                                double.parse(CUR_BALANCE);
                                            payMethod = null;
                                            usedBal = 0;
                                            isPayLayShow = true;
                                            payMethod = getTranslated(
                                                context, 'STRIPE_LBL');
                                            setState(() {});
                                          }
                                          paymentController.text = " " +
                                              double.parse(usedBal.toString())
                                                  .toStringAsFixed(2);
                                          checkoutState(() {});
                                          //widget.update();
                                          setState(() {});
                                          checkoutState(() {});
                                          print("method");
                                          print(payMethod);
                                        });
                                    },
                                    child: isUseWallet
                                        ? Icon(
                                            Icons.check_box,
                                            color: colors.grad1Color,
                                          )
                                        : Icon(
                                            Icons.check_box_outline_blank,
                                          ),
                                  ),
                                  SizedBox(width: 5),
                                  InkWell(
                                    //waller add funds
                                    onTap: () => _showDialog(),
                                    child: Container(
                                        // width: 80,
                                        height: 35,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        alignment: FractionalOffset.center,
                                        decoration: new BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                colors.grad1Color,
                                                colors.grad2Color
                                              ],
                                              stops: [
                                                0,
                                                1
                                              ]),
                                          borderRadius: new BorderRadius.all(
                                              const Radius.circular(10.0)),
                                        ),
                                        child: Text("Add Funds",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    color: colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15))),
                                  )
                                ],
                              )*/
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            if (isUseWallet)
                              isUseWallet = false;
                            else
                              isUseWallet = true;
                            setState(() {});
                            if (mounted)
                              setState(() {
                                //isUseWallet = value;
                                if (isUseWallet) {
                                  if (totalPrice <= double.parse(CUR_BALANCE)) {
                                    remWalBal = (double.parse(CUR_BALANCE) -
                                        totalPrice);
                                    usedBal = totalPrice;
                                    payMethod = "Wallet";
                                    paymentController.clear();
                                    paymentController.text = " " +
                                        double.parse(usedBal.toString())
                                            .toStringAsFixed(2);
                                    checkoutState(() {});
                                    isPayLayShow = false;
                                  } else {
                                    remWalBal = 0;
                                    usedBal = double.parse(CUR_BALANCE);
                                    isPayLayShow = true;
                                    payMethod =
                                        getTranslated(context, 'STRIPE_LBL');
                                    setState(() {});
                                  }
                                  totalPrice = totalPrice - usedBal;
                                } else {
                                  totalPrice = totalPrice + usedBal;
                                  remWalBal = double.parse(CUR_BALANCE);
                                  payMethod = null;
                                  usedBal = 0;
                                  isPayLayShow = true;
                                }
                                paymentController.text = " " +
                                    double.parse(usedBal.toString())
                                        .toStringAsFixed(2);
                                checkoutState(() {});
                                //widget.update();
                                setState(() {});
                                checkoutState(() {});
                                print("method");
                                print(payMethod);
                              });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, 'USE_WALLET'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Text(
                                      isUseWallet
                                          ? getTranslated(
                                                  context, 'REMAIN_BAL') +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              remWalBal.toStringAsFixed(2)
                                          : getTranslated(
                                                  context, 'TOTAL_BAL') +
                                              " : " +
                                              CUR_CURRENCY +
                                              " " +
                                              double.parse(
                                                      CUR_BALANCE.toString())
                                                  .toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 15, color: colors.black),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (isUseWallet)
                                        isUseWallet = false;
                                      else
                                        isUseWallet = true;
                                      setState(() {});
                                      if (mounted)
                                        setState(() {
                                          //isUseWallet = value;
                                          if (isUseWallet) {
                                            if (totalPrice <=
                                                double.parse(CUR_BALANCE)) {
                                              remWalBal =
                                                  (double.parse(CUR_BALANCE) -
                                                      totalPrice);
                                              usedBal = totalPrice;
                                              payMethod = "Wallet";
                                              paymentController.clear();
                                              paymentController.text = " " +
                                                  double.parse(
                                                          usedBal.toString())
                                                      .toStringAsFixed(2);
                                              checkoutState(() {});
                                              isPayLayShow = false;
                                            } else {
                                              remWalBal = 0;
                                              usedBal =
                                                  double.parse(CUR_BALANCE);
                                              isPayLayShow = true;
                                              payMethod = getTranslated(
                                                  context, 'STRIPE_LBL');
                                              setState(() {});
                                            }
                                            totalPrice = totalPrice - usedBal;
                                          } else {
                                            totalPrice = totalPrice + usedBal;
                                            remWalBal =
                                                double.parse(CUR_BALANCE);
                                            payMethod = null;
                                            usedBal = 0;
                                            isPayLayShow = true;
                                          }
                                          paymentController.text = " " +
                                              double.parse(usedBal.toString())
                                                  .toStringAsFixed(2);
                                          checkoutState(() {});
                                          //widget.update();
                                          setState(() {});
                                          checkoutState(() {});
                                          print("method");
                                          print(payMethod);
                                        });
                                    },
                                    child: isUseWallet
                                        ? Icon(Icons.check_box,
                                            color: colors.grad1Color)
                                        : Icon(
                                            Icons.check_box_outline_blank,
                                          ),
                                  ),
                                  /*  SizedBox(width: 10,),

                            InkWell(
                              onTap: ()=>_showDialog(),
                              child: Container(
                                  width: 80,
                                  height: 35,
                                  alignment: FractionalOffset.center,
                                  decoration: new BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [colors.grad1Color, colors.grad2Color],
                                        stops: [0, 1]),
                                    borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
                                  ),
                                  child: Text("Add Fund",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(color: colors.white, fontWeight: FontWeight.normal,fontSize: 15))),
                            )*/
                                ],
                              )
                            ],
                          ),
                        ),
                )
              : Card(
                  elevation: 0,
                  child: Container(
                    width: Get.width,
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pay by Wallet",
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Balance : $CUR_CURRENCY $CUR_BALANCE",
                                    style: TextStyle(
                                        fontSize: 15, color: colors.black),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                              //add fund button
                              SimBtn(
                                size: 0.4,
                                title: "Add Funds",
                                onBtnSelected: () {
                                  _showDialog();
                                  /*  Get.to(()=>MyWallet()).then((value) {
                          Get.back();
                        });*/
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        isUseWallet
            ? Card(
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pay by Wallet",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            "Balance : $CUR_CURRENCY",
                            style: TextStyle(fontSize: 15, color: colors.black),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border.all(color: colors.black),
                                borderRadius: BorderRadius.circular(5)),
                            child: TextFormField(
                              onFieldSubmitted: (value) {
                                if (double.parse(paymentController.text
                                        .split(" ")
                                        .last) <=
                                    double.parse(CUR_BALANCE)) {
                                  totalPrice = totalPrice + usedBal;
                                  print("yes");
                                  remWalBal = (double.parse(CUR_BALANCE) -
                                      double.parse(paymentController.text
                                          .split(" ")
                                          .last));
                                  totalPrice = totalPrice -
                                      double.parse(paymentController.text
                                          .split(" ")
                                          .last);
                                  usedBal = double.parse(
                                      paymentController.text.split(" ").last);
                                  payMethod =
                                      getTranslated(context, 'STRIPE_LBL');
                                  checkoutState(() {});
                                  isPayLayShow = false;
                                } else {
                                  isUseWallet = false;
                                  remWalBal = double.parse(CUR_BALANCE);
                                  totalPrice = totalPrice + usedBal;
                                  usedBal = 0;

                                  paymentController.text = usedBal.toString();
                                  setState(() {});

                                  checkoutState(() {});
                                }
                                setState(() {});
                                checkoutState(() {});
                              },
                              onTap: () {
                                _scrollController.jumpTo(200);
                                setState(() {});
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(bottom: 15),
                                /*  prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 5,left: 20),
                            child: Text(CUR_CURRENCY,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
                          )*/
                              ),
                              controller: paymentController,
                            ),
                          ),
                          /*SimBtn(
                      title: "Submit",
                      size: 0.2,
                      onBtnSelected: (){

                        if(double.parse(paymentController.text.split(" ").last)<= double.parse(CUR_BALANCE)){


                          totalPrice = totalPrice + usedBal;
                          print("yes");
                          remWalBal =
                          (double.parse(CUR_BALANCE)-double.parse(paymentController.text.split(" ").last));
                          totalPrice = totalPrice - double.parse(paymentController.text.split(" ").last);
                          usedBal = double.parse(paymentController.text.split(" ").last);
                          payMethod = getTranslated(context, 'STRIPE_LBL');
                         // paymentController.text = CUR_CURRENCY +" "+ remWalBal.toString();
                          checkoutState(() {});
                          isPayLayShow = false;

                        }else{
                          isUseWallet = false;
                          remWalBal = double.parse(CUR_BALANCE);
                          totalPrice = totalPrice + usedBal;
                          usedBal = 0;

                          paymentController.text = usedBal.toString();
                          setState(() {

                          });

                          Fluttertoast.showToast(
                            msg: "You Can't spend balance more than your wallet balance",
                            toastLength: Toast.LENGTH_LONG,
                            fontSize: 18.0,
                          );
                          checkoutState((){});
                        }
                        setState(() {

                        });
                        checkoutState((){});
                      },
                    ),*/
                        ],
                      ),
                      //Container(height: 1,color: Colors.grey,)
                    ],
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  _showDialog() async {
    payWarn = true;
    setState(() {});
    if (payWarn) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                //   padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      height: Get.height / 3.4,
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: Get.height / 5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1))),
                        child: Column(
                          children: [
                            Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                child: Text(
                                  "Add Money to Wallet",
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(color: colors.fontColor),
                                )),
                            Divider(color: colors.lightBlack),
                            Padding(
                                padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (val) => validateField(val,
                                      getTranslated(context, 'FIELD_REQUIRED')),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: getTranslated(context, "AMOUNT"),
                                    hintStyle: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: colors.lightBlack,
                                            fontWeight: FontWeight.normal),
                                  ),
                                  controller: amtC,
                                )),
                            Container(
                              width: Get.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      new TextButton(
                                          child: Text(
                                            getTranslated(context, 'CANCEL'),
                                            style: Theme.of(this.context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(
                                                    color: colors.lightBlack,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          }),
                                      new TextButton(
                                          child: Text(
                                            "Add",
                                            style: Theme.of(this.context)
                                                .textTheme
                                                .subtitle2
                                                .copyWith(
                                                    color: colors.fontColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            if (payWarn) {
                                              if (amtC.text.toString() != '0') {
                                                //int amount = int.parse(amtC.text) <=1?1:int.parse(amtC.text);
                                                if (double.parse(amtC.text
                                                            .toString())
                                                        .toInt() >
                                                    51) {
                                                  Get.snackbar("Error",
                                                      "You can't add more then $CUR_CURRENCY 50");
                                                } else {
                                                  var finalPrice = double.parse(
                                                          amtC.text.toString())
                                                      .toStringAsFixed(2);
                                                  stripePaymentWallet((double
                                                                  .parse(finalPrice
                                                                      .toString())
                                                              .toPrecision(1) *
                                                          100)
                                                      .toInt()
                                                      .toString() /*double.parse(amtC.text.toString())*/);
                                                }
                                                payWarn = false;
                                                setState(() {});
                                              }
                                            }
                                          })
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    }
  }

  setDelayDeliver() {
    delayProductList = [];
    setState(() {});

    if (oriPrice > 0) {
      /* await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckOut(widget.updateHome),
                        ),
                      );*/
      //checkout();
      print(cartList.length);

      ///OPEN CLOSE STORE POPUP
/*
      for (int i = 0; i < cartList.length; i++) {
        for (int j = 0;
        j < cartList[i].productList.length;
        j++) {

          DateTime now = DateTime.now();
          DateTime openStoreTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(
                  cartList[i].productList[j].openStoreTime.split(":").first),
              int.parse(cartList[i].productList[j].openStoreTime.split(":")[1]),
              int.parse(
                  cartList[i].productList[j].openStoreTime.split(":").last));
          DateTime closeStoreTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(
                  cartList[i].productList[j].closeStoreTime.split(":").first),
              int.parse(cartList[i].productList[j].closeStoreTime.split(":")[1]),
              int.parse(
                  cartList[i].productList[j].closeStoreTime.split(":").last));
          if (now.isBefore(openStoreTime) ||
              now.isAfter(closeStoreTime)) {
           // // if (now.isAfter(openStoreTime) && // now:2022-10-21 14:22:44.405300   open store time : 2022-10-21 00:00:00.000 //openStoreTime.isBefore(now) && closeStoreTime.isBefore(now)
           // //     now.isAfter(    closeStoreTime)) {//now: 2022-10-21 14:22:44.405300   //close : 2022-10-21 12:06:00.000
            delayProductList.add(cartList[i].productList[j].name);
          } else {
          }
        }
      }
      setState(() {});
      checkout();
   if (delayProductList.isNotEmpty) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                // title: Center(child: Text('Rate this app'),),
                content: Container(
                  width: double.minPositive,
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      SizedBox(height: 25),
                      Text(
                        "Hi! \n For the item(s) below, you've missed the last order for instant delivery. Would you like it for tomorrow, timing can be arranged with the driver? ",
                        style: Theme.of(
                            this.context)
                            .textTheme
                            .subtitle1
                            .copyWith(
                            color: colors
                                .fontColor),
                      ),
                      ListView.builder(
                          padding:
                          EdgeInsets.only(
                              top: 10),
                          itemCount:
                          delayProductList
                              .length,
                          shrinkWrap: true,
                          physics:
                          NeverScrollableScrollPhysics(),
                          itemBuilder:
                              (BuildContext
                          context,
                              int index) {
                            return Text(
                              delayProductList[
                              index],
                              style: Theme.of(this
                                  .context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                  color: colors
                                      .lightBlack,
                                  fontWeight:
                                  FontWeight
                                      .bold),
                            );
                          }),
                      SizedBox(height: 15),
                      Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          TextButton(
                              child: Text(
                                "No",
                                style: Theme.of(this
                                    .context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                    color: colors
                                        .lightBlack,
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                              onPressed: () {
                                Navigator.of(
                                    context)
                                    .pop(false);
                              }),
                          SizedBox(width: 10),
                          TextButton(
                              child: Text(
                                "Yes",
                                style: Theme.of(this
                                    .context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                    color: colors
                                        .fontColor,
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                              onPressed:
                                  () async {
                                // addItem(
                                // qty: qty,
                                // context: context,
                                // index: index,
                                //  model: model);
                                    Navigator.pop(context);
                                checkout();

                              })
                        ],
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            });
      } else {
        checkout();
      }*/
      checkout();
      if (mounted) setState(() {});
    } else
      setSnackbar(getTranslated(context, 'ADD_ITEM'), _scaffoldKey);
  }

  stripePaymentWallet(String price) async {
    var response = await StripeService.payWithPaymentSheet(
        amount: price.toString(), currency: stripeCurCode, from: "wallet");

    if (response.success == true) {
      sendRequest(response.id, "Stripe");
    }

    if (mounted) {
      setState(() {
        _isProgress = false;
      });
    }
    Get.back();
    setSnackbarMsg(response.message);
  }

  Future<Null> sendRequest(String txnId, String payMethod) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      String orderId =
          "wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          AMOUNT: amtC.text.toString(),
          TRANS_TYPE: WALLET,
          TYPE: CREDIT,
          MSG: (msgC.text == '' || msgC.text.isEmpty)
              ? "Added through wallet"
              : msgC.text,
          TXNID: txnId,
          ORDER_ID: orderId,
          STATUS: "Success",
          PAYMENT_METHOD: payMethod.toLowerCase()
        };

        http.Response response = await http
            .post(addTransactionApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(response);

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        // String msg = getdata["message"];

        if (!error) {
          CUR_BALANCE = double.parse(getdata["new_balance"]).toStringAsFixed(2);
        }
        if (mounted)
          setState(() {
            _isProgress = false;
          });
        Get.back();
        setSnackbarMsg("Funds successfully added to Wallet");
      } on TimeoutException catch (_) {
        setSnackbarMsg(getTranslated(context, 'somethingMSg'));

        setState(() {
          _isProgress = false;
        });
        Get.back();
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isProgress = false;
        });
      Get.back();
    }

    return null;
  }

  setSnackbarMsg(String msg) {
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
