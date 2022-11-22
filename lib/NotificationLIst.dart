import 'dart:async';
import 'dart:convert';

import 'package:eshop/Home3.dart';
import 'package:eshop/Model/Notification_Model.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';
import 'package:eshop/chat_manager/chat_manager.dart';
import 'package:eshop/utils/color_res.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class NotificationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateNoti();
}

List<NotificationModel> notiList = [];
int offset = 0;
int total = 0;
bool isLoadingmore = true;
bool _isLoading = true;

class StateNoti extends State<NotificationList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController controller = new ScrollController();
  List<NotificationModel> tempList = [];
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
    getNotification();
    controller.addListener(_scrollListener);
    getMessageCount();
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
    super.initState();
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
                  getNotification();
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

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    offset = 0;
    total = 0;
    notiList.clear();
    return getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colors.darkColor,
        key: _scaffoldKey,
        body:Stack(
          children: [
            _isNetworkAvail
                ? _isLoading
                ? shimmer()
                : notiList.length == 0
                ? Padding(
                padding: const EdgeInsetsDirectional.only(
                    top: kToolbarHeight),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter,
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
                      child: Text(getTranslated(context, 'noNoti'),style: TextStyle(color: ColorRes.white,))),
                ))
                : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // Color(0xFF280F43),
                          // Color(0xffE5CCFF),
                          colors.darkColor,
                          colors.darkColor.withOpacity(0.8),
                          Color(0xFFF8F8FF),
                        ]),
                  ),
                  child: ListView.builder(
                    // shrinkWrap: true,
                    controller: controller,
                    itemCount: (offset < total)
                        ? notiList.length + 1
                        : notiList.length,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return (index == notiList.length && isLoadingmore)
                          ? Center(child: CircularProgressIndicator())
                          : listItem(index);
                    },
                  ),
                ))
                : noInternet(context),

            ///todo : chat button 4 (Notification)
          /*  Positioned(
                bottom: 5,
                right: 10,
                child: FloatingActionButton(
                  backgroundColor: Color(0xff341069),
                  onPressed: () async{
                    // Future.delayed(Duration(milliseconds: 100), () {
                    //   isShow = true;
                    // });
                    // Future.delayed(Duration(seconds: 5), () {
                    //   isShow1 = true;
                    // });
                    CUR_USERID = await getPrefrence(ID);
                    if(CUR_USERID!=null){
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
                                  setState=setState;
                                  return Container(
                                    height: MediaQuery.of(context).size.height/1.1,
                                    child: ChatFireScreen(
                                      isManager: false,
                                      roomId: null,
                                    ),
                                  );
                                },
                              );
                            }).then((value) {
                          getMessageCount();
                          setState(() {

                          });
                        });

                      }
                    }
                    else{
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInUpAcc(),
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
                )),*/
          ],
        ));
  }

  Widget listItem(int index) {
    NotificationModel model = notiList[index];
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.date,
                    style: TextStyle(color: colors.primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      model.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(model.desc)
                ],
              ),
            ),
            model.img != null && model.img != ''
                ? Container(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(3.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(model.img),
                          radius: 25,
                        )),
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }

  Future<Null> getNotification() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        Response response =
            await post(getNotificationApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new NotificationModel.fromJson(data))
                  .toList();

              notiList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            if (msg != "Products Not Found !") setSnackbar(msg);
            isLoadingmore = false;
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
        if (mounted)
          setState(() {
            _isLoading = false;
            isLoadingmore = false;
          });
      }
    } else if (mounted)
      setState(() {
        _isNetworkAvail = false;
      });

    return null;
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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getNotification();
          });
      }
    }
  }
}
