import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'Helper/Color.dart';
import 'Helper/String.dart';
import 'Product_Detail.dart';

class CompareList extends StatefulWidget {
  @override
  _CompareListState createState() => _CompareListState();
}

List<Product> compareList = [];

class _CompareListState extends State<CompareList> {
  int maxLength = 0;

  @override
  void initState() {
    List val = [];
    for (int i = 0; i < compareList.length; i++) {
      if (compareList[i].prVarientList[0].attr_name != null)
        val.add(compareList[i].prVarientList[0].attr_name.split(',').length);
    }
    if (val.length > 0) {
      maxLength = val.reduce((curr, next) => curr > next ? curr : next);
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(getTranslated(context, 'COMPARE_PRO'), context),
        body: compareList.length == 0
            ? getNoItem(context)
            : ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: compareList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return listItem(index);
                  },
                )));
  }

  Widget listItem(int index) {
    Product model = compareList[index];

    double price = double.parse(model.prVarientList[model.selVarient].disPrice);
    if (price == 0)
      price = double.parse(model.prVarientList[model.selVarient].price);
    List att, val;
    if (model.prVarientList[model.selVarient].attr_name != null) {
      att = model.prVarientList[model.selVarient].attr_name.split(',');
      val = model.prVarientList[model.selVarient].varient_value.split(',');
    }
    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        child: Container(
          width: deviceWidth * 0.5,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton.icon(
                    onPressed: () {
                      setState(() {
                        compareList.removeWhere(
                            (item) => item.id == compareList[index].id);
                        List val = [];
                        for (int i = 0; i < compareList.length; i++) {
                          if (compareList[i].prVarientList[0].attr_name != null)
                            val.add(compareList[i]
                                .prVarientList[0]
                                .attr_name
                                .split(',')
                                .length);
                        }
                        if (val.length > 0)
                          maxLength = val.reduce(
                              (curr, next) => curr > next ? curr : next);
                      });
                    },
                    icon: Icon(Icons.close),
                    label: Text("Remove")),
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: FadeInImage(
                        image: NetworkImage(model.image),
                        height: deviceWidth * 0.5,
                        width: deviceWidth * 0.5,
                        fadeInDuration: Duration(milliseconds: 150),
                        fit: extendImg ? BoxFit.fill : BoxFit.contain,

                        //errorWidget:(context, url,e) => placeHolder(width) ,
                        placeholder: placeHolder(deviceWidth * 0.5),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: model.availability == "0"
                          ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold))
                          : Container(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RatingBarIndicator(
                    rating: double.parse(model.rating),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.primary,
                    ),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    model.name + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        double.parse(model.prVarientList[model.selVarient]
                                    .disPrice) !=
                                0
                            ? CUR_CURRENCY +
                                "" +
                                model.prVarientList[model.selVarient].price
                            : "",
                        style: Theme.of(context).textTheme.overline.copyWith(
                            decoration: TextDecoration.lineThrough,
                            letterSpacing: 1),
                      ),
                      Text(" " + CUR_CURRENCY + " " + price.toString(),
                          style: TextStyle(color: colors.primary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: maxLength,
                              itemBuilder: (context, index) {
                                if (model.prVarientList[model.selVarient]
                                            .attr_name !=
                                        null &&
                                    model.prVarientList[model.selVarient]
                                        .attr_name.isNotEmpty &&
                                    index < att.length) {

                                  return Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ":",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              start: 5.0),
                                          child: Text(
                                            val[index],
                                            maxLines: 1,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ]);
                                } else
                                  return Text(" ");
                              })),

                    ],
                  ),
                ),
                _madeIn(index),
                _warrenty(index),
                _gaurantee(index),
                _returnable(index),
                _cancleable(index),
              ],
            ),
            onTap: () {
              Product model = compareList[index];
              Navigator.push(
                context,
                PageRouteBuilder(
                    // transitionDuration: Duration(seconds: 1),
                    pageBuilder: (_, __, ___) => ProductDetail(
                          model: model,
                          // updateParent: updateSectionList,
                          //  updateHome: widget.updateHome,
                          secPos: index,
                          index: index,
                          list: true,
                        )),
              );
            },
          ),
        ),
      ),
    );
  }




  _gaurantee(int index) {
    String gaurantee = compareList[index].gurantee;

    return ListTile(
      trailing:
          Text(gaurantee != null && gaurantee.isNotEmpty ? gaurantee : "-"),
      dense: true,
      title: Text(
     getTranslated(context, 'GAURANTEE'),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  _returnable(int pos) {
    String returnable = compareList[pos].isReturnable;
    if (returnable == "1")
      returnable = RETURN_DAYS + " Days";
    else
      returnable = "No";
    return ListTile(
      trailing: Text(returnable),
      dense: true,
      title: Text(
               getTranslated(context, 'RETURNABLE'),
    
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  _cancleable(int pos) {
    String cancleable = compareList[pos].isCancelable;
    if (cancleable == "1")
      cancleable = "Till " + compareList[pos].cancleTill;
    else
      cancleable = "No";
    return ListTile(
      trailing: Text(cancleable),
      dense: true,
      title: Text(
         getTranslated(context, 'CANCELLABLE') ,
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  _warrenty(int index) {
    String warranty = compareList[index].warranty;

    return ListTile(
      trailing: Text(warranty != null && warranty.isNotEmpty ? warranty : "-"),
      dense: true,
      title: Text(
         getTranslated(context, 'WARRENTY') ,
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  _madeIn(int index) {
    String madeIn = compareList[index].madein;

    return ListTile(
      trailing: Text(madeIn != null && madeIn.isNotEmpty ? madeIn : "-"),
      dense: true,
      title: Text(
              getTranslated(context, 'MADE_IN'),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }
}
