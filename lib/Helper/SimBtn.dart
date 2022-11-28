import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';

// ignore: must_be_immutable
class SimBtn extends StatelessWidget {
  final String title;
  final VoidCallback onBtnSelected;

  double size;

  SimBtn({Key key, this.title, this.onBtnSelected, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    size=MediaQuery.of(context).size.width *size;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      child: Container(
          width: size,
          height: 35,
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.grad1Color, colors.grad2Color],
                stops: [0, 1]),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(color: colors.white, fontWeight: FontWeight.normal,fontSize: 15))),
      onPressed: () {
        onBtnSelected();
      },
    );
  }
}
