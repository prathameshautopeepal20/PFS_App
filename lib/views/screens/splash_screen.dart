import 'package:atpl_flashing_app/logic/controller/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Image.asset(
         'assets/new/autopeepal(1).png', // your image path
          width: 400, // adjust size if needed
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}