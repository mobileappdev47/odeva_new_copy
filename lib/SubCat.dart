import 'dart:async';
import 'dart:convert';

import 'package:eshop/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'Search.dart';

class SubCat extends StatefulWidget {
  String title;
  List<Product> subList = [];
  final Function updateHome;

  SubCat({this.subList, this.title, this.updateHome});

  @override
  _SubCatState createState() => _SubCatState(subList: subList);
}

class _SubCatState extends State<SubCat> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tc;
  ScrollController controller = new ScrollController();
  List<Map<String, dynamic>> _tabs = [];
  List<Widget> _views = [];
  List<Product> subList = [];
  List<Product> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  bool _isLoading = false, _isProgress = false;
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isNetworkAvail = true;

  String filter = "";
  String selId = "";
  String totalProduct;

  //var filterList;
  List<String> attnameList;
  List<String> attsubList;
  List<String> attListId;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  String curTabId;
  List<TextEditingController> _controller = [];

  _SubCatState({this.subList});

  @override
  void initState() {
    super.initState();

    this._addInitailTab();
    controller.addListener(_scrollListener);
    if (subList != null) {
      if (subList[0].subList == null || subList[0].subList.isEmpty) {
        curTabId = subList[0].id;
        _isLoading = true;
        getProduct(curTabId, 0, "0");
      }
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
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
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
                  if (mounted) if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  TabController _makeNewTabController(int pos) => TabController(
        vsync: this,
        length: _tabs.length,
      );

  void _addTab(List<Product> subItem, int index) {
    if (mounted) if (mounted)
      setState(() {
        _tabs.add({
          'text': subItem[index].name,
        });
        _views.add(createTabContent(index, subItem));
        _tc = _makeNewTabController(_tabs.length - 1)
          ..addListener(() {
            curTabId = subList[_tc.index].id;
            selId = null;
            if (mounted)
              setState(() {
                if (subList[_tc.index].subList == null ||
                    subList[_tc.index].subList.isEmpty) {
                  clearList("0");
                }
              });
          });
        _tc.animateTo(_tc.length - 1);
      });
    // -----------
/*     if (mounted) setState(() {
      for (int i = 0; i < subList.length; i++) {
        _tabs.add({
          'text': subList[i].name,
        });
        if (subList[i].subList == null || subList[i].subList.isEmpty) {
          _isLoading = true;
          isLoadingmore = true;
        }
        _views.add(createTabContent(i, subList));
      }

      _tc = _makeNewTabController(0)
        ..addListener(() {
           if (mounted) setState(() {
            if (subList[_tc.index].subList == null ||
                subList[_tc.index].subList.isEmpty) {
              clearList("0");
            } else {}
          });

          selId = null;
        });
    });*/
  }

  void _addInitailTab() {
    if (mounted)
      setState(() {
        for (int i = 0; i < subList.length; i++) {
          _tabs.add({
            'text': subList[i].name,
          });
          if (subList[i].subList == null || subList[i].subList.isEmpty) {
            _isLoading = true;
            isLoadingmore = true;
          }
          _views.add(createTabContent(i, subList));
        }

        _tc = _makeNewTabController(0)
          ..addListener(() {
            if (mounted)
              setState(() {
                if (subList[_tc.index].subList == null ||
                    subList[_tc.index].subList.isEmpty) {
                  clearList("0");
                } else {}
              });

            selId = null;
          });
      });
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: colors.fontColor,
          ),
        ),
        elevation: 5,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4.0),
                  child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                ),
              ),
            ),
          );
        }),
        bottom: TabBar(
          controller: _tc,
          isScrollable: true,
          tabs: _tabs
              .map((tab) => Tab(
                    text: tab['text'],
                  ))
              .toList(),
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(
                          updateHome: widget.updateHome,
                        ),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.search,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          subList.length > _tc.index &&
                  subList[_tc.index].filterList != null &&
                  subList[_tc.index].isFromProd &&
                  subList[_tc.index].filterList.length > 0
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: shadow(),
                  child: Card(
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          return filterDialog();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.tune,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                      )))
              : Container(),
          subList.length > _tc.index &&
                  subList[_tc.index].subList != null &&
                  subList[_tc.index].isFromProd &&
                  subList[_tc.index].subList.length > 0
              ? Container(
                  margin: EdgeInsetsDirectional.only(top: 10, bottom: 10),
                  decoration: shadow(),
                  child: Card(
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          return sortDialog();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.filter_list,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                      )))
              : Container(),
          Container(
            margin: EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 5),
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
                            builder: (context) => Cart(widget.updateHome, null),
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
      body: TabBarView(
        controller: _tc,
        children: _views.map((view) => view).toList(),
      ),
    );
  }

  Widget createTabContent(int i, List<Product> subList) {
    List<Product> subItem = subList[i].subList;

    return !subList[i].isFromProd && (subItem != null)
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FadeInImage(
                  fadeInDuration: Duration(milliseconds: 150),
                  image: NetworkImage(subList[i].banner),
                  height: 150,
                  width: double.maxFinite,
                  fit: BoxFit.fill,
                  placeholder: AssetImage(
                    "assets/images/sliderph.png",
                  ),
                ),
                GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      subItem.length,
                      (index) {
                        return listItem(index, subItem);
                      },
                    ))
              ],
            ),
          )
        : Stack(
            children: <Widget>[
              SingleChildScrollView(
                controller: controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeInImage(
                      fadeInDuration: Duration(milliseconds: 150),
                      image: NetworkImage(subList[i].banner),
                      height: 150,
                      width: double.maxFinite,
                      fit: BoxFit.fill,
                      placeholder: AssetImage(
                        "assets/images/sliderph.png",
                      ),
                    ),
                    _isLoading
                        ? shimmer()
                        : subItem.length == 0
                            ? Flexible(flex: 1, child: getNoItem(context))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    (subList[i].offset < subList[i].totalItem)
                                        ? subItem.length + 1
                                        : subItem.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return (index == subItem.length &&
                                          isLoadingmore)
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : productListItem(index, subItem);
                                },
                              )
                  ],
                ),
              ),
              showCircularProgress(_isProgress, colors.primary),
            ],
          );
  }

  Widget productListItem(int index, List<Product> subItem) {
    if (index < subItem.length) {
      Product model = subItem[index];

      double price = double.parse(subItem[index].prVarientList[0].disPrice);
      if (price == 0)
        price = double.parse(subItem[index].prVarientList[0].price);

      List att, val;
      if (model.prVarientList[model.selVarient].attr_name != null) {
        att = model.prVarientList[model.selVarient].attr_name.split(',');
        val = model.prVarientList[model.selVarient].varient_value.split(',');
      }
      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text = model.prVarientList[model.selVarient].cartCount;

      return subItem.length >= index
          ? Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Product model = subItem[index];
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                              model: model,
                              updateParent: updateProductList,
                              index: index,
                              secPos: 0,
                              updateHome: widget.updateHome,
                              list: true,
                            )),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Hero(
                          tag: "$index${subItem[index].id}",
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: FadeInImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                image: NetworkImage(subItem[index].image),
                                height: 80.0,
                                width: 80.0,
                                fit: BoxFit.cover,
                                placeholder: placeHolder(80),
                              )),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  subItem[index].name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(color: colors.lightBlack),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                            CUR_CURRENCY +
                                                " " +
                                                price.toString() +
                                                " ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1),
                                        Text(
                                          double.parse(subItem[index]
                                                      .prVarientList[0]
                                                      .disPrice) !=
                                                  0
                                              ? CUR_CURRENCY +
                                                  "" +
                                                  subItem[index]
                                                      .prVarientList[0]
                                                      .price
                                              : "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  letterSpacing: 0),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                model.prVarientList[model.selVarient]
                                                .attr_name !=
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
                                                        color:
                                                            colors.lightBlack),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                      start: 5.0),
                                              child: Text(
                                                val[index],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2
                                                    .copyWith(
                                                        color:
                                                            colors.lightBlack,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            )
                                          ]);
                                        })
                                    : Container(),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: colors.primary,
                                          size: 12,
                                        ),
                                        Text(
                                          " " + subItem[index].rating,
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        ),
                                        Text(
                                          " (" +
                                              subItem[index].noOfRating +
                                              ")",
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        )
                                      ],
                                    ),
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
                                                            color: colors
                                                                .fontColor,
                                                          ),
                                                          decoration: BoxDecoration(
                                                              color: colors
                                                                  .lightWhite,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          3))),
                                                        ),
                                                        onTap: () {
                                                          if (_isProgress ==
                                                                  false &&
                                                              (int.parse(model
                                                                      .prVarientList[
                                                                          model
                                                                              .selVarient]
                                                                      .cartCount)) >
                                                                  0)
                                                            removeFromCart(
                                                                index, model);
                                                        },
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 20,
                                                        child: Stack(
                                                          children: [
                                                            TextField(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              readOnly: true,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                              controller:
                                                                  _controller[
                                                                      index],
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: colors
                                                                          .fontColor,
                                                                      width:
                                                                          0.5),
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
                                                                      width:
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                ),
                                                              ),
                                                            ),
                                                            PopupMenuButton<
                                                                String>(
                                                              tooltip: '',
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                size: 1,
                                                              ),
                                                              onSelected:
                                                                  (String
                                                                      value) {
                                                                if (_isProgress ==
                                                                    false)
                                                                  addToCart(
                                                                      index,
                                                                      value,
                                                                      model);
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
                                                                      child: new Text(
                                                                          value),
                                                                      value:
                                                                          value);
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
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 8),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 14,
                                                            color: colors
                                                                .fontColor,
                                                          ),
                                                          decoration: BoxDecoration(
                                                              color: colors
                                                                  .lightWhite,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          3))),
                                                        ),
                                                        onTap: () {
                                                          if (_isProgress ==
                                                              false)
                                                            addToCart(
                                                                index,
                                                                (int.parse(model
                                                                            .prVarientList[model
                                                                                .selVarient]
                                                                            .cartCount) +
                                                                        int.parse(
                                                                            model.qtyStepSize))
                                                                    .toString(),
                                                                model);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    subItem[index].availability == "0"
                        ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold))
                        : Container(),
                  ]),
                ),
              ),
            )
          : Container();
    } else
      return Container();
  }

  Future<void> addToCart(int index, String qty, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
              _views[_tc.index] = createTabContent(_tc.index, subList);
            });

          if (int.parse(qty) < model.minOrderQuntity) {
            qty = model.minOrderQuntity.toString();
            setSnackbar('Minimum order quantity is $qty');
          }

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: model.prVarientList[model.selVarient].id,
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

            model.prVarientList[model.selVarient].cartCount = qty.toString();
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
              _views[_tc.index] = createTabContent(_tc.index, subList);
            });

          widget.updateHome();
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'));
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCart(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
              _views[_tc.index] = createTabContent(_tc.index, subList);
            });

          int qty;

          qty = (int.parse(model.prVarientList[model.selVarient].cartCount) -
              int.parse(model.qtyStepSize));

          if (qty < model.minOrderQuntity) {
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

            String qty = data['total_quantity'];
            CUR_CART_COUNT = data['cart_count'];

            model.prVarientList[model.selVarient].cartCount = qty.toString();
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
              _views[_tc.index] = createTabContent(_tc.index, subList);
            });
          if (widget.updateHome != null) widget.updateHome();
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'));
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Widget listItem(int index, List<Product> subItem) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: new FadeInImage(
                    fadeInDuration: Duration(milliseconds: 150),
                    image: NetworkImage(subItem[index].image),
                    height: double.maxFinite,
                    width: double.maxFinite,
                    placeholder: placeHolder(100),
                  ),
                ),
              ),
            ),
            Container(
              child: Text(
                subItem[index].name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              width: 100,
            ),
          ],
        ),
      ),
      onTap: () {
        if (subItem[index].subList != null)
          _addTab(subItem, index);
        else
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subItem[index].name,
                  id: subItem[index].id,
                  tag: false,
                  updateHome: widget.updateHome,
                ),
              ));
      },
    );
  }

  void sortDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: new AlertDialog(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding:
                          EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        getTranslated(context, 'SORT_BY'),
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(getTranslated(context, 'TOP_RATED'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: colors.lightBlack)),
                      onPressed: () {
                        sortBy = '';
                        orderBy = 'DESC';

                        clearList("1");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(getTranslated(context, 'F_NEWEST'),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: colors.lightBlack)),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';

                        clearList("0");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: Text(
                        getTranslated(context, 'F_OLDEST'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';
                        clearList("0");
                        Navigator.pop(context, 'option 2');
                      }),
                  Divider(color: colors.lightBlack),
                  TextButton(
                      child: new Text(
                        getTranslated(context, 'F_LOW'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';
                        clearList("0");
                        Navigator.pop(context, 'option 3');
                      }),
                  Divider(color: colors.lightBlack),
                  Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 5.0),
                      child: TextButton(
                          child: new Text(
                            getTranslated(context, 'F_HIGH'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: colors.lightBlack),
                          ),
                          onPressed: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';
                            clearList("0");
                            Navigator.pop(context, 'option 4');
                          })),
                ])),
          );
        });
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    getTranslated(context, 'FILTER'),
                    style: TextStyle(
                      color: colors.fontColor,
                    ),
                  ),
                  elevation: 5,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: shadow(),
                      child: Card(
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4.0),
                            child: Icon(Icons.keyboard_arrow_left,
                                color: colors.primary),
                          ),
                        ),
                      ),
                    );
                  }),
                  actions: [
                    Container(
                      margin: EdgeInsetsDirectional.only(end: 10.0),
                      alignment: Alignment.center,
                      child: InkWell(
                          child: Text(
                              getTranslated(context, 'FILTER_CLEAR_LBL'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: colors.fontColor)),
                          onTap: () {
                            if (mounted)
                              setState(() {
                                subList[_tc.index].selectedId.clear();
                              });
                          }),
                    ),
                  ],
                )),
            Expanded(
                child: Container(
                    color: colors.lightWhite,
                    padding: EdgeInsetsDirectional.only(
                        start: 7.0, end: 7.0, top: 7.0),
                    child: Card(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Expanded(
                              flex: 2,
                              child: Container(
                                  color: colors.lightWhite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    padding:
                                        EdgeInsetsDirectional.only(top: 10.0),
                                    itemCount:
                                        subList[_tc.index].filterList.length,
                                    itemBuilder: (context, index) {
                                      attsubList = subList[_tc.index]
                                          .filterList[index]
                                          .attributeValues
                                          .split(',');

                                      attListId = subList[_tc.index]
                                          .filterList[index]
                                          .attributeValId
                                          .split(',');

                                      if (filter == "") {
                                        filter = subList[_tc.index]
                                            .filterList[0]
                                            .name;
                                      }

                                      return InkWell(
                                          onTap: () {
                                            if (mounted)
                                              setState(() {
                                                filter = subList[_tc.index]
                                                    .filterList[index]
                                                    .name;
                                              });
                                          },
                                          child: Container(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 20,
                                                top: 10.0,
                                                bottom: 10.0),
                                            decoration: BoxDecoration(
                                                color: filter ==
                                                        subList[_tc.index]
                                                            .filterList[index]
                                                            .name
                                                    ? colors.white
                                                    : colors.lightWhite,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    bottomLeft:
                                                        Radius.circular(7))),
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: new Text(
                                              subList[_tc.index]
                                                  .filterList[index]
                                                  .name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                      color: filter ==
                                                              subList[_tc.index]
                                                                  .filterList[
                                                                      index]
                                                                  .name
                                                          ? colors.fontColor
                                                          : colors.lightBlack,
                                                      fontWeight:
                                                          FontWeight.normal),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ));
                                    },
                                  ))),
                          Expanded(
                              flex: 3,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  padding:
                                      EdgeInsetsDirectional.only(top: 10.0),
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      subList[_tc.index].filterList.length,
                                  itemBuilder: (context, index) {
                                    if (filter ==
                                        subList[_tc.index]
                                            .filterList[index]
                                            .name) {
                                      attsubList = subList[_tc.index]
                                          .filterList[index]
                                          .attributeValues
                                          .split(',');

                                      attListId = subList[_tc.index]
                                          .filterList[index]
                                          .attributeValId
                                          .split(',');
                                      return Container(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: attListId.length,
                                              itemBuilder: (context, i) {
                                                return CheckboxListTile(
                                                  dense: true,
                                                  title: Text(attsubList[i],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1
                                                          .copyWith(
                                                              color: colors
                                                                  .lightBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                  value: subList[_tc.index]
                                                      .selectedId
                                                      .contains(attListId[i]),
                                                  activeColor: colors.primary,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                  onChanged: (bool val) {
                                                    if (mounted)
                                                      setState(() {
                                                        if (val == true) {
                                                          subList[_tc.index]
                                                              .selectedId
                                                              .add(
                                                                  attListId[i]);
                                                        } else {
                                                          subList[_tc.index]
                                                              .selectedId
                                                              .remove(
                                                                  attListId[i]);
                                                        }
                                                      });
                                                  },
                                                );
                                              }));
                                    } else {
                                      return Container();
                                    }
                                  })),
                        ])))),
            Container(
              color: colors.white,
              child: Row(children: <Widget>[
                Padding(
                    padding: EdgeInsetsDirectional.only(start: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subList[_tc.index].totalItem.toString()),
                        Text(getTranslated(context, 'PRODUCTS_FOUND_LBL')),
                      ],
                    )),
                Spacer(),
                SimBtn(
                  size: 0.4,
                  title: getTranslated(context, 'APPLY'),
                  onBtnSelected: () {
                    if (subList[_tc.index].selectedId != null) {
                      selId = subList[_tc.index].selectedId.join(',');
                      clearList("0");
                      Navigator.pop(context, 'Product Filter');
                    }
                  },
                ),
              ]),
            )
          ]);
        });
      },
    );
  }

  Future<void> getProduct(String id, int cur, String top) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          CATID: id,
          SORT: sortBy,
          ORDER: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: subList[cur].subList == null
              ? '0'
              : subList[cur].subList.length.toString(),
          TOP_RETAED: top
        };
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        print("Parameters--"+parameter.toString());

        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));
      
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            total = int.parse(getdata["total"]);
            offset =
                subList[cur].subList == null ? 0 : subList[cur].subList.length;

            if (subList[cur].filterList == null ||
                subList[cur].filterList.length == 0) {
              subList[cur].filterList = (getdata["filters"] as List)
                  .map((data) => new Filter.fromJson(data))
                  .toList();
              subList[cur].selectedId = [];
            }

            if (offset < total) {
              tempList.clear();

              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new Product.fromJson(data))
                  .toList();
              if (offset == 0) subList[cur].subList = [];

              subList[cur].subList.addAll(tempList);
              offset = subList[cur].offset + perPage;

              subList[cur].offset = offset;
              subList[cur].totalItem = total;
            }
          } else {
            if (offset == 0) subList[cur].subList = [];
            if (msg != "Products Not Found !") setSnackbar(msg);
            isLoadingmore = false;
          }
          if (mounted)
            setState(() {
              _isLoading = false;
            });

          subList[cur].isFromProd = true;
          _views[cur] = createTabContent(cur, subList);
        } else {
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
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

  clearList(String top) {
    if (mounted)
      setState(() {
        _isLoading = true;
        _views[_tc.index] = createTabContent(_tc.index, subList);
        total = 0;
        offset = 0;
        subList[_tc.index].totalItem = 0;
        subList[_tc.index].offset = 0;
        subList[_tc.index].subList = [];
        curTabId = subList[_tc.index].id;

        getProduct(curTabId, _tc.index, top);
      });
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

  updateProductList() {
    if (mounted) setState(() {});
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (subList[_tc.index].offset < subList[_tc.index].totalItem) {
          //  if (mounted) setState(() {
          isLoadingmore = true;
          // });
          curTabId = subList[_tc.index].id;
          _views[_tc.index] = createTabContent(_tc.index, subList);
          getProduct(curTabId, _tc.index, "0");
        }
      }
    }
  }
}
