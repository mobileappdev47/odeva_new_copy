import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Product_Detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'Helper/Session.dart';
import 'Model/Section_Model.dart';
import 'Model/User.dart';

class ReviewPreview extends StatefulWidget {
  final int index;
  final Product model;

  const ReviewPreview({
    Key key,
    this.index,
    this.model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<ReviewPreview> {
  int curPos;
  bool flag = true;
  @override
  void initState() {
    super.initState();
    curPos = widget.index;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User model = widget
        .model.reviewList[0].productRating[revImgList[curPos].index];

    return Scaffold(
        body: Hero(
      tag: "${widget.index}",
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          
          Container(
              child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                  initialScale: PhotoViewComputedScale.contained * 0.9,
                  minScale: PhotoViewComputedScale.contained * 0.9,
                  imageProvider: NetworkImage(revImgList[index].img));
            },
            itemCount: revImgList.length,
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                ),
              ),
            ),
            backgroundDecoration: BoxDecoration(color: colors.white),
            pageController: PageController(initialPage: widget.index),
            onPageChanged: (index) {
              if (mounted)
                setState(() {
                  curPos = index;
                });
            },
          )),
          Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
                color: Colors.transparent,
                child: Container(
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
                )),
          ),
          Container(
            
            color: Colors.black87,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
           
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: double.parse(model.rating),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: colors.primary,
                  ),
                  itemCount: 5,
                  itemSize: 12.0,
                  direction: Axis.horizontal,
                ),
                model.comment != null && model.comment.isNotEmpty
                    ? Container(
                         width: MediaQuery.of(context).size.width - 20,
                    
                      child: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              model.comment ?? '',
                             // "ggggggggggggggggggggggggggggggggggggggggggggggggggggggghhhhhhhhhhhhhhhhhhhhhhhhhlllllllllllllllllllllllllll",
                               style: TextStyle(color: Colors.white),
                           // softWrap: true,
                          maxLines: flag ? 2 : null,
              
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              flag = !flag;
                            });
                          },
                        ),
                    )
                    : Container(),
                Container(
                    width: MediaQuery.of(context).size.width - 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          model.username ?? "",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          model.date ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        )
                      ],
                    ))
              ],
            ),
          )
        ],
      ),
    ));
  }
}
