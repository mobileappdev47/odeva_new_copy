
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';
import 'package:flutter_svg/flutter_svg.dart';
class RadioItem extends StatelessWidget {
    final RadioModel _item;

    RadioItem(this._item);

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Row(
                children: <Widget>[
                    Container(
                        height: 20.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _item.isSelected ? colors.primary : colors.white,
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
                    ),
                    Padding(
                        padding: const EdgeInsetsDirectional.only(start:15.0),
                        child: new Text(_item.name),
                    ),
                    Spacer(),
                    _item.img != "" ? SvgPicture.asset(_item.img) : Container()
                ],
            ),
        );
    }
}

class RadioModel {
    bool isSelected;
    final String img;
    final String name;

    RadioModel({this.isSelected, this.name, this.img});
}
