import 'package:eshop/Cart.dart';
import 'package:eshop/Helper/Stripe_Service.dart';
import 'package:eshop/card_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

var paymentIntent;

class Loader {
  showLoader(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void hideLoader() {
    Get.back();
  }
}

// class Loading extends StatefulWidget {
//   final String finalPrice;
//   final String Stripecurcode;
//   Function(String) callback;
//   final String from;
//
//   Loading({this.finalPrice, this.Stripecurcode, this.callback, this.from});
//
//   @override
//   State<Loading> createState() => _LoadingState();
// }
//
// class _LoadingState extends State<Loading> {
//   bool isLoad = true;
//
//   @override
//   void initState() {
//     api();
//     // apicall();
//
//     super.initState();
//   }

//   apicall() async {
//     try {
//       clientSecret = await StripeService.createPaymentIntent(widget.finalPrice,
//           widget.Stripecurcode, widget.from == null ? "order" : widget.from,context);
//       final billingDetails = BillingDetails(
//         email: "mobileappdev@gmail.com",
//         phone: '+7894561230',
//         address: Address(
//           city: 'LONDON',
//           country: 'UK',
//           line1: '1459  Circle Drive',
//           line2: '',
//           state: 'Westminster',
//           postalCode: 'SW1A 1AA',
//         ),
//       ); // mo mocked data for tests
//
//
//
//       paymentIntent = await Stripe.instance.confirmPayment(
//         clientSecret['client_secret'],
//         PaymentMethodParams.card(
// /*          billingDetails: billingDetails,
//           setupFutureUsage: null,*/
//         ),
//       );
// /*      final paymentIntent1 = await Stripe.instance.createPaymentMethod(
//         PaymentMethodParams.card(
//           billingDetails: billingDetails,
//           setupFutureUsage: null,
//         ),
//         clientSecret['clientSecret'],
//
//       );*/
//       print("paymentIntent1");
//       // print(paymentIntent1);
//       print(paymentIntent);
//       setState(() {
//         //  Loader().hideLoader();
//         stripePayId = paymentIntent.id.toString();
//       });
//       setState(() {});
//       widget.callback(paymentIntent.status.toString());
//       setState(() {
//         isLoad = false;
//         paymentIntent = null;
//         // Get.back();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//       print(e.toString());
//       setState(() {
//         isLoad = false;
//         paymentIntent = null;
//         Get.back();
//       });
//     }
//   }

 //  walletcall() async {
 //    try {
 //      var paymnet =
 //          await Stripe.instance.createPaymentMethod(PaymentMethodParams.card());
 //      print(paymnet.id);
 //      clientSecret = await StripeService.createPaymentIntent(widget.finalPrice,
 //          widget.Stripecurcode, widget.from == null ? "order" : widget.from,context);
 //      print(clientSecret);
 //      final billingDetails = BillingDetails(
 //        email: "mobileappdev@gmail.com",
 //        phone: '+7894561230',
 //        address: Address(
 //          city: 'LONDON',
 //          country: 'UK',
 //          line1: '1459  Circle Drive',
 //          line2: '',
 //          state: 'Westminster',
 //          postalCode: 'SW1A 1AA',
 //        ),
 //      ); // mo mocked data for tests
 //
 //      // 3. Confirm payment with card details
 //      // The rest will be done automatically using webhooks
 //      // ignore: unused_local_variable
 //
 // /*     var confrimPayment = await Stripe.instance.confirmPayment(
 //          clientSecret['clientSecret'],
 //          PaymentMethodParams.cardFromMethodId(paymentMethodId: paymnet.id));*/
 //
 //      paymentIntent = await Stripe.instance.confirmPayment(
 //        clientSecret['client_secret'],
 //        PaymentMethodParams.card(
 //       /*   billingDetails: billingDetails,
 //          setupFutureUsage: null,*/
 //        ),
 //      );
 //      final paymentIntent1 = await Stripe.instance.createPaymentMethod(
 //        PaymentMethodParams.card(
 // /*         billingDetails: billingDetails,
 //          setupFutureUsage: null,*/
 //        ),
 //        clientSecret['clientSecret'],
 //
 //      );
 //      print("paymentIntent1");
 //      // print(paymentIntent1);
 //      print(paymentIntent);
 //      setState(() {
 //        //  Loader().hideLoader();
 //        // stripePayId = paymentIntent.id.toString();
 //      });
 //      setState(() {});
 //      // widget.callback(paymentIntent.status.toString());
 //      setState(() {
 //        isLoad = false;
 //        paymentIntent = null;
 //        // Get.back();
 //      });
 //    } catch (e) {
 //      ScaffoldMessenger.of(context)
 //          .showSnackBar(SnackBar(content: Text(e.toString())));
 //      print(e.toString());
 //      setState(() {
 //        isLoad = false;
 //        Get.back();
 //      });
 //    }
 //  }
 //
 //  api() async {
 //    widget.from == "wallet" ? await walletcall() : await apicall();
 //  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     color: Colors.white,
  //     height: Get.height,
  //     child: isLoad
  //         ? Center(
  //             child: Image.asset("assets/images/process.gif"),
  //           )
  //         : Center(
  //             child: Image.asset("assets/images/process.gif"),
  //           ),
  //   );
  // }
//}
