import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop/All_Category.dart';
import 'package:eshop/Favorite.dart';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/MyProfile.dart';
import 'package:eshop/ProductList.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:eshop/SectionList.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
import 'Home.dart';
import 'Login.dart';
import 'Model/Model.dart';
import 'Model/Section_Model.dart';
import 'NotificationLIst.dart';
import 'Search.dart';
import 'SubCat.dart';

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


  @override
  void initState() {
    super.initState();
    final pushNotificationService =
    PushNotificationService(context: context, updateHome: updateHome);

    pushNotificationService.initialise();

    initDynamicLinks();
    home = new HomePage(updateHome);
    fragments = [
      HomePage(updateHome),
      Favorite(updateHome),
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
          //backgroundColor: Color(0xff1c1d23),
            key: scaffoldKey,
            appBar: curSelected == 3 ? null : _getAppbar(),
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
          ? Container(
        height: 53,
          width: 135,
          child: Image.asset('assets/images/titleicon.png'))
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
  // _getAppbar() {
  //   String title = curSelected == 1
  //       ? getTranslated(context, 'FAVORITE')
  //       : getTranslated(context, 'NOTIFICATION');
  //
  //   return AppBar(
  //     title: curSelected == 0
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
  //     // centerTitle:_curSelected == 0? false:true,
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
  //     backgroundColor: curSelected == 0 ? Colors.transparent : colors.white,
  //     elevation: 0,
  //   );
  // }

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
              ))).then((value) {

          }) ;
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

class HomePage extends StatefulWidget {
  Function updateHome;

  HomePage(this.updateHome);

  StateHomePage statehome = new StateHomePage();

  @override
  StateHomePage createState() => StateHomePage();

  updateHomepage() {
    // statehome.getSection();
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  var isDarkTheme;
  int selIndex;

  @override
  void initState() {
    super.initState();
     //callApi();
    getCat();
    getSetting();
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

    if(_isCatLoading){
      //print("Loading Shimmer");
      return homeShimmer();
    }else {
      //print("Loading Home");
      return _home();
    }
  }

  Widget _home() {
    return Scaffold(
        key: _scaffoldKey,
       // backgroundColor: Color(0xff1c1d23),
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: curSelected == 0 ? Colors.transparent : colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tc,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xffFED100),
              border: Border.all(color: Colors.white54),
            ),
            //indicatorColor: Colors.pinkAccent,
            labelColor: tabTextColor(),//Colors.white,
            //unselectedLabelColor: Colors.black,
            isScrollable: true,
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

  _esxtraOffer() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: offerImages.length >= sectionList.length
          ? offerImages.length - sectionList.length
          : 0,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _getOfferImage(sectionList.length + index);
      },
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
                            color: colors.darkColor2
                        ),
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
                                    color: colors.darkColor2
                                );
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

  Widget _slider() {
    double height = deviceWidth / 2.2;

    return homeSliderList.isNotEmpty
        ? Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          margin: EdgeInsetsDirectional.only(top: 10),
          child: PageView.builder(
            itemCount: homeSliderList.length,
            scrollDirection: Axis.horizontal,
            controller: _controller,
            physics: AlwaysScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (mounted)
                setState(() {
                  _curSlider = index;
                });
            },
            itemBuilder: (BuildContext context, int index) {
              return pages[index];
            },
          ),
        ),
        Positioned(
          bottom: 0,
          height: 40,
          left: 0,
          width: deviceWidth,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(
              homeSliderList,
                  (index, url) {
                return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _curSlider == index
                          ? colors.fontColor
                          : colors.lightBlack,
                    ));
              },
            ),
          ),
        ),
      ],
    )
        : Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 27),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Image.asset(
          'assets/images/sliderph.png',
          height: height,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
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

  _getSearchBar() {
    isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      child: SizedBox(
        height: 35,
        child: TextField(
          enabled: false,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(50.0),
                ),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              isDense: true,
              hintText: getTranslated(context, 'searchHint'),
              hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                color: colors.fontColor,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/images/search.svg',
                  color: isDarkTheme ? colors.secondary : colors.primary,
                ),
              ),
              fillColor: colors.white,
              filled: true),
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(
                updateHome: widget.updateHome,
              ),
            ));
        if (mounted) setState(() {});
      },
    );
  }

  _catHeading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            getTranslated(context, 'category'),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'seeAll'),
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: colors.primary),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllCategory(
                      updateHome: widget.updateHome,
                    )),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
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
    return ;
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
          print("_addInitailTab : " + i.toString() + " == " + subList[i].id.toString());
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
              SizedBox(height: deviceHeight*0.0243),
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

      List att, val;
      if (model.prVarientList[model.selVarient].attr_name != null) {
        att = model.prVarientList[model.selVarient].attr_name.split(',');
        val = model.prVarientList[model.selVarient].varient_value.split(',');
      }
      if (_controller2.length < index + 1)
        _controller2.add(new TextEditingController());

      _controller2[index].text = model.prVarientList[model.selVarient].cartCount;

      return subItem.length >= index
          ? Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: EdgeInsets.only(bottom: deviceHeight*0.0085),
          color: Colors.transparent,//Color(0xff1c1d23),
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
              child: Stack(
                children : [


                  // Positioned(
                  //   top: 130,
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         color: Color(0xff313237),
                  //         borderRadius: BorderRadius.all(Radius.circular(15)),
                  //         boxShadow: [
                  //           BoxShadow(color: Colors.black.withOpacity(0.84), offset: Offset(0, 3)),
                  //          ],
                  //       ),
                  //     ),
                  // ),

                  Positioned(
                    bottom:0,
                    right: 0,
                    left: 0,
                    top: deviceHeight*0.112,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff313237),
                        // borderRadius: BorderRadius.all(
                        //  Radius.circular(15),
                        // ),
                          borderRadius: BorderRadius.all(Radius.circular(15),),
                        // boxShadow: [
                        //   //BoxShadow(blurRadius: 33.0),
                        //   BoxShadow(color: Color(0xFFD3D3D3).withOpacity(.84), offset: Offset(0, -2),blurRadius: 33),
                        //   BoxShadow(color: Color(0xFF1c1d23).withOpacity(.84), offset: Offset(0, 3),blurRadius: 33),
                        //   // BoxShadow(color: Color(0xff303136).withOpacity(.5), offset: Offset(0,0)),
                        //   // BoxShadow(color: Color(0xff303136).withOpacity(.5), offset: Offset(0,0)),
                        // ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                color: Color(0xff313237),
                                  // borderRadius: BorderRadius.all(
                                  //  Radius.circular(15),
                                  // ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),topRight: Radius.circular(15),
                                    //bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                  ),
                                  boxShadow: [
                                    //BoxShadow(blurRadius: 33.0),
                                    BoxShadow(
                                        color: shadowColor(), offset: Offset(0, -2),blurRadius: 33
                                  // color: Color(0xFFD3D3D3).withOpacity(.3), offset: Offset(0, -2),blurRadius: 33
                                ),
                                    // BoxShadow(color: Color(0xff303136).withOpacity(.5), offset: Offset(0,0)),
                                    // BoxShadow(color: Color(0xff303136).withOpacity(.5), offset: Offset(0,0)),
                                  ],
                                ),),
                          ),
                          Expanded(flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff313237),
                                  // borderRadius: BorderRadius.all(
                                  //  Radius.circular(15),
                                  // ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                    //bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),
                                  ),
                                ),
                              ),),
                        ],
                      ),
                    ),
                  ),

                  ///for image
                  Positioned(
                    left: deviceWidth*0.094,
                    child: Container(
                      //color: Colors.tealAccent,
                      height: deviceHeight*0.155,
                      width: deviceWidth*0.230,
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
                  // /// for rating
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
                    top: deviceHeight*0.172,
                    left: deviceWidth*0.0255,
                    right: deviceWidth*0.0127,
                    child: Container(
                      //width: 190,
                      child: Text(
                        subItem[index].name.toString(),//model.name,
                        style: TextStyle(fontWeight: FontWeight.w600,fontSize: deviceHeight*0.0158 ,color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  ///for price
                  Positioned(
                    top: deviceHeight*0.227,
                    left: deviceWidth*0.0255,
                    child: Text(CUR_CURRENCY + "" + price.toString() + " ",
                      style: TextStyle(
                          color: Color(0xffFED100),
                          fontWeight: FontWeight.bold,fontSize: deviceHeight*0.0170),),
                  ),
                  ///for offprice
                  Positioned(
                    top: deviceHeight*0.249,
                    left: deviceWidth*0.0306,
                    child: Text(
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
                          fontSize: deviceHeight*0.0146,
                          color: Color(0xffFED100),
                          decoration: TextDecoration.lineThrough
                      ),
                    ),
                  ),

                  model.availability == "0"
                      ? Container()
                  //: cartBtnList
                      : Positioned(
                    top: deviceHeight*0.219,
                    left: deviceWidth*0.330,
                    child: Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                height: deviceHeight*0.0511,
                                width: deviceWidth*0.107,
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.only(
                                    left: 8),
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xffFED100),
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(
                                            12))),
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
                    ),
                  )
                  //: Container(),

                ] ,

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

  _catList2() {
    return Container(
      height: 80,
      child: ListView.builder(
        itemCount: catList.length < 10 ? catList.length : 10,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: GestureDetector(
              onTap: () async {
                if (catList[index].subList == null ||
                    catList[index].subList.length == 0) {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductList(
                            name: catList[index].name,
                            id: catList[index].id,
                            tag: false,
                            updateHome: widget.updateHome),
                      ));
                  if (mounted) setState(() {});
                } else {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubCat(
                            title: catList[index].name,
                            subList: catList[index].subList,
                            updateHome: widget.updateHome),
                      ));
                  if (mounted) setState(() {});
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                    child: new ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: new FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                          catList[index].image,
                        ),
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                        //  errorWidget: (context, url, e) => placeHolder(50),
                        placeholder: placeHolder(50),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      catList[index].name,
                      style: Theme.of(context).textTheme.caption.copyWith(
                          color: colors.fontColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    width: 50,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // _section() {
  //   return _isCatLoading
  //       ? getProgress()
  //       : ListView.builder(
  //     padding: EdgeInsets.all(0),
  //     itemCount: sectionList.length,
  //     shrinkWrap: true,
  //     physics: NeverScrollableScrollPhysics(),
  //     itemBuilder: (context, index) {
  //       return _singleSection(index);
  //     },
  //   );
  // }

  // Future<Null> _refresh() {
  //   if (mounted)
  //     setState(() {
  //       _isCatLoading = true;
  //     });
  //   return callApi();
  // }

  _singleSection(int index) {
    return sectionList[index].productList.length > 0
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _getHeading(sectionList[index].title, index),
        _getSection(index),
        offerImages.length > index ? _getOfferImage(index) : Container(),
      ],
    )
        : Container();
  }

  _getHeading(String title, int index) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'seeAll'),
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: colors.primary),
              ),
            ),
            onTap: () {
              SectionModel model = sectionList[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SectionList(
                      index: index,
                      section_model: model,
                      updateHome: updateHomePage,
                    ),
                  ));
            },
          ),
        ],
      ),
    );
  }

  _getOfferImage(index) {
    return InkWell(
      child: FadeInImage(
          fadeInDuration: Duration(milliseconds: 150),
          image: NetworkImage(offerImages[index].image),
          width: double.maxFinite,
          // errorWidget: (context, url, e) => placeHolder(50),
          placeholder: AssetImage(
            "assets/images/sliderph.png",
          )),
      onTap: () {
        if (offerImages[index].type == "products") {
          Product item = offerImages[index].list;

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
            homePage=true;
          });
        } else if (offerImages[index].type == "categories") {
          Product item = offerImages[index].list;
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

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? GridView.count(
        padding: EdgeInsetsDirectional.only(top: 5),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 0.8,
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(
          sectionList[i].productList.length < 4
              ? sectionList[i].productList.length
              : 4,
              (index) {
            return productItem(i, index, index % 2 == 0 ? true : false);
          },
        ))
        : sectionList[i].style == STYLE1
        ? sectionList[i].productList.length > 0
        ? Row(
      children: [
        Flexible(
            flex: 3,
            fit: FlexFit.loose,
            child: Container(
                height: orient == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.4
                    : MediaQuery.of(context).size.height,
                child: productItem(i, 0, true))),
        Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: orient == Orientation.portrait
                      ? deviceHeight * 0.2
                      : deviceHeight * 0.5,
                  child: productItem(i, 1, false)),
              Container(
                  height: orient == Orientation.portrait
                      ? deviceHeight * 0.2
                      : deviceHeight * 0.5,
                  child: productItem(i, 2, false)),
            ],
          ),
        ),
      ],
    )
        : Container()
        : sectionList[i].style == STYLE2
        ? Row(
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: orient == Orientation.portrait
                      ? deviceHeight * 0.2
                      : deviceHeight * 0.5,
                  child: productItem(i, 0, true)),
              Container(
                  height: orient == Orientation.portrait
                      ? deviceHeight * 0.2
                      : deviceHeight * 0.5,
                  child: productItem(i, 1, true)),
            ],
          ),
        ),
        Flexible(
            flex: 3,
            fit: FlexFit.loose,
            child: Container(
                height: orient == Orientation.portrait
                    ? deviceHeight * 0.4
                    : deviceHeight,
                child: productItem(i, 2, false))),
      ],
    )
        : sectionList[i].style == STYLE3
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
                height: orient == Orientation.portrait
                    ? deviceHeight * 0.3
                    : deviceHeight * 0.6,
                child: productItem(i, 0, false))),
        Container(
          height: orient == Orientation.portrait
              ? deviceHeight * 0.2
              : deviceHeight * 0.5,
          child: Row(
            children: [
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 1, true)),
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 2, true)),
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 3, false)),
            ],
          ),
        ),
      ],
    )
        : sectionList[i].style == STYLE4
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
                height: orient == Orientation.portrait
                    ? deviceHeight * 0.3
                    : deviceHeight * 0.6,
                child: productItem(i, 0, false))),
        Container(
          height: orient == Orientation.portrait
              ? deviceHeight * 0.2
              : deviceHeight * 0.5,
          child: Row(
            children: [
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 1, true)),
              Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 2, false)),
            ],
          ),
        ),
      ],
    )
        : GridView.count(
        padding: EdgeInsetsDirectional.only(top: 5),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: List.generate(
          sectionList[i].productList.length < 4
              ? sectionList[i].productList.length
              : 4,
              (index) {
            return productItem(
                i, index, index % 2 == 0 ? true : false);
          },
        ));
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
              homePage=true;
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

          subList = catList;//[0].subList;
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

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(verionAnd);
            //final Version latestVersionIos = Version.parse(verionIOS);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion)
            // || (Platform.isIOS && latestVersionIos > currentVersion)
            )
              updateDailog();
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

                          if (await canLaunch(_url)) {
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
            homePage=true;
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

