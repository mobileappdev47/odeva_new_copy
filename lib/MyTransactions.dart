import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/Transaction_Model.dart';

class TransactionHistory extends StatefulWidget {
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  List<TransactionModel> tranList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  ScrollController controller = new ScrollController();
  List<TransactionModel> tempList = [];

  @override
  void initState() {
    getTransaction();
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
    super.initState();
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xFF200738),
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
            getTranslated(context, 'MYTRANSACTION'),
            style: TextStyle(
              color: colors.fontColor,
            ),
          ),
        ),
        body: _isNetworkAvail
            ? _isLoading
            ? shimmer()
            : showContent()
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
                  getTransaction();
                } else {
                  await buttonController.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<Null> getTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID,
        };

        Response response =
        await post(getWalTranApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          // String msg = getdata["message"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new TransactionModel.fromJson(data))
                  .toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));

        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else
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

  Widget getNoItem1(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF280F43),
                // Color(0xffE5CCFF),
                Color(0xFF200738),
                Color(0xFF3B147A),
                Color(0xFFF8F8FF),
              ]),
        ),
        child: Center(child: Text(getTranslated(context, 'noItem'),style: TextStyle(color: Colors.white,),)));
  }

  showContent() {
    return tranList.length == 0
        ? getNoItem1(context)
        : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter,
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
      shrinkWrap: true,
      controller: controller,
      itemCount: (offset < total) ? tranList.length + 1 : tranList.length,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
          return (index == tranList.length && isLoadingmore)
              ? Center(child: CircularProgressIndicator())
              : listItem(index);
      },
    ),
        );
  }

  listItem(int index) {
    Color back;
    if (tranList[index].status.toLowerCase().contains("success")) {
      back = Colors.green;
    } else if (tranList[index].status.toLowerCase().contains("failure"))
      back = Colors.red;
    else
      back = Colors.orange;
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(5.0),
      child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            getTranslated(context, 'AMOUNT') +
                                " : " +
                                CUR_CURRENCY +
                                " " +
                                double.parse(tranList[index].amt).toStringAsFixed(2),
                            style: TextStyle(
                                color: colors.fontColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        Text(tranList[index].date),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(getTranslated(context, 'ORDER_ID_LBL') +
                                " : " +
                                tranList[index].orderNo ?? ""),//set order id
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: back,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(4.0))),
                            child: Text(
                              (tranList[index].status),
                              style: TextStyle(color: colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    tranList[index].type != null &&
                        tranList[index].type.isNotEmpty
                        ? Text(getTranslated(context, 'PAYMENT_METHOD_LBL') +
                        " : " +
                        tranList[index].type)
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: tranList[index].msg != null &&
                          tranList[index].msg.isNotEmpty
                          ? Text(getTranslated(context, 'MSG') +
                          " : " +
                          tranList[index].msg)
                          : Container(),
                    ),
                    tranList[index].txnID != null &&
                        tranList[index].txnID.isNotEmpty
                        ? Text(getTranslated(context, 'Txn_id') +
                        " : " +
                        tranList[index].txnID)
                        : Container(),
                  ]))),
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getTransaction();
          });
      }
    }
  }
}
