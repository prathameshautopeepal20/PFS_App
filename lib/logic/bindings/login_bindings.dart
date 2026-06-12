import 'package:atpl_flashing_app/logic/controller/auth/loginController.dart';
// import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:get/get.dart';

class LoginBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(LoginController());
  //  Get.find<PLCController>();
  }
  
}