import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop/Home3.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';
import 'package:eshop/chat_manager/chat_manager.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Section_Model.dart';
import 'Product_Detail.dart';

class Favorite extends StatefulWidget {
  Function update;

  Favorite(this.update);

  @override
  State<StatefulWidget> createState() => StateFav();
}

bool _isProgress = false, _isFavLoading = true;
int offset = 0;
int total = 0;
bool isLoadingmore = true;
List<SectionModel> favList = [];

class StateFav extends State<Favorite> with TickerProviderStateMixin {
  ScrollController controller = new ScrollController();
  List<SectionModel> tempList = [];
  String msg;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  bool isShow = false;
  bool isShow1 = false;
  StateSetter stateSet;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    checkVersion(context);
    getMessageCount();
    super.initState();
    new Future.delayed(Duration.zero, () {
      msg = getTranslated(context, 'noFav');
    });

    offset = 0;
    total = 0;
    getdata();

    controller.addListener(_scrollListener);
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

  getdata() async {
    await _getFav();
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
                  _getFav();
                } else {
                  await buttonController.reverse();
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    checkVersion(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff200738),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(),
                  showCircularProgress(_isProgress, colors.primary),
                  Positioned(
                      bottom: 5,
                      right: 10,
                      child: FloatingActionButton(
                        backgroundColor: Color(0xff341069),
                        onPressed: () async {
                          Future.delayed(Duration(milliseconds: 100), () {
                            isShow = true;
                          });
                          Future.delayed(Duration(seconds: 5), () {
                            isShow1 = true;
                          });
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
                                  }).then((value) {
                                    getMessageCount();
                                    setState(() {});
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
                          child: Stack(
                            children: [
                              Icon(
                                Icons.chat,
                                color: Colors.white,
                              ),
                              totalmessageCount >= 1
                                  ? Positioned(
                                right: 0,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red),
                                ),
                              )
                                  : SizedBox()
                            ],
                          ),
                        ),
                      )),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index) {
    if (favList[index].productList.length == 0) {
      return Container();
    } else {
      int selectedPos = 0;
      for (int i = 0;
          i < favList[index].productList[0].prVarientList.length;
          i++) {
        if (favList[index].varientId ==
            favList[index].productList[0].prVarientList[i].id) selectedPos = i;
      }

      double price = double.parse(
          favList[index].productList[0].prVarientList[selectedPos].disPrice);
      if (price == 0)
        price = double.parse(
            favList[index].productList[0].prVarientList[selectedPos].price);

      return Card(
        elevation: 0.1,
        child: Stack(
          children: [
            favList[index].productList[0].availability == "0"
                ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.red))
                : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                      tag: "$index${favList[index].productList[0].id}",
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: InkWell(
                            onTap: () {
                              Product model = favList[index].productList[0];
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => ProductDetail(
                                          model: model,
                                          updateParent: updateFav,
                                          updateHome: widget.update,
                                          secPos: 0,
                                          index: index,
                                          list: true,
                                          //  title: productList[index].name,
                                        )),
                              );
                            },
                            child: FadeInImage(
                              image: NetworkImage(
                                  favList[index].productList[0].image),
                              height: 80.0,
                              width: 80.0,
                              fit: BoxFit.cover,
                              // errorWidget: (context, url, e) => placeHolder(80),
                              placeholder: placeHolder(80),
                            ),
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
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 5.0),
                                  child: Text(
                                    favList[index].productList[0].name,
                                    style: TextStyle(
                                        color: colors.lightBlack,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                CUR_CURRENCY + " " + price.toString() + " ",
                                style: TextStyle(
                                    color: colors.fontColor,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                double.parse(favList[index]
                                            .productList[0]
                                            .prVarientList[selectedPos]
                                            .disPrice) !=
                                        0
                                    ? CUR_CURRENCY +
                                        "" +
                                        favList[index]
                                            .productList[0]
                                            .prVarientList[selectedPos]
                                            .price
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .overline
                                    .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        letterSpacing: 0.7),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 20,
                                child: PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  onSelected: (result) async {
                                    if (result == 0) {
                                      _removeFav(index);
                                    }
                                    if (result == 1) {
                                      addToCart(index);
                                    }
                                    if (result == 2) {
                                      if (mounted)
                                        setState(() {
                                          _isProgress = true;
                                        });
                                      createDynamicLink(index, 0, true,
                                          favList[index].productList[0].id);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    PopupMenuItem(
                                      value: 0,
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsetsDirectional.only(
                                                start: 0.0, end: 0.0),
                                        leading: Icon(
                                          Icons.close,
                                          color: colors.fontColor,
                                          size: 20,
                                        ),
                                        title: Text('Remove'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsetsDirectional.only(
                                                start: 0.0, end: 0.0),
                                        leading: Icon(Icons.shopping_cart,
                                            color: colors.fontColor, size: 20),
                                        title: Text('Add to Cart'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsetsDirectional.only(
                                                start: 0.0, end: 0.0),
                                        leading: Icon(Icons.share_outlined,
                                            color: colors.fontColor, size: 20),
                                        title: Text('Share'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  updateFav() {
    if (mounted) setState(() {});
  }

  Future<Null> _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (CUR_USERID != null) {
          var parameter = {
            USER_ID: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
          };

          Response response =
              await post(getFavApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new SectionModel.fromFav(data))
                  .toList();
              if (offset == 0) favList.clear();
              favList.addAll(tempList);
              for (int i = 0; i < favList.length; i++) {
                if (favList[i].productList.length == 0) {
                  favList.removeAt(i);
                  setState(() {});
                }
              }

              offset = offset + perPage;
            }
          } else {
            if (msg != 'No Favourite(s) Product Are Added') setSnackbar(msg);
            isLoadingmore = false;
            msg = getTranslated(context, 'noFav');
          }

          if (mounted) if (mounted)
            setState(() {
              _isFavLoading = false;
            });
        } else {
          if (mounted)
            setState(() {
              new Future.delayed(Duration.zero, () {
                msg = getTranslated(context, 'goToLogin');
                _isFavLoading = false;
              });
            });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
        if (mounted)
          setState(() {
            _isFavLoading = false;
            isLoadingmore = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    return null;
  }

  Future<void> addToCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            _isProgress = true;
          });
        String qty = (int.parse(
                    favList[index].productList[0].prVarientList[0].cartCount) +
                int.parse(favList[index].productList[0].qtyStepSize))
            .toString();

        if (int.parse(qty) < favList[index].productList[0].minOrderQuntity) {
          qty = favList[index].productList[0].minOrderQuntity.toString();
          setSnackbar('Minimum order quantity is $qty');
        }

        var parameter = {
          PRODUCT_VARIENT_ID: favList[index].productList[0].prVarientList[0].id,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            CUR_CART_COUNT = data['cart_count'];
            favList[index].productList[0].prVarientList[0].cartCount =
                qty.toString();

            widget.update();
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
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

  // removeFromCart(int index, bool remove) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     try {
  //       if (mounted)
  //         setState(() {
  //           _isProgress = true;
  //         });

  //       var parameter = {
  //         USER_ID: CUR_USERID,
  //         QTY: remove
  //             ? "0"
  //             : (int.parse(favList[index]
  //                         .productList[0]
  //                         .prVarientList[0]
  //                         .cartCount) -
  //                     1)
  //                 .toString(),
  //         PRODUCT_VARIENT_ID: favList[index].productList[0].prVarientList[0].id
  //       };

  //       Response response =
  //           await post(manageCartApi, body: parameter, headers: headers)
  //               .timeout(Duration(seconds: timeOut));
  //       if (response.statusCode == 200) {
  //         var getdata = json.decode(response.body);

  //         bool error = getdata["error"];
  //         String msg = getdata["message"];
  //         if (!error) {
  //           var data = getdata["data"];

  //           String qty = data['total_quantity'];
  //           CUR_CART_COUNT = data['cart_count'];

  //           if (remove)
  //             favList.removeWhere(
  //                 (item) => item.varientId == favList[index].varientId);
  //           else {
  //             favList[index].productList[0].prVarientList[0].cartCount =
  //                 qty.toString();
  //           }

  //           widget.update();
  //         } else {
  //           setSnackbar(msg);
  //         }
  //         if (mounted)
  //           setState(() {
  //             _isProgress = false;
  //           });
  //       }
  //     } on TimeoutException catch (_) {
  //       setSnackbar(getTranslated(context, 'somethingMSg'));
  //       if (mounted)
  //         setState(() {
  //           _isProgress = false;
  //         });
  //     }
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //   }
  // }

  _removeFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: favList[index].productId,
        };
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        for (int i = 0; i < favList.length; i++) {
          if (favList[i].productList.length == 0) {
            favList.removeAt(i);
            setState(() {});
          }
        }

        if (!error) {
          favList.removeWhere((item) =>
              item.productList[0].prVarientList[0].id ==
              favList[index].productList[0].prVarientList[0].id);
        } else {
          setSnackbar(msg);
        }

        if (mounted) setState(() {});
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

  Future<void> createDynamicLink(
      int index, int secPos, bool list, String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: deepLinkUrlPrefix,
      link: Uri.parse(
          'https://$deepLinkName/?index=$index&secPos=$secPos&list=$list&id=$id'),
      androidParameters: AndroidParameters(
        packageName: packageName,
        minimumVersion: 1,
      ),
      iosParameters: IOSParameters(
        bundleId: iosPackage,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
    );

    final Uri longDynamicUrl = await parameters.link;
    final ShortDynamicLink shortenedLink = ShortDynamicLink(
        type: ShortDynamicLinkType.short, shortUrl: longDynamicUrl);
/*        await ShortDynamicLink.shortenUrl(
      longDynamicUrl,
      new DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );*/

    var str =
        "\n$appName\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";
    var documentDirectory;
    if (Platform.isIOS)
      documentDirectory = (await getApplicationDocumentsDirectory()).path;
    else
      documentDirectory = (await getExternalStorageDirectory()).path;

    final response1 = await get(Uri.parse(favList[index].productList[0].image));
    final bytes1 = response1.bodyBytes;
    final File imageFile =
        File('$documentDirectory/${favList[index].productList[0].name}.png');
    imageFile.writeAsBytesSync(bytes1);
    Share.shareFiles(
        ['$documentDirectory/${favList[index].productList[0].name}.png'],
        text:
            "${favList[index].productList[0].name}\n${shortenedLink.shortUrl.toString()}\n$str");

    if (mounted)
      setState(() {
        _isProgress = false;
      });
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) _getFav();
          });
      }
    }
  }

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isFavLoading = true;
      });
    offset = 0;
    total = 0;
    return _getFav();
  }

  _showContent() {
    return _isFavLoading
        ? shimmer()
        : favList.length == 0
            ? Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      // Color(0xFF280F43),
                      // Color(0xffE5CCFF),
                      Color(0xFF200738),
                      Color(0xFF3B147A),
                      Color(0xFFF8F8FF),
                    ])),
                child: Center(
                    child: Text(
                  msg ?? getTranslated(context, 'noFav'),
                  style: TextStyle(color: Colors.white),
                )))
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // Color(0xFF280F43),
                          // Color(0xffE5CCFF),
                          Color(0xFF200738),
                          Color(0xFF3B147A),
                          Color(0xFFF8F8FF),
                        ]),
                  ),
                  child: ListView.builder(
                    //shrinkWrap: true,
                    controller: controller,
                    itemCount:
                        (offset < total) ? favList.length + 1 : favList.length,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return (index == favList.length && isLoadingmore)
                          ? Center(child: CircularProgressIndicator())
                          : listItem(index);
                    },
                  ),
                ));
  }
}
