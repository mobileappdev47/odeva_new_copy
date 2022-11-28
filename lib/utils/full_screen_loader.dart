import 'package:flutter/material.dart';
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

