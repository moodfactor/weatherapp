import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:weatherapp/app/modules/splash/views/loading_view.dart';

showLoadingOverLay(
    {required Future<dynamic> Function() asyncFunction, String? msg}) async {
  await Get.showOverlay(
    asyncFunction: () async {
      try {
        await asyncFunction();
      } catch (error) {
        //rethrow;
        Logger().e(error);
        //Logger().e(StackTrace.current);
      }
    },
    loadingWidget: const LoadingView(),
    opacity: 0.7,
    opacityColor: Colors.black,
  );
}
