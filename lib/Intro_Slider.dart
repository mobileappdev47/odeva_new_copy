

import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';

class IntroSlider extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  List slideList = [];

  @override
  void initState() {
    super.initState();



    new Future.delayed(Duration.zero,() {
  setState(() {
       slideList = [

        Slide(
          imageUrl: 'assets/images/introimage_a.png',
          title: getTranslated(context, 'TITLE1_LBL'),
          description: getTranslated(context, 'DISCRIPTION1'),
        ),
        Slide(
          imageUrl: 'assets/images/introimage_b.png',
          title: getTranslated(context,'TITLE2_LBL'),
          description: getTranslated(context, 'DISCRIPTION2'),
        ),
        Slide(
          imageUrl: 'assets/images/introimage_c.png',
          title: getTranslated(context, 'TITLE3_LBL'),
          description: getTranslated(context, 'DISCRIPTION3'),
        ),
      ];
  });
    });

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.9,
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
    super.dispose();
    _pageController.dispose();
    buttonController.dispose();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  _onPageChanged(int index) {
     if (mounted) setState(() {
      _currentPage = index;
    });
  }



  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Widget _slider() {
    return Expanded(
      child: PageView.builder(
        itemCount: slideList.length,
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Image.asset(
                    slideList[index].imageUrl,
                  ),
                ),
                Container(
                    margin: EdgeInsetsDirectional.only(top: 20),
                    child: Text(slideList[index].title,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                            color: colors.fontColor, fontWeight: FontWeight.bold))),
                Container(
                  padding: EdgeInsetsDirectional.only(top: 30.0, start: 15.0, end: 15.0),
                  child: Text(slideList[index].description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: colors.fontColor, fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _btn() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            slideList,
                (index, url) {
              return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? colors.fontColor
                        : colors.fontColor.withOpacity((0.5)),
                  ));
            },
          ),
        ),
        Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom:18.0),
              child: AppBtn(
                  title: _currentPage == 0 || _currentPage == 1
                      ? getTranslated(context, 'NEXT_LBL')
                      : getTranslated(context, 'GET_STARTED'),
                  btnAnim: buttonSqueezeanimation,
                  btnCntrl: buttonController,
                  onBtnSelected: () {
                    if (_currentPage == 2) {
                      setPrefrenceBool(ISFIRSTTIME, true);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignInUpAcc()),
                      );
                    } else {
                      _currentPage = _currentPage + 1;
                      _pageController.animateToPage(_currentPage,
                          curve: Curves.decelerate,
                          duration: Duration(milliseconds: 300));
                    }
                  }),
            )),
      ],
    );
  }

  skipBtn() {
    return _currentPage == 0 || _currentPage == 1
        ? Padding(
        padding: EdgeInsetsDirectional.only(top: 20.0, end: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInUpAcc()),
                );
              },
              child: Row(children: [
                Text(getTranslated(context, 'SKIP'),
                    style: Theme.of(context).textTheme.caption.copyWith(
                      color: colors.fontColor,
                    )),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colors.fontColor,
                  size: 12.0,
                ),
              ]),
            ),
          ],
        ))
        : Container(
      margin: EdgeInsetsDirectional.only(top: 50.0),
      height: 15,
    );
  }

  @override
  Widget build(BuildContext context) {

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              skipBtn(),
              _slider(),
              _btn(),
            ],
          ),
        ));
  }
}

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    @required this.imageUrl,
    @required this.title,
    @required this.description,
  });
}
