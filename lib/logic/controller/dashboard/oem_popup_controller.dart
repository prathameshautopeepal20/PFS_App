import 'package:get/get.dart';

class OEMPopupController extends GetxController {
  RxString selectedModel = ''.obs;
  RxString selectedSubModel = ''.obs;

  final List<String> modelList = [
    "TATA",
    "MAHINDRA",
    "ASHOK LEYLAND",
  ];

  final List<String> subModelList = [
    "BS4",
    "BS6",
    "EURO6",
  ];

  void submit() {
    print("Selected Model : ${selectedModel.value}");
    print("Selected Sub Model : ${selectedSubModel.value}");

    Get.back();
  }

  void closePopup() {
    Get.back();
  }
}