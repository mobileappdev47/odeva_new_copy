import 'package:eshop/Model/User.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';
import 'Session.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item.addItem.isDefault == "1"
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: colors.lightWhite,
                        borderRadius: new BorderRadius.only(
                            bottomRight: Radius.circular(10.0))),
                    child: Text(
                      getTranslated(context, 'DEFAULT_LBL'),
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: colors.fontColor),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Row(
                children: <Widget>[
                  _item.show
                      ? Container(
                          height: 20.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _item.isSelected
                                  ? colors.primary
                                  : colors.white,
                              border: Border.all(color: colors.grad2Color)),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: _item.isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 15.0,
                                    color: colors.white,
                                  )
                                : Icon(
                                    Icons.circle,
                                    size: 15.0,
                                    color: colors.white,
                                  ),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: new Container(
                      margin: new EdgeInsetsDirectional.only(start: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(_item.name),
                          new Text(_item.add1),
                          _item.add2!=""
                          ?Text(_item.add2):Container(),
                          Text(_item.cityorarea),
                          Text(_item.postcode),
                          Text(_item.mobile),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                InkWell(
                                  child: Text(
                                    getTranslated(context, 'EDIT'),
                                    style: TextStyle(
                                        color: colors.fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    _item.onEditSelected();
                                  },
                                ),
                                _item.addItem.isDefault == "0"
                                    ? Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 20),
                                        child: InkWell(
                                          onTap: () {
                                            _item.onSetDefault();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: colors.lightWhite,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        const Radius.circular(
                                                            4.0))),
                                            child: Text(
                                              getTranslated(
                                                  context, 'SET_DEFAULT'),
                                              style: TextStyle(
                                                  color: colors.fontColor,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              _item.onDeleteSelected();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                Icons.delete,
                color: colors.primary,
                size: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RadioModel {
  bool isSelected;
  final String add1;
  final String add2;
  final String cityorarea;
  final String postcode;
  final String name;
  final String mobile;
  final User addItem;
  final VoidCallback onEditSelected;
  final VoidCallback onDeleteSelected;
  final VoidCallback onSetDefault;
  final show;

  RadioModel({
    this.isSelected,
    this.name,
    this.add1,
    this.add2,
    this.cityorarea,
    this.postcode,
    this.mobile,
    this.addItem,
    this.onEditSelected,
    this.onSetDefault,
    this.show,
    this.onDeleteSelected,
  });
}
