import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';
// import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController(), permanent: true);
    // Get.put(PLCController(), permanent: true); // Your PLC controller
  }
}