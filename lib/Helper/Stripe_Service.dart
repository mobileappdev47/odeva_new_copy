import 'dart:convert';
import 'dart:math';

import 'package:eshop/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;


import 'String.dart';

class StripeTransactionResponse {
  final String message, status,id;

  bool success;


  StripeTransactionResponse({this.message, this.success, this.status,this.id});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String paymentApiUrl1 = '${StripeService.apiBase}/create-setup-intent';
  static String secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };


  static init(String stripeId, String stripeMode) async {
    Stripe.publishableKey = stripeId ?? '';
    Stripe.merchantIdentifier = "App Identifier";
    await Stripe.instance.applySettings();
  }
  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency, String from,BuildContext context}) async {
    try {
      var paymentMethod =/* await stripe.StripePayment.paymentRequestWithCardForm(
          stripe.CardFormPaymentRequest());*/await (StripeService.createPaymentIntent(
          amount, currency, from, context));

      var paymentIntent =await (StripeService.createPaymentIntent(
          amount, currency, from, context));
      // await  StripeService.createPaymentIntent(amount, currency, from);

    /*  var response = await stripe.StripePayment.confirmPaymentIntent(
        stripe.PaymentIntent(
        clientSecret: paymentIntent['client_secret'],
        paymentMethodId: paymentMethod.id,
      ));*/

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['client_secret'],
        /*      applePay: true,
              googlePay: true,
              merchantCountryCode: 'IN',*/
              style: ThemeMode.light,
              merchantDisplayName: 'Test'));
      await Stripe.instance.presentPaymentSheet();
      stripePayId = paymentIntent['id'];
      var response = await http.post(
          Uri.parse('${StripeService.paymentApiUrl}/$stripePayId'),
          headers: headers);
      var getdata = json.decode(response.body);
      var statusOfTransaction = getdata['status'];

      if (statusOfTransaction == 'succeeded') {
        return new StripeTransactionResponse(
          id: "",
            message: 'Transaction successful',
            success: true,
            status: statusOfTransaction);
      } else if (statusOfTransaction== 'pending' ||
          statusOfTransaction== "captured") {
        return new StripeTransactionResponse(
            message: 'Transaction pending',
            success: true,
            id: "",
            status: statusOfTransaction);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            id: "",
            status: statusOfTransaction);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          id: "",
          status: "fail");
    }
  }


  static Future<StripeTransactionResponse> payWithPaymentSheet(
      {String amount,
        String currency,
        String from,
        BuildContext context,

      }) async {
    try {
      //payWarn =true;
      //StateCart().setState(() {});
      //create Payment intent
      print(payWarn);
      var paymentIntent = await (StripeService.createPaymentIntent(
          amount, currency, from, context));
      //payWarn = false;
      //cnt = 0;
    //  StateCart().setState(() {});
      //setting up Payment Sheet

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent['client_secret'],

             /* merchantCountryCode: 'IN',*/
              style: ThemeMode.light,
              merchantDisplayName: 'Test'));

      //open payment sheet
      try{
        await Stripe.instance.presentPaymentSheet();
      }catch(e){
        print(e.toString());

      }
      //store paymentID of customer
      stripePayId = paymentIntent['id'];


      //confirm payment
      var response = await http.post(
          Uri.parse('${StripeService.paymentApiUrl}/$stripePayId'),
          headers: headers);

      var getdata = json.decode(response.body);
      var statusOfTransaction = getdata['status'];
      print(getdata);

      if (statusOfTransaction == 'succeeded') {
        return StripeTransactionResponse(
            message: 'Transaction successful',
            id: getdata['id'].toString(),
            success: true,
            status: statusOfTransaction);
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        return StripeTransactionResponse(
            message: 'Transaction pending',
            success: true,
            id: "",
            status: statusOfTransaction);
      } else {
        return StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            id:"",
            status: statusOfTransaction);
      }
    } on PlatformException catch (err) {

      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          id: "",
          status: 'fail');
    }
  }




  /*static Future<StripeTransactionResponse> payViaExistingCard({String amount, String currency, CreditCard card}) async{
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card)
      );
      var paymentIntent = await StripeService.createPaymentIntent(
          amount,
          currency
      );
      var response = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent['client_secret'],
              paymentMethodId: paymentMethod.id
          )
      );
      if (response.status == 'succeeded'||response.status == 'pending'||response.status == 'captured') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            status: response.status

        );
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            status: response.status
        );
      }
    } on PlatformException catch(err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          status: "fail"
      );
    }
  }
*/
  /*static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency, String from}) async {
    try {
      CardField(
        onCardChanged: (card) {

        },
      );
   */ /*   var paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());


      var paymentIntent =
          await StripeService.createPaymentIntent(amount, currency, from);

      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
        clientSecret: paymentIntent['client_secret'],
        paymentMethodId: paymentMethod.id,
      ));

      stripePayId = paymentIntent['id'];

      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            status: response.status);
      } else if (response.status == 'pending' ||
          response.status == "captured") {
        return new StripeTransactionResponse(
            message: 'Transaction pending',
            success: true,
            status: response.status);
      } else {
        return new StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            status: response.status);
      }*/ /*
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}',
          success: false,
          status: "fail");
    }
  }*/

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(
      id: "",
        message: message, success: false, status: "cancelled");
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency, String from, BuildContext context) async {
    String orderId =
        "wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";

    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': from,
      };
      if (from == 'wallet') body['metadata[order_id]'] = orderId;
      print(StripeService.headers);

      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: body, headers: StripeService.headers);
      cnt = 0;
      print("stripe response");
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}
