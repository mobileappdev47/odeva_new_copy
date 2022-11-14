
import 'package:eshop/utils/color_res.dart';
import 'package:flutter/cupertino.dart';

// ignore: non_constant_identifier_names
TextStyle AppTextStyle({
  FontWeight weight,
  double fontSize,
  Color color,
  TextDecoration decoration,
}) {
  return TextStyle(
    fontWeight: weight ?? FontWeight.normal,
    fontSize: fontSize ?? 16,
    color: color ?? ColorRes.white,
    decoration: decoration ?? TextDecoration.none,
  );
}
