import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Faqs_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/String.dart';

class Faqs extends StatefulWidget {
  final String title;

  const Faqs({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateFaqs();
  }
}

class StateFaqs extends State<Faqs> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String privacy;
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<FaqsModel> faqsList = [];
  List<String> selectedId = [];
  int selectedIndex = -1;
  List toggled = [];
  bool flag = true;
  bool expand = true;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();


  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getFaqs();
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
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
         if (mounted) setState(() {
          isLoadingmore = true;
          getFaqs();
        });
      }
    }
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
        appBar: getAppBar(widget.title, context),
        body: _isNetworkAvail ? _showForm() : noInternet(context));
  }

  _showForm() {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: _isLoading
            ? shimmer()
            : ListView.builder(
          controller: controller,
          itemCount: faqsList.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return (index == faqsList.length && isLoadingmore)
                ? Center(child: CircularProgressIndicator())
                : listItem(index);
          },
        ));
  }

  listItem(int index) {
    return Card(
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
             if (mounted) setState(() {
              selectedIndex = index;
              flag = !flag;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        faqsList[index].question,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: colors.lightBlack),
                      )),
                  selectedIndex != index || flag
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Text(
                                faqsList[index].answer,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                    color: colors.black.withOpacity(0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  )
                      : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  faqsList[index].answer,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                      color: colors.black.withOpacity(0.7)),
                                ))),
                        Icon(Icons.keyboard_arrow_up)
                      ]),
                ]),
          ),
        ));
  }

  Future<void> getFaqs() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response = await post(getFaqsApi, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            faqsList = (data as List)
                .map((data) => new FaqsModel.fromJson(data))
                .toList();
          } else {
            setSnackbar(msg);
          }
        }
         if (mounted) setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar( getTranslated(context,'somethingMSg'));
      }
    } else {
       if (mounted) setState(() {
        _isLoading = false;
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
}
