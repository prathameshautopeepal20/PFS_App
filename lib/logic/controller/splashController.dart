
// import 'package:atpl_flashing_appApp/utils/app_constants.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Future.delayed(Duration(seconds: Constants.splashDelay), () {
      getScreen();
    });
    super.onInit();
  }

  Future<void> getScreen() async { 
       Get.offAndToNamed(Routes.loginScreen);
    }
     
  }