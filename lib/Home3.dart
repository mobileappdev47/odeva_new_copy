import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/Helper/Stripe_Service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' as g;
import 'package:marquee/marquee.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/MyProfile.dart';
import 'package:eshop/ProductList.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'Cart.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Constant.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'Search.dart';
import 'SubCat.dart';

int curhome3Selected = 0;
int totalmessageCount = 0;
String isManager;

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

GlobalKey bottomNavigationKey = GlobalKey();
int count = 1;
int prodCall = 1;
StateSetter stateSet;
bool isShow = false;
bool isShow1 = false;

class StateHome extends State<Home> {
  List<Widget> fragments;
  DateTime currentBackPressTime;
  HomePage home;
  String profile;
  int curDrwSel = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print("This is Home Screen");
    final pushNotificationService =
        PushNotificationService(context: context, updateHome: updateHome);

    pushNotificationService.initialise();

    initDynamicLinks();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Search(
        updateHome: updateHome,
      ),
      Favourite(updateHome),
      NotificationList(),
      MyProfile(updateHome),
    ];
  }

  updateHome() {
    if (mounted)
      setState(() {
        print("update home called ");
        home.updateHomepage();
      });
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          decoration: BoxDecoration(),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              //Color(0xff1c1d23),
              key: scaffoldKey,
              appBar: curhome3Selected == 4
                  ? null
                  : curhome3Selected == 0
                      ? null
                      : curhome3Selected == 1
                          ? null
                          : curhome3Selected == 2
                              ? _getFavAppbar()
                              : curhome3Selected == 3
                                  ? _getNotificationAppbar()
                                  : _getAppbar(),
              // drawer: _getDrawer(),
              bottomNavigationBar: getBottomBar(),
              body: fragments[curhome3Selected]),
        ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (curhome3Selected != 0) {
      curhome3Selected = 0;
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

  _getNotificationAppbar() {
    return AppBar(
      //toolbarHeight: 80,
      titleSpacing: 15,
      title: Text(
        "Notifications",
        style: TextStyle(color: colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsetsDirectional.only(top: 5.0, bottom: 5, end: 10),
          child: Container(
            height: 55,
            width: 50,
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
                    child: Container(
                      height: 32,
                      width: 32,
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
                          bottom: 15,
                          child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 10,
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
      backgroundColor: colors.darkColor,
      //curSelected == 0 ? Colors.transparent : colors.white,
      elevation: 0,
    );
  }

  _getFavAppbar() {
    String title = curhome3Selected == 2
        ? getTranslated(context, 'FAVORITE')
        : getTranslated(context, 'NOTIFICATION');
    debugPrint(title.toString());

    return AppBar(
      //toolbarHeight: 80,
      titleSpacing: 15,
      title: Text(
        "Favorites",
        style: TextStyle(color: colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        Padding(
          padding:
              const EdgeInsetsDirectional.only(top: 5.0, bottom: 5, end: 10),
          child: Container(
            height: 55,
            width: 50,
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
                    child: Container(
                      height: 32,
                      width: 32,
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
                          bottom: 15,
                          child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary.withOpacity(0.5)),
                              child: new Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: new Text(
                                    CUR_CART_COUNT,
                                    style: TextStyle(
                                        fontSize: 10,
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
      backgroundColor: colors.darkColor,
      //curSelected == 0 ? Colors.transparent : colors.white,
      elevation: 0,
    );
  }

  _getAppbar() {
    String title = curhome3Selected == 2
        ? getTranslated(context, 'FAVORITE')
        : getTranslated(context, 'NOTIFICATION');

    return AppBar(
      //toolbarHeight: 80,
      title: curhome3Selected == 0
          ? Container(
              height: 73,
              width: 200,
              // child: Image.asset('assets/images/titleicon.png')
            )
          : Text(
              title,
              style: TextStyle(
                color: colors.fontColor,
              ),
            ),
      iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curhome3Selected == 0? false:true,
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
      backgroundColor:
          curhome3Selected == 0 ? Colors.transparent : colors.white,
      elevation: 0,
    );
  }

  // _getAppbar() {
  //   String title = curhome3Selected == 1
  //       ? getTranslated(context, 'FAVORITE')
  //       : getTranslated(context, 'NOTIFICATION');
  //
  //   return AppBar(
  //     title: curhome3Selected == 0
  //         ? Text("QUALITY STORE LIVE",
  //          style: TextStyle(letterSpacing: 0.3,fontWeight: FontWeight.w700,fontSize: 25,color: colors.fontColor),
  //         )
  //         : Text(
  //             title,
  //             style: TextStyle(
  //               color: colors.fontColor,
  //             ),
  //           ),
  //     iconTheme: new IconThemeData(color: colors.primary),
  //     // centerTitle:_curhome3Selected == 0? false:true,
  //     actions: <Widget>[
  //       Padding(
  //         padding:
  //             const EdgeInsetsDirectional.only(top: 6.0, bottom: 6.0, end: 10),
  //         child: Container(
  //           decoration: shadow(),
  //           child: Card(
  //             elevation: 0,
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(4),
  //               onTap: () {
  //                 CUR_USERID == null
  //                     ? Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => Login(),
  //                         ))
  //                     : goToCart();
  //               },
  //               child: new Stack(children: <Widget>[
  //                 Center(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(5.0),
  //                     child: SvgPicture.asset(
  //                       'assets/images/noti_cart.svg',
  //                     ),
  //                   ),
  //                 ),
  //                 (CUR_CART_COUNT != null &&
  //                         CUR_CART_COUNT.isNotEmpty &&
  //                         CUR_CART_COUNT != "0")
  //                     ? new Positioned(
  //                         top: 0.0,
  //                         right: 5.0,
  //                         bottom: 10,
  //                         child: Container(
  //                             decoration: BoxDecoration(
  //                                 shape: BoxShape.circle,
  //                                 color: colors.primary.withOpacity(0.5)),
  //                             child: new Center(
  //                               child: Padding(
  //                                 padding: EdgeInsets.all(3),
  //                                 child: new Text(
  //                                   CUR_CART_COUNT,
  //                                   style: TextStyle(
  //                                       fontSize: 7,
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                               ),
  //                             )),
  //                       )
  //                     : Container()
  //               ]),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //     backgroundColor: curhome3Selected == 0 ? Colors.transparent : colors.white,
  //     elevation: 0,
  //   );
  // }

  // getBottomBar() {
  //   isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  //   return CurvedNavigationBar(
  //       key: bottomNavigationKey,
  //       backgroundColor: isDarkTheme ? colors.darkColor : colors.lightWhite,
  //       color: Color(0xffEAE8ED),//isDarkTheme ? colors.darkColor2 : colors.white,
  //       height: 65,
  //       items: <Widget>[
  //         curhome3Selected == 0
  //             ? Container(
  //             height: 40,
  //             child: Center(
  //                 child: SvgPicture.asset(
  //                   "assets/images/sel_home.svg",
  //                 )))
  //             : SvgPicture.asset(
  //           "assets/images/desel_home.svg",
  //         ),
  //         curhome3Selected == 1
  //             ? Container(
  //           height: 40,
  //           child: Center(
  //             child: SvgPicture.asset(
  //               "assets/images/sel_fav.svg",
  //             ),
  //           ),
  //         )
  //             : SvgPicture.asset(
  //           "assets/images/desel_fav.svg",
  //         ),
  //         curhome3Selected == 2
  //             ? Container(
  //             height: 40,
  //             child: Center(
  //                 child: SvgPicture.asset(
  //                   "assets/images/sel_notification.svg",
  //                 )))
  //             : SvgPicture.asset(
  //           "assets/images/desel_notification.svg",
  //         ),
  //         curhome3Selected == 3
  //             ? Container(
  //             height: 40,
  //             child: Center(
  //                 child: SvgPicture.asset(
  //                   "assets/images/sel_user.svg",
  //                 )))
  //             : SvgPicture.asset(
  //           "assets/images/desel_user.svg",
  //         )
  //       ],
  //       onTap: (int index) {
  //         if (mounted)
  //           setState(() {
  //             curhome3Selected = index;
  //           });
  //       });
  // }
  getBottomBar() {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: curhome3Selected,
        //key: bottomNavigationKey,
        //backgroundColor: isDarkTheme ? colors.darkColor : colors.lightWhite,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.darkColor,
        //colors.lightWhite,
        //color: isDarkTheme ? colors.darkColor2 : colors.white,
        items: [
          curhome3Selected == 0
              ? BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/sel_home.svg"),
                  //label: 'Home',
                  label:
                      "Home" /*Text('Home', style: TextStyle(color: Colors.black54))*/,
                )
              : BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/desel_home.svg"),
                  //label: 'Home',
                  label: /*Text('Home', style: TextStyle(color: Colors.black54))*/ "Home",
                ),
          curhome3Selected == 1
              ? BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/sel_search.svg"),
                  //label: 'Home',
                  label:
                      "Search" /*Text('Search', style: TextStyle(color: Colors.black54))*/,
                )
              : BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/desel_search.svg"),
                  //label: 'Home',
                  label:
                      "Search" /*Text('Search', style: TextStyle(color: Colors.black54))*/,
                ),
          curhome3Selected == 2
              ? BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/sel_fav.svg"),
                  //label: 'Home',
                  label:
                      "Favourite" /*Text('Favourite',
                      style: TextStyle(color: Colors.black54))*/
                  ,
                )
              : BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/desel_fav.svg"),
                  //label: 'Home',
                  label:
                      "" /*Text('Favourite',
                      style: TextStyle(color: Colors.black54))*/
                      "Favourite",
                ),
          curhome3Selected == 3
              ? BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/sel_notification.svg"),
                  //label: 'Home',
                  label:
                      "Notification" /*Text('Notification',
                      style: TextStyle(color: Colors.black54))*/
                  ,
                )
              : BottomNavigationBarItem(
                  icon:
                      SvgPicture.asset("assets/images/desel_notification.svg"),
                  //label: 'Home',
                  label:
                      "Notification" /*Text('Notification',
                      style: TextStyle(color: Colors.black54))*/
                  ,
                ),
          curhome3Selected == 4
              ? BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/sel_user.svg"),
                  //label: 'Home',
                  label:
                      "User" /*Text('User', style: TextStyle(color: Colors.black54))*/,
                )
              : BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/desel_user.svg"),
                  //label: 'Home',
                  label:
                      "User" /*Text('User', style: TextStyle(color: Colors.black54))*/,
                ),
        ],
        onTap: (int index) {
          if (mounted)
            setState(() {
              curhome3Selected = index;
            });
        });
  }

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(updateHome, updateHome),
        )).then((val) => home.updateHomepage());
  }

  void initDynamicLinks() async {
    /*FirebaseDynamicLinks.instance.onLink(
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

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    updateHome: updateHome,
                    updateParent: updateParent,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList[index],
                    secPos: secPos,
                    list: list,
                  )));
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
  int selectedTabIndex;

  updateHomepage() {
    print("Here we are new2");

    // _views[_tc.index] = createTabContent(_tc.index, subList);
    // statehome._views[statehome._tc.index] = statehome.createTabContent(statehome._tc.index, statehome.subList);
    // statehome.getSection();
    statehome.updateHomePage();
    print("Here we are new outer...... old " + selectedTabIndex.toString());
    // statehome._views[selectedTabIndex] = statehome.createTabContent(selectedTabIndex, statehome.subList);
    print("Here we are new3");
  }
}

class StateHomePage extends State<HomePage> with TickerProviderStateMixin {
  final _controller = PageController();
  TabController _tc;
  int _curSlider = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool useMobileLayout;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool menuOpen = false;

  var isDarkTheme;
  int selIndex;

  // bool _useRtlText = false;

  Image imageCart;

  @override
  void initState() {
    check();

    init();
    imageCart = Image.asset(
      'assets/images/cart.png',
    );
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback(
    //         (_) => _showStartDialog());
  }

  check() async {
    await checkVersion(context);
  }

  init() {
    print("This is Home Page");
    print(totalmessageCount);
    //callApi();
    getCat();
    getMessageCount();
    getSetting();
    getPayment();

    this._addInitailTab();
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
  void didChangeDependencies() {
    checkVersion(context);
    precacheImage(imageCart.image, context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ));
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  updateHomePage() {
    if (mounted)
      setState(() {
        print("Here we are new outer " + widget.selectedTabIndex.toString());
      });
    //try{
    //   _views[selIndex] = createTabContent(selIndex, subList);
    clearList("");
    // }catch(_){
    //   print("Here we are new outer2");
    // }
    if (mounted)
      setState(() {
        print("Here we are new");
        _views[_tc.index] = createTabContent(_tc.index, subList);
      });
  }

  Widget _buildMarquee() {
    if (SCROLLING_TEXT != "") {
      return Marquee(
        //key: Key("$_useRtlText"),
        text: //!_useRtlText
            //?
            SCROLLING_TEXT + "                                               ",
        style: TextStyle(color: Colors.white),
        velocity: 35.0,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Home3");
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
    return Container(
      decoration: BoxDecoration(
          // gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       Color(0xff280F43),
          //      // Color(0xff726D8B),
          //       Color(0xffEAE8ED)]
          // ),
          ),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent, //Color(0xff1c1d23),
          appBar: AppBar(
            toolbarHeight: 150, //deviceHeight*0.207,
            backgroundColor:
                curhome3Selected == 0 ? colors.darkColor : colors.white,
            elevation: 0,
            //centerTitle: true,
            flexibleSpace: SafeArea(
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: deviceWidth * 0.216,
                          width: deviceWidth * 0.586,

                          ///todo : home icon
                          // child: Image.asset(
                          //   'assets/images/titleicon.png',
                          //   fit: BoxFit.fill,
                          //   color: colors.white,
                          // ),
                          child:
                              Image.asset("assets/images/new_title_logo.png"),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              end: 10, bottom: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Card(
                              color: Color(0xffFED100),
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
                                child: //new Stack(children: <Widget>[
                                    Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(11.0),
                                      child: imageCart,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3),
                                      child: Container(
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD7AD15),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                              width: 3,
                                            ),

                                            /// Items count
                                            Text(
                                              " " + CUR_CART_COUNT,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "Items ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            SizedBox(width: 3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colors.darkColor, //Color(0xfff1f1f1),
                            width: 1,
                          ),
                        ),
                        color: colors.darkColor,
                      ),
                      height: 30,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: _buildMarquee(),
                    ),
                    Container(
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TabBar(
                        onTap: (int index) {
                          setState(() {
                            widget.selectedTabIndex = index;
                            print("here here : " +
                                widget.selectedTabIndex.toString() +
                                " => " +
                                _tc.index.toString() +
                                " => " +
                                index.toString() +
                                " => " +
                                curTabId.toString());
                          });
                        },
                        controller: _tc,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xffFED100),
                          //border: Border.all(color: Colors.white54),
                        ),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        //indicatorColor: Colors.pinkAccent,
                        labelColor: Colors.black,
                        //tabTextColor(), //Colors.white,
                        unselectedLabelColor: Colors.white,
                        isScrollable: true,
                        tabs: _tabs
                            .map((tab) => Tab(
                                  text: tab['text'],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // title: Container(
            //     height: 85,
            //     width: 230,
            //     child: Image.asset('assets/images/titleicon.png',fit: BoxFit.fill)),
            // actions: <Widget>[
            //   Padding(
            //     padding:
            //     const EdgeInsetsDirectional.only(top: 60.0, bottom: 28.0, end: 10,start: 13),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(15),
            //       child: Card(
            //         color: Color(0xffFED100),
            //         elevation: 0,
            //         child: InkWell(
            //           borderRadius: BorderRadius.circular(4),
            //           onTap: () {
            //             CUR_USERID == null
            //                 ? Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => Login(),
            //                 ))
            //                 : goToCart();
            //           },
            //           child: //new Stack(children: <Widget>[
            //           Row(
            //             children: [
            //               Padding(
            //                 padding: const EdgeInsets.all(11.0),
            //                 child: Image.asset(
            //                   'assets/images/cart.png',
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.only(right: 3),
            //                 child: Container(height: 34,
            //                   decoration: BoxDecoration(
            //                     color: Color(0xFFD7AD15),
            //                     borderRadius: BorderRadius.circular(5),
            //                   ),
            //                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                     children: [
            //                       SizedBox(width: 3,),
            //                       Text(" "+CUR_CART_COUNT,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),),
            //                       SizedBox(width: 2),
            //                       Text("Items ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400),),
            //                       SizedBox(width: 3),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //           // (CUR_CART_COUNT != null &&
            //           //     CUR_CART_COUNT.isNotEmpty &&
            //           //     CUR_CART_COUNT != "0")
            //           //     ? new Positioned(
            //           //   top: 0.0,
            //           //   right: 5.0,
            //           //   bottom: 10,
            //           //   child: Container(
            //           //       decoration: BoxDecoration(
            //           //           shape: BoxShape.circle,
            //           //           color: colors.primary.withOpacity(0.5)),
            //           //       child: new Center(
            //           //         child: Padding(
            //           //           padding: EdgeInsets.all(3),
            //           //           child: new Text(
            //           //             CUR_CART_COUNT,
            //           //             style: TextStyle(
            //           //                 fontSize: 7,
            //           //                 fontWeight: FontWeight.bold),
            //           //           ),
            //           //         ),
            //           //       )),
            //           // )
            //           //     : Container()
            //           //]),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
            // bottom: PreferredSize(
            //   //preferredSize: Size(deviceWidth-15.0,30.0),
            //   child: Container(
            //     height: 30,
            //     padding: EdgeInsets.symmetric(horizontal: 10),
            //     child: TabBar(
            //       controller: _tc,
            //       indicator: BoxDecoration(
            //         borderRadius: BorderRadius.circular(8),
            //         color: Color(0xffFED100),
            //         //border: Border.all(color: Colors.white54),
            //       ),
            //       labelStyle: TextStyle(fontWeight: FontWeight.bold),
            //       //indicatorColor: Colors.pinkAccent,
            //       labelColor: Colors.black,//tabTextColor(), //Colors.white,
            //       unselectedLabelColor: Colors.white,
            //       isScrollable: true,
            //       tabs: _tabs
            //           .map((tab) => Tab(
            //         text: tab['text'],
            //       ))
            //           .toList(),
            //     ),
            //   ),
            // ),
          ),
          body: _isNetworkAvail
              ? _isCatLoading
                  ? homeShimmer()
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
                      child: Stack(
                        children: [
                          /// item list at home page
                          TabBarView(
                            controller: _tc,
                            children: _views.map((view) => view).toList(),
                          ),

                          ///todo : chat button 1 (Home)
                          // Positioned(
                          //   bottom: 5,
                          //   right: 10,
                          //   child: FloatingActionButton(
                          //     backgroundColor: Color(0xff341069),
                          //     onPressed: () async {
                          //       CUR_USERID = await getPrefrence(ID);
                          //       if (CUR_USERID != null) {
                          //         setState(() {});
                          //
                          //         isManager = await getPrefrence("isManager");
                          //
                          //         if (isManager == "true") {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (_) => ChatManager()));
                          //         } else {
                          //           showModalBottomSheet(
                          //               isScrollControlled: true,
                          //               context: context,
                          //               shape: RoundedRectangleBorder(
                          //                   borderRadius: BorderRadius.only(
                          //                 topLeft: Radius.circular(10),
                          //                 topRight: Radius.circular(10),
                          //               )),
                          //               builder: (builder) {
                          //                 return StatefulBuilder(
                          //                   builder: (BuildContext context,
                          //                       StateSetter setState) {
                          //                     setState = setState;
                          //                     return Container(
                          //                       height: MediaQuery.of(context)
                          //                               .size
                          //                               .height /
                          //                           1.1,
                          //                       child: ChatFireScreen(
                          //                         isManager: false,
                          //                         roomId: null,
                          //                       ),
                          //                     );
                          //                   },
                          //                 );
                          //               }).then((value) {
                          //             init();
                          //           });
                          //         }
                          //       } else {
                          //         Navigator.pushReplacement(
                          //             context,
                          //             MaterialPageRoute(
                          //               builder: (context) => Login(),
                          //             ));
                          //       }
                          //       // Future.delayed(Duration(milliseconds: 100), () {
                          //       //   isShow = true;
                          //       // });
                          //       // Future.delayed(Duration(seconds: 5), () {
                          //       //   isShow1 = true;
                          //       // });
                          //
                          //       // showModalBottomSheet(
                          //       //     isScrollControlled: true,
                          //       //     shape: RoundedRectangleBorder(
                          //       //         borderRadius: BorderRadius.only(
                          //       //             topLeft: Radius.circular(10),
                          //       //             topRight: Radius.circular(10))),
                          //       //     context: context,
                          //       //     builder: (builder) {
                          //       //       return StatefulBuilder(builder:
                          //       //           (BuildContext context, StateSetter setState) {
                          //       //         stateSet = setState;
                          //       //         return Padding(
                          //       //           padding: MediaQuery.of(context).viewInsets,
                          //       //           child: Stack(
                          //       //             children: [
                          //       //               Container(
                          //       //                 height: MediaQuery.of(context).size.height /
                          //       //                     1.2,
                          //       //                 child: Tawk(
                          //       //                   directChatLink:
                          //       //                   'https://tawk.to/chat/623b7e145a88d50db1a702f4/1fus690c2',
                          //       //                   visitor: TawkVisitor(
                          //       //                     name: 'Ayoub AMINE',
                          //       //                     email: 'ayoubamine2a@gmail.com',
                          //       //                   ),
                          //       //                   onLoad: () {
                          //       //                     Future.delayed(
                          //       //                         Duration(milliseconds: 100), () {
                          //       //                       stateSet(() {
                          //       //                         isShow = true;
                          //       //                       });
                          //       //                       setState(() {});
                          //       //                     });
                          //       //                     Future.delayed(Duration(seconds: 5),
                          //       //                             () {
                          //       //                           stateSet(() {
                          //       //                             isShow1 = true;
                          //       //                           });
                          //       //                           setState(() {});
                          //       //                         });
                          //       //                     print('Hello Tawk!');
                          //       //                   },
                          //       //                   onLinkTap: (String url) {
                          //       //                     print(url);
                          //       //                   },
                          //       //                   placeholder: Center(
                          //       //                     child: Text('Loading...'),
                          //       //                   ),
                          //       //                 ),
                          //       //               ),
                          //       //               isShow == true
                          //       //                   ? Positioned(
                          //       //                   top: 25,
                          //       //                   left: 30,
                          //       //                   child: InkWell(
                          //       //                     onTap: () {
                          //       //                       stateSet(() {
                          //       //                         isShow = false;
                          //       //                         isShow1 = false;
                          //       //                       });
                          //       //                       setState(() {});
                          //       //                       Navigator.pop(context);
                          //       //                     },
                          //       //                     child: Container(
                          //       //                         decoration: BoxDecoration(
                          //       //                             color: Color(0xFF111f70),
                          //       //                             borderRadius:
                          //       //                             BorderRadius.circular(
                          //       //                                 20)),
                          //       //                         child: Icon(
                          //       //                           Icons.close,
                          //       //                           color: Colors.white,
                          //       //                         )),
                          //       //                   ))
                          //       //                   : SizedBox(),
                          //       //               isShow1 == true
                          //       //                   ? Positioned(
                          //       //                   top: 20,
                          //       //                   left: 300,
                          //       //                   right: 30,
                          //       //                   child: Container(
                          //       //                       height: MediaQuery.of(context)
                          //       //                           .size
                          //       //                           .height /
                          //       //                           19,
                          //       //                       color: Color(0xFF111f70)))
                          //       //                   : SizedBox(),
                          //       //             ],
                          //       //           ),
                          //       //         );
                          //       //       });
                          //       //     }).then((value){
                          //       //   setState(() {
                          //       //     stateSet((){
                          //       //       isShow = false;
                          //       //       isShow1 = false;
                          //       //     });
                          //       //   });
                          //       // });
                          //     },
                          //     child: Center(
                          //       child: Stack(
                          //         children: [
                          //           Icon(
                          //             Icons.chat,
                          //             color: Colors.white,
                          //           ),
                          //           totalmessageCount >= 1
                          //               ? Positioned(
                          //                   right: 0,
                          //                   child: Container(
                          //                     height: 8,
                          //                     width: 8,
                          //                     decoration: BoxDecoration(
                          //                         shape: BoxShape.circle,
                          //                         color: Colors.red),
                          //                   ),
                          //                 )
                          //               : SizedBox()
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    )
              : noInternet(context)),
    );
  }

  goToCart() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Cart(widget.updateHomepage(), null),
        )).then((val) {
      init();
      widget.updateHomepage();
    });
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
    Color color = shimmerColor();

    double width = deviceWidth;
    double height = width / 2;
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: color,
        highlightColor: color,
        enabled: true,
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              height: height,
              color: colors.darkColor2,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              width: double.infinity,
              height: 18.0,
              color: colors.darkColor2,
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
                              color: colors.darkColor2,
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

  //TabController _tc;
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
  List<List<TextEditingController>> _controller2 = [];

  _catList() async {
    this._addInitailTab();
    controller.addListener(_scrollListener);
    if (subList != null) {
      if (subList[0].subList == null || subList[0].subList.isEmpty) {
        curTabId = subList[0].id;
        _isLoading = true;
        prodCall = 1;
        await getProduct(curTabId, 0, "0");
        await getProduct(curTabId, 0, "0");
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

  _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (subList[_tc.index].offset < subList[_tc.index].totalItem) {
          //  if (mounted) setState(() {
          isLoadingmore = true;
          // });
          curTabId = subList[_tc.index].id;
          _views[_tc.index] = createTabContent(_tc.index, subList);
          prodCall = 1;
          setState(() {});
          getProduct(curTabId, _tc.index, "0");
        }
      }
    }
  }

  TabController _makeNewTabController(int pos) => TabController(
        vsync: this,
        length: _tabs.length,
      );

  clearList(String top) async {
    if (mounted)
      setState(() async {
        _isLoading = true;
        _views[_tc.index] = createTabContent(_tc.index, subList);
        total = 0;
        offset = 0;
        subList[_tc.index].totalItem = 0;
        subList[_tc.index].offset = 0;
        subList[_tc.index].subList = [];
        curTabId = subList[_tc.index].id;

        prodCall = 1;
        setState(() {});

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
                } else {
                  //setSnackbar("okokok");
                }
              });

            selId = null;
          });
      });
  }

  Future<void> getProduct(String id, int cur, String top) async {
    print("getPrduct : " +
        id.toString() +
        " | " +
        cur.toString() +
        " | " +
        top.toString());
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
          TOP_RETAED: top,
          "offer": id == "0" ? "true" : "false"
        };
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        print("Parameters--" + parameter.toString());

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
              if (prodCall == 1) {
                subList[cur].filterList = (getdata["filters"] as List)
                    .map((data) => new Filter.fromJson(data))
                    .toList();
                subList[cur].filterList =
                    subList[cur].filterList.toSet().toList();
                subList[cur].selectedId = [];
              }
            }

            if (offset < total) {
              tempList.clear();

              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new Product.fromJson(data))
                  .toList();
              if (offset == 0) subList[cur].subList = [];
              if (prodCall == 1) {
                subList[cur].subList.addAll(tempList);
                subList[cur].subList = subList[cur].subList.toSet().toList();
                offset = subList[cur].offset + perPage;

                subList[cur].offset = offset;
                subList[cur].totalItem = total;
                setState(() {});
                prodCall = 0;
              }
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
    print("okokok");
    List<Product> subItem = subList[i].subList;
    List<TextEditingController> t = [];
    _controller2.insert(i, t);
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //SizedBox(height: deviceHeight * 0.0243),
              _isLoading
                  ? shimmer()
                  : subItem.length == 0
                      ? Flexible(flex: 1, child: getNoItem(context))
                      : GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          physics: NeverScrollableScrollPhysics(),
                          children: List.generate(
                            subItem.length,
                            (index) {
                              return productListItem(i, index, subItem);
                            },
                          ))
            ],
          ),
        ),
        showCircularProgress(_isProgress, colors.primary),
      ],
    );
  }

  Widget productListItem(int tabIndex, int index, List<Product> subItem) {
    //int tabIndex = int.parse(curTabId);
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
      debugPrint("------------- >> " + att.toString() + val.toString());
      print("New Length : " +
          index.toString() +
          " : " +
          _controller2[tabIndex].length.toString());

      if (_controller2[tabIndex].length < index + 1) {
        _controller2[tabIndex].add(new TextEditingController());
        print("New Length : " +
            index.toString() +
            " : " +
            _controller2[tabIndex].length.toString());
      }
      _controller2[tabIndex][index].text = getQty(model);
      print("QTY FROM API : ${_controller2[tabIndex][index].text}");
      String dropdownValue = subItem[index].productVolumeType == "piece" ? "1":"${subItem[index].defaultOrder}";

      var items = [
        '50',
        '100',
        '250',
        '500',
        '1000',
      ];

      ///todo: piece set here
      if (subItem[index].productVolumeType == "piece") {
        items=[];
        items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
      } else {
        if (!items.contains(subItem[index].defaultOrder)) {
          items.add(subItem[index].defaultOrder);
        }
        if (int.parse(subItem[index].minimumOrderQuantity) == 100) {
          items.remove("50");
        } else if (int.parse(subItem[index].minimumOrderQuantity) == 250) {
          items.remove("50");
          items.remove("100");
        } else if (int.parse(subItem[index].minimumOrderQuantity) == 500) {
          items.remove("50");
          items.remove("100");
          items.remove("250");
        } else if (int.parse(subItem[index].minimumOrderQuantity) == 1000) {
          items.remove("50");
          items.remove("100");
          items.remove("250");
          items.remove("500");
        }
      }

      return subItem.length >= index
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                //margin: EdgeInsets.only(left: 10),//Colors.transparent, //Color(0xff1c1d23),
                child: ClipRRect(
                  //borderRadius: BorderRadius. circular(20.0),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        top: deviceWidth * 0.293 - 3,
                        //deviceWidtgh*0.293,
                        child: Container(
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.green),
                            color: Color(0xffFBFBFB), ////313237
                            // color: Colors.purple, ////313237
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffFFFFFF), //313237
                                    // color: Colors.yellow,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      //bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                    ),
                                    boxShadow: [
                                      //BoxShadow(blurRadius: 33.0),
                                      BoxShadow(
                                          color: shadowColor(),
                                          offset: Offset(0, -2),
                                          blurRadius: 33),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xffFFFFFF), //313237
                                      // color: Colors.orange,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        //bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                      ),
                                      boxShadow: [
                                        //BoxShadow(blurRadius: 33.0),
                                        BoxShadow(
                                            color: shadowColor(),
                                            offset: Offset(0, -2),
                                            blurRadius: 33),
                                      ],
                                    ),
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color:Colors.red,
                                    color: Color(0xffFFFFFF), //313237
                                    // borderRadius: BorderRadius.all(
                                    //  Radius.circular(15),
                                    // ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                      //bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ///for image
                      Positioned(
                        left: deviceWidth * 0.038,
                        child: Container(
                          // color: Colors.tealAccent,
                          height: deviceWidth * 0.350, //deviceHeight * 0.185,
                          width: deviceWidth * 0.370,
                          child: GestureDetector(
                            onTap: () {
                              Product model = subItem[index];
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => ProductDetail(
                                          model: model,
                                          updateParent: updateHomePage,
                                          index: index,
                                          secPos: 0,
                                          updateHome: widget.updateHome,
                                          list: true,
                                        )),
                              );
                              setState(() {
                                homePage = true;
                              });
                            },
                            child: Image.network(subItem[index].image,
                                fit: BoxFit.fitHeight),
                          ),
                        ),
                      ),

                      ///for name
                      Positioned(
                        top: deviceWidth * 0.370 - 7, //deviceHeight * 0.182,
                        left: deviceWidth * 0.0255,
                        right: deviceWidth * 0.0127,
                        child: Container(
                          //width: 190,
                          child: Text(
                            subItem[index].name.toString(), //model.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: deviceHeight * 0.0170,
                                color: colors.fontColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      ///DropDown
                      Positioned(
                        top: deviceWidth * 0.425 - 12, //deviceHeight*0.210,
                        left: deviceWidth * 0.0210,
                        child: Container(
                          width: g.Get.width / 2.5,
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              // color: Colors.white38,
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.8))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              // underline: Divider(
                              //   color: Colors.teal,
                              // ),
                              // borderRadius:
                              //     BorderRadius.all(Radius.circular(5)),
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
                                      /* items.toString() == "1000"
                                          ? "1 kg"
                                          : */
                                      "$items gm",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                              isDense: true,
                              onChanged: (val) {
                                setState(() {
                                  dropdownValue = val;
                                  subItem[index].defaultOrder = val;
                                });
                                setState(() {
                                  _views[_tc.index] =
                                      createTabContent(_tc.index, subList);
                                });
                                print("SELECTED DROPDOWN VAL : $dropdownValue");
                                // updateHomePage();
                              },
                            ),
                          ),
                        ),
                      ),

                      ///price and off prfrtxice
                      Positioned(
                        top: deviceWidth * 0.495 - 10,
                        //deviceWidth * 0.430 + 25, //deviceHeight*0.210,
                        left: deviceWidth * 0.0210,
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                                style: TextStyle(
                                    fontSize: deviceHeight * 0.0160,
                                    color: Colors.black54, //Color(0xffFED100),
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Color(0xffFF2525)),
                              ),
                              Text(
                                " " +
                                    CUR_CURRENCY +
                                    " " +
                                    priceUpdate(
                                        price2: price.toStringAsFixed(2),
                                        grams2: subItem[index].defaultOrder),
                                style: TextStyle(
                                    fontSize: deviceHeight * 0.0200,
                                    color: colors.darkColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      model.availability == "0"
                          ? Container()
                          //: cartBtnList
                          : Positioned(
                              top: deviceWidth * 0.55 - 12,
                              // deviceWidth * 0.500 +25, //deviceHeight * 0.243,
                              left: deviceWidth * 0.0255,
                              child: Container(
                                width: deviceWidth * 0.43,
                                //color: Colors.teal,
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: colors.darkColor,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFF4CD),
                                              //shape: BoxShape.circle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                            ),
                                          ),
                                          onTap: () {
                                            if (_isProgress == false &&
                                                (int.parse(model
                                                        .prVarientList[
                                                            model.selVarient]
                                                        .cartCount)) >
                                                    0)
                                              removeFromCart(index, model);
                                          },
                                        ),
                                        Container(
                                          width: deviceWidth * 0.098,
                                          height: deviceHeight * 0.0341,
                                          padding: EdgeInsets.only(
                                              left: deviceWidth * 0.0025,
                                              bottom: deviceHeight * 0.0012),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF3F3F3),
                                            // border: Border.all(color: Color(0xffFC8019),),
                                          ),
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                            controller: _controller2[tabIndex]
                                                [index],
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          /// item add to cart
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            // margin: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: colors.darkColor,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFC805),
                                              //shape: BoxShape.circle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                            ),
                                          ),
                                          onTap: () {
                                            print("tap");
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
                                                  model,
                                                  context);
                                          },
                                        )
                                      ],
                                    ),
                                    Spacer(),

                                    ///Favurate
                                    Container(
                                        padding: EdgeInsets.only(
                                            top: deviceWidth * 0.017),
                                        child: model.isFavLoading
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 0.7,
                                                    )),
                                              )
                                            : Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    if (CUR_USERID != null) {
                                                      model.isFav == "0"
                                                          ? _setFav(
                                                              index, subItem)
                                                          : _removeFav(
                                                              index, subItem);
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Login()),
                                                      );
                                                    }
                                                  },
                                                  child: SvgPicture.asset(
                                                    model.isFav == "0"
                                                        ? "assets/images/des_heart.svg"
                                                        : "assets/images/sel_heart.svg",
                                                    height: deviceWidth * 0.076,
                                                    width: deviceWidth * 0.076,
                                                  ),
                                                ),
                                                // InkWell(
                                                //     borderRadius:
                                                //     BorderRadius.circular(4),
                                                //     child: Padding(
                                                //       padding: const EdgeInsets.all(5.0),
                                                //       child: Icon(
                                                //         model.isFav == "0"
                                                //             ? Icons.favorite_border
                                                //             : Icons.favorite,
                                                //         color: Color(0xffFF2525),
                                                //         size: 25,
                                                //       ),
                                                //     ),
                                                //     onTap: () {
                                                //       if (CUR_USERID != null) {
                                                //         model.isFav == "0"
                                                //             ? _setFav(index, subItem)
                                                //             : _removeFav(index, subItem);
                                                //       } else {
                                                //         Navigator.push(
                                                //           context,
                                                //           MaterialPageRoute(
                                                //               builder: (context) =>
                                                //                   Login()),
                                                //         );
                                                //       }
                                                //     }),
                                              )),
                                    SizedBox(width: 3),
                                  ],
                                ),
                              )
                              // Row(
                              //   children: <Widget>[
                              //     Row(
                              //       children: <Widget>[
                              //         GestureDetector(
                              //           child: Container(
                              //             height: deviceHeight*0.0511,
                              //             width: deviceWidth*0.107,
                              //             padding: EdgeInsets.all(2),
                              //             margin: EdgeInsets.only(
                              //                 left: 8),
                              //             child: Icon(
                              //               Icons.add,
                              //               size: 25,
                              //               color: Colors.white,
                              //             ),
                              //             decoration: BoxDecoration(
                              //                 color: Color(0xffFED100),
                              //                 borderRadius:
                              //                 BorderRadius.all(
                              //                     Radius.circular(
                              //                         12))),
                              //           ),
                              //           onTap: () {
                              //             if (_isProgress ==
                              //                 false)
                              //               addToCart(
                              //                   index,
                              //                   (int.parse(model
                              //                       .prVarientList[model
                              //                       .selVarient]
                              //                       .cartCount) +
                              //                       int.parse(
                              //                           model.qtyStepSize))
                              //                       .toString(),
                              //                   model);
                              //           },
                              //         )
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              )
                      //: Container(),
                    ],
                  ),
                ),
              ),
            )
          : Container();
    } else
      return Container();
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

  _setFav(int index, List<Product> subItem) async {
    if (index < subItem.length) {
      Product model = subItem[index];

      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (mounted)
            setState(() {
              model.isFavLoading = true;
            });

          var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
          Response response =
              await post(setFavoriteApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            if (mounted)
              setState(() {
                subItem[index].isFav = "1";
              });
          } else {
            setSnackbar(msg);
          }

          if (mounted)
            setState(() {
              model.isFavLoading = false;
            });
          _views[_tc.index] = createTabContent(_tc.index, subList);
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
  }

  _removeFav(int index, List<Product> subItem) async {
    if (index < subItem.length) {
      Product model = subItem[index];
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (mounted)
            setState(() {
              model.isFavLoading = true;
            });

          var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
          Response response =
              await post(removeFavApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            model.isFav = "0";
            if (mounted) setState(() {});
            favList.removeWhere((item) =>
                item.productList[0].prVarientList[0].id ==
                model.prVarientList[0].id);
          } else {
            setSnackbar(msg);
          }
          if (mounted)
            setState(() {
              model.isFavLoading = false;
            });
          _views[_tc.index] = createTabContent(_tc.index, subList);
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
  }

  /*showContinueShoppingDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Text(
                   "Store is closed now product will be delivery next day, are you still want to continue..?",
                    style: Theme.of(this.context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: colors.fontColor),
                  ),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(
                          getTranslated(context, 'Cancel'),
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
                          getTranslated(context, 'Continue'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async{

                        })
                  ],
                );
              });
        });
  }*/

/*  showContinueShoppingDialog(BuildContext context, Function() onContinue) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // title: Center(child: Text('Rate this app'),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 25),
                Text(
                  "Store is closed now product will be delivery next day, are you still want to continue..?",
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: colors.fontColor),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        child: Text(
                          "Cancel",
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
                    SizedBox(width: 10),
                    TextButton(
                        child: Text(
                          "Continue",
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                                  color: colors.fontColor,
                                  fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (mounted)
                            setState(() {
                              _isProgress = true;
                              _views[_tc.index] =
                                  createTabContent(_tc.index, subList);
                            });

                          if (int.parse(qty) < model.minOrderQuntity) {
                            qty = model.minOrderQuntity.toString();
                            setSnackbar('Minimum order quantity is $qty');
                          }

                          var parameter = {
                            USER_ID: CUR_USERID,
                            PRODUCT_VARIENT_ID:
                                model.prVarientList[model.selVarient].id,
                            QTY: qty
                          };

                          Response response = await post(manageCartApi,
                                  body: parameter, headers: headers)
                              .timeout(Duration(seconds: timeOut));

                          var getdata = json.decode(response.body);

                          bool error = getdata["error"];
                          String msg = getdata["message"];
                          if (!error) {
                            var data = getdata["data"];

                            String qty = data['total_quantity'];
                            CUR_CART_COUNT = data['cart_count'];

                            ///api get items
                            // CUR_CART_COUNT = data['total_items'];

                            //model.prVarientList[model.selVarient].cartCount = qty.toString();
                            updateQty(model, qty);
                          } else {
                            setSnackbar(msg);
                          }
                          if (mounted)
                            setState(() {
                              _isProgress = false;
                              _views[_tc.index] =
                                  createTabContent(_tc.index, subList);
                            });

                          widget.updateHome();
                        })
                  ],
                ),
                SizedBox(height: 5),
              ],
            ),
          );
        });
  }*/

  addItem({int index, String qty, Product model, BuildContext context}) async {
    if (mounted)
      setState(() {
        _isProgress = true;
        _views[_tc.index] = createTabContent(_tc.index, subList);
      });

    ///TODO : QTY REMOVE
    ///if (int.parse(qty) < model.minOrderQuntity)
    if (int.parse(qty) < 1) {
      qty = model.minOrderQuntity.toString();
      setSnackbar('Minimum order quantity is $qty');
    }

    print("DD Grams ===> ${model.defaultOrder}");
    var parameter = {
      USER_ID: CUR_USERID,
      PRODUCT_VARIENT_ID: model.prVarientList[model.selVarient].id,
      QTY: qty,
      "gram": model.defaultOrder,
      PRODUCT_VOLUME_TYPE: model.productVolumeType
    };
    print("manageCartApi Pass BODY ===> $parameter");

    Response response = await post(
            Uri.parse(
                'https://codeskipinfotech.com/nikshop/app/v1/api/manage_cart'),
            body: parameter,
            headers: headers)
        .timeout(Duration(seconds: timeOut));

    var getdata = json.decode(response.body);

    bool error = getdata["error"];
    String msg = getdata["message"];
    if (!error) {
      var data = getdata["data"];

      String qty = data['total_quantity'];
      CUR_CART_COUNT = data['cart_count'];

      ///api get items
      // CUR_CART_COUNT = data['total_items'];

      //model.prVarientList[model.selVarient].cartCount = qty.toString();
      updateQty(model, qty);
    } else {
      setSnackbar(msg);
    }
    if (mounted)
      setState(() {
        _isProgress = false;
        _views[_tc.index] = createTabContent(_tc.index, subList);
      });

    widget.updateHome();
  }

  Future<void> addToCart(
      int index, String qty, Product model, BuildContext context) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          addItem(qty: qty, context: context, index: index, model: model);
/*          print("OPEN_STORE_TIME : ${model.openStoreTime} ");
          print("CLOSE_STORE_TIME  ${model.closeStoreTime}");
    */ /*      model.openStoreTime = "7:0:0";
          model.closeStoreTime = "10:0:0";*/ /*
          DateTime now = DateTime.now();
          DateTime openStoreTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(model.openStoreTime.split(":").first),
              int.parse(model.openStoreTime.split(":")[1]),
              int.parse(model.openStoreTime.split(":").last));
          DateTime closeStoreTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(model.closeStoreTime.split(":").first),
              int.parse(model.closeStoreTime.split(":")[1]),
              int.parse(model.closeStoreTime.split(":").last));

          print(
              "openStoreTime DATE : $openStoreTime   closeStoreTime DATE : $closeStoreTime");

          if (model.openStoreTime == "00:00:00" ||
              model.closeStoreTime == "00:00:00") {
            addItem(qty: qty, context: context, index: index, model: model);
          } else {
            if (now.isAfter(openStoreTime) && now.isBefore(closeStoreTime)) {
              print("VALID");
              addItem(qty: qty, context: context, index: index, model: model);
            } else {
              print("Show Dialog");
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // title: Center(child: Text('Rate this app'),),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 25),
                          Text(
                            "Store is closed now product will be delivery next day, are you still want to continue..?",
                            style: Theme.of(this.context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: colors.fontColor),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  child: Text(
                                    "Cancel",
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
                              SizedBox(width: 10),
                              TextButton(
                                  child: Text(
                                    "Continue",
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                            color: colors.fontColor,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    addItem(
                                        qty: qty,
                                        context: context,
                                        index: index,
                                        model: model);
                                    Navigator.pop(context);
                                  })
                            ],
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    );
                  });
            }
          }*/
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

          ///MINIMUM QUANTITY
          // if (qty < model.minOrderQuntity) {
          //   qty = 0;
          // }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList[model.selVarient].id,
            USER_ID: CUR_USERID,
            QTY: qty.toString(),
            "gram": model.defaultOrder,
            PRODUCT_VOLUME_TYPE: model.productVolumeType
          };
          print("manageCartApi Pass BODY ===> $parameter");
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

            /// item remove from card
//             CUR_CART_COUNT = data['total_items'];

            //model.prVarientList[model.selVarient].cartCount = qty.toString();
            updateQty(model, qty);
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
            );
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

  // Future<void> callApi() async {
  //   bool avail = await isNetworkAvailable();
  //   if (avail) {
  //     getCat();
  //     getSetting();
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //     if (mounted) if (mounted)
  //       setState(() {
  //         _isCatLoading = false;
  //       });
  //   }
  // }

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
          subList =
              new List.from([new Product(id: "0", name: "Offers", offset: 0)])
                ..addAll(catList); //[0].subList;
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
    isManager = await getPrefrence("isManager");
    setState(() {});
    _catList();
    return null;
  }

  getPayment() async {
    try {
      var parameter = {TYPE: PAYMENT_METHOD, USER_ID: CUR_USERID};
      Response response =
          await post(getSettingApi, body: parameter, headers: headers)
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

  // Future<Null> getSection() async {
  //   try {
  //     var parameter = {PRODUCT_LIMIT: "4", PRODUCT_OFFSET: "0"};
  //
  //     if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
  //
  //     Response response =
  //     await post(getSectionApi, body: parameter, headers: headers)
  //         .timeout(Duration(seconds: timeOut));
  //     if (response.statusCode == 200) {
  //       var getdata = json.decode(response.body);
  //
  //       bool error = getdata["error"];
  //       String msg = getdata["message"];
  //       if (!error) {
  //         var data = getdata["data"];
  //         sectionList.clear();
  //         sectionList = (data as List)
  //             .map((data) => new SectionModel.fromJson(data))
  //             .toList();
  //       } else {
  //         setSnackbar(msg);
  //       }
  //     }
  //     Future.delayed(const Duration(seconds: 1), () {
  //       if (mounted) if (mounted)
  //         setState(() {
  //           _isCatLoading = false;
  //         });
  //     });
  //   } on TimeoutException catch (_) {
  //     setSnackbar(getTranslated(context, 'somethingMSg'));
  //     if (mounted)
  //       setState(() {
  //         _isCatLoading = false;
  //       });
  //   }
  //   return null;
  // }

  Future<Null> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter;
      if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};
      print("Parameter of getsettings: " + parameter.toString());
      Response response = await post(getSettingApi,
              body: CUR_USERID != null ? parameter : null, headers: headers)
          .timeout(Duration(seconds: timeOut));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        print("Response of getsettings: " + getdata.toString());

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
          print("Minimum order amount :" + MIN_AMT);
          CUR_DEL_CHR = data['delivery_charge'];
          print("Current Delivery Charge: " + CUR_DEL_CHR);
          String isVerion = data['is_version_system_on'];
          extendImg = data["expand_product_images"] == "1" ? true : false;
          String del = data["area_wise_delivery_charge"];
          print("Area wise delivery data: " + del.toString());
          SCROLLING_TEXT = getdata["data"]["system_settings"][0]
                  ["scrolling_news"]
              .toString();
          if (del == "0") {
            ISFLAT_DEL = true;
          } else {
            ISFLAT_DEL = false;
          }
          if (CUR_USERID != null) {
            // CUR_CART_COUNT = getdata["data"]["user_data"][0][""].toString();
            CUR_CART_COUNT =
                getdata["data"]["user_data"][0]["cart_total_items"].toString();
            print("FIRST TIME OPEN APP ASSIGN ITEMS: $CUR_CART_COUNT");
            REFER_CODE = getdata['data']['user_data'][0]['referral_code'];
            if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE.isEmpty)
              generateReferral();
            CUR_BALANCE = getdata["data"]["user_data"][0]["balance"];
          }
          widget.updateHome();

          if (isVerion == "1") {
            String verionAnd = data['current_version'];
            String verionIOS = data['current_version_ios'];
            debugPrint("---> ${verionIOS.toString()}");
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

    debugPrint(response.statusCode.toString());
  }

  // Future<Null> getOfferImages() async {
  //   try {
  //     Response response = await post(getOfferImageApi, headers: headers)
  //         .timeout(Duration(seconds: timeOut));
  //     if (response.statusCode == 200) {
  //       var getdata = json.decode(response.body);
  //
  //       bool error = getdata["error"];
  //       String msg = getdata["message"];
  //       if (!error) {
  //         var data = getdata["data"];
  //         offerImages.clear();
  //         offerImages =
  //             (data as List).map((data) => new Model.fromSlider(data)).toList();
  //       } else {
  //         setSnackbar(msg);
  //       }
  //     }
  //     Future.delayed(const Duration(seconds: 1), () {
  //       if (mounted) if (mounted)
  //         setState(() {
  //           _isCatLoading = false;
  //         });
  //     });
  //   } on TimeoutException catch (_) {
  //     setSnackbar(getTranslated(context, 'somethingMSg'));
  //     if (mounted)
  //       setState(() {
  //         _isCatLoading = false;
  //       });
  //   }
  //   return null;
  // }

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
          placeholder: (context, url) => Image.asset(
            "assets/images/sliderph.png",
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
          );
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

void launchAppStore(String androidApplicationId, String iOSAppId) async {
  StoreRedirect.redirect(
      androidAppId: androidApplicationId, iOSAppId: iOSAppId);
}

checkVersion(BuildContext context) async {
  print("Token");
  print(await FirebaseMessaging.instance.getToken());
  // return;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await FirebaseFirestore.instance
      .collection("check_upgrade")
      .doc(Platform.isAndroid ? "android" : "ios")
      .get()
      .then((value) {
    Map<String, dynamic> map = value.data();
    final liveVersion = Version.parse(map['version']).toString();
    final localVersion = Version.parse(packageInfo.version).toString();

    if (map['upgrade_reqired'] == true) {
      if (liveVersion != localVersion) {
        print("Update Available");
        final platform = Theme.of(context).platform;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return platform == TargetPlatform.iOS
                ? WillPopScope(
                    onWillPop: () async => false,
                    child: CupertinoAlertDialog(
                      title: Text('Update Available'),
                      content: Text("You can now update this app from store."),
                      actions: <Widget>[
                        WillPopScope(
                          onWillPop: () async => false,
                          child: CupertinoDialogAction(
                            child: Text('Update Now'),
                            onPressed: () => launchAppStore(
                                packageInfo.packageName,
                                packageInfo.packageName),
                          ),
                        ),
                      ],
                    ),
                  )
                : WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: Text('Update Available'),
                      content: Text("You can now update this app from store."),
                      actions: <Widget>[
                        /*    FlatButton(
                      child: dismiss,
                      onPressed: dismissAction,
                    ),*/
                        // ignore: deprecated_member_use
                        FlatButton(
                          child: Text('Update Now'),
                          onPressed: () => launchAppStore(
                              packageInfo.packageName, packageInfo.packageName),
                        ),
                      ],
                    ),
                  );
          },
        );
      }
    }
    /*if(localVersion==liveVersion){
      print("Update Available");
      final platform = Theme.of(context).platform;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return platform == TargetPlatform.iOS
              ? WillPopScope(
            onWillPop: () async => false,
            child: CupertinoAlertDialog(
              title: Text('Update Available'),
              content: Text("You can now update this app from store."),
              actions: <Widget>[
                WillPopScope(
                  onWillPop: () async => false,
                  child: CupertinoDialogAction(
                    child: Text('Update Now'),
                    onPressed: ()=>
                        launchAppStore(packageInfo.packageName, packageInfo.packageName)
                    ,
                  ),
                ),
              ],
            ),
          )
              : WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text('Update Available'),
              content: Text("You can now update this app from store."),
              actions: <Widget>[
                */ /*    FlatButton(
                      child: dismiss,
                      onPressed: dismissAction,
                    ),*/ /*
                FlatButton(
                  child: Text('Update Now'),
                  onPressed: ()=>
                launchAppStore(packageInfo.packageName, packageInfo.packageName)
                  ,
                ),
              ],
            ),
          );
        },
      );
    }else {
      if(true){
        print("Update Available");
        print("Update Available");
        final platform = Theme.of(context).platform;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return platform == TargetPlatform.iOS
                ? WillPopScope(
              onWillPop: () async => false,
              child: CupertinoAlertDialog(
                title: Text('Update Available'),
                content: Text("You can now update this app from store."),
                actions: <Widget>[
                  WillPopScope(
                    onWillPop: () async => false,
                    child: CupertinoDialogAction(
                      child: Text('Update Now'),
                      onPressed: ()=>
                          launchAppStore(packageInfo.packageName, packageInfo.packageName)
                      ,
                    ),
                  ),
                ],
              ),
            )
                : WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Update Available'),
                content: Text("You can now update this app from store."),
                actions: <Widget>[
                  */ /*    FlatButton(
                      child: dismiss,
                      onPressed: dismissAction,
                    ),*/ /*
                  FlatButton(
                    child: Text('Update Now'),
                    onPressed: ()=> launchAppStore(packageInfo.packageName, packageInfo.packageName)
                    ,
                  ),
                ],
              ),
            );
          },
        );
        //CheckVersion().showUpdateDialog("odeva.clickk", "odeva.click");
      }

    }*/
  });

/*  final checkVersion = CheckVersion(
    context: context,
    androidId: "odeva.clickk"
  );

  final appStatus = await checkVersion.getVersionStatus();
  if (appStatus.canUpdate) {
    //Container(height: 100,color: Colors.black,);
    checkVersion.showUpdateDialog("odeva.clickk", "odeva.click");
  }
  print("canUpdate ${appStatus.canUpdate}");
  print("localVersion ${appStatus.localVersion}");
  print("appStoreLink ${appStatus.appStoreUrl}");
  print("storeVersion ${appStatus.storeVersion}");*/
}

getMessageCount() async {
  // if (isManager == "true") {
  //   await FirebaseFirestore.instance.collection("chatroom").get().then((value) {
  //     for (int i = 0; i < value.docs.length; i++) {
  //       Map<String, dynamic> map = value.docs[i].data();
  //       if (map[map['id'] + "_newMessage"] >= 1) {
  //         totalmessageCount = 1;
  //         print(totalmessageCount);
  //         break;
  //       } else {
  //         totalmessageCount = 0;
  //       }
  //     }
  //   });
  // } else {
  //
  //
  //
  // }
}
