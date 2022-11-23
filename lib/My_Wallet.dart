import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:eshop/PaypalWebviewActivity.dart';
import 'package:eshop/card_payment.dart';
import 'package:eshop/utils/full_screen_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as stripes;

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

//import 'package:paytm/paytm.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/PaymentRadio.dart';
import 'Helper/Session.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Helper/Stripe_Service.dart';
import 'Model/Transaction_Model.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class MyWallet extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return StateWallet();
//   }
// }
//
// class StateWallet extends State<MyWallet> with TickerProviderStateMixin {
//   bool _isNetworkAvail = true;
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   Animation buttonSqueezeanimation;
//   AnimationController buttonController;
//   String paymentMethodId;
//   String errorMessage = "";
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();
//   ScrollController singlecontroller = new ScrollController();
//   ScrollController controller = new ScrollController();
//   List<TransactionModel> tempList = [];
//   TextEditingController amtC, msgC;
//   List<String> paymentMethodList = [];
//   List<String> paymentIconList = [
//     'assets/images/paypal.svg',
//     'assets/images/rozerpay.svg',
//     'assets/images/paystack.svg',
//     'assets/images/flutterwave.svg',
//     'assets/images/stripe.svg',
//     'assets/images/paytm.svg',
//   ];
//   List<RadioModel> payModel = [];
//   bool paypal, razorpay, paumoney, paystack, flutterwave, stripe, paytm;
//   String razorpayId,
//       paystackId,
//       stripeId,
//       stripeSecret,
//       stripeMode = "test",
//       stripeCurCode,
//       stripePayId,
//       paytmMerId,
//       paytmMerKey;
//
//   int selectedMethod;
//   String payMethod;
//   StateSetter dialogState;
//   bool _isProgress = false;
//   // Razorpay _razorpay;
//   List<TransactionModel> tranList = [];
//   int offset = 0;
//   int total = 0;
//   bool isLoadingmore = true, _isLoading = true, payTesting = true;
//   final paystackPlugin = PaystackPlugin();
//   String _paymentMethodId;
//   String _errorMessage = "";
//
//   @override
//   void initState() {
//     super.initState();
//     selectedMethod = null;
//     payMethod = null;
//     new Future.delayed(Duration.zero, () {
//       paymentMethodList = [
//         getTranslated(context, 'PAYPAL_LBL'),
//         getTranslated(context, 'RAZORPAY_LBL'),
//         getTranslated(context, 'PAYSTACK_LBL'),
//         getTranslated(context, 'FLUTTERWAVE_LBL'),
//         getTranslated(context, 'STRIPE_LBL'),
//         getTranslated(context, 'PAYTM_LBL'),
//       ];
//       _getpaymentMethod();
//     });
//
//     controller.addListener(_scrollListener);
//     buttonController = new AnimationController(
//         duration: new Duration(milliseconds: 2000), vsync: this);
//
//     buttonSqueezeanimation = new Tween(
//       begin: deviceWidth * 0.7,
//       end: 50.0,
//     ).animate(new CurvedAnimation(
//       parent: buttonController,
//       curve: new Interval(
//         0.0,
//         0.150,
//       ),
//     ));
//     amtC = new TextEditingController();
//     msgC = new TextEditingController();
//     getTransaction();
//     // _razorpay = Razorpay();
//     // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     setState(() {
//
//     });
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//         //backgroundColor: Color(0xFF3B147A),
//         key: _scaffoldKey,
//         appBar: AppBar(
//           titleSpacing: 0,
//           backgroundColor: Color(0xff200738),
//           leading: Builder(builder: (BuildContext context) {
//             return Container(
//               margin: EdgeInsets.all(10),
//               decoration: shadow(),
//               child: Card(
//                 elevation: 0,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(4),
//                   onTap: () => Navigator.of(context).pop(),
//                   child: Center(
//                     child: Icon(
//                       Icons.keyboard_arrow_left,
//                       color: colors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//           title: Text(
//             getTranslated(context, 'MYWALLET'),
//             style: TextStyle(
//               color: colors.fontColor,
//             ),
//           ),
//         ),
//         body: _isNetworkAvail
//             ? _isLoading
//                 ? shimmer()
//                 : Stack(
//                     children: <Widget>[
//                       showContent(),
//                       showCircularProgress(_isProgress, colors.primary),
//                     ],
//                   )
//             : noInternet(context));
//   }
//
//   Widget paymentItem(int index) {
//     if (index == 0 && paypal ||
//         index == 1 && razorpay ||
//         index == 2 && paystack ||
//         index == 3 && flutterwave ||
//         index == 4 && stripe ||
//         index == 5 && paytm) {
//       return InkWell(
//         onTap: () {
//           if (mounted)
//             dialogState(() {
//               selectedMethod = index;
//               payMethod = paymentMethodList[selectedMethod];
//               payModel.forEach((element) => element.isSelected = false);
//               payModel[index].isSelected = true;
//             });
//         },
//         child: new RadioItem(payModel[index]),
//       );
//     } else
//       return Container();
//   }
//
//   Future<Null> sendRequest(String txnId, String payMethod) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       String orderId =
//           "wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
//       try {
//         var parameter = {
//           USER_ID: CUR_USERID,
//           AMOUNT: amtC.text.toString(),
//           TRANS_TYPE: WALLET,
//           TYPE: CREDIT,
//           MSG: (msgC.text == '' || msgC.text.isEmpty)
//               ? "Added through wallet"
//               : msgC.text,
//           TXNID: txnId,
//           ORDER_ID: orderId,
//           STATUS: "Success",
//           PAYMENT_METHOD: payMethod.toLowerCase()
//         };
//
//         http.Response response = await http
//             .post(addTransactionApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(response);
//
//         var getdata = json.decode(response.body);
//
//         bool error = getdata["error"];
//         String msg = getdata["message"];
//
//         if (!error) {
//           CUR_BALANCE = double.parse(getdata["new_balance"]).toStringAsFixed(2);
//         }
//         if (mounted)
//           setState(() {
//             _isProgress = false;
//           });
//         setSnackbar(msg);
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg'));
//
//         setState(() {
//           _isProgress = false;
//         });
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//           _isProgress = false;
//         });
//     }
//
//     return null;
//   }
//
//   _showDialog() async {
//  payWarn = true;
//     showModalBottomSheet(
//       isScrollControlled: true,
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(builder: (BuildContext context, setState) {
//           return SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               //   padding: EdgeInsets.all(10),
//               child: Column(
//                 children: [
//                   Container(
//                     height: Get.height / 3.8,
//                     padding: EdgeInsets.all(10),
//                     child: Container(
//                       height: Get.height / 5,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           border:
//                           Border.all(color: Colors.black.withOpacity(0.1))),
//                       child: Column(
//                         children: [
//                           Padding(
//                               padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
//                               child: Text(
//                                   "Add Money to Wallet",
//                                 style: Theme.of(this.context)
//                                     .textTheme
//                                     .subtitle1
//                                     .copyWith(color: colors.fontColor),
//                               )),
//                           Divider(color: colors.lightBlack),
//                           Padding(
//                               padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                               child: TextFormField(
//                                 keyboardType: TextInputType.number,
//                                 validator: (val) => validateField(val,
//                                     getTranslated(context, 'FIELD_REQUIRED')),
//                                 autovalidateMode:
//                                     AutovalidateMode.onUserInteraction,
//                                 decoration: InputDecoration(
//                                   hintText: getTranslated(context, "AMOUNT"),
//                                   hintStyle: Theme.of(this.context)
//                                       .textTheme
//                                       .subtitle1
//                                       .copyWith(
//                                           color: colors.lightBlack,
//                                           fontWeight: FontWeight.normal),
//                                 ),
//                                 controller: amtC,
//                               )),
//                          /* Padding(
//                               padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                               child: TextFormField(
//                                 autovalidateMode:
//                                     AutovalidateMode.onUserInteraction,
//                                 decoration: new InputDecoration(
//                                   hintText: getTranslated(context, 'MSG'),
//                                   hintStyle: Theme.of(this.context)
//                                       .textTheme
//                                       .subtitle1
//                                       .copyWith(
//                                           color: colors.lightBlack,
//                                           fontWeight: FontWeight.normal),
//                                 ),
//                                 controller: msgC,
//                               )),*/
//                           Container(
//                             width: Get.width,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   children: [
//                                     new TextButton(
//                                         child: Text(
//                                           getTranslated(context, 'CANCEL'),
//                                           style: Theme.of(this.context)
//                                               .textTheme
//                                               .subtitle2
//                                               .copyWith(
//                                                   color: colors.lightBlack,
//                                                   fontWeight: FontWeight.bold),
//                                         ),
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         }),
//                                     new TextButton(
//                                         child: Text(
//                                           "Add",
//                                           style: Theme.of(this.context)
//                                               .textTheme
//                                               .subtitle2
//                                               .copyWith(
//                                                   color: colors.fontColor,
//                                                   fontWeight: FontWeight.bold),
//                                         ),
//                                         onPressed: () {
//                                           if(payWarn){
//                                             if (amtC.text != '0') {
//                                               if (double.parse(amtC.text.toString()).toInt() >
//                                                   51) {
//                                                 Get.snackbar("Error",
//                                                     "You can't add more then $CUR_CURRENCY 50");
//                                               } else {
//                                                 var finalPrice = double.parse(amtC.text.toString()).toStringAsFixed(2);
//                                                 stripePayment((double.parse(finalPrice.toString()).toPrecision(1) * 100).toInt().toString());
//                                                 //stripePayment(amtC.text);
//                                               }
//                                               payWarn = false;
//                                               setState((){});
//                                             }
//                                           }
//
//                                         })
//                                   ],
//                                 )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//       },
//     );
// /*    await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext contet, StateSetter setStater) {
//             dialogState = setStater;
//             return AlertDialog(
//               contentPadding: const EdgeInsets.all(0.0),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(5.0))),
//               content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Padding(
//                         padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
//                         child: Text(
//                           getTranslated(context, 'ADD_MONEY'),
//                           style: Theme.of(this.context)
//                               .textTheme
//                               .subtitle1
//                               .copyWith(color: colors.fontColor),
//                         )),
//                     Divider(color: colors.lightBlack),
//                     Form(
//                       key: _formkey,
//                       child: Flexible(
//                         child: SingleChildScrollView(
//                             child: new Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                               Padding(
//                                   padding:
//                                       EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     validator: (val) => validateField(
//                                         val,
//                                         getTranslated(
//                                             context, 'FIELD_REQUIRED')),
//                                     autovalidateMode:
//                                         AutovalidateMode.onUserInteraction,
//                                     decoration: InputDecoration(
//                                       hintText:
//                                           getTranslated(context, "AMOUNT"),
//                                       hintStyle: Theme.of(this.context)
//                                           .textTheme
//                                           .subtitle1
//                                           .copyWith(
//                                               color: colors.lightBlack,
//                                               fontWeight: FontWeight.normal),
//                                     ),
//                                     controller: amtC,
//                                   )),
//                               Padding(
//                                   padding:
//                                       EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                                   child: TextFormField(
//                                     autovalidateMode:
//                                         AutovalidateMode.onUserInteraction,
//                                     decoration: new InputDecoration(
//                                       hintText: getTranslated(context, 'MSG'),
//                                       hintStyle: Theme.of(this.context)
//                                           .textTheme
//                                           .subtitle1
//                                           .copyWith(
//                                               color: colors.lightBlack,
//                                               fontWeight: FontWeight.normal),
//                                     ),
//                                     controller: msgC,
//                                   )),
//                               //Divider(),
//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
//                                 child: Text(
//                                   getTranslated(context, 'SELECT_PAYMENT'),
//                                   style: Theme.of(context).textTheme.subtitle2,
//                                 ),
//                               ),
//                               Divider(),
//                               payWarn
//                                   ? Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 20.0),
//                                       child: Text(
//                                         getTranslated(context, 'payWarning'),
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .caption
//                                             .copyWith(color: Colors.red),
//                                       ),
//                                     )
//                                   : Container(),
//
//                               paypal == null
//                                   ? Center(child: CircularProgressIndicator())
//                                   : Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: getPayList()),
//                             ])),
//                       ),
//
//                       */ /*ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: paymentMethodList.length,
//                                     itemBuilder: (context, index) {
//                                       if (index == 1 && paypal)
//                                         return paymentItem(index);
//                                       else if (index == 2 && paumoney)
//                                         return paymentItem(index);
//                                       else if (index == 3 && razorpay)
//                                         return paymentItem(index);
//                                       else if (index == 4 && paystack)
//                                         return paymentItem(index);
//                                       else if (index == 5 && flutterwave)
//                                         return paymentItem(index);
//                                       else if (index == 6 && stripe)
//                                         return paymentItem(index);
//                                       else if (index == 7 && paytm)
//                                         return paymentItem(index);
//                                       else
//                                         return Container();
//                                     }),*/ /*
//                     )
//                   ]),
//               actions: <Widget>[
//                 new TextButton(
//                     child: Text(
//                       getTranslated(context, 'CANCEL'),
//                       style: Theme.of(this.context)
//                           .textTheme
//                           .subtitle2
//                           .copyWith(
//                               color: colors.lightBlack,
//                               fontWeight: FontWeight.bold),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     }),
//                 new TextButton(
//                     child: Text(
//                       getTranslated(context, 'SEND'),
//                       style: Theme.of(this.context)
//                           .textTheme
//                           .subtitle2
//                           .copyWith(
//                               color: colors.fontColor,
//                               fontWeight: FontWeight.bold),
//                     ),
//                     onPressed: () {
//                       final form = _formkey.currentState;
//
//                       if (form.validate() &&
//                           int.parse(amtC.text.toString()) >= 51) {
//                         setSnackbar("You can't add more then $CUR_CURRENCY 50");
//                       } else {
//                         if (form.validate() && amtC.text != '0') {
//                           form.save();
//                           if (payMethod == null) {
//                             dialogState(() {
//                               payWarn = true;
//                             });
//                           } else {
//                             if (payMethod.trim() ==
//                                 getTranslated(context, 'STRIPE_LBL').trim()) {
//                               stripePayment(int.parse(amtC.text),contet);
//                             } else if (payMethod.trim() ==
//                                 getTranslated(context, 'RAZORPAY_LBL').trim())
//                               razorpayPayment(double.parse(amtC.text));
//                             else if (payMethod.trim() ==
//                                 getTranslated(context, 'PAYSTACK_LBL').trim())
//                               paystackPayment(context, int.parse(amtC.text));
//                             // else if (payMethod ==
//                             //     getTranslated(context, 'PAYTM_LBL'))
//                             //   paytmPayment(double.parse(amtC.text));
//                             else if (payMethod ==
//                                 getTranslated(context, 'PAYPAL_LBL')) {
//                               paypalPayment((amtC.text).toString());
//                             } else if (payMethod ==
//                                 getTranslated(context, 'FLUTTERWAVE_LBL'))
//                               flutterwavePayment(amtC.text);
//                             Navigator.pop(context);
//                           }
//                         }
//                       }
//                     })
//               ],
//             );
//           });
//         });*/
//   }
//
//   List<Widget> getPayList() {
//     return paymentMethodList
//         .asMap()
//         .map(
//           (index, element) => MapEntry(index, paymentItem(index)),
//         )
//         .values
//         .toList();
//   }
//
//   Future<void> paypalPayment(String amt) async {
//     String orderId =
//         "wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
//
//     try {
//       var parameter = {USER_ID: CUR_USERID, ORDER_ID: orderId, AMOUNT: amt};
//       http.Response response = await http
//           .post(paypalTransactionApi, body: parameter, headers: headers)
//           .timeout(Duration(seconds: timeOut));
//
//       var getdata = json.decode(response.body);
//
//       bool error = getdata["error"];
//       String msg = getdata["message"];
//       if (!error) {
//         String data = getdata["data"];
//
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (BuildContext context) => PaypalWebview(
//                       url: data,
//                       from: "wallet",
//                     )));
//       } else {
//         setSnackbar(msg);
//       }
//     } on TimeoutException catch (_) {
//       setSnackbar(getTranslated(context, 'somethingMSg'));
//     }
//   }
//
//   Future<void> flutterwavePayment(String price) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         if (mounted)
//           setState(() {
//             _isProgress = true;
//           });
//         var parameter = {
//           AMOUNT: price,
//           USER_ID: CUR_USERID,
//         };
//         http.Response response = await http
//             .post(flutterwaveApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//           String msg = getdata["message"];
//           if (!error) {
//             var data = getdata["link"];
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (BuildContext context) => PaypalWebview(
//                           url: data,
//                           from: "wallet",
//                           amt: amtC.text.toString(),
//                           msg: msgC.text,
//                         )));
//           } else {
//             setSnackbar(msg);
//           }
//           setState(() {
//             _isProgress = false;
//           });
//         }
//       } on TimeoutException catch (_) {
//         setState(() {
//           _isProgress = false;
//         });
//         setSnackbar(getTranslated(context, 'somethingMSg'));
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   /* void paytmPayment(double price) async {
//     String payment_response;
//     setState(() {
//       _isProgress = true;
//     });
//     String orderId = DateTime.now().millisecondsSinceEpoch.toString();
//
//     String callBackUrl = (payTesting
//             ? 'https://securegw-stage.paytm.in'
//             : 'https://securegw.paytm.in') +
//         '/theia/paytmCallback?ORDER_ID=' +
//         orderId;
//
//     var parameter = {
//       AMOUNT: price.toString(),
//       USER_ID: CUR_USERID,
//       ORDER_ID: orderId
//     };
//
//     try {
//       final response = await post(
//         getPytmChecsumkApi,
//         body: parameter,
//         headers: headers,
//       );
//       var getdata = json.decode(response.body);
//       String txnToken;
//       setState(() {
//         txnToken = getdata["txn_token"];
//       });
//
//       var paytmResponse = Paytm.payWithPaytm(paytmMerId, orderId, txnToken,
//           price.toString(), callBackUrl, payTesting);
//
//       paytmResponse.then((value) {
//         setState(() {
//           _isProgress = false;
//
//           if (value['error']) {
//             payment_response = value['errorMessage'];
//           } else {
//             if (value['response'] != null) {
//               payment_response = value['response']['STATUS'];
//               if (payment_response == "TXN_SUCCESS")
//                 sendRequest(orderId, "Paytm");
//             }
//           }
//
//           setSnackbar(payment_response);
//         });
//       });
//     } catch (e) {
//       print(e);
//     }
//   }*/
//
//   stripePayment(String price) async {
//    // var finalPrice = double.parse(amtC.text.toString()).toStringAsFixed(2);
//
//     var response = await StripeService.payWithPaymentSheet(
//         amount: price,
//         currency: stripeCurCode,
//         from: "wallet");
//
//     if(response.success==true){
//       sendRequest(response.id,"Stripe");
//     }
//
//     if (mounted) {
//       setState(() {
//         _isProgress = false;
//       });
//     }
//     Get.back();
//     setSnackbar(response.message);
//   }
//   Future<Null> getSetting() async {
//     try {
//       CUR_USERID = await getPrefrence(ID);
//
//       var parameter;
//       if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};
//       print("Parameter of getsettings: " + parameter.toString());
//       http.Response response = await http.post(getSettingApi,
//           body: CUR_USERID != null ? parameter : null, headers: headers)
//           .timeout(Duration(seconds: timeOut));
//
//       if (response.statusCode == 200) {
//         var getdata = json.decode(response.body);
//         print("Response of getsettings: " + getdata.toString());
//
//         bool error = getdata["error"];
//         String msg = getdata["message"];
//         if (!error) {
//           var data = getdata["data"]["system_settings"][0];
//           cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
//           CUR_CURRENCY = data["currency"];
//           RETURN_DAYS = data['max_product_return_days'];
//           MAX_ITEMS = data["max_items_cart"];
//           MIN_AMT = data['min_amount'];
//           MIN_CART_AMT = data['minimum_cart_amt'];
//           print("Minimum order amount :" + MIN_AMT);
//           CUR_DEL_CHR = data['delivery_charge'];
//           print("Current Delivery Charge: " + CUR_DEL_CHR);
//           String isVerion = data['is_version_system_on'];
//           extendImg = data["expand_product_images"] == "1" ? true : false;
//           String del = data["area_wise_delivery_charge"];
//           print("Area wise delivery data: " + del.toString());
//           SCROLLING_TEXT = getdata["data"]["system_settings"][0]
//           ["scrolling_news"]
//               .toString();
//           if (del == "0") {
//             ISFLAT_DEL = true;
//           } else {
//             ISFLAT_DEL = false;
//           }
//           if (CUR_USERID != null) {
//             // CUR_CART_COUNT = getdata["data"]["user_data"][0]["cart_total_items"].toString();
//             CUR_CART_COUNT =
//                 getdata["data"]["user_data"][0]["total_items"].toString();
//             REFER_CODE = getdata['data']['user_data'][0]['referral_code'];
//             if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE.isEmpty)
//
//             CUR_BALANCE = getdata["data"]["user_data"][0]["balance"];
//           }
//           //widget.updateHome();
//
//           if (isVerion == "1") {
//             String verionAnd = data['current_version'];
//             String verionIOS = data['current_version_ios'];
//             //
//             // PackageInfo packageInfo = await PackageInfo.fromPlatform();
//             //
//             // String version = packageInfo.version;
//             //
//             // final Version currentVersion = Version.parse(version);
//             // final Version latestVersionAnd = Version.parse(verionAnd);
//             // //final Version latestVersionIos = Version.parse(verionIOS);
//             //
//             // if ((Platform.isAndroid && latestVersionAnd > currentVersion)
//             // // || (Platform.isIOS && latestVersionIos > currentVersion)
//             // ) updateDailog();
//           }
//         } else {
//           setSnackbar(msg);
//         }
//       }
//     } on TimeoutException catch (_) {
//       setSnackbar(getTranslated(context, 'somethingMSg'));
//     }
//     return null;
//   }
//
//
//   paystackPayment(BuildContext context, int price) async {
//     if (mounted)
//       setState(() {
//         _isProgress = true;
//       });
//
//     String email = await getPrefrence(EMAIL);
//
//     Charge charge = Charge()
//       ..amount = price
//       ..reference = _getReference()
//       ..email = email;
//
//     try {
//       CheckoutResponse response = await paystackPlugin.checkout(
//         context,
//         method: CheckoutMethod.card,
//         charge: charge,
//       );
//       if (response.status) {
//         sendRequest(response.reference, "Paystack");
//       } else {
//         setSnackbar(response.message);
//         if (mounted)
//           setState(() {
//             _isProgress = false;
//           });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _isProgress = false);
//       rethrow;
//     }
//   }
//
//   String _getReference() {
//     String platform;
//     if (Platform.isIOS) {
//       platform = 'iOS';
//     } else {
//       platform = 'Android';
//     }
//
//     return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
//   }
//
//   // void _handlePaymentSuccess(PaymentSuccessResponse response) {
//   //   //placeOrder(response.paymentId);
//   //   sendRequest(response.paymentId, "RazorPay");
//   // }
//   //
//   // void _handlePaymentError(PaymentFailureResponse response) {
//   //   setSnackbar(response.message);
//   //   if (mounted)
//   //     setState(() {
//   //       _isProgress = false;
//   //     });
//   // }
//   //
//   // void _handleExternalWallet(ExternalWalletResponse response) {
//   //   print("EXTERNAL_WALLET: " + response.walletName);
//   // }
//
//   razorpayPayment(double price) async {
//     String contact = await getPrefrence(MOBILE);
//     String email = await getPrefrence(EMAIL);
//
//     double amt = price * 100;
//
//     if (contact != '' && email != '') {
//       if (mounted)
//         setState(() {
//           _isProgress = true;
//         });
//
//       var options = {
//         KEY: razorpayId,
//         AMOUNT: amt.toString(),
//         NAME: CUR_USERNAME,
//         'prefill': {CONTACT: contact, EMAIL: email},
//       };
//
//       try {
//         // _razorpay.open(options);
//       } catch (e) {
//         debugPrint(e);
//       }
//     } else {
//       if (email == '')
//         setSnackbar(getTranslated(context, 'emailWarning'));
//       else if (contact == '')
//         setSnackbar(getTranslated(context, 'phoneWarning'));
//     }
//   }
//
//   listItem(int index) {
//     Color back;
//     if (tranList[index].type == "credit") {
//       back = Colors.green;
//     } else
//       back = Colors.red;
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.all(5.0),
//       child: InkWell(
//           borderRadius: BorderRadius.circular(4),
//           child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Expanded(
//                           child: Text(
//                             getTranslated(context, 'AMOUNT') +
//                                 " : " +
//                                 CUR_CURRENCY +
//                                 " " +
//                                 double.parse(tranList[index].amt.toString()).toStringAsFixed(2),
//                             style: TextStyle(
//                                 color: colors.fontColor,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         // Text(tranList[index].id),
//                       ],
//                     ),
//                     Divider(),
//                     Row(
//                       //wallet id
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Text(getTranslated(context, 'ORDER_ID_LBL') +
//                             " : " +
//                             tranList[index].orderNo),
//                         Spacer(),
//                         Container(
//                           margin: EdgeInsets.only(left: 8),
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//                           decoration: BoxDecoration(
//                               color: back,
//                               borderRadius: new BorderRadius.all(
//                                   const Radius.circular(4.0))),
//                           child: Text(
//                             (tranList[index].type),
//                             style: TextStyle(color: colors.white),
//                           ),
//                         )
//                       ],
//                     ),
//                     tranList[index].msg != null &&
//                             tranList[index].msg.isNotEmpty
//                         ? Text(getTranslated(context, 'MSG') +
//                             " : " +
//                             tranList[index].msg)
//                         : Container(),
//                   ]))),
//     );
//   }
//
//   Future<Null> _playAnimation() async {
//     try {
//       await buttonController.forward();
//     } on TickerCanceled {}
//   }
//
//   Widget noInternet(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           noIntImage(),
//           noIntText(context),
//           noIntDec(context),
//           AppBtn(
//             title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
//             btnAnim: buttonSqueezeanimation,
//             btnCntrl: buttonController,
//             onBtnSelected: () async {
//               _playAnimation();
//
//               Future.delayed(Duration(seconds: 2)).then((_) async {
//                 _isNetworkAvail = await isNetworkAvailable();
//                 if (_isNetworkAvail) {
//                   getTransaction();
//                 } else {
//                   await buttonController.reverse();
//                   setState(() {});
//                 }
//               });
//             },
//           )
//         ]),
//       ),
//     );
//   }
//
//   Future<Null> getTransaction() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       CUR_USERID = await getPrefrence(ID);
//       try {
//         var parameter = {
//           LIMIT: perPage.toString(),
//           OFFSET: offset.toString(),
//           USER_ID: CUR_USERID,
//           TRANS_TYPE: WALLET
//         };
// /// my wallet api order no
//         var response = await http
//             .post(getWalTranApi, headers: headers, body: parameter)
//             .timeout(Duration(seconds: timeOut));
//
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//           bool error = getdata["error"];
//           // String msg = getdata["message"];
//
//           if (!error) {
//             total = int.parse(getdata["total"]);
//             getdata.containsKey("balance");
//             CUR_BALANCE = getdata["balance"];
//
//             if ((offset) < total) {
//               tempList.clear();
//               var data = getdata["data"];
//               tempList = (data as List)
//                   .map((data) => new TransactionModel.fromJson(data))
//                   .toList();
//
//               tranList.addAll(tempList);
//
//               offset = offset + perPage;
//             }
//           } else {
//             isLoadingmore = false;
//           }
//         }
//         if (mounted)
//           setState(() {
//             _isLoading = false;
//           });
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg'));
//
//         setState(() {
//           _isLoading = false;
//           isLoadingmore = false;
//         });
//       }
//     } else
//       setState(() {
//         _isNetworkAvail = false;
//       });
//
//     return null;
//   }
//
//   Future<Null> getRequest() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         var parameter = {
//           LIMIT: perPage.toString(),
//           OFFSET: offset.toString(),
//           USER_ID: CUR_USERID,
//         };
//
//         http.Response response = await http
//             .post(getWalTranApi, headers: headers, body: parameter)
//             .timeout(Duration(seconds: timeOut));
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//           bool error = getdata["error"];
//           // String msg = getdata["message"];
//
//           if (!error) {
//             total = int.parse(getdata["total"]);
//
//             if ((offset) < total) {
//               tempList.clear();
//               var data = getdata["data"];
//               tempList = (data as List)
//                   .map((data) => new TransactionModel.fromReqJson(data))
//                   .toList();
//
//               tranList.addAll(tempList);
//
//               offset = offset + perPage;
//             }
//           } else {
//             isLoadingmore = false;
//           }
//         }
//         if (mounted)
//           setState(() {
//             _isLoading = false;
//           });
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg'));
//
//         setState(() {
//           _isLoading = false;
//           isLoadingmore = false;
//         });
//       }
//     } else
//       setState(() {
//         _isNetworkAvail = false;
//       });
//
//     return null;
//   }
//
//   setSnackbar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
//       content: new Text(
//         msg,
//         textAlign: TextAlign.center,
//         style: TextStyle(color: colors.black),
//       ),
//       backgroundColor: colors.white,
//       elevation: 1.0,
//     ));
//   }
//
//   @override
//   void dispose() {
//     buttonController.dispose();
//     // _razorpay.clear();
//     super.dispose();
//   }
//
//   Future<Null> _refresh() {
//     setState(() {
//       _isLoading = true;
//     });
//     offset = 0;
//     total = 0;
//     tranList.clear();
//     return getTransaction();
//   }
//
//   _scrollListener() {
//     if (controller.position.pixels == controller.position.maxScrollExtent &&
//         !controller.position.outOfRange) {
//       if (this.mounted) {
//         setState(() {
//           isLoadingmore = true;
//
//           if (offset < total) getTransaction();
//         });
//       }
//     }
//   }
//
//   Future<void> _getpaymentMethod() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         var parameter = {
//           TYPE: PAYMENT_METHOD,
//         };
//         http.Response response = await http
//             .post(getSettingApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//
//           if (!error) {
//             var data = getdata["data"];
//
//             var payment = data["payment_method"];
//
//             paypal = payment["paypal_payment_method"] == "1" ? true : false;
//             paumoney =
//                 payment["payumoney_payment_method"] == "1" ? true : false;
//             flutterwave =
//                 payment["flutterwave_payment_method"] == "1" ? true : false;
//             razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
//             paystack = payment["paystack_payment_method"] == "1" ? true : false;
//             stripe = payment["stripe_payment_method"] == "1" ? true : false;
//             paytm = payment["paytm_payment_method"] == "1" ? true : false;
//
//             if (razorpay) razorpayId = payment["razorpay_key_id"];
//             if (paystack) {
//               paystackId = payment["paystack_key_id"];
//
//               paystackPlugin.initialize(publicKey: paystackId);
//             }
//             if (stripe) {
//               stripeId = payment['stripe_publishable_key'];
//               stripeSecret = payment['stripe_secret_key'];
//               stripeCurCode = payment['stripe_currency_code'];
//               stripeMode = payment['stripe_mode'] ?? 'test';
//               StripeService.secret = stripeSecret;
//               //  StripeService.init(stripeId, stripeMode);
//             }
//             if (paytm) {
//               paytmMerId = payment['paytm_merchant_id'];
//               paytmMerKey = payment['paytm_merchant_key'];
//               payTesting =
//                   payment['paytm_payment_mode'] == 'sandbox' ? true : false;
//             }
//
//             for (int i = 0; i < paymentMethodList.length; i++) {
//               payModel.add(RadioModel(
//                   isSelected: i == selectedMethod ? true : false,
//                   name: paymentMethodList[i],
//                   img: paymentIconList[i]));
//             }
//           }
//         }
//         if (mounted)
//           setState(() {
//             _isLoading = false;
//           });
//         if (dialogState != null) dialogState(() {});
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg'));
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   showContent() {
//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   // Color(0xFF280F43),
//                   // Color(0xffE5CCFF),
//                   Color(0xFF200738),
//                   Color(0xFF3B147A),
//                   Color(0xFFF8F8FF),
//                 ]),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 RefreshIndicator(
//                     key: _refreshIndicatorKey,
//                     onRefresh: _refresh,
//                     child: Column(mainAxisSize: MainAxisSize.min, children: [
//                       Padding(
//                         padding:
//                             const EdgeInsets.only(top: 7.0, left: 7, right: 7),
//                         child: Card(
//                           elevation: 0,
//                           child: Padding(
//                             padding: const EdgeInsets.all(18.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.account_balance_wallet,
//                                       color: colors.fontColor,
//                                     ),
//                                     Text(
//                                       " " +
//                                           getTranslated(context, 'CURBAL_LBL'),
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .subtitle2
//                                           .copyWith(
//                                               color: colors.fontColor,
//                                               fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                     CUR_CURRENCY +
//                                         " " +
//                                         double.parse(CUR_BALANCE)
//                                             .toStringAsFixed(2),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .headline6
//                                         .copyWith(
//                                             color: colors.fontColor,
//                                             fontWeight: FontWeight.bold)),
//                                 SimBtn(
//                                   size: 0.8,
//                                   title: getTranslated(context, "ADD_MONEY"),
//                                   onBtnSelected: () => _showDialog(),
//                                   /*    _showDialog();*/
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       tranList.length == 0
//                           ? getNoItem(context)
//                           : Container(
//                         height: Get.height*0.63,
//
//                             child: ListView.builder(
//                                 shrinkWrap: true,
//                                 scrollDirection: Axis.vertical,
//                                 controller: controller,
//                                 itemCount: (offset < total)
//                                     ? tranList.length + 1
//                                     : tranList.length,
// //                              physics: NeverScrollableScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return (index == tranList.length &&
//                                           isLoadingmore)
//                                       ? Center(child: CircularProgressIndicator())
//                                       : listItem(index);
//                                 },
//                               ),
//                           ),
//                     ])),
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
