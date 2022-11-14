import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class GiveRating extends StatefulWidget {
  final String productId, name, img;

  const GiveRating({Key key, this.productId, this.name, this.img})
      : super(key: key);

  @override
  _GiveRatingState createState() => _GiveRatingState();
}

class _GiveRatingState extends State<GiveRating> {
  bool _isNetworkAvail = true;
  TextEditingController _commentC = new TextEditingController();
  List<File> files = [];
  double curRating = 0.0;
  double initialRate = 0;
  bool _isProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(getTranslated(context, 'PRODUCT_REVIEW'), context),
      body:

      Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Card(
                    elevation: 0,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                        child: Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(7.0),
                                child: FadeInImage(
                                  fadeInDuration: Duration(milliseconds: 150),
                                  image: NetworkImage(widget.img),
                                  height: 50.0,
                                  width: 50.0,
                                  fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                  placeholder: placeHolder(90),
                                )),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  widget.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                          color: colors.lightBlack,
                                          fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ))),
                Card(
                    elevation: 0,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getTranslated(context, 'WRITE_REVIEW_LBL'),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(color: colors.fontColor),
                              ),
                              _rating(),
                              Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 20.0, end: 20.0),
                                  child: TextField(
                                    controller: _commentC,
                                    style: Theme.of(context).textTheme.subtitle2,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText:
                                          getTranslated(context, 'REVIEW_HINT_LBL'),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                              color: colors.lightBlack2
                                                  .withOpacity(0.7)),
                                    ),
                                  )),
                              Container(
                                padding: EdgeInsetsDirectional.only(
                                    start: 20.0, end: 20.0, top: 5),
                                height:
                                    files != null && files.length > 0 ? 180 : 80,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: files.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return InkWell(
                                          child: Stack(
                                            alignment: AlignmentDirectional.topEnd,
                                            children: [
                                              Image.file(
                                                files[i],
                                                width: 180,
                                                height: 180,
                                              ),
                                              Container(
                                                  color: Colors.black26,
                                                  child: Icon(
                                                    Icons.clear,
                                                    size: 15,
                                                  ))
                                            ],
                                          ),
                                          onTap: () {
                                            if (mounted)
                                              setState(() {
                                                files.removeAt(i);
                                              });
                                          },
                                        );
                                      },
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.add_photo_alternate,
                                            color: colors.primary,
                                            size: 25.0,
                                          ),
                                          onPressed: () {
                                            _imgFromGallery();
                                          }),
                                    )
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.bottomEnd,
                                child: GestureDetector(
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(
                                        start: 8, end: 20),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: colors.lightWhite,
                                        borderRadius: new BorderRadius.all(
                                            const Radius.circular(4.0))),
                                    child: Text(
                                      getTranslated(context, 'SUBMIT_LBL'),
                                      style: TextStyle(color: colors.fontColor),
                                    ),
                                  ),
                                  onTap: () {
                                    if (curRating != 0 ||
                                        _commentC.text != '' ||
                                        (files != null && files.length > 0))
                                      setRating(curRating, _commentC.text, files);
                                    else
                                      setSnackbar(
                                          getTranslated(context, 'REVIEW_W'));
                                  },
                                ),
                              ),
                            ]))),
              ],
            ),
          ),
          showCircularProgress(_isProgress, colors.primary),
        ],
      ),
    );
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

  _imgFromGallery() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> setRating(
      double rating, String comment, List<File> files) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            _isProgress = true;
          });
        var request = http.MultipartRequest("POST", setRatingApi);
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID;
        request.fields[PRODUCT_ID] = widget.productId;

        if (files != null) {
          for (int i = 0; i < files.length; i++) {
            var pic = await http.MultipartFile.fromPath(IMGS, files[i].path);
            request.files.add(pic);
          }
        }

        if (comment != "") request.fields[COMMENT] = comment;
        if (rating != 0) request.fields[RATING] = rating.toString();
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          setSnackbar(msg);
        } else {
          setSnackbar(msg);
          initialRate = 0;
        }

        _commentC.text = "";
        files.clear();
        if (mounted)
          setState(() {
            _isProgress = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'));
      }
    } else if (mounted)
      setState(() {
        _isNetworkAvail = false;
      });
  }

  _rating() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 7.0, bottom: 7.0),
      child: RatingBar.builder(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 32,
        itemPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: colors.primary,
        ),
        onRatingUpdate: (rating) {
          curRating = rating;
        },
      ),
    );
  }
}
