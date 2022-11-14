import 'dart:convert';

import 'package:eshop/Cart.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Helper/Stripe_Service.dart';
import 'package:eshop/utils/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:eshop/Helper/Color.dart';

bool isLoad = false;
var clientSecret;

class CardPayment extends StatefulWidget {
  final String finalPrice;
  final String StripcurCode;
  final String from;
  Function(String) placeOrder;

  CardPayment({this.finalPrice, this.from, this.StripcurCode, this.placeOrder});

  @override
  State<CardPayment> createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  CardFieldInputDetails _card;

  final controller = CardFormEditController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController amtC, msgC;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF200738),
        title: Text("Payment",style:TextStyle(
          color: Colors.white
        ),),
        leading: InkWell(
          onTap: (){
            Get.back();
          },
          child: Icon(Icons.arrow_back,color: Colors.white,),
        ),

      ),
      body: isLoad
          ? Container(
              height: Get.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          :SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              /*Container(
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_back),
                        ],
                      ),
                    ),*/
              Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: CardFormField(
                  controller: controller,
                  enablePostalCode: true,
                  onCardChanged: (card) {
                    if (mounted)
                      setState(() {
                        _card = card;

                      });
                  },
                  /*   onCardChanged: (card) {
                  setState(() {
                      _card = card;
                  });
                }*/
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  if (controller.details.complete == true) {

                      Get.to(() => Loading(
                        finalPrice: widget.finalPrice,
                        Stripecurcode: widget.StripcurCode,
                        callback: widget.placeOrder,
                        from: widget.from,
                      )).then((value) {
                        _handlePayPress();
                      });

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Card Details is Empty")));
                    // callback();
                    //Loader().hideLoader();
                  }
                  //  Loader().showLoader(context);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20,right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF200738),
                  ),
                  height: Get.height/12,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                        "Pay",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayPress() async {
    if (_card == null) {
      // Loader().hideLoader();
      setState(() {
          Loader().hideLoader();
        // callback();
        isLoad = false;
      });
      return;
    }
    // FocusManager.instance.primaryFocus?.unfocus();
    try {

      // 1. fetch Intent Client Secret from backend
           await StripeService.createPaymentIntent(
          widget.finalPrice, widget.StripcurCode, widget.from,context);
      print(controller.details);
      setState(() {
        isLoad = true;
      });
      // 2. Gather customer billing information (ex. email)
      final billingDetails = BillingDetails(
        email: "mobileappdev@gmail.com",
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mo mocked data for tests

      // 3. Confirm payment with card details
      // The rest will be done automatically using webhooks
      // ignore: unused_local_variable
      var paymentIntent = await Stripe.instance.confirmPayment(
        clientSecret['client_secret'],
        PaymentMethodParams.card(
   /*       billingDetails: billingDetails,
          setupFutureUsage: null,*/
        ),
      );

      print(paymentIntent);
      setState(() {
        isLoad = true;
        //  Loader().hideLoader();
       // stripePayId = paymentIntent.id.toString();
      });
    if (paymentIntent.status != null) {


      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Success!: The payment was confirmed successfully!')));
    }

    //  Loader().hideLoader();

    // Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
    //  Loader().hideLoader();
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    Map<String, dynamic> fromMap = {
      "amount": int.parse(widget.finalPrice),
      "currency": widget.StripcurCode.toString(),
      'payment_method_types[]': 'card',
      'description': widget.from,
    };
    final url = Uri.parse(StripeService.paymentApiUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            "Bearer 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"
      },
      body: fromMap,
      encoding: Encoding.getByName("utf-8"),
    );
    return json.decode(response.body);
  }

  Widget loader() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  callback() {
    Get.back();
  }
  _showDialog() async {
    bool payWarn = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext contet, StateSetter setStater) {
                //dialogState = setStater;
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(25.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'ADD_MONEY'),
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(color: colors.fontColor),
                            )),
                        Divider(color: colors.lightBlack),
                        Form(
                          key: _formkey,
                          child: Flexible(
                            child: SingleChildScrollView(
                                child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            validator: (val) => validateField(
                                                val,
                                                getTranslated(
                                                    context, 'FIELD_REQUIRED')),
                                            autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                            decoration: InputDecoration(
                                              hintText:
                                              getTranslated(context, "AMOUNT"),
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            controller: amtC,
                                          )),
                                      Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                          child: TextFormField(
                                            autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                            decoration: new InputDecoration(
                                              hintText: getTranslated(context, 'MSG'),
                                              hintStyle: Theme.of(this.context)
                                                  .textTheme
                                                  .subtitle1
                                                  .copyWith(
                                                  color: colors.lightBlack,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                            controller: msgC,
                                          )),
                                      //Divider(),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 5),
                                        child: Text(
                                          getTranslated(context, 'SELECT_PAYMENT'),
                                          style: Theme.of(context).textTheme.subtitle2,
                                        ),
                                      ),
                                      Divider(),
                                      payWarn
                                          ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          getTranslated(context, 'payWarning'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .copyWith(color: Colors.red),
                                        ),
                                      )
                                          : Container(),

                                /*      paypal == null
                                          ? Center(child: CircularProgressIndicator())
                                          : Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: getPayList())*/
                                    ])),
                          ),

                          /*ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: paymentMethodList.length,
                                    itemBuilder: (context, index) {
                                      if (index == 1 && paypal)
                                        return paymentItem(index);
                                      else if (index == 2 && paumoney)
                                        return paymentItem(index);
                                      else if (index == 3 && razorpay)
                                        return paymentItem(index);
                                      else if (index == 4 && paystack)
                                        return paymentItem(index);
                                      else if (index == 5 && flutterwave)
                                        return paymentItem(index);
                                      else if (index == 6 && stripe)
                                        return paymentItem(index);
                                      else if (index == 7 && paytm)
                                        return paymentItem(index);
                                      else
                                        return Container();
                                    }),*/
                        )
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(
                          getTranslated(context, 'CANCEL'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: colors.lightBlack,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(
                          getTranslated(context, 'SEND'),
                          style: Theme.of(this.context)
                              .textTheme
                              .subtitle2
                              .copyWith(
                              color: colors.fontColor,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final form = _formkey.currentState;

                          if (form.validate() &&
                              int.parse(amtC.text.toString()) >= 51) {
                            Get.snackbar("Error", "You can't add more then $CUR_CURRENCY 50");

                          } else {
                            if (form.validate() && amtC.text != '0') {
                              form.save();
                              if (payMethod == null) {

                                  payWarn = true;

                              } else {
                                Get.to(()=>Loading(
                                  finalPrice: widget.finalPrice,
                                  Stripecurcode: widget.StripcurCode,
                                  callback: widget.placeOrder,
                                  from: widget.from,
                                ));
                             /*   if (payMethod.trim() ==
                                    getTranslated(context, 'STRIPE_LBL').trim()) {
                                  stripePayment(int.parse(amtC.text),contet);
                                }*/ /*else if (payMethod.trim() ==
                                    getTranslated(context, 'RAZORPAY_LBL').trim())
                                  razorpayPayment(double.parse(amtC.text));
                                else if (payMethod.trim() ==
                                    getTranslated(context, 'PAYSTACK_LBL').trim())
                                  paystackPayment(context, int.parse(amtC.text));
                                // else if (payMethod ==
                                //     getTranslated(context, 'PAYTM_LBL'))
                                //   paytmPayment(double.parse(amtC.text));
                                else if (payMethod ==
                                    getTranslated(context, 'PAYPAL_LBL')) {
                                  paypalPayment((amtC.text).toString());
                                } else if (payMethod ==
                                    getTranslated(context, 'FLUTTERWAVE_LBL'))
                                  flutterwavePayment(amtC.text);
                                Navigator.pop(context);*/
                              }
                            }
                          }
                        })
                  ],
                );
              });
        });
  }
}
