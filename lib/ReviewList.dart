import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'Product_Detail.dart';
import 'Model/User.dart';
import 'Product_Preview.dart';

class ReviewList extends StatefulWidget {
  final String id;

  const ReviewList({Key key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateRate();
  }
}

class StateRate extends State<ReviewList> {
  bool _isNetworkAvail = true;
 // bool _isProgress = false, _isLoading = true;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  List<User> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getReview();
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(getTranslated(context, 'CUSTOMER_REVIEW_LBL'), context),
      body: _review(),
    );
  }

  Widget _review() {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        controller: controller,
        itemCount: (offset < total) ? reviewList.length + 1 : reviewList.length,
        // physics: BouncingScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index) {
          return (index == reviewList.length && isLoadingmore)
              ? Center(child: CircularProgressIndicator())
              : Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reviewList[index].username,
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Spacer(),
                            Text(
                              reviewList[index].date,
                              style: TextStyle(
                                  color: colors.lightBlack, fontSize: 11),
                            )
                          ],
                        ),
                        RatingBarIndicator(
                          rating: double.parse(reviewList[index].rating),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: colors.primary,
                          ),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                        ),
                        reviewList[index].comment != null &&
                                reviewList[index].comment.isNotEmpty
                            ? Text(reviewList[index].comment ?? '')
                            : Container(),
                        reviewImage(index)
                      ],
                    ),
                  ),
                );
        });
  }

  reviewImage(int i) {
    return Container(
      height: reviewList[i].imgList.length > 0 ? 50 : 0,
      child: ListView.builder(
        itemCount: reviewList[i].imgList.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsetsDirectional.only(end: 10, bottom: 5.0, top: 5),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductPreview(
                        pos: index,
                        secPos: 0,
                        index: 0,
                        id: "$index${reviewList[i].id}",
                        imgList: reviewList[i].imgList,
                        list: true,
                        from: false,
                      ),
                    ));
              },
              child: Hero(
                tag: '$index${reviewList[i].id}',
                child: new ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: new FadeInImage(
                    image: NetworkImage(reviewList[i].imgList[index]),
                    height: 50.0,
                    width: 50.0,
                    placeholder: placeHolder(50),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getReview() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_ID: widget.id,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        Response response =
            await post(getRatingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          total = int.parse(getdata["total"]);

          if ((offset) < total) {
            tempList.clear();
            var data = getdata["data"];
            tempList =
                (data as List).map((data) => new User.forReview(data)).toList();

            reviewList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "No ratings found !") setSnackbar(msg);
          isLoadingmore = false;
        }
        if (mounted) if (mounted)
          setState(() {
           
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
        if (mounted)
          setState(() {
           
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
}
