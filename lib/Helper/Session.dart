import 'package:connectivity/connectivity.dart';
import 'package:eshop/Cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';
import 'Constant.dart';
import 'Demo_Localization.dart';
import 'String.dart';

final String isLogin = appName + 'isLogin';

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

setPreferencesInt(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

Future<String> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<int> getPreferencesInt(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

 Future<void> removePreferences(String key)async{
   SharedPreferences _prefs = await SharedPreferences.getInstance();
await _prefs.remove(key);
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool(key) ?? false;
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

erroWidget(double size) {
  return Image.asset(
    'assets/images/placeholder.png',
    height: size,
    width: size,
  );
}

back() {
  return BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.lightWhite, colors.white],
        stops: [0, 1]),
  );
}

shadow() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(color: colors.darkColor, offset: Offset(0, 0), blurRadius: 30)
    ],
  );
}

placeHolder(double height) {
  return AssetImage(
    'assets/images/placeholder.png',
  );
}

errorWidget(double size) {
  return Icon(
    Icons.account_circle,
    color: Colors.grey,
    size: size,
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

getAppBar(String title, BuildContext context) {
  return AppBar(
    titleSpacing: 0,
    leading: Builder(builder: (BuildContext context) {
      return Container(
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
      );
    }),
    title: Text(
      title,
      style: TextStyle(
        color: colors.fontColor,
      ),
    ),
  );
}

noIntImage() {
  return SvgPicture.asset(
    'assets/images/no_internet.svg',
    fit: BoxFit.contain,
  );
}

noIntText(BuildContext context) {
  return Container(
      child: Text(getTranslated(context, 'NO_INTERNET'),
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: colors.primary, fontWeight: FontWeight.normal)));
}

noIntDec(BuildContext context) {
  return Container(
    padding: EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
    child: Text(getTranslated(context, 'NO_INTERNET_DISC'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6.copyWith(
              color: colors.lightBlack2,
              fontWeight: FontWeight.normal,
            )),
  );
}

Widget showCircularProgress(bool _isProgress, Color color) {
  if (_isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return Container(
    height: 0.0,
    width: 0.0,
  );
}

imagePlaceHolder(double size) {
  return new Container(
    height: size,
    width: size,
    child: Icon(
      Icons.account_circle,
      color: colors.white,
      size: size,
    ),
  );
}

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(ID));
  waitList.add(prefs.remove(NAME));
  waitList.add(prefs.remove(MOBILE));
  waitList.add(prefs.remove(EMAIL));
  CUR_USERID = '';
  CUR_USERNAME = "";
  CUR_CART_COUNT = "";
  CUR_BALANCE = '';
  selAddress ="";

  await prefs.clear();
}

Future<void> saveUserDetail(
    String userId,
    String name,
    String email,
    String mobile,
    String city,
    String area,
    String address,
    String pincode,
    String latitude,
    String longitude,
    String image) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, userId));
  waitList.add(prefs.setString(USERNAME, name ?? ""));
  waitList.add(prefs.setString(EMAIL, email ?? ""));
  waitList.add(prefs.setString(MOBILE, mobile ?? ""));
  waitList.add(prefs.setString(CITY, city ?? ""));
  waitList.add(prefs.setString(AREA, area??""));
  waitList.add(prefs.setString(ADDRESS, address ?? ""));
  waitList.add(prefs.setString(PINCODE, pincode ?? ""));
  waitList.add(prefs.setString(LATITUDE, latitude ?? ""));
  waitList.add(prefs.setString(LONGITUDE, longitude ?? ""));
  waitList.add(prefs.setString(IMAGE, image ?? ""));

  await Future.wait(waitList);
}

String validateUserName(String value, String msg1, String msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length <= 1) {
    return msg2;
  }
  return null;
}

String validateMob1(String value, String msg1, String msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length <= 9) {
    return msg2;
  }
  return null;
}

String validateMob(String value, String msg1, String msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length < 8) {
    return msg2;
  }
  return null;
}

String validateCountryCode(String value, String msg1, String msg2) {
  if (value.isEmpty) {
    return msg1;
  }
  if (value.length <= 0) {
    return msg2;
  }
  return null;
}

String validatePass(String value, String msg1, String msg2) {
  if (value.length == 0)
    return msg1;
  else if (value.length <= 5)
    return msg2;
  else
    return null;
}

String validateAltMob(String value, String msg) {
  if (value.isNotEmpty) if (value.length < 9) {
    return msg;
  }
  return null;
}

String validateField(String value, String msg) {
  if (value.length == 0)
    return msg;
  else
    return null;
}

String validatePincode(String value, String msg1) {
  if (value.length == 0)
    return msg1;
  else
    return null;
}

String validateEmail(String value, String msg1, String msg2) {
  if (value.length == 0) {
    return msg1;
  } else if (!RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
      .hasMatch(value)) {
    return msg2;
  } else {
    return null;
  }
}

Widget getProgress() {
  return Center(child: CircularProgressIndicator());
}

Widget getNoItem(BuildContext context) {
  return Center(child: Text(getTranslated(context, 'noItem')));
}
var isDarkTheme;

Color shimmerColor(){
  Color color = Colors.white;
  if(isDarkTheme){
    color = colors.darkColor2;
  }
  return color;
}
Color shadowColor(){
  Color color = Color(0xFF1c1d23);
  if(isDarkTheme){
    color = Color(0xFFD3D3D3).withOpacity(.3);
  }else{
    color = color.withOpacity(.0);
  }
  return color;
}
Color tabTextColor(){
  Color color = Colors.black;//Color(0xFF1C9DC7);
  if(isDarkTheme){
    color = Colors.white;
  }
  return color;
}

Widget shimmer() {
  Color color = shimmerColor();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: color,
      highlightColor: color,
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map((_) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          color: color,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: color,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: color,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 100.0,
                                height: 8.0,
                                color: color,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 20.0,
                                height: 8.0,
                                color: color,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case "en":
      return Locale("en", 'US');
    case "zh":
      return Locale("zh", "CN");
    case "es":
      return Locale("es", "ES");
    case "hi":
      return Locale("hi", "IN");
    case "ar":
      return Locale("ar", "DZ");
    case "ru":
      return Locale("ru", "RU");
    case "ja":
      return Locale("ja", "JP");
    case "de":
      return Locale("de", "DE");
    default:
      return Locale("en", 'US');
  }
}

String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context).translate(key);
}

String getToken() {
  final claimSet = new JwtClaim(
      issuer: 'eshop',
      maxAge: const Duration(minutes: 5),
      issuedAt: DateTime.now().toUtc());

  String token = issueJwtHS256(claimSet, jwtKey);
  print("token"+token.toString());

  return token;
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };
