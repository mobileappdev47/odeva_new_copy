import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Home.dart';
import 'package:eshop/Home3.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';
import 'package:eshop/chat_manager/chat_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';
import 'Login.dart';
import 'Cart.dart';

class Search extends StatefulWidget {
  final Function updateHome;

  Search({this.updateHome});

  @override
  _StateSearch createState() => _StateSearch();
}

class _StateSearch extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pos = 0;
  bool _isProgress = false;
  List<Product> productList = [];
  List<TextEditingController> _controllerList = [];
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;

  String _searchText = "", _lastsearch = "";
  int notificationoffset = 0;
  ScrollController notificationcontroller;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  AnimationController _animationController;
  FocusNode textFocus = FocusNode();

  @override
  void initState() {
    checkVersion(context);
    getMessageCount();
    super.initState();
    productList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller.addListener(_transactionscrollListener);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted)
          setState(() {
            _searchText = "";
          });
      } else {
        if (mounted)
          setState(() {
            _searchText = _controller.text;
          });
      }

      if (_lastsearch != _searchText && (_searchText.length > 2)) {
        _lastsearch = _searchText;
        notificationisloadmore = true;
        notificationoffset = 0;
        getProduct();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

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

  _transactionscrollListener() {
    if (notificationcontroller.offset >=
            notificationcontroller.position.maxScrollExtent &&
        !notificationcontroller.position.outOfRange) {
      if (mounted)
        setState(() {
          getProduct();
        });
    }
  }

  @override
  void didChangeDependencies() {
    checkVersion(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    buttonController.dispose();
    notificationcontroller.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++)
      _controllerList[i].dispose();
    _animationController.dispose();
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
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // leading: Builder(builder: (BuildContext context) {
          //   return Container(
          //     margin: EdgeInsets.all(10),
          //     decoration: shadow(),
          //     child: Card(
          //       elevation: 0,
          //       child: InkWell(
          //         borderRadius: BorderRadius.circular(4),
          //         onTap: () => Navigator.of(context)
          //       .pushNamedAndRemoveUntil('/Home', (Route<dynamic> route) => false),
          //         child: Padding(
          //           padding: const EdgeInsetsDirectional.only(end: 4.0),
          //           child:
          //               Icon(Icons.keyboard_arrow_left, color: colors.primary),
          //         ),
          //       ),
          //     ),
          //   );
          // }),
          leading: InkWell(
            onTap: () {
              curhome3Selected = 0;
              Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
              //HomePage(widget.updateHome);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),
          //leadingWidth: 20,
          backgroundColor: colors.darkColor,
          title: TextField(
            controller: _controller,
            autofocus: true,
            focusNode: textFocus,
            decoration: InputDecoration(
              // filled: true,
              // fillColor: Color(0xFF3B147A),
              contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              prefixIcon: Icon(Icons.search, color: Colors.white, size: 20),
              suffixIcon: InkWell(
                  onTap: () {
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  )),
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              border: InputBorder.none,

              // enabledBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: Color(0xFF3B147A)),
              // ),
              // focusedBorder: UnderlineInputBorder(
              //   borderSide: BorderSide(color: colors.white),
              // ),
            ),
            // onChanged: (query) => updateSearchQuery(query),
          ),
          titleSpacing: 0,
          actions: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: shadow(),
              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    CUR_USERID == null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Cart(widget.updateHome, null),
                            )).then((val) => widget.updateHome);
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
          ],
        ),
        body: Stack(
          children: [
            _isNetworkAvail
                ? Stack(
                    children: <Widget>[
                      _showContent(),
                      showCircularProgress(_isProgress, colors.primary),
                    ],
                  )
                : noInternet(context),
            ///todo : chat button 2 (Search)
            // Positioned(
            //     bottom: 5,
            //     right: 10,
            //     child: FloatingActionButton(
            //       backgroundColor: Color(0xff341069),
            //       onPressed: () async {
            //         // Future.delayed(Duration(milliseconds: 100), () {
            //         //   isShow = true;
            //         // });
            //         // Future.delayed(Duration(seconds: 5), () {
            //         //   isShow1 = true;
            //         // });
            //         CUR_USERID = await getPrefrence(ID);
            //         if (CUR_USERID != null) {
            //           setState(() {});
            //           String isManager;
            //           isManager = await getPrefrence("isManager");
            //
            //           if (isManager == "true") {
            //             Navigator.push(context,
            //                 MaterialPageRoute(builder: (_) => ChatManager()));
            //           } else {
            //             showModalBottomSheet(
            //                 isScrollControlled: true,
            //                 context: context,
            //                 shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.only(
            //                   topLeft: Radius.circular(10),
            //                   topRight: Radius.circular(10),
            //                 )),
            //                 builder: (builder) {
            //                   return StatefulBuilder(
            //                     builder: (BuildContext context,
            //                         StateSetter setState) {
            //                       setState = setState;
            //                       return Container(
            //                         height: MediaQuery.of(context).size.height /
            //                             1.1,
            //                         child: ChatFireScreen(
            //                           isManager: false,
            //                           roomId: null,
            //                         ),
            //                       );
            //                     },
            //                   );
            //                 }).then((value) {
            //               getMessageCount();
            //               setState(() {});
            //             });
            //             //Navigator.push(context,MaterialPageRoute(builder: (_)=>ChatFireScreen(isManager: false,roomId: null,)));
            //           }
            //         } else {
            //           Navigator.pushReplacement(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => Login(),
            //               ));
            //         }
            //       },
            //       child: Center(
            //         child: Stack(
            //           children: [
            //             Icon(
            //               Icons.chat,
            //               color: Colors.white,
            //             ),
            //             totalmessageCount >= 1
            //                 ? Positioned(
            //                     right: 0,
            //                     child: Container(
            //                       height: 8,
            //                       width: 8,
            //                       decoration: BoxDecoration(
            //                           shape: BoxShape.circle,
            //                           color: Colors.red),
            //                     ),
            //                   )
            //                 : SizedBox()
            //           ],
            //         ),
            //       ),
            //     )),
          ],
        ));
  }

  Widget listItem(int index) {
    Product model = productList[index];

    if (_controllerList.length < index + 1)
      _controllerList.add(new TextEditingController());

    _controllerList[index].text =
        model.prVarientList[model.selVarient].cartCount;

    double price = double.parse(model.prVarientList[model.selVarient].disPrice);
    if (price == 0)
      price = double.parse(model.prVarientList[model.selVarient].price);

    List att, val;
    if (model.prVarientList[model.selVarient].attr_name != null) {
      att = model.prVarientList[model.selVarient].attr_name.split(',');
      val = model.prVarientList[model.selVarient].varient_value.split(',');
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                      tag: "$index${model.id}",
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: FadeInImage(
                            image: NetworkImage(productList[index].image),
                            height: 80.0,
                            width: 80.0,
                            fit: BoxFit.cover,
                            //errorWidget:(context, url,e) => placeHolder(80) ,
                            placeholder: placeHolder(80),
                          ))),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      color: colors.lightBlack, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    CUR_CURRENCY + " " + price.toString() + " ",
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text(
                                  double.parse(model
                                              .prVarientList[model.selVarient]
                                              .disPrice) !=
                                          0
                                      ? CUR_CURRENCY +
                                          "" +
                                          model.prVarientList[model.selVarient]
                                              .price
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ],
                            ),
                            model.prVarientList[model.selVarient].attr_name !=
                                        null &&
                                    model.prVarientList[model.selVarient]
                                        .attr_name.isNotEmpty
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
                                                    color: colors.lightBlack),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),
                            Row(
                              children: [
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.star,
                                //       color: colors.primary,
                                //       size: 12,
                                //     ),
                                //     Text(
                                //       " " + productList[index].rating,
                                //       style:
                                //           Theme.of(context).textTheme.overline,
                                //     ),
                                //     Text(
                                //       " (" +
                                //           productList[index].noOfRating +
                                //           ")",
                                //       style:
                                //           Theme.of(context).textTheme.overline,
                                //     )
                                //   ],
                                // ),
                                Spacer(),
                                model.availability == "0"
                                    ? Container()
                                    : cartBtnList
                                        ? Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      margin:
                                                          EdgeInsetsDirectional
                                                              .only(end: 8),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 14,
                                                        color: colors.fontColor,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              colors.lightWhite,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          3))),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress ==
                                                              false &&
                                                          (int.parse(productList[
                                                                      index]
                                                                  .prVarientList[
                                                                      model
                                                                          .selVarient]
                                                                  .cartCount)) >
                                                              0)
                                                        removeFromCart(index);
                                                    },
                                                  ),
                                                  Container(
                                                    width: 40,
                                                    height: 20,
                                                    child: Stack(
                                                      children: [
                                                        TextField(
                                                          textAlign:
                                                              TextAlign.center,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                          controller:
                                                              _controllerList[
                                                                  index],
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: colors
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: colors
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                          ),
                                                        ),
                                                        PopupMenuButton<String>(
                                                          tooltip: '',
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 1,
                                                          ),
                                                          onSelected:
                                                              (String value) {
                                                            if (_isProgress ==
                                                                false)
                                                              addToCart(
                                                                  index, value);
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return model
                                                                .itemsCounter
                                                                .map<
                                                                    PopupMenuItem<
                                                                        String>>((String
                                                                    value) {
                                                              return new PopupMenuItem(
                                                                  child:
                                                                      new Text(
                                                                          value),
                                                                  value: value);
                                                            }).toList();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ), // ),
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      margin: EdgeInsets.only(
                                                          left: 8),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 14,
                                                        color: colors.fontColor,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              colors.lightWhite,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          3))),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress == false)
                                                        addToCart(
                                                            index,
                                                            ((int.parse(model
                                                                        .prVarientList[model
                                                                            .selVarient]
                                                                        .cartCount)) +
                                                                    int.parse(model
                                                                        .qtyStepSize))
                                                                .toString());
                                                    },
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        : Container(),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(model.shortDescription)
                          ],
                        )),
                  )
                ],
              ),
              productList[index].availability == "0"
                  ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold))
                  : Container(),
            ],
          ),
          splashColor: colors.primary.withOpacity(0.2),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Product model = productList[index];
            setState(() {
              search = true;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductDetail(
                        model: model,
                        updateParent: updateSearch,
                        updateHome: widget.updateHome,
                        secPos: 0,
                        index: index,
                        list: true,
                      )),
            ).then((value) {});
          },
        ),
      ),
    );
  }

  updateSearch() {
    if (mounted) setState(() {});
  }

  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });

          if (int.parse(qty) < productList[index].minOrderQuntity) {
            qty = productList[index].minOrderQuntity.toString();
            setSnackbar('Minimum order quantity is $qty');
          }

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: productList[index]
                .prVarientList[productList[index].selVarient]
                .id,
            QTY: qty
          };
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            CUR_CART_COUNT = data['cart_count'];

            productList[index]
                .prVarientList[productList[index].selVarient]
                .cartCount = qty.toString();
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
          widget.updateHome();
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'));
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

  Future<void> removeFromCart(int index) async {
    Product model = productList[index];
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });
          int qty;
          qty = (int.parse(productList[index]
                  .prVarientList[model.selVarient]
                  .cartCount) -
              int.parse(productList[index].qtyStepSize));
          if (qty < productList[index].minOrderQuntity) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList[model.selVarient].id,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            String qty = data["total_quantity"];
            CUR_CART_COUNT = data['cart_count'];
            model.prVarientList[model.selVarient].cartCount = qty.toString();

            widget.updateHome();
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'));
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

  void getAvailVarient(List<Product> tempList) {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList.length; i++) {
          if (tempList[j].prVarientList[i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  Future getProduct() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          if (mounted)
            setState(() {
              notificationisloadmore = false;
              notificationisgettingdata = true;
              if (notificationoffset == 0) {
                productList = [];
              }
            });

          var parameter = {
            SEARCH: _searchText.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };

          if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;

          Response response =
              await post(getProductApi, headers: headers, body: parameter)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];

          notificationisgettingdata = false;
          if (notificationoffset == 0) notificationisnodata = error;

          if (!error) {
            if (mounted) {
              new Future.delayed(
                  Duration.zero,
                  () => setState(() {
                        List mainlist = getdata['data'];

                        if (mainlist.length != 0) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(mainlist
                              .map((data) => new Product.fromJson(data))
                              .toList());

                          allitems.addAll(items);
                          for (Product item in items) {
                            productList
                                .where((i) => i.id == item.id)
                                .map((obj) {
                              allitems.remove(item);
                              return obj;
                            }).toList();
                          }

                          getAvailVarient(allitems);

                          notificationisloadmore = true;
                          notificationoffset = notificationoffset + perPage;
                        } else {
                          notificationisloadmore = false;
                        }
                      }));
            }
          } else {
            notificationisloadmore = false;
            if (mounted) setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
        if (mounted)
          setState(() {
            notificationisloadmore = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
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

  _showContent() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: notificationisnodata
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
              child: Center(
                  child: Text(
                getTranslated(context, 'noItem'),
                style: TextStyle(color: Colors.white),
              )))
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {},
              child: Container(
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
                      child: ListView.builder(
                          padding: EdgeInsetsDirectional.only(
                              bottom: 5, start: 10, end: 10, top: 12),
                          controller: notificationcontroller,
                          physics: BouncingScrollPhysics(),
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            Product item;
                            try {
                              item = productList.isEmpty
                                  ? null
                                  : productList[index];
                              if (notificationisloadmore &&
                                  index == (productList.length - 1) &&
                                  notificationcontroller.position.pixels <= 0) {
                                getProduct();
                              }
                            } on Exception catch (_) {}

                            return item == null ? Container() : listItem(index);
                          }),
                    ),
                    notificationisgettingdata
                        ? Padding(
                            padding:
                                EdgeInsetsDirectional.only(top: 5, bottom: 5),
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }
}
