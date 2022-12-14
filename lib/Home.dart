import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/MyProfile.dart';
import 'package:eshop/ProductList.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'SubCat2.dart';

bool search = false;
bool homePage = false;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

bool isConfigured = false;
List<Product> catList = [];
List<Model> homeSliderList = [];
List<SectionModel> sectionList = [];
List<Model> offerImages = [];
List<Widget> pages = [];
bool _isCatLoading = true;
bool _isNetworkAvail = true;
int curSelected = 0;
GlobalKey bottomNavigationKey = GlobalKey();
int count = 1;

class StateHome extends State<Home> {
  List<Widget> fragments;
  DateTime currentBackPressTime;
  HomePage home;
  String profile;
  int curDrwSel = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  var isDarkTheme;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    print("This is Home Screen");
    final pushNotificationService =
        PushNotificationService(context: context, updateHome: updateHome);

    pushNotificationService.initialise();

    initDynamicLinks();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Favourite(updateHome),
      NotificationList(),
      MyProfile(updateHome),
    ];
  }

  updateHome() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            key: scaffoldKey,
            appBar: curSelected == 0
                ? null
                : curSelected == 3
                    ? null
                    : _getAppbar(),
            // drawer: _getDrawer(),
            bottomNavigationBar: getBottomBar(),
            body: fragments[curSelected]));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (curSelected != 0) {
      curSelected = 0;
      final CurvedNavigationBarState navBarState =
          bottomNavigationKey.currentState;
      navBarState.setPage(0);

      return Future.value(false);
    } else if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(getTranslated(context, 'EXIT_WR'));

      return Future.value(false);
    }
    return Future.value(true);
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

  _getAppbar() {
    String title = curSelected == 1
        ? getTranslated(context, 'FAVORITE')
        : getTranslated(context, 'NOTIFICATION');

    return AppBar(
      title: curSelected == 0
          ? Image.asset('assets/images/titleicon.png')
          : Text(
              title,
              style: TextStyle(
                color: colors.fontColor,
              ),
            ),
      iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
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
                onTap: () {
                  CUR_USERID == null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ))
                      : goToCart();
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
      backgroundColor: curSelected == 0 ? Colors.transparent : colors.white,
      elevation: 0,
    );
  }

  getBottomBar() {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return CurvedNavigationBar(
        key: bottomNavigationKey,
        backgroundColor: isDarkTheme ? colors.darkColor : colors.lightWhite,
        color: isDarkTheme ? colors.darkColor2 : colors.white,
        height: 65,
        items: <Widget>[
          curSelected == 0
              ? Container(
                  height: 40,
                  child: Center(
                      child: SvgPicture.asset(
                    "assets/images/sel_home.svg",
                  )))
              : SvgPicture.asset(
                  "assets/images/desel_home.svg",
                ),
          curSelected == 1
              ? Container(
                  height: 40,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/images/sel_fav.svg",
                    ),
                  ),
                )
              : SvgPicture.asset(
                  "assets/images/desel_fav.svg",
                ),
          curSelected == 2
              ? Container(
                  height: 40,
                  child: Center(
                      child: SvgPicture.asset(
                    "assets/images/sel_notification.svg",
                  )))
              : SvgPicture.asset(
                  "assets/images/desel_notification.svg",
                ),
          curSelected == 3
              ? Container(
                  height: 40,
                  child: Center(
                      child: SvgPicture.asset(
                    "assets/images/sel_user.svg",
                  )))
              : SvgPicture.asset(
                  "assets/images/desel_user.svg",
                )
        ],
        onTap: (int index) {
          if (mounted)
            setState(() {
              curSelected = index;
            });
        });
  }

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(updateHome, null),
        )).then((val) {
      home.updateHomepage();
      init();
    });
  }

  void initDynamicLinks() async {
/*   Stream<PendingDynamicLinkData> firebaseDynamicLinks= FirebaseDynamicLinks.instance.onLink;
   firebaseDynamicLinks.

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']);

          int secPos = int.parse(deepLink.queryParameters['secPos']);

          String id = deepLink.queryParameters['id'];

          String list = deepLink.queryParameters['list'];

          getProduct(id, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });*/

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']);

        int secPos = int.parse(deepLink.queryParameters['secPos']);

        String id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    print("get Product");
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => ProductDetail(
                        index: list ? int.parse(id) : index,
                        updateHome: updateHome,
                        updateParent: updateParent,
                        model: list
                            ? items[0]
                            : sectionList[secPos].productList[index],
                        secPos: secPos,
                        list: list,
                      )))
              .then((value) {
            setState(() {
              home.updateHomepage();
              init();
            });
          });
          setState(() {
            homePage = true;
          });
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else {
      {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  updateParent() {
    if (mounted) setState(() {});
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  Function updateHome;

  HomePage(this.updateHome);

  StateHomePage statehome = new StateHomePage();

  @override
  StateHomePage createState() => StateHomePage();

  updateHomepage() {
    statehome.getSection();
  }
}

class StateHomePage extends State<HomePage> with TickerProviderStateMixin {
  final _controller = PageController();
  int _curSlider = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool useMobileLayout;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool menuOpen = false;
  var isDarkTheme;
  int selIndex;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    print("This is home page");
    callApi();
    //getCat();
    //getSetting();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
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

  updateHomePage() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    //print("Loading Categories");
    // getSetting();

    if (_isCatLoading) {
      //print("Loading Shimmer");
      return homeShimmer();
    } else {
      //print("Loading Home");
      return _home();
    }
  }

  Widget _home() {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colors.darkColor2, //Color(0xff1c1d23),
        appBar: AppBar(
          title: Image.asset('assets/images/titleicon.png'),
          iconTheme: new IconThemeData(color: colors.primary),
          // centerTitle:_curSelected == 0? false:true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  top: 10.0, bottom: 10, end: 10),
              child: Container(
                decoration: shadow(),
                child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      // CUR_USERID == null
                      //     ? Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Login(),
                      //     ))
                      //     : goToCart();
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
          backgroundColor: curSelected == 0 ? Colors.transparent : colors.white,
          elevation: 0,
          bottom: TabBar(
            onTap: (index) {
              print(_tc.index.toString());
              if (mounted)
                setState(() {
                  curTabId = index.toString();
                });
            },
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xffd99d60),
              border: Border.all(color: Colors.white54),
            ),
            //indicatorColor: Colors.pinkAccent,
            labelColor: Colors.white,
            //unselectedLabelColor: Colors.black,
            isScrollable: true,
            controller: _tc,
            tabs: _tabs
                .map((tab) => Tab(
                      text: tab['text'],
                    ))
                .toList(),
          ),
        ),
        body: _isNetworkAvail
            ? _isCatLoading
                ? homeShimmer()
                : TabBarView(
                    controller: _tc,
                    children: _views.map((view) => view).toList())
            : noInternet(context));
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
                  //getSlider();
                  //getCat();
                  //getSection();
                  getSetting();
                  //getOfferImages();
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

  Widget homeShimmer() {
    double width = deviceWidth;
    double height = width / 2;
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: colors.darkColor2,
        highlightColor: colors.darkColor2,
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              height: height,
              color: colors.darkColor,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              height: 18.0,
              color: colors.darkColor,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                        .map((_) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              width: 50.0,
                              height: 50.0,
                              color: colors.darkColor,
                            ))
                        .toList()),
              ),
            ),
            Column(
                children: [0, 1, 2, 3, 4]
                    .map((_) => Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: double.infinity,
                              height: 18.0,
                              color: colors.darkColor2,
                            ),
                            Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 8.0,
                                color: colors.darkColor2),
                            GridView.count(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: colors.darkColor2);
                                  },
                                )),
                          ],
                        ))
                    .toList()),
          ],
        )),
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 30)).then((_) {
      if (mounted) {
        int nextPage = _controller.hasClients
            ? _controller.page.round() + 1
            : _controller.initialPage;

        if (nextPage == homeSliderList.length) {
          nextPage = 0;
        }
        if (_controller.hasClients)
          _controller
              .animateToPage(nextPage,
                  duration: Duration(milliseconds: 200), curve: Curves.linear)
              .then((_) => _animateSlider());
      }
    });
  }

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
  String curTabId;
  List<TextEditingController> _controller2 = [];

  _catList() {
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
    return;
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

  TabController _makeNewTabController(int pos) => TabController(
        vsync: this,
        length: _tabs.length,
      );

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

  void _addInitailTab() {
    if (mounted)
      setState(() {
        print("_addInitailTab : " + subList.length.toString());
        for (int i = 0; i < subList.length; i++) {
          _tabs.add({
            'text': subList[i].name,
          });
          if (subList[i].subList == null || subList[i].subList.isEmpty) {
            _isLoading = true;
            isLoadingmore = true;
          }
          print("_addInitailTab : " +
              i.toString() +
              " == " +
              subList[i].id.toString());
          _views.insert(i, createTabContent(i, subList));
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
        //print("Parameters--"+parameter.toString());

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

  Widget createTabContent(int i, List<Product> subList) {
    List<Product> subItem = subList[i].subList;

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              _isLoading
                  ? shimmer()
                  : subItem.length == 0
                      ? Flexible(flex: 1, child: getNoItem(context))
                      : GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          physics: NeverScrollableScrollPhysics(),
                          children: List.generate(
                            subItem.length,
                            (index) {
                              return productListItem(index, subItem);
                            },
                          ))
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

      if (_controller2.length < index + 1)
        _controller2.add(new TextEditingController());

      _controller2[index].text =
          model.prVarientList[model.selVarient].cartCount;

      return subItem.length >= index
          ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                margin: EdgeInsets.only(bottom: 7),
                //color: Color(0xffeef3f9) ,//,Colors.teal
                color: Colors.transparent,
                child: ClipRRect(
                  //borderRadius: BorderRadius. circular(20.0),
                  child: InkWell(
                    //borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Product model = subItem[index];
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ProductDetail(
                                  model: model,
                                  //updateParent: updateProductList,
                                  index: index,
                                  secPos: 0,
                                  updateHome: widget.updateHome,
                                  list: true,
                                )),
                      ).then((value) {
                        setState(() {
                          updateHomePage();
                          init();
                        });
                      });
                      setState(() {
                        homePage = true;
                      });
                    },
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          top: 90,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff313237),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                //BoxShadow(blurRadius: 33.0),
                                BoxShadow(
                                    color: Color(0xFFD3D3D3).withOpacity(.84),
                                    offset: Offset(0, -2),
                                    blurRadius: 33),
                                BoxShadow(
                                    color: Color(0xFFD3D3D3).withOpacity(.84),
                                    offset: Offset(0, 0)),
                                BoxShadow(
                                    color: Color(0xff303136).withOpacity(.5),
                                    offset: Offset(0, 0)),
                                BoxShadow(
                                    color: Color(0xff303136).withOpacity(.5),
                                    offset: Offset(0, 0)),
                              ],
                            ),
                          ),
                        ),

                        ///for image
                        Positioned(
                          left: 36,
                          child: Container(
                            //color: Colors.tealAccent,
                            height: 125,
                            width: 90,
                            child: Image.network(subItem[index].image,
                                fit: BoxFit.cover),
                          ),
                        ),
                        // Positioned(
                        //   top: 128,
                        //   left: 10,
                        //   child: Text(_tc.index.toString(),
                        //   style: TextStyle(color: Colors.white),),
                        // ),
                        /// for rating
                        // Positioned(
                        //   top: 128,
                        //   left: 10,
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.star,
                        //         color: colors.primary,
                        //         size: 12,
                        //       ),
                        //       Text(
                        //         " " + model.rating,
                        //         style: TextStyle(color: Color(0xfff6b343)),
                        //       ),
                        //       Text(
                        //         " (" + model.noOfRating + ")",
                        //         style: TextStyle(color: Color(0xfff6b343)),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        ///for name
                        Positioned(
                          top: 148,
                          left: 10,
                          right: 5,
                          child: Container(
                            //width: 190,
                            child: Text(
                              subItem[index].name.toString(), //model.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        ///for price
                        Positioned(
                          top: 185,
                          left: 10,
                          child: Text(
                            CUR_CURRENCY + "" + price.toString() + " ",
                            style: TextStyle(
                                color: Color(0xfff6b343),
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),

                        ///for offprice 1

                        Positioned(
                          top: 202,
                          left: 12,
                          child: Text(
                            double.parse(model.prVarientList[model.selVarient]
                                        .disPrice) !=
                                    0
                                ? CUR_CURRENCY +
                                    "" +
                                    model.prVarientList[model.selVarient].price
                                : "",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xfff6b343),
                                decoration: TextDecoration.lineThrough),
                          ),
                        ),

                        model.availability == "0"
                            ? Container()
                            //: cartBtnList
                            : Positioned(
                                top: 182,
                                left: 132,
                                child: Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: Container(
                                            height: 42,
                                            width: 42,
                                            padding: EdgeInsets.all(2),
                                            margin: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              Icons.add,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            decoration: BoxDecoration(
                                                color: Color(0xfff6b343),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                          ),
                                          onTap: () {
                                            if (_isProgress == false)
                                              addToCart(
                                                  index,
                                                  (int.parse(model
                                                              .prVarientList[model
                                                                  .selVarient]
                                                              .cartCount) +
                                                          int.parse(model
                                                              .qtyStepSize))
                                                      .toString(),
                                                  model);
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                        //: Container(),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Stack(children: <Widget>[
                    //     Row(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: <Widget>[
                    //         Hero(
                    //           tag: "$index${subItem[index].id}",
                    //           child: ClipRRect(
                    //               borderRadius: BorderRadius.circular(7.0),
                    //               child: FadeInImage(
                    //                 fadeInDuration: Duration(milliseconds: 150),
                    //                 image: NetworkImage(subItem[index].image),
                    //                 height: 80.0,
                    //                 width: 80.0,
                    //                 fit: BoxFit.cover,
                    //                 placeholder: placeHolder(80),
                    //               )),
                    //         ),
                    //         Expanded(
                    //           child: Padding(
                    //             padding:
                    //             const EdgeInsets.symmetric(horizontal: 8.0),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 Text(
                    //                   subItem[index].name,
                    //                   style: Theme.of(context)
                    //                       .textTheme
                    //                       .subtitle2
                    //                       .copyWith(color: colors.lightBlack),
                    //                   maxLines: 2,
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //                 Row(
                    //                   children: <Widget>[
                    //                     Row(
                    //                       children: <Widget>[
                    //                         Text(
                    //                             CUR_CURRENCY +
                    //                                 " " +
                    //                                 price.toString() +
                    //                                 " ",
                    //                             style: Theme.of(context)
                    //                                 .textTheme
                    //                                 .subtitle1),
                    //                         Text(
                    //                           double.parse(subItem[index]
                    //                               .prVarientList[0]
                    //                               .disPrice) !=
                    //                               0
                    //                               ? CUR_CURRENCY +
                    //                               "" +
                    //                               subItem[index]
                    //                                   .prVarientList[0]
                    //                                   .price
                    //                               : "",
                    //                           style: Theme.of(context)
                    //                               .textTheme
                    //                               .overline
                    //                               .copyWith(
                    //                               decoration: TextDecoration
                    //                                   .lineThrough,
                    //                               letterSpacing: 0),
                    //                         ),
                    //                       ],
                    //                     )
                    //                   ],
                    //                 ),
                    //                 model.prVarientList[model.selVarient]
                    //                     .attr_name !=
                    //                     null &&
                    //                     model.prVarientList[model.selVarient]
                    //                         .attr_name.isNotEmpty
                    //                     ? ListView.builder(
                    //                     physics: NeverScrollableScrollPhysics(),
                    //                     shrinkWrap: true,
                    //                     itemCount: att.length,
                    //                     itemBuilder: (context, index) {
                    //                       return Row(children: [
                    //                         Flexible(
                    //                           child: Text(
                    //                             att[index].trim() + ":",
                    //                             overflow: TextOverflow.ellipsis,
                    //                             style: Theme.of(context)
                    //                                 .textTheme
                    //                                 .subtitle2
                    //                                 .copyWith(
                    //                                 color:
                    //                                 colors.lightBlack),
                    //                           ),
                    //                         ),
                    //                         Padding(
                    //                           padding:
                    //                           EdgeInsetsDirectional.only(
                    //                               start: 5.0),
                    //                           child: Text(
                    //                             val[index],
                    //                             style: Theme.of(context)
                    //                                 .textTheme
                    //                                 .subtitle2
                    //                                 .copyWith(
                    //                                 color:
                    //                                 colors.lightBlack,
                    //                                 fontWeight:
                    //                                 FontWeight.bold),
                    //                           ),
                    //                         )
                    //                       ]);
                    //                     })
                    //                     : Container(),
                    //                 Row(
                    //                   children: [
                    //                     Row(
                    //                       children: [
                    //                         Icon(
                    //                           Icons.star,
                    //                           color: colors.primary,
                    //                           size: 12,
                    //                         ),
                    //                         Text(
                    //                           " " + subItem[index].rating,
                    //                           style: Theme.of(context)
                    //                               .textTheme
                    //                               .overline,
                    //                         ),
                    //                         Text(
                    //                           " (" +
                    //                               subItem[index].noOfRating +
                    //                               ")",
                    //                           style: Theme.of(context)
                    //                               .textTheme
                    //                               .overline,
                    //                         )
                    //                       ],
                    //                     ),
                    //                     Spacer(),
                    //                     model.availability == "0"
                    //                         ? Container()
                    //                         : cartBtnList
                    //                         ? Row(
                    //                       children: <Widget>[
                    //                         Row(
                    //                           children: <Widget>[
                    //                             GestureDetector(
                    //                               child: Container(
                    //                                 padding:
                    //                                 EdgeInsets.all(2),
                    //                                 margin:
                    //                                 EdgeInsetsDirectional
                    //                                     .only(end: 8),
                    //                                 child: Icon(
                    //                                   Icons.remove,
                    //                                   size: 14,
                    //                                   color: colors
                    //                                       .fontColor,
                    //                                 ),
                    //                                 decoration: BoxDecoration(
                    //                                     color: colors
                    //                                         .lightWhite,
                    //                                     borderRadius: BorderRadius
                    //                                         .all(Radius
                    //                                         .circular(
                    //                                         3))),
                    //                               ),
                    //                               onTap: () {
                    //                                 if (_isProgress ==
                    //                                     false &&
                    //                                     (int.parse(model
                    //                                         .prVarientList[
                    //                                     model
                    //                                         .selVarient]
                    //                                         .cartCount)) >
                    //                                         0)
                    //                                   removeFromCart(
                    //                                       index, model);
                    //                               },
                    //                             ),
                    //                             Container(
                    //                               width: 40,
                    //                               height: 20,
                    //                               child: Stack(
                    //                                 children: [
                    //                                   TextField(
                    //                                     textAlign:
                    //                                     TextAlign
                    //                                         .center,
                    //                                     readOnly: true,
                    //                                     style: TextStyle(
                    //                                       fontSize: 10,
                    //                                     ),
                    //                                     controller:
                    //                                     _controller2[
                    //                                     index],
                    //                                     decoration:
                    //                                     InputDecoration(
                    //                                       contentPadding:
                    //                                       EdgeInsets
                    //                                           .all(
                    //                                           5.0),
                    //                                       focusedBorder:
                    //                                       OutlineInputBorder(
                    //                                         borderSide: BorderSide(
                    //                                             color: colors
                    //                                                 .fontColor,
                    //                                             width:
                    //                                             0.5),
                    //                                         borderRadius:
                    //                                         BorderRadius
                    //                                             .circular(
                    //                                             5.0),
                    //                                       ),
                    //                                       enabledBorder:
                    //                                       OutlineInputBorder(
                    //                                         borderSide: BorderSide(
                    //                                             color: colors
                    //                                                 .fontColor,
                    //                                             width:
                    //                                             0.5),
                    //                                         borderRadius:
                    //                                         BorderRadius
                    //                                             .circular(
                    //                                             5.0),
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                   PopupMenuButton<
                    //                                       String>(
                    //                                     tooltip: '',
                    //                                     icon: const Icon(
                    //                                       Icons
                    //                                           .arrow_drop_down,
                    //                                       size: 1,
                    //                                     ),
                    //                                     onSelected:
                    //                                         (String
                    //                                     value) {
                    //                                       if (_isProgress ==
                    //                                           false)
                    //                                         addToCart(
                    //                                             index,
                    //                                             value,
                    //                                             model);
                    //                                     },
                    //                                     itemBuilder:
                    //                                         (BuildContext
                    //                                     context) {
                    //                                       return model
                    //                                           .itemsCounter
                    //                                           .map<
                    //                                           PopupMenuItem<
                    //                                               String>>((String
                    //                                       value) {
                    //                                         return new PopupMenuItem(
                    //                                             child: new Text(
                    //                                                 value),
                    //                                             value:
                    //                                             value);
                    //                                       }).toList();
                    //                                     },
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                             ), // ),
                    //
                    //                             GestureDetector(
                    //                               child: Container(
                    //                                 padding:
                    //                                 EdgeInsets.all(2),
                    //                                 margin:
                    //                                 EdgeInsets.only(
                    //                                     left: 8),
                    //                                 child: Icon(
                    //                                   Icons.add,
                    //                                   size: 14,
                    //                                   color: colors
                    //                                       .fontColor,
                    //                                 ),
                    //                                 decoration: BoxDecoration(
                    //                                     color: colors
                    //                                         .lightWhite,
                    //                                     borderRadius: BorderRadius
                    //                                         .all(Radius
                    //                                         .circular(
                    //                                         3))),
                    //                               ),
                    //                               onTap: () {
                    //                                 if (_isProgress ==
                    //                                     false)
                    //                                   addToCart(
                    //                                       index,
                    //                                       (int.parse(model
                    //                                           .prVarientList[model
                    //                                           .selVarient]
                    //                                           .cartCount) +
                    //                                           int.parse(
                    //                                               model.qtyStepSize))
                    //                                           .toString(),
                    //                                       model);
                    //                               },
                    //                             )
                    //                           ],
                    //                         ),
                    //                       ],
                    //                     )
                    //                         : Container(),
                    //                   ],
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //     subItem[index].availability == "0"
                    //         ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .subtitle2
                    //             .copyWith(
                    //             color: Colors.red,
                    //             fontWeight: FontWeight.bold))
                    //         : Container(),
                    //   ]),
                    // ),
                  ),
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

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList.length > index) {
      String offPer;
      double price = double.parse(
          sectionList[secPos].productList[index].prVarientList[0].disPrice);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList[index].prVarientList[0].price);
      } else {
        double off = double.parse(
                sectionList[secPos].productList[index].prVarientList[0].price) -
            price;
        offPer = ((off * 100) /
                double.parse(sectionList[secPos]
                    .productList[index]
                    .prVarientList[0]
                    .price))
            .toStringAsFixed(2);
      }

      double width = deviceWidth * 0.5;

      return Card(
        elevation: 0.2,
        margin: EdgeInsetsDirectional.only(bottom: 5, end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    child: Hero(
                      tag:
                          "${sectionList[secPos].productList[index].id}$secPos$index",
                      child: FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                            sectionList[secPos].productList[index].image),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        fit: extendImg ? BoxFit.fill : BoxFit.contain,
                        // errorWidget: (context, url, e) => placeHolder(width),
                        placeholder: placeHolder(width),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, top: 5, bottom: 5),
                child: Text(
                  sectionList[secPos].productList[index].name,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: colors.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(" " + CUR_CURRENCY + " " + price.toString(),
                  style: TextStyle(
                      color: colors.fontColor, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, bottom: 5, top: 3),
                child: double.parse(sectionList[secPos]
                            .productList[index]
                            .prVarientList[0]
                            .disPrice) !=
                        0
                    ? Row(
                        children: <Widget>[
                          Text(
                            double.parse(sectionList[secPos]
                                        .productList[index]
                                        .prVarientList[0]
                                        .disPrice) !=
                                    0
                                ? CUR_CURRENCY +
                                    "" +
                                    sectionList[secPos]
                                        .productList[index]
                                        .prVarientList[0]
                                        .price
                                : "",
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0),
                          ),
                          Flexible(
                            child: Text(" | " + "-$offPer%",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .overline
                                    .copyWith(
                                        color: colors.primary,
                                        letterSpacing: 0)),
                          ),
                        ],
                      )
                    : Container(
                        height: 5,
                      ),
              )
            ],
          ),
          onTap: () {
            Product model = sectionList[secPos].productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                  // transitionDuration: Duration(milliseconds: 150),
                  pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      updateParent: updateHomePage,
                      secPos: secPos,
                      index: index,
                      updateHome: widget.updateHome,
                      list: false
                      //  title: sectionList[secPos].title,
                      )),
            ).then((value) {
              setState(() {
                updateHomePage();
                init();
              });
            });
            setState(() {
              homePage = true;
            });
          },
        ),
      );
    } else
      return Container();
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

  Future<void> callApi() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getCat();
      getSetting();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
      if (mounted) if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
  }

  Future<Null> getSlider() async {
    try {
      Response response = await post(getSliderApi, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          homeSliderList =
              (data as List).map((data) => new Model.fromSlider(data)).toList();

          pages = homeSliderList.map((slider) {
            return _buildImagePageItem(slider);
          }).toList();
        } else {
          setSnackbar(msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
    return null;
  }

  Future<Null> getCat() async {
    try {
      var parameter = {
        CAT_FILTER: "false",
      };
      Response response =
          await post(getCatApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          catList =
              (data as List).map((data) => new Product.fromCat(data)).toList();

          subList = catList; //[0].subList;
          print("Loading Cat Finish : " + subList.length.toString());
        } else {
          setSnackbar(msg);
        }
      }
      if (mounted) if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted) if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
    _catList();
    return null;
  }

  Future<Null> getSection() async {
    try {
      var parameter = {PRODUCT_LIMIT: "4", PRODUCT_OFFSET: "0"};

      if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;

      Response response =
          await post(getSectionApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          sectionList.clear();
          sectionList = (data as List)
              .map((data) => new SectionModel.fromJson(data))
              .toList();
        } else {
          setSnackbar(msg);
        }
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) if (mounted)
          setState(() {
            _isCatLoading = false;
          });
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
    return null;
  }

  Future<Null> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter;
      if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

      Response response = await post(getSettingApi,
              body: CUR_USERID != null ? parameter : null, headers: headers)
          .timeout(Duration(seconds: timeOut));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"]["system_settings"][0];
          cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
          CUR_CURRENCY = data["currency"];
          RETURN_DAYS = data['max_product_return_days'];
          MAX_ITEMS = data["max_items_cart"];
          MIN_AMT = data['min_amount'];
          MIN_CART_AMT = data['minimum_cart_amt'];
          CUR_DEL_CHR = data['delivery_charge'];
          String isVerion = data['is_version_system_on'];
          extendImg = data["expand_product_images"] == "1" ? true : false;
          String del = data["area_wise_delivery_charge"];
          if (del == "0")
            ISFLAT_DEL = true;
          else
            ISFLAT_DEL = false;
          if (CUR_USERID != null) {
            CUR_CART_COUNT =
                getdata["data"]["user_data"][0]["cart_total_items"].toString();
            REFER_CODE = getdata['data']['user_data'][0]['referral_code'];
            if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE.isEmpty)
              generateReferral();
            CUR_BALANCE = getdata["data"]["user_data"][0]["balance"];
          }
          widget.updateHome();

          if (isVerion == "1") {
            String verionAnd = data['current_version'];
            String verionIOS = data['current_version_ios'];
            debugPrint(verionIOS.toString());
            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(verionAnd);
            //final Version latestVersionIos = Version.parse(verionIOS);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion)
                // || (Platform.isIOS && latestVersionIos > currentVersion)
                ) updateDailog();
          }
        } else {
          setSnackbar(msg);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
    }
    return null;
  }

  updateDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              title: Text(getTranslated(context, 'UPDATE_APP')),
              content: Text(
                getTranslated(context, 'UPDATE_AVAIL'),
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: colors.fontColor),
              ),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, 'NO'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.lightBlack,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                new TextButton(
                    child: Text(
                      getTranslated(context, 'YES'),
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          .copyWith(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop(false);

                      String _url = '';
                      if (Platform.isAndroid) {
                        _url = androidLink + packageName;
                      } else if (Platform.isIOS) {
                        _url = iosLink;
                      }

                      // ignore: deprecated_member_use
                      if (await canLaunch(_url)) {
                        // ignore: deprecated_member_use
                        await launch(_url);
                      } else {
                        throw 'Could not launch $_url';
                      }
                    })
              ],
            );
          });
        });
  }

  Future<Null> generateReferral() async {
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
        REFER_CODE = refer;
        setUpdateUser(refer);
      } else {
        if (count < 5) generateReferral();
        count++;
      }
    } on TimeoutException catch (_) {}
    return null;
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Null> setUpdateUser(String code) async {
    var data = {
      USER_ID: CUR_USERID,
      REFERCODE: code,
    };

    Response response =
        await post(getUpdateUserApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    print(response.statusCode);
  }

  Future<Null> getOfferImages() async {
    try {
      Response response = await post(getOfferImageApi, headers: headers)
          .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          offerImages.clear();
          offerImages =
              (data as List).map((data) => new Model.fromSlider(data)).toList();
        } else {
          setSnackbar(msg);
        }
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) if (mounted)
          setState(() {
            _isCatLoading = false;
          });
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'));
      if (mounted)
        setState(() {
          _isCatLoading = false;
        });
    }
    return null;
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth / 2.2;

    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7.0),
        child: CachedNetworkImage(
          imageUrl: (slider.image),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.fill,
          placeholder: (context, url) => SvgPicture.asset(
            "assets/images/sliderph.svg",
            fit: BoxFit.fill,
            height: height,
          ),
        ),
      ),
      onTap: () async {
        if (homeSliderList[_curSlider].type == "products") {
          Product item = homeSliderList[_curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
                //transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: item,
                    updateParent: updateHomePage,
                    secPos: 0,
                    index: 0,
                    updateHome: widget.updateHome,
                    list: true
                    //  title: sectionList[secPos].title,
                    )),
          ).then((value) {
            setState(() {
              updateHomePage();
              init();
            });
          });
          setState(() {
            homePage = true;
          });
        } else if (homeSliderList[_curSlider].type == "categories") {
          Product item = homeSliderList[_curSlider].list;
          if (item.subList == null || item.subList.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                      name: item.name,
                      id: item.id,
                      tag: false,
                      updateHome: widget.updateHome),
                ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCat(
                      title: item.name,
                      subList: item.subList,
                      updateHome: widget.updateHome),
                ));
          }
        }
      },
    );
  }
}
