import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';
import 'package:get/get.dart';

class DashboardBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(DashboardController());
   Get.find<PLCController>();
  }
  
}